#!/bin/sh

CONTAINER_PREFIX=${1:-wordpress}
BACKUP_DIR=${2:-`realpath ./`}
BACKUP_SUFFIX=${3:-backup}

docker run \
  --name ${CONTAINER_PREFIX}_data \
  --read-only \
  vibioh/wordpress:latest

docker run -d \
  --name ${CONTAINER_PREFIX}_mysql \
  -e MYSQL_ROOT_PASSWORD=s3Cr3T! \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=wordpress \
  -e MYSQL_PASSWORD=${PASSWORD} \
  -l traefik.enable=false \
  --volumes-from ${CONTAINER_PREFIX}_data \
  --read-only \
  -m 512M \
  --cpu-shares=512 \
  vibioh/mysql:latest

docker run -d \
  --name ${CONTAINER_PREFIX}_mail \
  -l traefik.port=1080 \
  -l traefik.frontend.passHostHeader=true \
  --read-only \
  -m 128M \
  --cpu-shares=128 \
  vibioh/maildev:latest \
  --web-user admin --web-pass ${PASSWORD}

docker run -d \
  --name ${CONTAINER_PREFIX} \
  --link ${CONTAINER_PREFIX}_mysql:db \
  --link ${CONTAINER_PREFIX}_mail:smtp \
  -e SMTP_URL=smtp \
  -e SMTP_PORT=1025 \
  -l traefik.port=1080 \
  -l traefik.frontend.passHostHeader=true \
  --volumes-from ${CONTAINER_PREFIX}_data \
  -m 256M \
  --cpu-shares=512 \
  vibioh/php:latest

