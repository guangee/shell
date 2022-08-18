FROM maven:3.8.6-openjdk-8
RUN cat /etc/apt/sources.list
# 修改镜像源为阿里云
RUN echo "deb http://mirrors.aliyun.com/debian bullseye main" > /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/debian bullseye-updates main" >> /etc/apt/sources.list

RUN apt update && apt install curl vim figlet iputils-ping procps net-tools less -y
# 修改欢迎命令
COPY .bashrc /root/.bashrc
