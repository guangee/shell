FROM jc21/nginx-proxy-manager:2.15.0
RUN pip install --upgrade pip
RUN pip install certbot-dns-aliyun~=0.38.1
ADD pip.conf /etc/pip.conf
RUN apt update && apt install -y wget curl vim jq

ADD generate-ip-ranges.sh /usr/local/bin/generate-ip-ranges.sh
RUN chmod +x /usr/local/bin/generate-ip-ranges.sh \
	&& /usr/local/bin/generate-ip-ranges.sh

ENV IP_RANGES_FETCH_ENABLED=false
