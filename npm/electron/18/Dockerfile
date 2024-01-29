FROM node:18
RUN apt update && apt install gettext -y
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改欢迎命令
COPY .bashrc /root/.bashrc
RUN apt-get update && apt-get install -y electron-packager tree
RUN apt-get install -y wine
RUN apt-get install -y wine32
RUN apt-get install -y wine64
