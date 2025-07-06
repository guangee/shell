FROM jc21/nginx-proxy-manager:2.12.4
ADD pip.conf /etc/pip.conf
RUN pip install --upgrade pip
RUN pip install certbot-dns-aliyun~=0.38.1
RUN apt update && apt install -y wget curl vim
