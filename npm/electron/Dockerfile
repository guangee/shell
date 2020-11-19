FROM registry.cn-beijing.aliyuncs.com/guanweiming/node:12
RUN dpkg --add-architecture i386 && apt-get update && apt-get install wine wine32 -y
RUN apt-get install wine64 -y
RUN npm install electron-packager -g
WORKDIR /electron
