FROM node:18
RUN apt update && apt install gettext -y
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改欢迎命令
COPY .bashrc /root/.bashrc
RUN apt-get update && apt-get install wine wine32 wine64 electron-packager tree -y
