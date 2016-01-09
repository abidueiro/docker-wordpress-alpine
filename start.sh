#!/bin/sh

if [[ ${#} -eq 0 ]]; then
  echo Usage: start.sh [name] [password]
  exit
fi

CONTAINER_NAME=${1:-wordpress}
PASSWORD=${2:-password}
DATA_CONTAINER=${3:-${CONTAINER_NAME}_data}
MYSQL_CONTAINER=${4:-${CONTAINER_NAME}_mysql}
MAIL_CONTAINER=${5:-${CONTAINER_NAME}_mail}

docker run \
  --name ${DATA_CONTAINER} \
  --read-only \
  vibioh/wordpress:latest

docker run -d \
  --name ${MYSQL_CONTAINER} \
  -e MYSQL_ROOT_PASSWORD=s3Cr3T! \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=wordpress \
  -e MYSQL_PASSWORD=${PASSWORD} \
  -l traefik.enable=false \
  --volumes-from ${DATA_CONTAINER} \
  --read-only \
  -m 512M \
  --cpu-shares=512 \
  vibioh/mysql:latest

docker run -d \
  --name ${MAIL_CONTAINER} \
  -l traefik.port=1080 \
  -l traefik.frontend.passHostHeader=true \
  --read-only \
  -m 128M \
  --cpu-shares=128 \
  vibioh/maildev:latest \
  --web-user admin --web-pass ${PASSWORD}

docker run -d \
  --name ${CONTAINER_NAME} \
  --link ${MYSQL_CONTAINER}:db \
  --link ${MAIL_CONTAINER}:smtp \
  -e SMTP_URL=smtp \
  -e SMTP_PORT=1025 \
  -l traefik.port=1080 \
  -l traefik.frontend.passHostHeader=true \
  --volumes-from ${DATA_CONTAINER} \
  -m 256M \
  --cpu-shares=512 \
  vibioh/php:latest
