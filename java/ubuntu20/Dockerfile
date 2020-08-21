FROM ubuntu:20.04
RUN echo "Asia/Shanghai" > /etc/timezone
USER root
ADD sources.list /etc/apt/sources.list

RUN apt update && apt install -y apt-transport-https curl
RUN apt install gnupg -y
RUN curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
RUN apt update
RUN apt upgrade -y
RUN apt install -y git wget unzip openjdk-8-jdk-headless
RUN apt install -y kubectl
RUN kubectl get pods
