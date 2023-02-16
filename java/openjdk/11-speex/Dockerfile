FROM openjdk:11.0.16-jre-slim-buster
RUN apt update && apt install curl vim figlet iputils-ping procps net-tools less libspeex-dev gcc make -y
# 修改欢迎命令
COPY .bashrc /root/.bashrc
ADD speex_lib /speex_lib
WORKDIR /speex_lib
RUN tar -xzvf speex-1.2.0.tar.gz
RUN tar -xzvf speex-lib-master.tar.gz
RUN cd speex-1.2.0 && ./configure && make && make install
RUN cd speex-lib-master  && make && ls ./bin
RUN mv /speex_lib/speex-lib-master/bin/speex_decode  /usr/bin/speex_decode
# 修改docker时间为东八区
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改镜像源为阿里云
RUN echo "deb https://mirrors.aliyun.com/debian buster main" > /etc/apt/sources.list
RUN echo "deb https://mirrors.aliyun.com/debian buster-updates main" >> /etc/apt/sources.list
