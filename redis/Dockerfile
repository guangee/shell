FROM redis:7.4.1
RUN apt update && apt upgrade -y
RUN apt install wget curl net-tools -y
COPY .bashrc /root/.bashrc
RUN wget  https://github.com/laixintao/iredis/releases/latest/download/iredis.tar.gz \
     && tar -xzf iredis.tar.gz \
     && ./iredis && mv ./iredis /usr/bin/
