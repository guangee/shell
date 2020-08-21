FROM ubuntu:20.04
RUN echo "Asia/Shanghai" > /etc/timezone

USER root
RUN apt update
RUN apt upgrade -y
RUN apt install git -y
RUN apt install wget unzip -y
RUN apt install openjdk-8-jdk-headless -y
