#!/bin/sh

WORDPRESS_NAME=${1:-wordpress}
BACKUP_DIR=${2:-`realpath ./`}

echo Restoring ${WORDPRESS_NAME} Wordpress data container from ${BACKUP_DIR}

docker stop ${WORDPRESS_NAME}_mysql

docker run --rm \
  -v ${BACKUP_DIR}:/usr/src \
  --volumes-from ${WORDPRESS_NAME}_volumes \
  alpine:latest \
  tar xvf /usr/src/${WORDPRESS_NAME}_backup_mysql.tar -C /var/lib/mysql

docker run --rm \
  -v ${BACKUP_DIR}:/usr/src \
  --volumes-from ${WORDPRESS_NAME}_volumes \
  alpine:latest \
  tar xvf /usr/src/${WORDPRESS_NAME}_backup_www.tar -C /var/www/localhost

docker start ${WORDPRESS_NAME}_volumes ${WORDPRESS_NAME}_mysql

