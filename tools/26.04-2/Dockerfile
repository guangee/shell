FROM ubuntu:26.04
USER root

ENV LANG                            C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
# CI/工具镜像允许系统级 pip 安装（绕过 PEP 668）
ENV PIP_BREAK_SYSTEM_PACKAGES=1

RUN echo "Asia/Shanghai" > /etc/timezone
# 修改欢迎命令
COPY .bashrc /root/.bashrc
RUN apt update && apt upgrade -y \
    && apt install -y wget unzip curl jq tzdata gettext net-tools tree python3 python3-pip \
    && ln -sf /usr/bin/pip3 /usr/bin/pip
RUN wget https://dl.min.io/aistor/mc/release/linux-amd64/mc && chmod +x mc && mv mc /usr/bin/
RUN wget https://github.com/mikefarah/yq/releases/download/v4.16.2/yq_linux_amd64 && chmod +x yq_linux_amd64 && mv yq_linux_amd64 /usr/bin/yq
ADD sources.list /etc/apt/sources.list
