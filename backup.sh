#!/bin/sh

if [[ ${#} -eq 0 ]]; then
  Usage: backup.sh [name] [suffix] [directory]
fi

CONTAINER_NAME=${1:-wordpress}
BACKUP_SUFFIX=${2:-backup}
BACKUP_DIR=${3:-`realpath ./`}
MYSQL_CONTAINER=${4:-${CONTAINER_NAME}_mysql}
DATA_CONTAINER=${5:-${CONTAINER_NAME}_data}

MYSQL_DIR=/var/lib/mysql
WWW_DIR=/var/www/localhost

echo Backuping ${CONTAINER_NAME} containers into ${BACKUP_DIR} with ${BACKUP_SUFFIX}

docker stop ${MYSQL_CONTAINER}

docker run --rm \
  -v ${BACKUP_DIR}:/usr/src \
  --volumes-from ${DATA_CONTAINER} \
  alpine:latest \
  sh -c 'tar cvf /tmp/mysql.tar -C '${MYSQL_DIR}' --exclude mysqld.sock --exclude *.pid . \
  && tar cvf /tmp/www.tar -C '${WWW_DIR}' . \
  && tar cvzf /usr/src/'${CONTAINER_NAME}'_'${BACKUP_SUFFIX}'.tar.gz -C /tmp mysql.tar www.tar'

docker start ${MYSQL_CONTAINER}

