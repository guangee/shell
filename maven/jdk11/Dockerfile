FROM maven:3.8.4-jdk-11-slim

RUN cat /etc/apt/sources.list
# 修改镜像源为阿里云
RUN echo "deb https://mirrors.aliyun.com/debian buster main" > /etc/apt/sources.list
RUN echo "deb https://mirrors.aliyun.com/debian buster-updates main" >> /etc/apt/sources.list
RUN apt update && apt install gettext -y
