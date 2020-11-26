FROM ubuntu:20.04
RUN echo "Asia/Shanghai" > /etc/timezone
USER root
ADD sources.list /etc/apt/sources.list
RUN apt update && apt install git zsh openjdk-8-jdk-headless maven -y