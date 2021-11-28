FROM maven:3.8.3-openjdk-8
RUN cat /etc/apt/sources.list
# 修改镜像源为阿里云
RUN echo "deb http://mirrors.aliyun.com/debian bullseye main" > /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/debian bullseye-updates main" >> /etc/apt/sources.list
ADD settings.xml /root/.m2/settings.xml
RUN apt update && apt install gettext -y