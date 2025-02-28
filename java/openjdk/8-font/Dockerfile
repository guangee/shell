FROM openjdk:8u342-jre-slim-buster

# 安装必要的软件
RUN apt update && apt install -y fontconfig libfreetype6 curl vim figlet iputils-ping procps net-tools less wget unzip
# 修改欢迎命令
COPY .bashrc /root/.bashrc

# 修改docker时间为东八区
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改镜像源为阿里云
RUN echo "deb https://mirrors.aliyun.com/debian bullseye main" > /etc/apt/sources.list
RUN echo "deb https://mirrors.aliyun.com/debian bullseye-updates main" >> /etc/apt/sources.list
