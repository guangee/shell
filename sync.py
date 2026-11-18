#!/usr/bin/env python3
"""将 Docker Hub 上 zziaguan 名下镜像同步到阿里云 ACR。

示例:
  zziaguan/node:14
    -> registry.cn-zhangjiakou.aliyuncs.com/zziaguan/node:14

已同步且 digest 一致的镜像会自动跳过；源 digest 变化时会重新同步。

用法:
  python3 sync.py                 # 同步全部仓库/标签
  python3 sync.py --dry-run       # 只打印将要执行的操作
  python3 sync.py --list          # 只列出镜像
  python3 sync.py --repo node     # 只同步指定仓库
  python3 sync.py --tag 14        # 只同步指定标签
  python3 sync.py --force         # 忽略 digest 比对，强制同步
  python3 sync.py --cleanup       # push 成功后删除本地源/目标镜像

推送前请先登录阿里云:
  docker login registry.cn-zhangjiakou.aliyuncs.com
"""

from __future__ import annotations

import argparse
import json
import platform
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from typing import Iterator, List, Optional, Sequence, Tuple

SOURCE_NAMESPACE = "zziaguan"
TARGET_REGISTRY = "registry.cn-zhangjiakou.aliyuncs.com"
TARGET_NAMESPACE = "zziaguan"
HUB_API = "https://hub.docker.com/v2"
PAGE_SIZE = 100
DEFAULT_TIMEOUT = 60
DOCKER_CMD_TIMEOUT = None  # None = 不限制 docker 命令超时


class HubError(RuntimeError):
    pass


def log(msg: str) -> None:
    print(msg, flush=True)


def http_get_json(url: str, timeout: int = DEFAULT_TIMEOUT, retries: int = 5) -> dict:
    last_err: Optional[BaseException] = None
    for attempt in range(1, retries + 1):
        try:
            req = urllib.request.Request(
                url,
                headers={
                    "Accept": "application/json",
                    "User-Agent": "sync.py/1.0",
                },
                method="GET",
            )
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                raw = resp.read().decode("utf-8")
                return json.loads(raw)
        except (urllib.error.HTTPError, urllib.error.URLError, TimeoutError, json.JSONDecodeError) as exc:
            last_err = exc
            wait = min(2 ** attempt, 30)
            log(f"[warn] 请求失败 ({attempt}/{retries}): {url} -> {exc}; {wait}s 后重试")
            time.sleep(wait)
    raise HubError(f"请求失败: {url}: {last_err}")


def paginate(url: str) -> Iterator[dict]:
    next_url: Optional[str] = url
    while next_url:
        data = http_get_json(next_url)
        for item in data.get("results") or []:
            yield item
        next_url = data.get("next")


def host_arch() -> str:
    machine = platform.machine().lower()
    if machine in ("x86_64", "amd64"):
        return "amd64"
    if machine in ("aarch64", "arm64"):
        return "arm64"
    return machine


def normalize_digest(digest: Optional[str]) -> Optional[str]:
    if not digest:
        return None
    digest = digest.strip().lower()
    if not digest:
        return None
    if not digest.startswith("sha256:"):
        digest = f"sha256:{digest}"
    return digest


def pick_source_digest(tag_item: dict, arch: str, os_name: str = "linux") -> Optional[str]:
    """优先取当前平台对应的镜像 digest，避免 multi-arch 清单 digest 比对失败。"""
    for img in tag_item.get("images") or []:
        if img.get("architecture") != arch:
            continue
        if (img.get("os") or "linux") != os_name:
            continue
        digest = normalize_digest(img.get("digest"))
        if digest:
            return digest
    return normalize_digest(tag_item.get("digest"))


def list_repositories(namespace: str) -> List[str]:
    url = (
        f"{HUB_API}/repositories/{urllib.parse.quote(namespace)}/"
        f"?page_size={PAGE_SIZE}"
    )
    names = []
    for item in paginate(url):
        name = item.get("name")
        if name:
            names.append(name)
    names.sort()
    return names


