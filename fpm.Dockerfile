FROM php:8.2.8-fpm-bookworm

RUN apt-get update  \
    && apt-get install -y libpcre3-dev git \
    && apt-get clean -y

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN install-php-extensions  \
    gd  \
    xdebug  \
    imagick  \
    gettext  \
    pdo_mysql  \
    sodium  \
    redis  \
    amqp  \
    decimal  \
    apcu
#RUN install-php-extensions memcached
RUN pecl install zephir_parser && echo "extension=zephir_parser.so" > /usr/local/etc/php/conf.d/zephir-parser.ini

ADD https://github.com/zephir-lang/zephir/releases/download/0.17.0/zephir.phar /usr/local/bin/zephir
RUN chmod a+x /usr/local/bin/zephir

RUN echo 'memory_limit = 2G' > /usr/local/etc/php/php.ini \
    && git clone https://github.com/phalcon/cphalcon /root/cphalcon \
    && cd /root/cphalcon  \
    && git checkout tags/v5.2.2 ./  \
    && cd /root/cphalcon  \
    && zephir fullclean  \
    && zephir build  \
    && mv ext/modules/phalcon.so `php-config --extension-dir` \
    && rm -fR /root/cphalcon \
    && echo "extension=phalcon.so" > /usr/local/etc/php/conf.d/phalcon.ini

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
RUN composer global require phalcon/devtools
ENV PATH="${PATH}:/root/.composer/vendor/bin"
