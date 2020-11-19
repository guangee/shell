FROM node
RUN dpkg --add-architecture i386 && apt-get update && apt-get install wine wine32 -y
RUN apt-get install wine64 -y
RUN npm install electron-packager -g
WORKDIR /electron
