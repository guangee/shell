#FROM registry.cn-beijing.aliyuncs.com/guanweiming/node:12
FROM registry.cn-beijing.aliyuncs.com/guanweiming/nginx-node:1
RUN dpkg --add-architecture i386 && apt-get update && apt-get install wine wine32 -y
RUN apt-get install wine64 -y
RUN npm install electron-packager -g
RUN apt install tree -y
WORKDIR /electron
