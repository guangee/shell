FROM node:9.11
RUN echo "Asia/Shanghai" > /etc/timezone
RUN cat /etc/apt/sources.list
# 修改镜像源为阿里云
RUN echo "deb https://mirrors.aliyun.com/debian jessie main" > /etc/apt/sources.list
RUN echo "deb https://mirrors.aliyun.com/debian jessie-updates main" >> /etc/apt/sources.list

RUN npm --version
RUN apt update
RUN npm install -g gitbook-cli
RUN gitbook --version
