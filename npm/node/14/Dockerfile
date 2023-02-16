FROM node:14
RUN apt update && echo 'Yes, do as I say!' | apt install libtinfo5  && apt install -y gettext net-tools
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改镜像源为阿里云
RUN echo "deb https://mirrors.aliyun.com/debian stretch main" > /etc/apt/sources.list
RUN echo "deb https://mirrors.aliyun.com/debian stretch-updates main" >> /etc/apt/sources.list
