FROM redis:7.4.1
RUN apt update && apt upgrade -y
RUN apt install wget curl net-tools -y
COPY .bashrc /root/.bashrc
ADD  ./iredis.tar.gz /usr/bin/
RUN chmod 777 /usr/bin/iredis
