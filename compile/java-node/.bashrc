#!/bin/bash

export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

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
if command -v node >/dev/null 2>&1; then
	echo -e "\E[1;36mNODE_VERSION \E[1;32m$(node -v)\e[0m (nvm default)"
fi
echo -e "\E[1;35m──────── 版本切换说明 ────────\e[0m"
echo -e "\E[1;36mJDK（SDKMAN）\e[0m  查看已安装: \E[1;33msdk list java\E[0m  当前: \E[1;33msdk current java\E[0m"
echo "  仅当前终端生效: sdk use java <id>    例: sdk use java 17.0.12-oracle"
echo "  持久默认版本:   sdk default java <id>    例: sdk default java 17.0.12-oracle"
echo "  （<id> 以 sdk list java 中带星号/Installed 的标识为准，如 8.0.492-tem、11.0.31-tem）"
echo -e "\E[1;36mNode（nvm）\e[0m    已安装列表: \E[1;33mnvm ls\E[0m  当前: \E[1;33mnvm current\E[0m"
echo "  仅当前终端生效: nvm use <主版本号>    例: nvm use 18"
echo "  持久默认版本:   nvm alias default <主版本号>    例: nvm alias default 22"
echo -e "\E[1;35m──────────────────────────────\e[0m"
echo -e -n '\E[1;34m'
echo "Base: ${PRETTY_NAME:-linux/amd64}"
echo -e '\E[0m'
