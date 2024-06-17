FROM php:7.4-fpm-alpine

RUN apk --no-cache add shadow git tzdata libxml2-dev imap-dev

RUN docker-php-ext-install pdo_mysql pcntl soap imap 

RUN mkdir -p /srv/api/libs \
	&& usermod --uid 219 www-data \
	&& groupmod --gid 219 www-data \
	&& groupadd mailboxes -g 203 \
	&& useradd mailboxes -u 203 -g 203 \
	&& usermod -a -G mailboxes www-data

COPY ./optimus-avocats/php.ini /usr/local/etc/php/conf.d

COPY ./optimus-avocats /srv

COPY ./optimus-libs/init.php /srv/init.php

COPY \
	./optimus-libs/datatables.php \
	./optimus-libs/functions.php \
	./optimus-libs/JWT.php \
	./optimus-libs/websocket_client.php \
	/srv/api/libs/

ENTRYPOINT ["php", "/srv/init.php"]