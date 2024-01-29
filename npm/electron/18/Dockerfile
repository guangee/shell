FROM node:18
RUN apt update && apt install gettext -y
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改欢迎命令
COPY .bashrc /root/.bashrc
RUN apt update && apt install -y tree
RUN apt install -y wine
RUN apt install -y wine32
RUN apt install -y wine64
