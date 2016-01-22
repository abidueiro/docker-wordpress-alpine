#!/bin/sh

if [ "${#}" -eq 0 ]; then
  echo Usage: backup.sh [name] [suffix] [directory]
  exit
fi

CONTAINER_NAME=${1:-wordpress}
BACKUP_SUFFIX=${2:-backup}
BACKUP_DIR=${3:-`realpath ./`}

MYSQL_DIR=/var/lib/mysql
WWW_DIR=/var/www/localhost

echo Backuping ${CONTAINER_NAME} containers into ${BACKUP_DIR} with ${BACKUP_SUFFIX}

docker run --rm \
  -v ${BACKUP_DIR}:/usr/src \
  --volumes-from ${DATA_CONTAINER} \
  alpine:latest \
  sh -c 'tar cf /tmp/mysql.tar -C '${MYSQL_DIR}' --exclude mysqld.sock --exclude *.pid . \
  && tar cf /tmp/www.tar -C '${WWW_DIR}' . \
  && tar czf /usr/src/'${CONTAINER_NAME}'_'${BACKUP_SUFFIX}'.tar.gz -C /tmp mysql.tar www.tar'
