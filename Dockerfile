FROM alpine:latest
MAINTAINER Vincent Boutour <vincent.boutour@gmail.com>

LABEL keep=true
ENV MYSQL_DIR=/var/lib/mysql
ENV WWW_DIR=/var/www/localhost

COPY entrypoint.sh /

RUN export WORDPRESS_VERSION=latest \
 && apk --update add openssl \
 && adduser -u 1000 -S -s /sbin/nologin mysql \
 && adduser -u 1001 -S -s /sbin/nologin nginx \
 && addgroup mysql mysql \
 && mkdir -p ${MYSQL_DIR} \
 && chown -R mysql:mysql ${MYSQL_DIR} \
 && wget fr.wordpress.org/wordpress-$WORDPRESS_VERSION-fr_FR.zip \
 && mkdir -p /var/www/ \
 && unzip wordpress-$WORDPRESS_VERSION-fr_FR.zip -d /var/www/ \
 && rm -rf wordpress-$WORDPRESS_VERSION-fr_FR.zip \
 && mv /var/www/wordpress ${WWW_DIR} \
 && chown -R nginx:nogroup ${WWW_DIR} \
 && apk del openssl \
 && chmod +x /entrypoint.sh \
 && rm -rf /var/cache/apk/*

VOLUME ${MYSQL_DIR} ${WWW_DIR} /tmp

ENTRYPOINT [ "/entrypoint.sh" ]