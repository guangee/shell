FROM ubuntu:20.04
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改镜像源为阿里云
RUN echo "deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse" > /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt update && apt install -y curl
RUN curl -sL https://deb.nodesource.com/setup_14.x |  bash -
RUN apt install -y nodejs
RUN npm --version
RUN npm install -g gitbook-cli gitbook
RUN gitbook --version
