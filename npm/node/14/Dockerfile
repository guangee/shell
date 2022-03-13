FROM node:14
RUN echo 'hi'
RUN cat /etc/apt/sources.list
# 修改镜像源为阿里云
RUN echo "deb https://mirrors.aliyun.com/debian stretch main" > /etc/apt/sources.list
RUN echo "deb https://mirrors.aliyun.com/debian stretch-updates main" >> /etc/apt/sources.list

RUN echo "deb-src https://mirrors.aliyun.com/debian stretch main" >> /etc/apt/sources.list
RUN echo "deb-src https://mirrors.aliyun.com/debian stretch-updates main" >> /etc/apt/sources.list


RUN apt update && apt install gettext -y
#RUN apt install -y build-essential fakeroot dpkg-dev libcurl4-openssl-dev
#RUN apt source git
#RUN ls
#mkdir ~/git-openssl
#cd ~/git-openssl

