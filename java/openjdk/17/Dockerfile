FROM openjdk:17-jdk-slim-buster
# 修改docker时间为东八区
RUN echo "Asia/Shanghai" > /etc/timezone
RUN cat /etc/apt/sources.list
# 修改镜像源为阿里云
RUN echo "deb http://mirrors.aliyun.com/debian bullseye main" > /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/debian bullseye-updates main" >> /etc/apt/sources.list