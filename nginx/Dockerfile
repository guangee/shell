FROM jc21/nginx-proxy-manager:2.12.4
RUN pip install --upgrade pip
RUN pip install certbot-dns-aliyun~=0.38.1
RUN pip install certbot-dns-cloudflare~=4.0.0 and cloudflare~=4.0.*
ADD pip.conf /etc/pip.conf
RUN apt update && apt install -y wget curl vim
