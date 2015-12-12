#!/bin/sh

WORDPRESS_NAME=${1:-wordpress}
BACKUP_DIR=${2:-`realpath ./`}

echo Backuping ${WORDPRESS_NAME} Wordpress data container into ${BACKUP_DIR}

docker run -d \
  -name ${WORDPRESS_NAME}_backup \
  -v ${BACKUP_DIR}:/usr/src \
  --volumes-from ${WORDPRESS_NAME}_volumes \
  -w /usr/src \
  alpine:latest \
  tar cvf ${WORDPRESS_NAME}_backup.tar /var/lib/mysql /var/www/localhost
