FROM openjdk:11.0.15-jre-slim-buster
# 修改docker时间为东八区
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改镜像源为阿里云
RUN echo "deb https://mirrors.aliyun.com/debian buster main" > /etc/apt/sources.list
RUN echo "deb https://mirrors.aliyun.com/debian buster-updates main" >> /etc/apt/sources.list

ADD elastic-apm-agent-1.32.0.jar /elastic-apm-agent.jar
