#!/bin/sh

WORDPRESS_NAME=${1:-wordpress}
BACKUP_DIR=${2:-`realpath ./`}

echo Backuping ${WORDPRESS_NAME} Wordpress data container into ${BACKUP_DIR}

docker run -d \
  --name ${WORDPRESS_NAME}_backup \
  -v ${BACKUP_DIR}:/usr/src \
  --volumes-from ${WORDPRESS_NAME}_volumes \
  alpine:latest \
  cd /var/lib/mysql && tar cvf /usr/src/${WORDPRESS_NAME}_backup_mysql.tar . \
  && cd /var/www/localhost && tar cvf /usr/src/${WORDPRESS_NAME}_backup_www.tar .
