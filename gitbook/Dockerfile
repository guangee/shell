FROM ubuntu:16.04
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改镜像源为阿里云  # main restricted multiverse universe
RUN echo "deb http://mirrors.aliyun.com/ubuntu/ xenial main universe" > /etc/apt/sources.list
RUN echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main universe" >> /etc/apt/sources.list

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_VERSION_NUM                v14.20.0
ENV NODE_VERSION                    node-${NODE_VERSION_NUM}
ENV NODE_HOME                       /opt/node/${NODE_VERSION}-linux-x64
ENV PATH                            $PATH:$NODE_HOME/bin
ENV NODE_PATH                       $PATH:$NODE_HOME/lib/node_modules
ENV QTWEBENGINE_DISABLE_SANDBOX     1
ENV PUPPETEER_SKIP_DOWNLOAD         true
ENV LANG                            C.UTF-8
ENV GITBOOK_VERSION                 3.2.3
ENV GITBOOK_CLI_VERSION             2.3.2
# 添加字体
ADD simsun.ttc /usr/share/fonts/truetype/
# 设置工作目录
WORKDIR /book

# 安装npm和yarn
RUN apt update \
    && apt install -y curl wget bzip2 language-pack-zh-hans \
    && apt install -y --no-install-recommends calibre \
    && mkdir -p /opt/node \
    && cd /opt/node \
    && wget https://registry.npmmirror.com/-/binary/node/${NODE_VERSION_NUM}/${NODE_VERSION}-linux-x64.tar.gz \
    && tar -xzvf ${NODE_VERSION}-linux-x64.tar.gz \
    && rm ${NODE_VERSION}-linux-x64.tar.gz \
    && npm install -g yarn

# 安装gitbook
RUN npm install -g gitbook-cli \
    && sed -i "62,64d" /opt/node/${NODE_VERSION}-linux-x64/lib/node_modules/gitbook-cli/node_modules/npm/node_modules/graceful-fs/polyfills.js \
    && gitbook --version

# 安装phantomjs@2.1.1
RUN npm install puppeteer@3.3.0 -g --unsafe-perm \
    && mkdir -p /tmp/phantomjs/ \
    && wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
    && mv phantomjs-2.1.1-linux-x86_64.tar.bz2 /tmp/phantomjs/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
    && npm install -g phantomjs@2.1.1 --unsafe-perm \
    && npm install -g svgexport@0.3.2 --unsafe-perm


# 打印版本号
COPY .bashrc /root/.bashrc
