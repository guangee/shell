#!/usr/bin/env bash
# 为指定官方 gitlab-runner 版本生成私有镜像构建目录
# 用法: ./script/add-gitlab-runner.sh <版本号>
# 示例: ./script/add-gitlab-runner.sh 19.1.2
#       ./script/add-gitlab-runner.sh v19.1.2
#
# 版本规则（相对本地最新模板）:
#   目录:       gitlab-runner/vX.Y.Z/
#   Dockerfile: FROM gitlab/gitlab-runner:vX.Y.Z
#   entrypoint: 同步 HELPER_IMAGE 默认值
#               hub.tulan.wang/gitlab/gitlab-runner-helper:x86_64-vX.Y.Z
#   README.md:  原样复制

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
RUNNER_DIR="${REPO_ROOT}/gitlab-runner"
IMAGE_REPO="gitlab/gitlab-runner"
HELPER_IMAGE_PREFIX="hub.tulan.wang/gitlab/gitlab-runner-helper:x86_64-"
IMAGE_PROXY="hub.coding-space.cn"

usage() {
  cat <<'EOF'
用法: add-gitlab-runner.sh <版本号> [--skip-check]

为指定版本创建 gitlab-runner 私有镜像构建目录：
以本地最新版为模板复制，并更新：
  1) Dockerfile 的 FROM 标签
  2) entrypoint.sh 中 HELPER_IMAGE 默认 helper 版本

参数:
  版本号         如 19.1.2 或 v19.1.2（会自动补全 v 前缀）
  --skip-check   跳过镜像代理存在性检查

示例:
  ./script/add-gitlab-runner.sh 19.1.2
  ./script/add-gitlab-runner.sh v19.1.2
  ./script/add-gitlab-runner.sh 19.1.2 --skip-check
EOF
}

normalize_version() {
  local raw="$1"
  raw="${raw#v}"
  if [[ "$raw" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "v${raw}"
  else
    echo "错误: 版本号格式无效: $1（期望 x.y.z 或 vx.y.z）" >&2
    return 1
  fi
}

template_version() {
  local exclude="${1:-}"

  if [[ ! -d "$RUNNER_DIR" ]]; then
    echo "错误: 目录不存在: $RUNNER_DIR" >&2
    return 1
  fi

  local latest
  latest="$(
    find "$RUNNER_DIR" -mindepth 1 -maxdepth 1 -type d -print \
      | while IFS= read -r dir; do
          basename "$dir"
        done \
      | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' \
      | { if [[ -n "$exclude" ]]; then grep -vxF "$exclude"; else cat; fi; } \
      | sort -V \
      | tail -n 1
  )"

  if [[ -z "$latest" ]]; then
    echo "错误: 未找到可用的本地 gitlab-runner 模板目录" >&2
    return 1
  fi
  echo "$latest"
}

http_probe() {
  local url="$1"
  local code
  code="$(
    curl -sS -o /dev/null -w '%{http_code}' --connect-timeout 8 --max-time 15 \
      -H "Accept: application/vnd.docker.distribution.manifest.v2+json, application/vnd.oci.image.manifest.v1+json, application/vnd.docker.distribution.manifest.list.v2+json" \
      "$url" 2>/dev/null || true
  )"
  if [[ "$code" =~ ^[0-9]{3}$ ]]; then
    echo "$code"
  else
    echo "000"
  fi
}

image_exists_on_proxy() {
  local tag="$1"
  local proxy_image="${IMAGE_PROXY}/${IMAGE_REPO}:${tag}"
  local proxy_url="https://${IMAGE_PROXY}/v2/${IMAGE_REPO}/manifests/${tag}"
  local http_code

  echo "经代理检查镜像: ${proxy_image}"

  # runner 多架构 tag 下 HTTP manifests 常误报 404，优先 docker manifest
  if command -v docker >/dev/null 2>&1; then
    if docker manifest inspect "$proxy_image" >/dev/null 2>&1; then
      echo "docker manifest 确认存在"
      return 0
    fi
  fi

  http_code="$(http_probe "$proxy_url")"
  http_code="${http_code:-000}"
  if [[ "$http_code" == "200" ]]; then
    echo "镜像代理 API 确认存在"
    return 0
  fi
  if [[ "$http_code" == "404" ]]; then
    echo "错误: 代理上不存在镜像 ${IMAGE_REPO}:${tag}" >&2
    return 1
  fi

  echo "错误: 无法经代理确认镜像 ${IMAGE_REPO}:${tag}" >&2
  echo "提示: 若你确认镜像已发布，可加 --skip-check 跳过检查" >&2
  return 1
}

