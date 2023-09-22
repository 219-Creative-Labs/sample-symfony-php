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

FROM europe-west4-docker.pkg.dev/spain-iac-common-7epn/spain-base-images/php:8.1.22-20230828_142922 as app

WORKDIR /var/www/html

COPY templates templates
COPY public public
COPY bin bin
COPY src src

COPY --from=bootstrap-composer /app/ .

COPY --from=bootstrap-composer /usr/bin/composer /usr/bin/composer

CMD ["symfony","server:start","--port=8080"]

# USER www-data