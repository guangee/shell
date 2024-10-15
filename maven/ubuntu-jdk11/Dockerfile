FROM ubuntu:22.04
USER root

ENV LANG                            C.UTF-8

RUN DEBIAN_FRONTEND=noninteractive
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改欢迎命令
COPY .bashrc /root/.bashrc
RUN apt update && apt upgrade -y \
    && apt install -y openjdk-11-jdk-headless wget unzip curl jq tzdata language-pack-zh*
RUN apt install maven -y

ADD sources.list /etc/apt/sources.list
