FROM composer:2.0 as bootstrap-composer

ARG DEPLOY_ENV

WORKDIR /app

COPY src src
COPY config config
COPY composer.json composer.lock ./

RUN APP_ENV=prod composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist \
    --optimize-autoloader

#----------------------------------------------------

FROM local/php:latest as app

WORKDIR /var/www/html

COPY templates templates
COPY public public
COPY bin bin
COPY src src

COPY --from=bootstrap-composer /app/ .

COPY --from=bootstrap-composer /usr/bin/composer /usr/bin/composer


# USER www-data