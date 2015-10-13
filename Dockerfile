FROM vibioh/nginx:latest
MAINTAINER Vincent Boutour <vincent.boutour@gmail.com>

COPY ./wordpress-entrypoint.sh /

ENV WORDPRESS_VERSION latest
USER root

RUN apk --update add php-fpm php-mysql php-zlib php-curl openssl \
 && wget fr.wordpress.org/wordpress-${WORDPRESS_VERSION}-fr_FR.zip \
 && unzip wordpress-${WORDPRESS_VERSION}-fr_FR.zip -d /var/www/ \
 && rm -rf wordpress-${WORDPRESS_VERSION}-fr_FR.zip \
 && sed -i "s/\/var\/www\/localhost/\/var\/www\/wordpress/" /etc/nginx/sites-enabled/localhost \
 && chown -R nginx:nogroup /var/www/wordpress \
 && chown -R nginx:nogroup /var/log/ \
 && chmod +x /wordpress-entrypoint.sh \
 && apk del openssl \
 && rm -rf /var/cache/apk/*

COPY ./wordpress.conf /var/www/wordpress/wordpress.conf

VOLUME /var/www/wordpress
VOLUME /var/log

ENTRYPOINT [ "/wordpress-entrypoint.sh" ]
