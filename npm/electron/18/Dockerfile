FROM node:18
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改欢迎命令
COPY .bashrc /root/.bashrc
RUN apt update && apt install -y tree gettext
RUN apt install -y wine neofetch
