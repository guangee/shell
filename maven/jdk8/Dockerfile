FROM ubuntu:20.04
RUN echo "Asia/Shanghai" > /etc/timezone
USER root
ADD sources.list /etc/apt/sources.list
RUN apt update
RUN apt upgrade -y
RUN apt install -y git wget unzip openjdk-8-jdk-headless gettext maven
