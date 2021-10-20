FROM openjdk:8u302-jre
# 修改docker时间为东八区
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改镜像源为阿里云
RUN echo "deb http://mirrors.aliyun.com/debian bullseye main" > /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/debian bullseye-updates main" >> /etc/apt/sources.list