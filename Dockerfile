FROM vibioh/nginx:latest
MAINTAINER Vincent Boutour <vincent.boutour@gmail.com>

RUN apk --update add php-mysql php-zlib \
 && wget http://fr.wordpress.org/wordpress-4.2.2-fr_FR.tar.gz -O - | tar xz -C /var/www/vhosts/localhost/ \
 && rm -rf /var/www/vhosts/localhost/www \
 && mv /var/www/vhosts/localhost/wordpress /var/www/vhosts/localhost/www \
 && chown -R nobody:nogroup /var/www/vhosts/localhost/www/ \
 && rm -rf /var/cache/apk/*
