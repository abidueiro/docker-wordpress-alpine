#! /bin/sh

sed -i -E "s/\/var\/www\/vhosts\/mysite.mydomain.com\/www/\/var\/www\/wordpress/" /etc/nginx/sites-available/domain.conf

/nginx-entrypoint.sh