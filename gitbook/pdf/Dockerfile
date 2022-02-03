FROM node:14.11 AS node
RUN echo "Asia/Shanghai" > /etc/timezone
RUN cat /etc/apt/sources.list
# 修改镜像源为阿里云
RUN echo "deb http://mirrors.aliyun.com/debian stretch main" > /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/debian stretch-updates main" >> /etc/apt/sources.list

FROM ubuntu:22.04
RUN echo "Asia/Shanghai" > /etc/timezone
RUN cat /etc/apt/sources.list
ENV DEBIAN_FRONTEND=noninteractive
# 修改镜像源为阿里云  # main restricted multiverse universe
RUN echo "deb http://mirrors.aliyun.com/ubuntu/ jammy main universe" > /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/ubuntu/ jammy-updates main universe" >> /etc/apt/sources.list

WORKDIR /book

RUN apt update
RUN apt install -y node


RUN npm --version
RUN npm install -g gitbook-cli
RUN sed -i "287d" /usr/local/lib/node_modules/gitbook-cli/node_modules/npm/node_modules/graceful-fs/polyfills.js
RUN gitbook --version
RUN apt update
#RUN apt install -y libpython2.7 libpython2.7-stdlib
#RUN apt install -y calibre-bin
#RUN apt install -y calibre
RUN apt install -y exiftool
ADD simsun.ttc /usr/share/fonts/truetype/
