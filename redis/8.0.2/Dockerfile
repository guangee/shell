FROM redis:8.0.2
RUN apt update && apt upgrade -y
RUN apt install wget curl net-tools -y
COPY .bashrc /root/.bashrc
ADD  ./iredis.tar.gz /usr/bin/
RUN chmod 777 /usr/bin/iredis