create_version_dir() {
  local version="$1"
  local source_version="$2"
  local src="${RUNNER_DIR}/${source_version}"
  local dst="${RUNNER_DIR}/${version}"

  if [[ -d "$dst" ]]; then
    echo "错误: 目标版本目录已存在: $dst" >&2
    return 1
  fi

  if [[ ! -f "${src}/Dockerfile" || ! -f "${src}/entrypoint.sh" || ! -f "${src}/README.md" ]]; then
    echo "错误: 模板版本目录缺少必要文件: $src" >&2
    return 1
  fi

  mkdir -p "$dst"
  cp "${src}/README.md" "${dst}/README.md"
  cp "${src}/Dockerfile" "${dst}/Dockerfile"
  cp "${src}/entrypoint.sh" "${dst}/entrypoint.sh"

  sed -i.bak "s|^FROM ${IMAGE_REPO}:.*|FROM ${IMAGE_REPO}:${version}|" "${dst}/Dockerfile"
  rm -f "${dst}/Dockerfile.bak"

  # 同步 HELPER_IMAGE 默认 tag（x86_64-vX.Y.Z）
  sed -i.bak -E \
    "s|(x86_64-)v[0-9]+\.[0-9]+\.[0-9]+|\1${version}|" \
    "${dst}/entrypoint.sh"
  rm -f "${dst}/entrypoint.sh.bak"

  if [[ "$(head -n 1 "${dst}/Dockerfile")" != "FROM ${IMAGE_REPO}:${version}" ]]; then
    echo "错误: Dockerfile FROM 行更新失败" >&2
    rm -rf "$dst"
    return 1
  fi

  if ! grep -Fq "${HELPER_IMAGE_PREFIX}${version}" "${dst}/entrypoint.sh"; then
    echo "错误: entrypoint.sh 中 HELPER_IMAGE 版本更新失败" >&2
    rm -rf "$dst"
    return 1
  fi

  echo "已创建构建目录: $dst"
  echo "  模板版本: ${source_version}"
  echo "  基础镜像: ${IMAGE_REPO}:${version}"
  echo "  Helper 默认: ${HELPER_IMAGE_PREFIX}${version}"
}

show_diff_against_template() {
  local version="$1"
  local source_version="$2"
  local src_rel="gitlab-runner/${source_version}"
  local dst_rel="gitlab-runner/${version}"
  local src="${REPO_ROOT}/${src_rel}"
  local dst="${REPO_ROOT}/${dst_rel}"

  echo
  echo "======== 与模板差异: ${source_version} → ${version} ========"

  if [[ ! -d "$src" || ! -d "$dst" ]]; then
    echo "错误: 无法对比，目录不存在" >&2
    return 1
  fi

  if command -v git >/dev/null 2>&1; then
    local color_arg=(--color=never)
    if [[ -t 1 ]]; then
      color_arg=(--color=always)
    fi
    (
      cd "$REPO_ROOT"
      git --no-pager diff --no-index "${color_arg[@]}" \
        --stat \
        -- \
        "$src_rel" "$dst_rel" || true
      echo
      git --no-pager diff --no-index "${color_arg[@]}" \
        -- \
        "$src_rel" "$dst_rel" || true
    )
  else
    echo "(未找到 git，回退为 diff -ruN)"
    diff -ruN "$src" "$dst" || true
  fi

  echo "======== 差异结束 ========"
}

main() {
  if [[ $# -lt 1 ]] || [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
    usage
    [[ $# -ge 1 ]] && exit 0 || exit 1
  fi

  local raw_version=""
  local skip_check=0
  local arg
  for arg in "$@"; do
    case "$arg" in
      -h|--help)
        usage
        exit 0
        ;;
      --skip-check)
        skip_check=1
        ;;
      -*)
        echo "错误: 未知参数: $arg" >&2
        usage
        exit 1
        ;;
      *)
        if [[ -n "$raw_version" ]]; then
          echo "错误: 只能指定一个版本号" >&2
          exit 1
        fi
        raw_version="$arg"
        ;;
    esac
  done

  if [[ -z "$raw_version" ]]; then
    usage
    exit 1
  fi

  local version
  version="$(normalize_version "$raw_version")"

  local template
  template="$(template_version "$version")"
  echo "模板版本: ${template}"
  echo "目标版本: ${version}"

  if [[ -d "${RUNNER_DIR}/${version}" ]]; then
    echo "目标版本目录已存在: ${RUNNER_DIR}/${version}"
    show_diff_against_template "$version" "$template"
    exit 0
  fi

  if [[ "$skip_check" -eq 1 ]]; then
    echo "已跳过镜像代理检查 (--skip-check)"
  elif ! image_exists_on_proxy "$version"; then
    exit 1
  fi

  create_version_dir "$version" "$template"
  show_diff_against_template "$version" "$template"
  echo "私有镜像构建目录已就绪。"
}

main "$@"
