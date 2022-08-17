FROM registry.cn-zhangjiakou.aliyuncs.com/guanweiming/openjdk:11.0.16-jre

RUN apt update \
    && apt install ffmpeg -y \
    && ffmpeg -version

RUN echo 'echo -e "\E[1;36mHOSTNAME     \E[1;32m$(ffmpeg -version)\E[0m"' >> /root/.bashrc
