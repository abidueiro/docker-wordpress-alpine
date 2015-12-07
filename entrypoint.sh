#!/bin/sh

chown -R nginx:nogroup /var/www/localhost
chown -R mysql:mysql /var/lib/mysql

tail -f /dev/null