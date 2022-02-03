FROM node:9.11
RUN echo "Asia/Shanghai" > /etc/timezone
RUN cat /etc/apt/sources.list
# 修改镜像源为阿里云
RUN echo "deb http://mirrors.aliyun.com/debian jessie main" > /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/debian jessie-updates main" >> /etc/apt/sources.list

WORKDIR /book

RUN npm --version
RUN apt update && apt install -y calibre
RUN npm install -g gitbook-cli
RUN gitbook --version
