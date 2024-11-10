FROM redis:7.4.1
RUN apt update && apt upgrade -y
RUN apt install wget curl net-tools -y
COPY .bashrc /root/.bashrc
ADD  https://github.com/laixintao/iredis/releases/latest/download/iredis.tar.gz /usr/bin/iredis
