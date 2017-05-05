FROM php:7.1-fpm

RUN apt-get update && apt-get install -y \
        wget \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt pdo_mysql zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) mysqli \
    && wget --no-check-certificate --progress=bar:force --retry-connrefused -t 5 https://github.com/redis/hiredis/archive/v0.13.3.tar.gz -O /tmp/hiredis.tar.gz \
    && (cd /tmp && tar zxf hiredis.tar.gz && cd /tmp/hiredis-0.13.3 && make && make install && ldconfig && rm -rf /tmp/hiredis*) \
    && (cd /tmp && pecl download swoole-beta && tar zxf swoole-*.tgz && cd swoole* && phpize && ./configure --enable-async-redis --enable-coroutine && make clean && make -j $(nproc) && make install && rm -rf /tmp/swoole*) \
    && pecl install redis \
    && docker-php-ext-enable swoole redis

VOLUME /www
WORKDIR /www
