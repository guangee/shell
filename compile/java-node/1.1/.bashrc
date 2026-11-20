#!/bin/bash

export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# 按主版本切换，不必记 SDKMAN 的完整标识。--default 写入持久默认版本。
use-java() {
	local major="${1:-}"
	local mode="${2:-}"
	local id=""
	case "${major}" in
		8) id="${JAVA_8_SDK_ID}" ;;
		11) id="${JAVA_11_SDK_ID}" ;;
		17) id="${JAVA_17_SDK_ID}" ;;
		*)
			echo "用法: use-java 8|11|17 [--default]"
			return 1
			;;
	esac
	if [[ "${mode}" == "--default" ]]; then
		sdk default java "${id}"
	else
		sdk use java "${id}"
	fi
}

use-node() {
	local major="${1:-}"
	local mode="${2:-}"
	case "${major}" in
		14|15|16|17|18|19|20|21|22) ;;
		*)
			echo "用法: use-node 14|15|16|17|18|19|20|21|22 [--default]"
			return 1
			;;
	esac
	if [[ "${mode}" == "--default" ]]; then
		nvm alias default "${major}"
		nvm use default
	else
		nvm use "${major}"
	fi
}

if [ -t 1 ]; then
	export PS1="\e[1;34m[\e[1;33m\u@\e[1;32mdocker-\h\e[1;37m:\w\[\e[1;34m]\e[1;36m\\$ \e[0m"
fi

# Aliases
alias l='ls -lAsh --color'
alias ls='ls -C1 --color'
alias cp='cp -ip'
alias rm='rm -i'
alias mv='mv -i'
alias h='cd ~;clear;'

. /etc/os-release

echo -e -n '\E[1;34m'
figlet -w 120 "TulanTech"
echo -e "\E[1;36mJAVA_VERSION \E[1;32m${JAVA_VERSION:-unknown}\e[0m"
echo -e "\E[1;36mJAVA_HOME    \E[1;32m${JAVA_HOME:-unknown}\e[0m"
echo -e "\E[1;36mMAVEN_VERSION\E[1;32m${MAVEN_VERSION:-unknown}\e[0m"
echo -e "\E[1;36mMAVEN_HOME   \E[1;32m${MAVEN_HOME:-unknown}\e[0m"
if command -v python3 >/dev/null 2>&1; then
	echo -e "\E[1;36mPYTHON       \E[1;32m$(python3 --version 2>&1)\e[0m"
fi
if command -v node >/dev/null 2>&1; then
	echo -e "\E[1;36mNODE_VERSION \E[1;32m$(node -v)\e[0m (nvm default)"
fi
echo -e "\E[1;35m──────── 版本切换说明 ────────\e[0m"
echo -e "\E[1;36mJDK\e[0m   当前终端: \E[1;33muse-java 8|11|17\E[0m    持久默认: \E[1;33muse-java 17 --default\E[0m"
echo "       已安装: Java 8 ${JAVA_8_SDK_ID:-} / Java 11 ${JAVA_11_SDK_ID:-} / Java 17 ${JAVA_17_SDK_ID:-}"
echo -e "\E[1;36mNode\e[0m  当前终端: \E[1;33muse-node 14|15|16|17|18|19|20|21|22\E[0m"
echo "       持久默认: use-node 22 --default    已安装列表: nvm ls"
echo -e "\E[1;35m──────────────────────────────\e[0m"
echo -e -n '\E[1;34m'
echo "Base: ${PRETTY_NAME:-linux/amd64}"
echo -e '\E[0m'
