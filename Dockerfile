FROM vibioh/nginx:latest
MAINTAINER Vincent Boutour <vincent.boutour@gmail.com>

COPY ./wordpress-entrypoint.sh /

ENV WORDPRESS_VERSION latest

RUN apk --update add php-fpm php-mysql php-zlib \
 && wget fr.wordpress.org/wordpress-${WORDPRESS_VERSION}-fr_FR.zip \
 && unzip wordpress-${WORDPRESS_VERSION}-fr_FR.zip -d /var/www/ \
 && rm -rf wordpress-${WORDPRESS_VERSION}-fr_FR.zip \
 && sed -i "s/\/var\/www\/localhost/\/var\/www\/wordpress/" /etc/nginx/sites-enabled/localhost \
 && chown -R nginx:www-data /var/www/wordpress \
 && chmod +x /wordpress-entrypoint.sh \
 && rm -rf /var/cache/apk/*

COPY ./wordpress.conf /var/www/wordpress/wordpress.conf

VOLUME /var/www/wordpress

ENTRYPOINT [ "/wordpress-entrypoint.sh" ]