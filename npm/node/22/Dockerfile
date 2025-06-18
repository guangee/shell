FROM node:22
RUN apt update && apt install gettext -y
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改欢迎命令
COPY .bashrc /root/.bashrc
