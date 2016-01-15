#!/bin/sh

if [ "${#}" -eq 0 ]; then
  echo Usage: stop.sh [name]
  exit
fi

CONTAINER_NAME=${1:-test}
DATA_CONTAINER=${2:-${CONTAINER_NAME}_data}
MYSQL_CONTAINER=${3:-${CONTAINER_NAME}_mysql}
MAIL_CONTAINER=${4:-${CONTAINER_NAME}_mail}

docker stop ${CONTAINER_NAME} ${MYSQL_CONTAINER} ${MAIL_CONTAINER} ${DATA_CONTAINER}
