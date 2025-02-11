FROM jc21/nginx-proxy-manager:2.12.3
ADD pip.conf /etc/pip.conf
RUN pip install --upgrade pip
RUN pip install certbot-dns-aliyun~=0.38.1
