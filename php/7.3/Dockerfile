FROM php:7.3-fpm
ADD sources.list /etc/apt/sources.list
RUN apt update
RUN apt install -y vim net-tools cron git nginx libfreetype6-dev libjpeg62-turbo-dev libpng-dev
RUN rm /etc/nginx/sites-enabled/default
RUN docker-php-ext-install -j$(nproc) gd
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
