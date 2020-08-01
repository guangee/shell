FROM node:14.7
ADD source.list /etc/apt/sources.list
RUN apt update
RUN nodejs --version && npm --version
RUN npm install gitbook-cli -g
RUN pwd && cd /var/www/blog && npm install
RUN gitbook init