FROM node:16
# 修改镜像源为阿里云
RUN echo "deb https://mirrors.aliyun.com/debian buster main" > /etc/apt/sources.list
RUN echo "deb https://mirrors.aliyun.com/debian buster-updates main" >> /etc/apt/sources.list

RUN echo "deb-src https://mirrors.aliyun.com/debian stretch main" >> /etc/apt/sources.list
RUN echo "deb-src https://mirrors.aliyun.com/debian stretch-updates main" >> /etc/apt/sources.list


RUN apt update && apt install gettext -y
