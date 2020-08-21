FROM ubuntu:20.04
RUN echo "Asia/Shanghai" > /etc/timezone
USER root
ADD sources.list /etc/apt/sources.list

RUN apt update && apt install -y apt-transport-https curl
RUN curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
ADD k8s.list /etc/apt/sources.list.d/k8s.list

RUN apt update
RUN apt upgrade -y
RUN apt install git -y
RUN apt install wget unzip -y
RUN apt install openjdk-8-jdk-headless -y