def list_tags_with_digest(
    namespace: str,
    repository: str,
    arch: str,
) -> List[Tuple[str, Optional[str]]]:
    url = (
        f"{HUB_API}/repositories/"
        f"{urllib.parse.quote(namespace)}/{urllib.parse.quote(repository)}/tags/"
        f"?page_size={PAGE_SIZE}&ordering=last_updated"
    )
    tags: List[Tuple[str, Optional[str]]] = []
    seen = set()
    for item in paginate(url):
        tag = item.get("name")
        if not tag or tag in seen:
            continue
        seen.add(tag)
        tags.append((tag, pick_source_digest(item, arch)))
    return tags


def run_docker(
    args: Sequence[str],
    *,
    dry_run: bool = False,
    check: bool = True,
    capture: bool = False,
) -> subprocess.CompletedProcess:
    cmd = ["docker", *args]
    pretty = " ".join(cmd)
    if dry_run:
        log(f"[dry-run] {pretty}")
        return subprocess.CompletedProcess(cmd, 0, stdout="", stderr="")
    log(f"[exec] {pretty}")
    try:
        result = subprocess.run(
            cmd,
            check=False,
            capture_output=capture,
            text=True if capture else None,
            timeout=DOCKER_CMD_TIMEOUT,
        )
    except FileNotFoundError as exc:
        raise RuntimeError("未找到 docker 命令，请先安装并确保在 PATH 中") from exc
    if check and result.returncode != 0:
        err = ""
        if capture:
            err = (result.stderr or result.stdout or "").strip()
            if err:
                err = f": {err}"
        raise RuntimeError(f"命令失败 (exit={result.returncode}): {pretty}{err}")
    return result


def get_remote_digest(image_ref: str) -> Optional[str]:
    """查询远端镜像 digest；镜像不存在或查询失败时返回 None。"""
    result = run_docker(
        [
            "buildx",
            "imagetools",
            "inspect",
            "--format",
            "{{.Digest}}",
            image_ref,
        ],
        check=False,
        capture=True,
    )
    if result.returncode != 0:
        return None
    return normalize_digest((result.stdout or "").strip())


def needs_sync(
    source_digest: Optional[str],
    target_ref_name: str,
    *,
    force: bool,
) -> Tuple[bool, str]:
    if force:
        return True, "强制同步"
    target_digest = get_remote_digest(target_ref_name)
    if target_digest is None:
        return True, "目标不存在"
    if source_digest is None:
        return True, "源 digest 未知，保险起见重新同步"
    if source_digest == target_digest:
        return False, f"digest 一致 ({source_digest})"
    return True, f"digest 变化: {target_digest} -> {source_digest}"


def sync_image(
    source: str,
    target: str,
    *,
    dry_run: bool,
    cleanup: bool,
) -> None:
    run_docker(["pull", source], dry_run=dry_run)
    run_docker(["tag", source, target], dry_run=dry_run)
    run_docker(["push", target], dry_run=dry_run)
    if cleanup:
        for ref in (source, target):
            try:
                run_docker(["rmi", "-f", ref], dry_run=dry_run, check=False)
            except RuntimeError as exc:
                log(f"[warn] 清理本地镜像失败: {ref}: {exc}")


def collect_images(
    namespace: str,
    repo_filter: Optional[str],
    tag_filter: Optional[str],
    arch: str,
) -> List[Tuple[str, str, Optional[str]]]:
    repos = list_repositories(namespace)
    if repo_filter:
        repos = [r for r in repos if r == repo_filter]
        if not repos:
            raise HubError(f"未找到仓库: {namespace}/{repo_filter}")

    images: List[Tuple[str, str, Optional[str]]] = []
    for repo in repos:
        log(f"[info] 扫描仓库: {namespace}/{repo}")
        tags = list_tags_with_digest(namespace, repo, arch)
        if tag_filter:
            tags = [(t, d) for t, d in tags if t == tag_filter]
        if not tags:
            log(f"[warn] 仓库无匹配标签: {namespace}/{repo}")
            continue
        for tag, digest in tags:
            images.append((repo, tag, digest))
    return images


