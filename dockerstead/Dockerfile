# DockerStead PHP image. Compose builds this same image definition for every
# supported PHP_VERSION (7.4, 8.0, 8.1, 8.2, 8.3, 8.4 and 8.5).
ARG PHP_VERSION=8.5
FROM php:${PHP_VERSION}-fpm

ARG PHP_VERSION
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS=1

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        git unzip zip libicu-dev libonig-dev libzip-dev \
        libpng-dev libjpeg62-turbo-dev libfreetype6-dev libwebp-dev \
        libpq-dev libsqlite3-dev libxml2-dev libssl-dev; \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp; \
    docker-php-ext-install -j"$(nproc)" \
        bcmath exif gd intl mbstring opcache pcntl pdo_mysql pdo_pgsql \
        sockets xml zip pdo_sqlite; \
    case "${PHP_VERSION}" in \
        7.4) pecl install redis-5.3.7 swoole-4.8.13 ;; \
        8.0) pecl install redis-6.0.2 ;; \
        *) pecl install redis ;; \
    esac; \
    docker-php-ext-enable redis; \
    if [ "${PHP_VERSION}" = "7.4" ]; then docker-php-ext-enable swoole; fi; \
    rm -rf /tmp/pear /var/lib/apt/lists/*

COPY php/conf.d/99-dockerstead.ini /usr/local/etc/php/conf.d/99-dockerstead.ini

WORKDIR /home/vagrant/code
