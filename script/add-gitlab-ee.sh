#!/usr/bin/env bash
# 为指定官方 gitlab-ee 版本生成私有镜像构建目录，并同步 gitlab-zoekt
# 用法: ./script/add-gitlab-ee.sh <版本号>
# 示例: ./script/add-gitlab-ee.sh 19.1.3
#       ./script/add-gitlab-ee.sh 19.0.3-ee.0
#
# 版本对应规则:
#   gitlab-ee:     X.Y.Z-ee.0  →  FROM gitlab/gitlab-ee:X.Y.Z-ee.0
#   gitlab-zoekt:  vX.Y.Z      →  FROM registry.gitlab.com/gitlab-org/build/cng/gitlab-zoekt:vX.Y.Z

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
GITLAB_EE_DIR="${REPO_ROOT}/gitlab-ee"
GITLAB_ZOEKT_DIR="${REPO_ROOT}/gitlab-zoekt"
IMAGE_REPO="gitlab/gitlab-ee"
ZOEKT_IMAGE_REPO="registry.gitlab.com/gitlab-org/build/cng/gitlab-zoekt"
# Docker Hub 镜像代理（用于检查 gitlab-ee）
IMAGE_PROXY="hub.coding-space.cn"

usage() {
  cat <<'EOF'
用法: add-gitlab-ee.sh <版本号> [--skip-check]

为指定版本创建 gitlab-ee 私有镜像构建目录，并同步创建 gitlab-zoekt：
- gitlab-ee:    以本地最新版为模板复制，仅改 Dockerfile FROM
- gitlab-zoekt: 目录名 vX.Y.Z，Dockerfile 仅一行官方 CNG zoekt 镜像

版本对应: X.Y.Z / X.Y.Z-ee.0  →  ee: X.Y.Z-ee.0  +  zoekt: vX.Y.Z

参数:
  版本号         如 19.1.3 或 19.1.3-ee.0（会自动补全 -ee.0 后缀）
  --skip-check   跳过镜像存在性检查（网络不可用时使用）

示例:
  ./script/add-gitlab-ee.sh 19.1.3
  ./script/add-gitlab-ee.sh 19.0.3-ee.0
  ./script/add-gitlab-ee.sh 19.0.3 --skip-check
EOF
}

normalize_version() {
  local raw="$1"
  raw="${raw#v}"
  if [[ "$raw" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "${raw}-ee.0"
  elif [[ "$raw" =~ ^[0-9]+\.[0-9]+\.[0-9]+-ee\.[0-9]+$ ]]; then
    echo "$raw"
  else
    echo "错误: 版本号格式无效: $1（期望 x.y.z 或 x.y.z-ee.N）" >&2
    return 1
  fi
}

# X.Y.Z-ee.N → X.Y.Z
ee_base_version() {
  local ee_version="$1"
  echo "${ee_version%%-ee.*}"
}

# X.Y.Z-ee.N → vX.Y.Z
zoekt_version_from_ee() {
  local ee_version="$1"
  echo "v$(ee_base_version "$ee_version")"
}

# 按 semver 找本地最新版本目录，用作复制模板
# 可选参数 $1：排除该版本（避免目标已是最新时与自身对比）
template_version() {
  local base_dir="$1"
  local pattern="$2"
  local exclude="${3:-}"

  if [[ ! -d "$base_dir" ]]; then
    echo "错误: 目录不存在: $base_dir" >&2
    return 1
  fi

  local latest
  latest="$(
    find "$base_dir" -mindepth 1 -maxdepth 1 -type d -print \
      | while IFS= read -r dir; do
          basename "$dir"
        done \
      | grep -E "$pattern" \
      | { if [[ -n "$exclude" ]]; then grep -vxF "$exclude"; else cat; fi; } \
      | sort -V \
      | tail -n 1
  )"

  if [[ -z "$latest" ]]; then
    echo "错误: 未找到可用的本地模板目录: $base_dir" >&2
    return 1
  fi
  echo "$latest"
}

# HTTP 探测镜像是否存在，输出状态码；失败时输出 000
http_probe() {
  local url="$1"
  local code
  code="$(
    curl -sS -o /dev/null -w '%{http_code}' --connect-timeout 8 --max-time 15 \
      -H "Accept: application/vnd.docker.distribution.manifest.v2+json, application/vnd.oci.image.manifest.v1+json, application/vnd.docker.distribution.manifest.list.v2+json, application/vnd.oci.image.index.v1+json" \
      "$url" 2>/dev/null || true
  )"
  if [[ "$code" =~ ^[0-9]{3}$ ]]; then
    echo "$code"
  else
    echo "000"
  fi
}

