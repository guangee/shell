FROM ubuntu:18.04
RUN apt update && apt install -y curl
RUN curl -sL https://deb.nodesource.com/setup_14.x |  bash -
RUN apt install -y nodejs
RUN npm --version
RUN npm install -g gitbook-cli
RUN gitbook fetcg 3.0.0