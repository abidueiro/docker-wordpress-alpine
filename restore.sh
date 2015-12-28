#!/bin/sh

CONTAINER_NAME=${1:-wordpress}
BACKUP_SUFFIX=${2:-backup}
BACKUP_DIR=${3:-`realpath ./`}
MYSQL_CONTAINER=${4:-${CONTAINER_NAME}_mysql}
DATA_CONTAINER=${5:-${CONTAINER_NAME}_data}

MYSQL_DIR=/var/lib/mysql
WWW_DIR=/var/www/localhost

echo Restoring ${CONTAINER_NAME} containers from ${BACKUP_DIR} with ${BACKUP_SUFFIX}

docker stop ${MYSQL_CONTAINER}

docker run --rm \
  -v ${BACKUP_DIR}:/usr/src \
  --volumes-from ${DATA_CONTAINER} \
  alpine:latest \
  sh -c 'tar xvzf /usr/src/'${CONTAINER_NAME}'_'${BACKUP_SUFFIX}'.tar.gz -C /tmp \
  && rm -rf '${MYSQL_DIR}' '${WWW_DIR}' \
  && tar xvf /tmp/www.tar -C '${WWW_DIR}' \
  && tar xvf /tmp/mysql.tar -C '${MYSQL_DIR}

docker start ${DATA_CONTAINER} ${MYSQL_CONTAINER}

