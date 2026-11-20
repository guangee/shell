# syntax=docker/dockerfile:1
# compile/java-node:1.2
# 在 1.1 基础上合并 tools/26.04-2 常用运维指令：gettext、net-tools、tree、mc、yq。
# Python 3 + Temurin JDK 8/11/17 + Node 14–22；切换：use-java / use-node
FROM ubuntu:26.04
USER root

ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
# CI/工具镜像允许系统级 pip 安装（绕过 PEP 668）
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# 2026-11-20 SDKMAN linuxx64 上 Temurin 8/11/17 的最新标识。
ARG JAVA_8_SDK_ID=8.0.514.0+1-tem
ARG JAVA_11_SDK_ID=11.0.33.0+10-tem
ARG JAVA_17_SDK_ID=17.0.21.1+2-tem
ENV JAVA_8_SDK_ID=${JAVA_8_SDK_ID}
ENV JAVA_11_SDK_ID=${JAVA_11_SDK_ID}
ENV JAVA_17_SDK_ID=${JAVA_17_SDK_ID}

ENV MAVEN_VERSION=3.9.16
ENV MAVEN_HOME=/opt/maven/apache-maven-${MAVEN_VERSION}
ENV NVM_DIR=/root/.nvm
ENV SDKMAN_DIR=/root/.sdkman
ENV JAVA_VERSION=17
ENV NODE_MAJOR_VERSIONS="14 15 16 17 18 19 20 21 22"
ENV NODE_DEFAULT=22
ARG YQ_VERSION=v4.43.1
ENV YQ_VERSION=${YQ_VERSION}

COPY .bashrc /root/.bashrc

RUN set -eux; \
    apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        wget \
        unzip \
        zip \
        curl \
        jq \
        tzdata \
        ca-certificates \
        git \
        figlet \
        gettext \
        net-tools \
        tree \
        python3 \
        python3-pip \
        python3-venv \
    && ln -sf "$(command -v python3)" /usr/local/bin/python \
    && ln -sf "$(command -v pip3)" /usr/local/bin/pip \
    && ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

# MinIO Client + yq（与 tools 镜像同用途，yq 升到较新版本）
RUN set -eux; \
    wget -q "https://dl.min.io/aistor/mc/release/linux-amd64/mc" -O /usr/local/bin/mc; \
    chmod +x /usr/local/bin/mc; \
    wget -q "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" -O /usr/local/bin/yq; \
    chmod +x /usr/local/bin/yq

RUN set -eux; \
    curl -fsSL "https://get.sdkman.io?ci=true&rcupdate=false" | bash; \
    { \
        echo "sdkman_auto_answer=true"; \
        echo "sdkman_selfupdate_feature=false"; \
        echo "sdkman_healthcheck_enable=false"; \
    } >> "${SDKMAN_DIR}/etc/config"; \
    bash <<INSTALL
set -eo pipefail
source "${SDKMAN_DIR}/bin/sdkman-init.sh"
sdk install java ${JAVA_8_SDK_ID}
sdk install java ${JAVA_11_SDK_ID}
sdk install java ${JAVA_17_SDK_ID}
sdk default java ${JAVA_17_SDK_ID}
sdk flush archives
sdk flush tmp
INSTALL

ENV JAVA_HOME=/root/.sdkman/candidates/java/current
ENV PATH="/root/.sdkman/candidates/java/current/bin:${MAVEN_HOME}/bin:${PATH}"

RUN set -eux; \
    mkdir -p /opt/maven; \
    wget -q "https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/${MAVEN_VERSION}/apache-maven-${MAVEN_VERSION}-bin.tar.gz" -O /tmp/maven.tar.gz; \
    tar -xzf /tmp/maven.tar.gz -C /opt/maven; \
    rm -f /tmp/maven.tar.gz

ARG NVM_VERSION=v0.40.4
RUN set -eux; \
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash; \
    bash -c 'set -e; source "$NVM_DIR/nvm.sh"; \
        for major in ${NODE_MAJOR_VERSIONS}; do nvm install "${major}"; done; \
        nvm alias default ${NODE_DEFAULT}; \
        nvm use default; \
        npm install -g yarn' \
    && rm -rf /root/.npm/_cacache

RUN bash <<'NODEBIN'
set -eo pipefail
. "${NVM_DIR}/nvm.sh"
nvm use default >/dev/null
for x in node npm npx yarn; do
    ln -sfn "$(command -v "${x}")" "/usr/local/bin/${x}"
done
NODEBIN

COPY test.sh /root/test.sh
RUN chmod +x /root/test.sh

# 构建结束前：切换各 JDK / Node 并校验运维工具，失败则镜像构建失败
RUN /root/test.sh

WORKDIR /root
