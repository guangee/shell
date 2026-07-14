#!/usr/bin/env bash
# 统一入口：交互选择 gitlab-ee / gitlab-runner，输入版本号后执行构建目录准备
# 用法: ./script/add-gitlab.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

latest_dir_version() {
  local base_dir="$1"
  local pattern="$2"

  find "$base_dir" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null \
    | while IFS= read -r dir; do
        basename "$dir"
      done \
    | grep -E "$pattern" \
    | sort -V \
    | tail -n 1
}

# 交互提示走 stderr，避免被命令替换吞掉
choose_product() {
  local choice=""
  echo "请选择要处理的软件：" >&2
  echo "  1) gitlab-ee（同时同步 gitlab-zoekt）" >&2
  echo "  2) gitlab-runner" >&2
  echo "  q) 退出" >&2
  echo >&2

  while true; do
    read -r -p "请输入选项 [1/2/q]: " choice
    case "$choice" in
      1|ee|gitlab-ee|gitlab_ee)
        echo "ee"
        return 0
        ;;
      2|runner|gitlab-runner|gitlab_runner)
        echo "runner"
        return 0
        ;;
      q|Q|quit|exit)
        echo "quit"
        return 0
        ;;
      *)
        echo "无效选项，请重新输入。" >&2
        ;;
    esac
  done
}

ask_version() {
  local product="$1"
  local hint="$2"
  local example="$3"
  local version=""

  echo >&2
  echo "当前本地最新 ${product}: ${hint:-（无）}" >&2
  while true; do
    read -r -p "请输入目标版本号（例如 ${example}）: " version
    version="${version// /}"
    if [[ -n "$version" ]]; then
      echo "$version"
      return 0
    fi
    echo "版本号不能为空，请重新输入。" >&2
  done
}

confirm_run() {
  local product="$1"
  local version="$2"
  local ans=""

  echo >&2
  echo "将执行：" >&2
  echo "  软件: ${product}" >&2
  echo "  版本: ${version}" >&2
  echo "  检查: 经代理检查官方镜像是否存在" >&2
  read -r -p "确认继续？[Y/n]: " ans
  case "$ans" in
    n|N|no|NO)
      return 1
      ;;
    *)
      return 0
      ;;
  esac
}

main() {
  # 优先从控制终端读入；不可用时回退到当前 stdin（便于管道测试）
  if ( : </dev/tty ) 2>/dev/null; then
    exec </dev/tty
  fi

  echo "======== GitLab 私有镜像版本准备 ========"
  echo "仓库: ${REPO_ROOT}"
  echo

  local product
  product="$(choose_product)"
  if [[ "$product" == "quit" ]]; then
    echo "已取消。"
    exit 0
  fi

  local latest=""
  local example=""
  local target_script=""
  local label=""

  case "$product" in
    ee)
      label="gitlab-ee"
      target_script="${SCRIPT_DIR}/add-gitlab-ee.sh"
      latest="$(latest_dir_version "${REPO_ROOT}/gitlab-ee" '^[0-9]+\.[0-9]+\.[0-9]+-ee\.[0-9]+$')"
      example="19.1.3 或 19.1.3-ee.0"
      ;;
    runner)
      label="gitlab-runner"
      target_script="${SCRIPT_DIR}/add-gitlab-runner.sh"
      latest="$(latest_dir_version "${REPO_ROOT}/gitlab-runner" '^v[0-9]+\.[0-9]+\.[0-9]+$')"
      example="19.1.2 或 v19.1.2"
      ;;
  esac

  if [[ ! -x "$target_script" ]]; then
    echo "错误: 找不到可执行脚本: $target_script" >&2
    exit 1
  fi

  local version
  version="$(ask_version "$label" "$latest" "$example")"

  if ! confirm_run "$label" "$version"; then
    echo "已取消。"
    exit 0
  fi

  echo
  echo "======== 开始执行 ========"
  "$target_script" "$version"
}

main "$@"
