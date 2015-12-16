#!/bin/sh

CONTAINER_PREFIX=${1:-wordpress}
BACKUP_DIR=${2:-`realpath ./`}
BACKUP_SUFFIX=${3:-backup}

echo Restoring ${CONTAINER_PREFIX} containers from ${BACKUP_DIR} with ${BACKUP_SUFFIX}

docker stop ${CONTAINER_PREFIX}_mysql

docker run --rm \
  -v ${BACKUP_DIR}:/usr/src \
  --volumes-from ${CONTAINER_PREFIX}_data \
  alpine:latest \
  tar xvf /usr/src/${CONTAINER_PREFIX}_${BACKUP_SUFFIX}_mysql.tar -C /var/lib/mysql

docker run --rm \
  -v ${BACKUP_DIR}:/usr/src \
  --volumes-from ${CONTAINER_PREFIX}_data \
  alpine:latest \
  tar xvf /usr/src/${CONTAINER_PREFIX}_${BACKUP_SUFFIX}_www.tar -C /var/www/localhost

docker start ${CONTAINER_PREFIX}_data ${CONTAINER_PREFIX}_mysql

