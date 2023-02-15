#!/bin/bash

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
echo -e "\E[1;36mNODE_VERSION \E[1;32m${NODE_VERSION:-unknown}\e[0m"
echo -e "\E[1;36mCLI_VERSION  \E[1;32m${GITBOOK_CLI_VERSION:-unknown}\e[0m"
echo -e "\E[1;36mGITBOOK      \E[1;32m${GITBOOK_VERSION:-unknown}\e[0m"
echo -e "\E[1;36mHOSTNAME     \E[1;32m${HOSTNAME:-unknown}\e[0m"
echo -e -n '\E[1;34m'
echo "Base: ${PRETTY_NAME:-linux/amd64}"
echo -e '\E[0m'
