FROM alpine:latest
MAINTAINER Vincent Boutour <vincent.boutour@gmail.com>

ENV WORDPRESS_VERSION=latest

RUN apk --update add openssl \
 && addgroup mysql mysql \
 && mkdir -p /var/lib/mysql \
 && chown -R mysql:mysql /var/lib/mysql \
 && adduser -S nginx \
 && wget fr.wordpress.org/wordpress-${WORDPRESS_VERSION}-fr_FR.zip \
 && mkdir -p /var/www/ \
 && unzip wordpress-${WORDPRESS_VERSION}-fr_FR.zip -d /var/www/ \
 && rm -rf wordpress-${WORDPRESS_VERSION}-fr_FR.zip \
 && mv /var/www/wordpress /var/www/localhost \
 && chown -R nginx:nogroup /var/www/localhost \
 && apk del openssl \
 && rm -rf /var/cache/apk/*

VOLUME /var/lib/mysql
VOLUME /var/www/localhost

CMD ["echo", "Data container for Wordpress"]
