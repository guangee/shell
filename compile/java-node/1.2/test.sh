#!/usr/bin/env bash
# 构建阶段校验：依次切换各 JDK 与 Node，打印版本；任一步失败则退出非 0。
set -eo pipefail

: "${SDKMAN_DIR:=/root/.sdkman}"
: "${NVM_DIR:=/root/.nvm}"
: "${JAVA_8_SDK_ID:?JAVA_8_SDK_ID not set}"
: "${JAVA_11_SDK_ID:?JAVA_11_SDK_ID not set}"
: "${JAVA_17_SDK_ID:?JAVA_17_SDK_ID not set}"
: "${NODE_DEFAULT:=22}"

# shellcheck source=/dev/null
source /root/.bashrc

echo "========== Python =========="
python3 --version
python --version
pip3 --version

echo "========== 运维工具（tools 合并项）=========="
command -v envsubst
command -v ifconfig
command -v tree
command -v mc
command -v yq
envsubst --version | head -n 1
tree --version | head -n 1
mc --version
yq --version

echo "========== JDK（use-java <major>）=========="
for major in 8 11 17; do
	echo "---------- use-java ${major} ----------"
	use-java "${major}"
	java -version
	javac -version
	case "${major}" in
		8) expected="1.8." ;;
		*) expected="version \"${major}." ;;
	esac
	java -version 2>&1 | grep -F "${expected}" >/dev/null
done

echo "========== Node（use-node <major>）=========="
for major in ${NODE_MAJOR_VERSIONS}; do
	echo "---------- use-node ${major} ----------"
	use-node "${major}"
	node -v
	node -v | grep -E "^v${major}\\." >/dev/null
done

echo "---------- 恢复默认：JDK 17 + Node ${NODE_DEFAULT} ----------"
use-java 17 --default
use-node "${NODE_DEFAULT}" --default

echo "---------- 默认 JDK ----------"
java -version
javac -version
java -version 2>&1 | grep -F 'version "17.' >/dev/null
sdk current java

echo "---------- 默认 Node ----------"
node -v
node -v | grep -E "^v${NODE_DEFAULT}\\." >/dev/null
nvm current

echo "---------- Maven（应使用当前 JAVA_HOME）----------"
mvn -version | head -n 3

echo "========== test.sh 通过 =========="
