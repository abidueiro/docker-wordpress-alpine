FROM vibioh/nginx:latest
MAINTAINER Vincent Boutour <vincent.boutour@gmail.com>

COPY ./entrypoint.sh /

ENV WORDPRESS_VERSION latest

USER root
RUN apk --update add php-fpm php-mysql php-zlib php-curl \
 && chown -R nginx:nogroup /var/log/ \
 && chmod +x /entrypoint.sh \
 && rm -rf /var/cache/apk/*

COPY ./php.conf /etc/nginx/conf.d/php.conf

VOLUME /var/log

USER nginx

ENTRYPOINT [ "/wordpress-entrypoint.sh" ]
