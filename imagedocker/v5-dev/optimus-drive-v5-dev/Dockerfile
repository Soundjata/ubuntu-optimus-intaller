FROM php:7.4-fpm-alpine

RUN apk --no-cache add shadow git tzdata zip libreoffice
RUN apk --no-cache add font-liberation font-liberation-sans-narrow
RUN docker-php-ext-install pdo_mysql pcntl

RUN mkdir -p /srv/api/libs
RUN mkdir -p /srv/files
RUN mkdir -p /srv/sabredav
RUN usermod --uid 219 www-data && groupmod --gid 219 www-data

WORKDIR /srv/sabredav
COPY ./optimus-drive /srv
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --quiet --no-interaction --no-dev
RUN composer update --quiet --no-interaction --no-dev

COPY ./optimus-drive/php.ini /usr/local/etc/php/conf.d

COPY ./optimus-libs/init.php /srv/init.php

COPY \
	./optimus-libs/datatables.php \
	./optimus-libs/functions.php \
	./optimus-libs/JWT.php \
	./optimus-libs/ovh.php \
	./optimus-libs/websocket_client.php \
	/srv/api/libs/

ENTRYPOINT ["php", "/srv/init.php"]