FROM php:7.4-apache

USER root

WORKDIR /var/www/html

RUN apt update && apt install -y curl \
    libpng-dev \
    zlib1g-dev \
    libxml2-dev \
    libzip-dev \
    libonig-dev \
    zip \
    curl \
    unzip \
    gcc \
    make \
    autoconf \
    libc-dev \
    pkg-config \
    libssh2-1-dev \
    iputils-ping \
    && yes '' | pecl install ssh2-beta \
    && pecl install redis redis-tools && docker-php-ext-enable redis \
    #&& docker-php-ext-install pdo pdo_mysql
    && docker-php-ext-configure gd \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install xml \
    && docker-php-ext-install zip \
    && docker-php-source delete

#COPY ./vhost.conf /etc/apache2/sites-available/000-default.conf

RUN chown -R $USER:$USER /var/www/html/
RUN chmod -R 777 /var/www/html/
RUN a2enmod rewrite

RUN echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
RUN cat /var/www/html/phpinfo.php

RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 750M/g' /usr/local/etc/php/php.ini && \
    sed -i 's/post_max_size = 8M/post_max_size = 750M/g' /usr/local/etc/php/php.ini && \
    sed -i 's/memory_limit = 128M/memory_limit = 1000M/g' /usr/local/etc/php/php.ini && \
    sed -i 's/max_execution_time = 30/max_execution_time = 5000/g' /usr/local/etc/php/php.ini && \
    sed -i 's/;max_input_vars = 1000/max_input_vars = 5000/g' /usr/local/etc/php/php.ini && \
    sed -i 's/;realpath_cache_size = 4096k/realpath_cache_size = 4096k/g' /usr/local/etc/php/php.ini && \
    sed -i 's/;realpath_cache_ttl = 120/realpath_cache_ttl = 120/g' /usr/local/etc/php/php.ini && \
    sed -i 's/max_input_time = 60/max_input_time = 5000/g' /usr/local/etc/php/php.ini

RUN service apache2 restart
