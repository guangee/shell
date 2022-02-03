FROM centos:7.9.2009
RUN echo "Asia/Shanghai" > /etc/timezone
#RUN cat /etc/apt/sources.list
ENV DEBIAN_FRONTEND=noninteractive
# 修改镜像源为阿里云  # main restricted multiverse universe
#RUN echo "deb http://mirrors.aliyun.com/ubuntu/ jammy main universe" > /etc/apt/sources.list
#RUN echo "deb http://mirrors.aliyun.com/ubuntu/ jammy-updates main universe" >> /etc/apt/sources.list

WORKDIR /book
# 安装node
RUN yum install -y curl wget
ENV NODE_VERSION_NUM                v14.18.1
ENV NODE_VERSION                    node-${NODE_VERSION_NUM}
RUN mkdir -p /opt/node \
    && cd /opt/node \
    && wget https://registry.npmmirror.com/-/binary/node/${NODE_VERSION_NUM}/${NODE_VERSION}-linux-x64.tar.gz \
    && tar -xzvf ${NODE_VERSION}-linux-x64.tar.gz \
    && rm ${NODE_VERSION}-linux-x64.tar.gz

ENV NODE_HOME                       /opt/node/${NODE_VERSION}-linux-x64
ENV PATH                            $PATH:$NODE_HOME/bin
ENV NODE_PATH                       $PATH:$NODE_HOME/lib/node_modules
ENV QTWEBENGINE_DISABLE_SANDBOX     1
RUN npm --version
RUN npm install -g gitbook-cli
RUN sed -i "62,64d" /opt/node/${NODE_VERSION}-linux-x64/lib/node_modules/gitbook-cli/node_modules/npm/node_modules/graceful-fs/polyfills.js
RUN gitbook --version
# RUN yum install -y exiftool
RUN npm install -g yarn
ADD simsun.ttc /usr/share/fonts/truetype/
RUN yum install -y epel-release
RUN yum install -y snapd
# RUN systemctl enable --now snapd.socket
#RUN ln -s /var/lib/snapd/snap /snap
RUN systemctl snap start
RUN snap install calibre --edge
RUN yum install -y calibre
