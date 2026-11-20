# syntax=docker/dockerfile:1
# 基础系统：26.04；若更偏重 LTS 稳态可改为 FROM ubuntu:24.04
FROM ubuntu:26.04
USER root

ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# JDK：SDKMAN broker 上 Oracle 标识目前仅提供 17/21/25/26，故 17 使用 17.0.12-oracle 为默认。
# Java 8/11 在 broker 无 Oracle 包；默认使用 Eclipse Temurin（JDK）。若需 8/11 也为 Oracle，请先在本机构建机
# 「sdk install java <自定义id> <已解压的 Oracle JDK 根目录>」再传入对应 id，例如：
#   docker build --build-arg JAVA_8_SDK_ID=8u401-oracle-local --build-arg JAVA_11_SDK_ID=11.0.25-oracle-local .
ARG JAVA_8_SDK_ID=8.0.492-tem
ARG JAVA_11_SDK_ID=11.0.31-tem
ARG JAVA_17_SDK_ID=17.0.12-oracle
ENV JAVA_8_SDK_ID=${JAVA_8_SDK_ID}
ENV JAVA_11_SDK_ID=${JAVA_11_SDK_ID}
ENV JAVA_17_SDK_ID=${JAVA_17_SDK_ID}

ENV MAVEN_VERSION=3.9.15
ENV MAVEN_HOME=/opt/maven/apache-maven-${MAVEN_VERSION}
ENV NVM_DIR=/root/.nvm
ENV SDKMAN_DIR=/root/.sdkman
ENV JAVA_VERSION=17

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
    && ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

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
    wget -q "https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" -O /tmp/maven.tar.gz; \
    tar -xzf /tmp/maven.tar.gz -C /opt/maven; \
    rm -f /tmp/maven.tar.gz

ARG NVM_VERSION=v0.40.4
RUN set -eux; \
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash; \
    bash -c 'set -e; source "$NVM_DIR/nvm.sh" \
        && nvm install 16 \
        && nvm install 18 \
        && nvm install 20 \
        && nvm install 22 \
        && nvm install 24 \
        && nvm alias default 22 \
        && nvm use default \
        && npm install -g yarn' \
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

# 构建结束前：切换各 JDK / Node 并打印版本，失败则镜像构建失败
RUN /root/test.sh

WORKDIR /root
