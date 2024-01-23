FROM demartis/matlab-runtime:R2021a
RUN apt update && apt install -y curl vim figlet iputils-ping procps net-tools less ffmpeg -y openjdk-11-jdk-headless
# 修改欢迎命令
COPY .bashrc /root/.bashrc
# 修改docker时间为东八区
RUN echo "Asia/Shanghai" > /etc/timezone
