FROM ubuntu:16.04
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改镜像源为阿里云  # main restricted multiverse universe
RUN echo "deb http://mirrors.aliyun.com/ubuntu/ xenial main universe" > /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main universe" >> /etc/apt/sources.list


ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_VERSION_NUM                v14.18.1
ENV NODE_VERSION                    node-${NODE_VERSION_NUM}
ENV NODE_HOME                       /opt/node/${NODE_VERSION}-linux-x64
ENV PATH                            $PATH:$NODE_HOME/bin
ENV NODE_PATH                       $PATH:$NODE_HOME/lib/node_modules
ENV QTWEBENGINE_DISABLE_SANDBOX     1
ENV PUPPETEER_SKIP_DOWNLOAD         true

RUN apt update && apt install -y curl wget exiftool bzip2
RUN apt install -y --no-install-recommends calibre
ADD simsun.ttc /usr/share/fonts/truetype/

RUN mkdir -p /opt/node \
    && cd /opt/node \
    && wget https://registry.npmmirror.com/-/binary/node/${NODE_VERSION_NUM}/${NODE_VERSION}-linux-x64.tar.gz \
    && tar -xzvf ${NODE_VERSION}-linux-x64.tar.gz \
    && rm ${NODE_VERSION}-linux-x64.tar.gz

RUN npm install -g yarn

# 安装gitbook
RUN npm install -g gitbook-cli
RUN sed -i "62,64d" /opt/node/${NODE_VERSION}-linux-x64/lib/node_modules/gitbook-cli/node_modules/npm/node_modules/graceful-fs/polyfills.js
RUN gitbook --version

# 安装phantomjs@2.1.1
RUN npm install puppeteer@3.3.0 -g --unsafe-perm
RUN mkdir -p /tmp/phantomjs/
RUN wget https://files.coding-space.cn/rar/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
    && mv phantomjs-2.1.1-linux-x86_64.tar.bz2 /tmp/phantomjs/phantomjs-2.1.1-linux-x86_64.tar.bz2
RUN npm install -g phantomjs@2.1.1 --unsafe-perm
RUN npm install -g svgexport@0.3.2 --unsafe-perm
# 设置工作目录
WORKDIR /book
ENV LANG C.UTF-8
RUN apt install -y language-pack-zh-hans
