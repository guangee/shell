FROM openjdk:11.0.16-jre-slim-buster
# 修改docker时间为东八区
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改镜像源为阿里云
RUN echo "deb https://mirrors.aliyun.com/debian buster main" > /etc/apt/sources.list
RUN echo "deb https://mirrors.aliyun.com/debian buster-updates main" >> /etc/apt/sources.list

RUN apt update && apt install curl vim figlet iputils-ping procps -y
# 修改欢迎命令
COPY .bashrc /root/.bashrc
