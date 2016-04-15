# Wordpress with 60MB Docker's image

[![Build Status](https://travis-ci.org/ViBiOh/docker-wordpress.svg?branch=master)](https://travis-ci.org/ViBiOh/docker-wordpress) [![](https://badge.imagelayers.io/vibioh/wordpress:latest.svg)](https://imagelayers.io/?images=vibioh/wordpress:latest 'Get your own badge on imagelayers.io')

```
REPOSITORY                      VIRTUAL SIZE
vibioh/maildev                  44.78 MB
vibioh/php                      32.38 MB
vibioh/wordpress                27.31 MB
vibioh/mysql                    156 MB
```

## Forewords

All images used in this guide are based on the latest [Alpine image](https://registry.hub.docker.com/_/alpine/). A very light Linux distributions, shipped with nothing, perfect for making one role image.

## Quick start with Docker Compose

Define environment variables `WORDPRESS_NAME`, `MYSQL_PASSWORD`, `WORDPRESS_PASSWORD` and `MAILDEV_PASSWORD` to configure variables interpolations and also `DOMAIN` if you use [Traefik](https://traefik.github.io/).

```bash
docker-compose -p ${WORDPRESS_NAME} up -d
```

## Wordpress Data Docker

Wordpress is written in PHP and is provided as a directory that you simply have to deploy in your web server. This directory also contains the `wp-content` directory, the one that makes your blog very unique. We want to keep this directory in a safe zone, where we can make easy backup. Also, Wordpress stores data in a relational database, commonly MySQL. As the `wp-content` directory, we want to keep datas in a the database in a safe place.

So we'll put all this informations in a data container which the only prupose is to provide a filesystem.

The full Dockerfile is available on my [GitHub account](https://github.com/ViBiOh/docker-wordpress/blob/master/Dockerfile).

```docker
docker run \
  --name wordpress \
  --read-only \
  vibioh/wordpress:latest
```

Some explanations are welcome:

* `--name wordpress` option gives a name to the container. It's especially important in our case. Next, we will link containers and they must be referenced by name
* `--read-only` option define a read-only filesystem. The container is autorized to write data only in places specified in the `Dockerfile`

## MySql Docker

Wordpress works pretty well with MySql, so we will start a container for it.

The entrypoint of MySql's image allows us to create a database and user with credentials to connect (largely inspired by [MySQL official image](https://github.com/docker-library/mysql) and [Hypriot MySQL image](https://github.com/hypriot/rpi-mysql))

The full Dockerfile is available on my [GitHub account](https://github.com/ViBiOh/docker-mysql/blob/master/Dockerfile).

```docker
docker run -d \
  --name mysql \
  -e MYSQL_ROOT_PASSWORD=s3Cr3T! \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=wordpress \
  -e MYSQL_PASSWORD=W0RDPR3SS! \
  --volumes-from wordpress \
  --read-only \
  vibioh/mysql:latest
```

Some explanations are welcome:

* `-d` option start the container as a *daemon*
* `-e MYSQL_ROOT_PASSWORD=s3Cr3T!` option defines the root's password of MySql (MariaDB) used to initialize database structure
* `-e MYSQL_DATABASE=wordpress` option defines the database's name that will be created when the container starts
* `-e MYSQL_USER=wordpress -e MYSQL_PASSWORD=W0RDPR3SS!` option defines the username with its credentials that will have access to database created
* `--volumes-from wordpress` option is an important part too. In the `wordpress` container [Dockerfile](https://github.com/ViBiOh/docker-wordpress/blob/master/Dockerfile#L28), we defined a volume `/var/lib/mysql` and the same in `mysql` container [Dockerfile](https://github.com/ViBiOh/docker-mysql/blob/master/Dockerfile#L18). This option tells Docker to map `mysql`'s volume to the `wordpress`'s one
* We don't use the `-p` to expose port 3306 to external connections (outside of host machine). Only Docker will need access to the container.

## SMTP Server Docker

Wordpress need to send mails to users when account are created or to reset password. We use [MailDev](http://djfarrelly.github.io/MailDev/) for demonstration purpose.

    docker run -d \
      --name maildev \
      --read-only \
      vibioh/maildev:latest \
      --web-user admin --web-pass password

## Wordpress Docker

Wordpress needs is a HTTP server, with PHP enabled and zlib to uncompress modules, themes, updates, etc.

The full Dockerfile is available on my [GitHub account](https://github.com/ViBiOh/docker-php/blob/master/Dockerfile).

    docker run -d \
      --name php \
      --link mysql:db \
      --link mail:smtp \
      -e SMTP_URL=smtp \
      -e SMTP_PORT=1025 \
      --volumes-from wordpress \
      vibioh/php:latest

Some explanations are welcome:

* `--link mysql:db` option is the most interesting one. Our MySql container doesn't expose any port to the outside world and even if, we don't want to manage its IP. So we link the container `mysql` to our new container with the name `db`. What Docker does is to modify the `/etc/hosts` to match container's ip to the given alias.

## Configuring Wordpress

You can now browse to [Wordpress admin](http://docker-IP/) to install and start configuring your blog :)

![](./wp_configure.png)

## On an `armhf` infrastructure

This tutorial has been executed on a standard architecture (x68/x64) architecture. You can run it on an ARM infrastructure (e.g. a Raspberry Pi2 running [HypriotOS](http://blog.hypriot.com)).

All images are based on Alpine, so I have rebuilt all of them using my own Alpine builded on an ARM. Checkout the `arm` branch and run the compose !

N.B. At the time, NodeJS is not working on ARM so maildev was turned of.
