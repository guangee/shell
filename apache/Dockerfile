FROM ubuntu:18.04
RUN echo "Asia/Shanghai" > /etc/timezone

USER root
RUN apt update
RUN apt install apache2 -y
#RUN service apache2 start
#CMD ["service","apache2","start"]