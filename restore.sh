#!/bin/sh

WORDPRESS_NAME=${1:-wordpress}
BACKUP_DIR=${2:-`realpath ./`}

echo Restoring ${WORDPRESS_NAME} Wordpress data container from ${BACKUP_DIR}

docker run -d \
  -name ${WORDPRESS_NAME}_restore \
  -v ${BACKUP_DIR}:/usr/src \
  --volumes-from ${WORDPRESS_NAME}_volumes \
  alpine:latest \
  tar xvf /usr/src/${WORDPRESS_NAME}_backup.tar -C /tmp \
  && cp -r /tmp/var/lib/mysql /var/lib/mysql \
  && cp -r /tmp/var/www/localhost /var/www/localhost
