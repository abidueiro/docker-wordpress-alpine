# Wordpress with 57MB Docker's image

[![](https://badge.imagelayers.io/vibioh/wordpress:latest.svg)](https://imagelayers.io/?images=vibioh/wordpress:latest 'Get your own badge on imagelayers.io')

    REPOSITORY                      VIRTUAL SIZE
    vibioh/php                      29.78 MB
    vibioh/wordpress                27.7 MB
    vibioh/mysql                    132.4 MB
    vibioh/maildev                  53.94 MB

## Forewords

All images used in this guide are based on the latest [Alpine image](https://registry.hub.docker.com/_/alpine/). A very light Linux distributions, shipped with nothing, perfect for making one role image.

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

## Mysql Docker

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

To do that, you have to build your own ARM images from the same Dockerfile used for building standard images. The only thing that change is the base `alpine` image, an ARM one. All behave the same way if you don't forget to add the `-arm` to every image's name.

### Create a MySql image

    git clone https://github.com/ViBiOh/docker-mysql.git
    cd docker-mysql
    sed -i "s/alpine/vibioh\/alpine-arm/" Dockerfile
    docker build -t vibioh/mysql-arm --rm .

### Create a nginx image

    git clone https://github.com/ViBiOh/docker-nginx.git
    cd docker-nginx
    sed -i "s/alpine/vibioh\/alpine-arm/" Dockerfile
    docker build -t vibioh/nginx-arm --rm .

### Create a php image

    git clone https://github.com/ViBiOh/docker-php.git
    cd docker-php
    sed -i "s/vibioh\/nginx/vibioh\/nginx-arm/" Dockerfile
    docker build -t vibioh/php-arm --rm .

### Create a Wordpress image

    git clone https://github.com/ViBiOh/docker-wordpress.git
    cd docker-wordpress
    sed -i "s/alpine/vibioh\/alpine-arm/" Dockerfile
    docker build -t vibioh/wordpress-arm --rm .
