FROM ubuntu:18.04
RUN curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
RUN apt install -y nodejs
RUN npm --version
RUN npm install -g gitbook-cli
RUN gitbook install