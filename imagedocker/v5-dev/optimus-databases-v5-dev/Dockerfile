FROM mariadb:latest

COPY ./optimus-databases/init.sql /docker-entrypoint-initdb.d/init.sql
COPY ./optimus-databases/manifest.json /srv/manifest.json

RUN usermod --uid 221 mysql \
	&& groupmod --gid 221 mysql