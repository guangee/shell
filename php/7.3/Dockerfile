FROM php:7.3-fpm
RUN apt update
RUN apt install -y vim net-tools cron git nginx libfreetype6-dev libjpeg62-turbo-dev libpng-dev
RUN rm /etc/nginx/sites-enabled/default
#RUN docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install gd
RUN docker-php-ext-install bcmath
ADD php-ext/phpredis-5.3.7.tar.gz /etc/
RUN mv /etc/phpredis-5.3.7 /etc/phpredis
RUN cd /etc/phpredis && ls && pwd  \
    && phpize  \
    && ./configure  \
    && make  \
    && make install
ADD php-ext/swoole-4.6.6.tgz /etc/
RUN mv /etc/swoole-4.6.6 /etc/swoole
RUN cd /etc/swoole && ls && pwd  \
    && phpize  \
    && ./configure  \
    && make  \
    && make install
RUN docker-php-ext-enable redis
RUN docker-php-ext-enable swoole
RUN docker-php-ext-install pdo_mysql && docker-php-ext-enable pdo_mysql
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
COPY .bashrc /root/.bashrc

# 修改镜像源为阿里云
RUN echo "deb https://mirrors.aliyun.com/debian bullseye main" > /etc/apt/sources.list
RUN echo "deb https://mirrors.aliyun.com/debian bullseye-updates main" >> /etc/apt/sources.list
RUN echo "deb https://mirrors.aliyun.com/debian-security bullseye-updates main" >> /etc/apt/sources.list
