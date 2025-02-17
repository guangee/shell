FROM ubuntu:22.04
USER root

ENV LANG                            C.UTF-8

RUN DEBIAN_FRONTEND=noninteractive
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改欢迎命令
COPY .bashrc /root/.bashrc
RUN apt update && apt upgrade -y \
    && apt install -y wget unzip curl jq tzdata gettext net-tools tree iputils-ping
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc && chmod +x mc && mv mc /usr/bin/
RUN wget https://github.com/mikefarah/yq/releases/download/v4.16.2/yq_linux_amd64 && chmod +x yq_linux_amd64 && mv yq_linux_amd64 /usr/bin/yq
ADD sources.list /etc/apt/sources.list
CMD /usr/bin/ping 172.17.0.1