# 经镜像代理检查官方 gitlab-ee tag 是否存在
ee_image_exists() {
  local tag="$1"
  local proxy_url="https://${IMAGE_PROXY}/v2/${IMAGE_REPO}/manifests/${tag}"
  local http_code

  echo "经代理检查 gitlab-ee: ${IMAGE_PROXY}/${IMAGE_REPO}:${tag}"

  http_code="$(http_probe "$proxy_url")"
  http_code="${http_code:-000}"
  if [[ "$http_code" == "200" ]]; then
    echo "镜像代理确认 gitlab-ee 存在"
    return 0
  fi
  if [[ "$http_code" == "404" ]]; then
    echo "错误: 代理上不存在镜像 ${IMAGE_REPO}:${tag}" >&2
    return 1
  fi

  echo "镜像代理 API 不可用 (HTTP ${http_code})，尝试 docker manifest inspect..."
  if command -v docker >/dev/null 2>&1; then
    if docker manifest inspect "${IMAGE_PROXY}/${IMAGE_REPO}:${tag}" >/dev/null 2>&1; then
      echo "docker manifest 确认 gitlab-ee 存在"
      return 0
    fi
  fi

  echo "错误: 无法经代理确认镜像 ${IMAGE_REPO}:${tag}" >&2
  echo "提示: 若你确认镜像已发布，可加 --skip-check 跳过检查" >&2
  return 1
}

# 获取 GitLab Container Registry 匿名 pull token
gitlab_registry_token() {
  local repo_path="$1"
  local token
  token="$(
    curl -sS --connect-timeout 8 --max-time 15 \
      "https://gitlab.com/jwt/auth?service=container_registry&scope=repository:${repo_path}:pull" \
      2>/dev/null \
      | sed -n 's/.*"token"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
  )"
  if [[ -n "$token" ]]; then
    echo "$token"
    return 0
  fi
  return 1
}

# zoekt 官方镜像在 registry.gitlab.com，不在 Docker Hub 代理上
zoekt_image_exists() {
  local tag="$1"
  local image="${ZOEKT_IMAGE_REPO}:${tag}"
  local repo_path="gitlab-org/build/cng/gitlab-zoekt"
  local manifest_url="https://registry.gitlab.com/v2/${repo_path}/manifests/${tag}"
  local token http_code

  echo "检查 gitlab-zoekt: ${image}"

  if token="$(gitlab_registry_token "$repo_path")"; then
    http_code="$(
      curl -sS -o /dev/null -w '%{http_code}' --connect-timeout 8 --max-time 15 \
        -H "Authorization: Bearer ${token}" \
        -H "Accept: application/vnd.docker.distribution.manifest.v2+json, application/vnd.oci.image.manifest.v1+json, application/vnd.docker.distribution.manifest.list.v2+json, application/vnd.oci.image.index.v1+json" \
        "$manifest_url" 2>/dev/null || true
    )"
    http_code="${http_code:-000}"
    if [[ "$http_code" == "200" ]]; then
      echo "registry.gitlab.com 确认 gitlab-zoekt 存在"
      return 0
    fi
    if [[ "$http_code" == "404" ]]; then
      echo "错误: 不存在镜像 ${image}" >&2
      return 1
    fi
    echo "registry.gitlab.com API 不可用 (HTTP ${http_code})，尝试 docker manifest inspect..."
  else
    echo "无法获取 GitLab Registry token，尝试 docker manifest inspect..."
  fi

  if command -v docker >/dev/null 2>&1; then
    if docker manifest inspect "$image" >/dev/null 2>&1; then
      echo "docker manifest 确认 gitlab-zoekt 存在"
      return 0
    fi
  else
    echo "错误: docker 不可用，且无法经 API 确认镜像" >&2
    echo "提示: 可加 --skip-check 跳过检查" >&2
    return 1
  fi

  echo "错误: 无法确认镜像 ${image}" >&2
  echo "提示: 若你确认镜像已发布，可加 --skip-check 跳过检查" >&2
  return 1
}

create_ee_version_dir() {
  local version="$1"
  local source_version="$2"
  local src="${GITLAB_EE_DIR}/${source_version}"
  local dst="${GITLAB_EE_DIR}/${version}"

  if [[ -d "$dst" ]]; then
    echo "gitlab-ee 目录已存在: $dst"
    return 0
  fi

  if [[ ! -f "${src}/Dockerfile" || ! -f "${src}/import-license.sh" || ! -f "${src}/license.rb" ]]; then
    echo "错误: gitlab-ee 模板缺少必要文件: $src" >&2
    return 1
  fi

  mkdir -p "$dst"
  cp "${src}/import-license.sh" "${dst}/import-license.sh"
  cp "${src}/license.rb" "${dst}/license.rb"
  cp "${src}/Dockerfile" "${dst}/Dockerfile"
  sed -i.bak "s|^FROM ${IMAGE_REPO}:.*|FROM ${IMAGE_REPO}:${version}|" "${dst}/Dockerfile"
  rm -f "${dst}/Dockerfile.bak"

  if [[ "$(cat "${dst}/Dockerfile" | head -n 1)" != "FROM ${IMAGE_REPO}:${version}" ]]; then
    echo "错误: gitlab-ee Dockerfile FROM 行更新失败" >&2
    rm -rf "$dst"
    return 1
  fi

  echo "已创建 gitlab-ee: $dst"
  echo "  模板: ${source_version}"
  echo "  基础镜像: ${IMAGE_REPO}:${version}"
}

