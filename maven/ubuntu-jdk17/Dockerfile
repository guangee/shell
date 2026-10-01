# JDK 17 + mvnd 构建镜像。底子是 Ubuntu 22.04（glibc 2.35），
# 能跑 Runner 挂进来的 docker 客户端（需要 GLIBC_2.34）。
# mvnd 1.0.6 自带 Maven 3.9.16。
FROM ubuntu:22.04
USER root

ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    JAVA_VERSION=17 \
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 \
    MVND_VERSION=1.0.6 \
    MAVEN_VERSION=3.9.16 \
    MVND_HOME=/opt/mvnd \
    MAVEN_HOME=/opt/mvnd/mvn

ENV PATH="${MVND_HOME}/bin:${MAVEN_HOME}/bin:${PATH}"

COPY sources.list /etc/apt/sources.list
COPY .bashrc /root/.bashrc

# 修改docker时间为东八区
RUN echo "Asia/Shanghai" > /etc/timezone \
    && ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
         openjdk-17-jdk-headless \
         ca-certificates \
         curl \
         wget \
         unzip \
         jq \
         tzdata \
         figlet \
         gettext \
         net-tools \
         language-pack-zh-hans \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL "https://mirrors.aliyun.com/apache/maven/mvnd/${MVND_VERSION}/maven-mvnd-${MVND_VERSION}-linux-amd64.tar.gz" -o /tmp/mvnd.tgz \
    && tar -xzf /tmp/mvnd.tgz -C /opt \
    && mv "/opt/maven-mvnd-${MVND_VERSION}-linux-amd64" /opt/mvnd \
    && rm /tmp/mvnd.tgz \
    && java -version \
    && mvnd --version
