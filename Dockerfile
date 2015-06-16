FROM vibioh/nginx:latest
MAINTAINER Vincent Boutour <vincent.boutour@gmail.com>

COPY ./wordpress-entrypoint.sh /

ENV WORDPRESS_VERSION 4.2.2

RUN apk --update add php-mysql php-zlib \
 && wget fr.wordpress.org/wordpress-${WORDPRESS_VERSION}-fr_FR.zip \
 && unzip wordpress-${WORDPRESS_VERSION}-fr_FR.zip -d /var/www/ \
 && rm -rf wordpress-${WORDPRESS_VERSION}-fr_FR.zip \
 && chown -R nobody:nogroup /var/www/wordpress \
 && chmod +x /wordpress-entrypoint.sh \
 && rm -rf /var/cache/apk/*

ENTRYPOINT [ "/wordpress-entrypoint.sh" ]