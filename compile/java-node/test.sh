#!/usr/bin/env bash
# 构建阶段校验：依次切换各 JDK（SDKMAN）与 Node（nvm），打印版本；任一步失败则退出非 0。
set -euo pipefail

: "${SDKMAN_DIR:=/root/.sdkman}"
: "${NVM_DIR:=/root/.nvm}"

: "${JAVA_8_SDK_ID:?JAVA_8_SDK_ID not set}"
: "${JAVA_11_SDK_ID:?JAVA_11_SDK_ID not set}"
: "${JAVA_17_SDK_ID:?JAVA_17_SDK_ID not set}"

# shellcheck source=/dev/null
source "${SDKMAN_DIR}/bin/sdkman-init.sh"
# shellcheck source=/dev/null
source "${NVM_DIR}/nvm.sh"

echo "========== JDK（sdk use java <id>）=========="
for id in "${JAVA_8_SDK_ID}" "${JAVA_11_SDK_ID}" "${JAVA_17_SDK_ID}"; do
	echo "---------- sdk use java ${id} ----------"
	sdk use java "${id}"
	java -version
	javac -version
	command -v java
	command -v javac
done

echo "========== Node（nvm use <major>）=========="
for major in 16 18 20 22 24; do
	echo "---------- nvm use ${major} ----------"
	nvm use "${major}"
	node -v
	command -v node
done

echo "---------- 恢复默认：JDK 17 + Node 22 ----------"
sdk default java "${JAVA_17_SDK_ID}"
nvm alias default 22
nvm use default

echo "---------- 默认 JDK ----------"
java -version
javac -version
sdk current java

echo "---------- 默认 Node ----------"
node -v
nvm current

echo "---------- Maven（应使用当前 JAVA_HOME）----------"
mvn -version | head -n 3

echo "========== test.sh 通过 =========="
