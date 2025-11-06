FROM openjdk:26-ea-17-jdk-slim
RUN apt update && apt install -y curl vim figlet iputils-ping procps net-tools less fontconfig libfreetype6
# 修改欢迎命令
COPY .bashrc /root/.bashrc
# 修改docker时间为东八区
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改镜像源为阿里云
RUN echo "deb https://mirrors.aliyun.com/debian trixie main" > /etc/apt/sources.list
RUN echo "deb https://mirrors.aliyun.com/debian trixie-updates main" >> /etc/apt/sources.list