def target_ref(repo: str, tag: str) -> str:
    return f"{TARGET_REGISTRY}/{TARGET_NAMESPACE}/{repo}:{tag}"


def source_ref(repo: str, tag: str) -> str:
    return f"{SOURCE_NAMESPACE}/{repo}:{tag}"


def parse_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="同步 Docker Hub zziaguan 镜像到阿里云 ACR",
    )
    parser.add_argument("--repo", help="只同步指定仓库名，例如 node")
    parser.add_argument("--tag", help="只同步指定标签，例如 14")
    parser.add_argument(
        "--list",
        action="store_true",
        help="只列出将要同步的镜像，不执行 docker 操作",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="打印 docker 命令但不实际执行",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="忽略 digest 比对，强制同步全部镜像",
    )
    parser.add_argument(
        "--cleanup",
        action="store_true",
        help="push 成功后删除本地源镜像和目标镜像，节省磁盘",
    )
    parser.add_argument(
        "--continue-on-error",
        action="store_true",
        help="单个镜像失败时继续处理后续镜像",
    )
    parser.add_argument(
        "--source-namespace",
        default=SOURCE_NAMESPACE,
        help=f"源命名空间 (默认: {SOURCE_NAMESPACE})",
    )
    parser.add_argument(
        "--target-registry",
        default=TARGET_REGISTRY,
        help=f"目标 registry (默认: {TARGET_REGISTRY})",
    )
    parser.add_argument(
        "--target-namespace",
        default=TARGET_NAMESPACE,
        help=f"目标命名空间 (默认: {TARGET_NAMESPACE})",
    )
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> int:
    global SOURCE_NAMESPACE, TARGET_REGISTRY, TARGET_NAMESPACE

    args = parse_args(argv)
    SOURCE_NAMESPACE = args.source_namespace
    TARGET_REGISTRY = args.target_registry
    TARGET_NAMESPACE = args.target_namespace
    arch = host_arch()

    log(
        f"[info] 源: docker.io/{SOURCE_NAMESPACE}/*  "
        f"目标: {TARGET_REGISTRY}/{TARGET_NAMESPACE}/*  "
        f"平台: linux/{arch}"
    )

    try:
        images = collect_images(SOURCE_NAMESPACE, args.repo, args.tag, arch)
    except HubError as exc:
        log(f"[error] {exc}")
        return 1

    if not images:
        log("[info] 没有需要处理的镜像")
        return 0

    log(f"[info] 共扫描到 {len(images)} 个镜像")
    for repo, tag, digest in images:
        src = source_ref(repo, tag)
        dst = target_ref(repo, tag)
        digest_text = digest or "unknown"
        log(f"  {src}  =>  {dst}  ({digest_text})")

    if args.list:
        return 0

    synced = 0
    skipped = 0
    failed: List[str] = []

    for idx, (repo, tag, source_digest) in enumerate(images, 1):
        src = source_ref(repo, tag)
        dst = target_ref(repo, tag)
        log(f"\n[{idx}/{len(images)}] 检查 {src} -> {dst}")

        try:
            do_sync, reason = needs_sync(source_digest, dst, force=args.force)
            if not do_sync:
                log(f"[skip] {reason}")
                skipped += 1
                continue

            log(f"[sync] {reason}")
            if args.dry_run:
                log(f"[dry-run] 将同步 {src} -> {dst}")
                synced += 1
                continue

            sync_image(src, dst, dry_run=False, cleanup=args.cleanup)
            synced += 1
        except Exception as exc:  # noqa: BLE001 - 需要汇总失败项
            log(f"[error] {src}: {exc}")
            failed.append(src)
            if not args.continue_on_error:
                break

    log("\n========== 结果 ==========")
    log(f"同步: {synced}")
    log(f"跳过: {skipped}")
    log(f"失败: {len(failed)}")
    if failed:
        for item in failed:
            log(f"  - {item}")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
