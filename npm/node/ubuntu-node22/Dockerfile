FROM ubuntu:22.04
USER root

ENV LANG                            C.UTF-8

RUN DEBIAN_FRONTEND=noninteractive
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改欢迎命令
COPY .bashrc /root/.bashrc
RUN apt update && apt upgrade -y \
    && apt install -y wget unzip curl jq tzdata
RUN curl -sL https://deb.nodesource.com/setup_22.x | bash -
RUN apt install -y nodejs
RUN npm install -g yarn
ADD sources.list /etc/apt/sources.list
