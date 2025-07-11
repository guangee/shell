FROM jc21/nginx-proxy-manager:2.12.6
RUN pip install --upgrade pip
RUN pip install certbot-dns-aliyun~=0.38.1
ADD pip.conf /etc/pip.conf
RUN apt update && apt install -y wget curl vim
