FROM maven:3.8.6-openjdk-8
ENV MAVEN_VERSION 3.8.6

RUN apt update && \
    apt install -y --no-install-recommends curl vim figlet iputils-ping procps net-tools less gettext && \
    rm -rf /var/lib/apt/lists/*
# 修改欢迎命令
COPY .bashrc /root/.bashrc

# 修改docker时间为东八区
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改镜像源为阿里云
RUN echo "deb https://mirrors.aliyun.com/debian bullseye main" > /etc/apt/sources.list
RUN echo "deb https://mirrors.aliyun.com/debian bullseye-updates main" >> /etc/apt/sources.list
