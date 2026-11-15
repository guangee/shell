# OpenJDK 17.0.21 运行/运维底包。底子是 Ubuntu 24.04（Noble）。
FROM ubuntu:24.04
USER root

ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    JAVA_VERSION=17.0.21 \
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 \
    OPENJDK_APT_VERSION=17.0.21.0.3+1-1~24.04.1

ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Ubuntu 24.04 默认使用 DEB822 sources，先清掉再换成阿里云传统 sources.list
RUN rm -f /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/*.sources
COPY sources.list /etc/apt/sources.list
COPY .bashrc /root/.bashrc

RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
         openjdk-17-jdk-headless=${OPENJDK_APT_VERSION} \
         openjdk-17-jre-headless=${OPENJDK_APT_VERSION} \
         ca-certificates \
         curl \
         wget \
         vim \
         figlet \
         iputils-ping \
         procps \
         net-tools \
         less \
         tzdata \
         locales \
         language-pack-zh-hans \
    && locale-gen zh_CN.UTF-8 \
    && update-locale LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8 \
    && rm -rf /var/lib/apt/lists/* \
    && java -version
