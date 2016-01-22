#!/bin/sh

if [ "${#}" -eq 0 ]; then
  echo Usage: restore.sh [container] [name] [suffix] [directory]
  exit
fi

DATA_CONTAINER=${1:-wordpress}
BACKUP_NAME=${2:-wordpress}
BACKUP_SUFFIX=${3:-backup}
BACKUP_DIR=${4:-`realpath ./`}

MYSQL_DIR=/var/lib/mysql
WWW_DIR=/var/www/localhost

echo Restoring ${BACKUP_NAME} containers from ${BACKUP_DIR} with ${BACKUP_SUFFIX}

docker run --rm \
  -v ${BACKUP_DIR}:/usr/src \
  --volumes-from ${DATA_CONTAINER} \
  alpine:latest \
  sh -c 'tar xzf /usr/src/'${BACKUP_NAME}'_'${BACKUP_SUFFIX}'.tar.gz -C /tmp \
  && rm -rf '${MYSQL_DIR}'/* '${WWW_DIR}'/* \
  && tar xf /tmp/www.tar -C '${WWW_DIR}' \
  && tar xf /tmp/mysql.tar --exclude mysqld.sock --exclude *.pid -C '${MYSQL_DIR}
