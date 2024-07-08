FROM nginx:latest
RUN apt update -y && apt install -y vim curl inetutils-ping
# 修改欢迎命令
COPY .bashrc /root/.bashrc
