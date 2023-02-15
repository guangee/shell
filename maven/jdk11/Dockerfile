FROM maven:3.8.6-openjdk-11
ENV MAVEN_VERSION 3.8.6
RUN cat /etc/apt/sources.list
# 修改镜像源为阿里云
RUN echo "deb https://mirrors.aliyun.com/debian buster main" > /etc/apt/sources.list
RUN echo "deb https://mirrors.aliyun.com/debian buster-updates main" >> /etc/apt/sources.list
RUN apt update && apt install gettext net-tools -y
# 修改欢迎命令
COPY .bashrc /root/.bashrc
