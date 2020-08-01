FROM node:14.7
RUN apt update
RUN nodejs --version && npm --version
RUN npm install gitbook-cli -g
RUN pwd && cd /var/www/blog && npm install
RUN gitbook init