create_zoekt_version_dir() {
  local version="$1"
  local source_version="$2"
  local src="${GITLAB_ZOEKT_DIR}/${source_version}"
  local dst="${GITLAB_ZOEKT_DIR}/${version}"

  if [[ -d "$dst" ]]; then
    echo "gitlab-zoekt 目录已存在: $dst"
    return 0
  fi

  if [[ ! -f "${src}/Dockerfile" ]]; then
    echo "错误: gitlab-zoekt 模板缺少 Dockerfile: $src" >&2
    return 1
  fi

  mkdir -p "$dst"
  # 保持与现有目录一致：单行 FROM，无末尾换行
  printf 'FROM %s:%s' "${ZOEKT_IMAGE_REPO}" "${version}" > "${dst}/Dockerfile"

  if [[ "$(cat "${dst}/Dockerfile")" != "FROM ${ZOEKT_IMAGE_REPO}:${version}" ]]; then
    echo "错误: gitlab-zoekt Dockerfile 写入失败" >&2
    rm -rf "$dst"
    return 1
  fi

  echo "已创建 gitlab-zoekt: $dst"
  echo "  模板: ${source_version}"
  echo "  基础镜像: ${ZOEKT_IMAGE_REPO}:${version}"
}

# 以 git diff 风格对比目标目录与模板目录
show_diff_against_template() {
  local label="$1"
  local src_rel="$2"
  local dst_rel="$3"
  local src="${REPO_ROOT}/${src_rel}"
  local dst="${REPO_ROOT}/${dst_rel}"

  echo
  echo "======== ${label} 与模板差异: ${src_rel} → ${dst_rel} ========"

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

  local ee_version
  ee_version="$(normalize_version "$raw_version")"
  local zoekt_version
  zoekt_version="$(zoekt_version_from_ee "$ee_version")"

  local ee_template
  ee_template="$(template_version "$GITLAB_EE_DIR" '^[0-9]+\.[0-9]+\.[0-9]+-ee\.[0-9]+$' "$ee_version")"
  local zoekt_template
  zoekt_template="$(template_version "$GITLAB_ZOEKT_DIR" '^v[0-9]+\.[0-9]+\.[0-9]+$' "$zoekt_version")"

  echo "gitlab-ee 目标: ${ee_version}（模板 ${ee_template}）"
  echo "gitlab-zoekt 目标: ${zoekt_version}（模板 ${zoekt_template}）"

  local ee_exists=0
  local zoekt_exists=0
  [[ -d "${GITLAB_EE_DIR}/${ee_version}" ]] && ee_exists=1
  [[ -d "${GITLAB_ZOEKT_DIR}/${zoekt_version}" ]] && zoekt_exists=1

  if [[ "$ee_exists" -eq 1 && "$zoekt_exists" -eq 1 ]]; then
    echo "两个版本目录均已存在，仅展示差异。"
    show_diff_against_template "gitlab-ee" "gitlab-ee/${ee_template}" "gitlab-ee/${ee_version}"
    show_diff_against_template "gitlab-zoekt" "gitlab-zoekt/${zoekt_template}" "gitlab-zoekt/${zoekt_version}"
    exit 0
  fi

  if [[ "$skip_check" -eq 1 ]]; then
    echo "已跳过镜像存在性检查 (--skip-check)"
  else
    if [[ "$ee_exists" -eq 0 ]]; then
      ee_image_exists "$ee_version" || exit 1
    fi
    if [[ "$zoekt_exists" -eq 0 ]]; then
      zoekt_image_exists "$zoekt_version" || exit 1
    fi
  fi

  if [[ "$ee_exists" -eq 0 ]]; then
    create_ee_version_dir "$ee_version" "$ee_template"
  else
    echo "gitlab-ee 目录已存在，跳过创建"
  fi

  if [[ "$zoekt_exists" -eq 0 ]]; then
    create_zoekt_version_dir "$zoekt_version" "$zoekt_template"
  else
    echo "gitlab-zoekt 目录已存在，跳过创建"
  fi

  show_diff_against_template "gitlab-ee" "gitlab-ee/${ee_template}" "gitlab-ee/${ee_version}"
  show_diff_against_template "gitlab-zoekt" "gitlab-zoekt/${zoekt_template}" "gitlab-zoekt/${zoekt_version}"
  echo "私有镜像构建目录已就绪。"
}

main "$@"
