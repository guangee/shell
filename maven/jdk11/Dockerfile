FROM maven:3.8.1-openjdk-11

RUN cat /etc/apt/sources.list
# 修改镜像源为阿里云
RUN echo "deb http://mirrors.aliyun.com/debian stretch main" > /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/debian stretch-updates main" >> /etc/apt/sources.list
RUN apt update && apt install gettext -y
