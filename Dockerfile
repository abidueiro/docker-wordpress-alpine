FROM vibioh/nginx:latest
MAINTAINER Vincent Boutour <vincent.boutour@gmail.com>

RUN apk --update add php-mysql php-zlib \
 && chown -R nobody:nobody /var/www/vhosts/localhost/www \
 && rm -rf /var/cache/apk/*
