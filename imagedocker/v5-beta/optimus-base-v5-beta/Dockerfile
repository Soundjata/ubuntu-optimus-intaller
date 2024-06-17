FROM php:7.4-fpm-alpine

RUN apk --no-cache add shadow git tzdata
RUN docker-php-ext-install pdo_mysql pcntl

RUN mkdir -p /srv/api/libs \
	&& usermod --uid 219 www-data \
	&& groupmod --gid 219 www-data \
	&& groupadd --gid 220 docker \
	&& usermod -a -G docker www-data

COPY ./optimus-base/php.ini /usr/local/etc/php/conf.d

COPY ./optimus-base /srv

COPY ./optimus-libs/init.php /srv/init.php

COPY \
	./optimus-libs/functions.php \
	./optimus-libs/datatables.php \
	./optimus-libs/docker_socket.php \
	./optimus-libs/JWT.php \
	./optimus-libs/ovh.php \
	./optimus-libs/websocket_client.php \
	./optimus-libs/websocket_server.php \
	/srv/api/libs/

ENTRYPOINT ["php", "/srv/init.php"]