FROM node:14

# 修改镜像源为阿里云
RUN echo "deb https://mirrors.aliyun.com/debian buster main" > /etc/apt/sources.list
RUN echo "deb https://mirrors.aliyun.com/debian buster-updates main" >> /etc/apt/sources.list
RUN apt update && apt install gettext -y
RUN apt install -y build-essential fakeroot dpkg-dev libcurl4-openssl-dev
RUN apt  build-dep git -y
#mkdir ~/git-openssl
#cd ~/git-openssl

