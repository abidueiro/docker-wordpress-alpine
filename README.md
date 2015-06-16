# Wordpress on less than 200MB Docker's image

    REPOSITORY          VIRTUAL SIZE
    vibioh/wordpress    47.04 MB
    vibioh/nginx        17.08 MB
    vibioh/mysql        130.2 MB

## Forewords

All images used in this guide are based on the latest [alpine image](https://registry.hub.docker.com/_/alpine/). A very light (the lightest ?) Linux distributions, shipped with nothing, perfect for making one role image.

## Mysql Docker

In order to run Wordpress, the first thing we need is a database. Wordpress works pretty well with MySql, so we will start a container for it.

### Starting the container for Mysql

The entrypoint of MySql's image allows us to create a database and user with credentials to connect (largely inspired by [MySQL official image](https://github.com/docker-library/mysql) and [Hypriot MySQL image](https://github.com/hypriot/rpi-mysql))

The full Dockerfile is available on my [GitHub account](https://github.com/ViBiOh/docker-mysql/blob/master/Dockerfile).

```bash
docker run -d --name wpmysql -e MYSQL_ROOT_PASSWORD=s3cr3t! -e MYSQL_DATABASE=wordpress -e MYSQL_USER=wordpress -e MYSQL_PASSWORD=W0RDPR3SS! -v /wordpress/mysql-data:/var/lib/mysql vibioh/mysql:latest
```

Some explanations are welcome:

* `-d` option start the container as a *daemon*
* `--name wpmysql` option gives a name to the container. It's especially important in our case. Next, we will link containers and they must be referenced by name
* `-e MYSQL_ROOT_PASSWORD=s3cr3t!` option defines the root's password of MySql (MariaDB) used to initialize database structure
* `-e MYSQL_DATABASE=wordpress` option defines the database's name that will be created when the container starts
* `-e MYSQL_USER=wordpress -e MYSQL_PASSWORD=W0RDPR3SS!` option defines the username with its credentials that will have access to database created
* `-v /wordpress/mysql-data:/var/lib/mysql` option is an important part too. Here we define the place in the host machine where MySql will store its data so that the container can die, your datas are safe.
* We don't use the `-p` to expose port 3306 for allowing external connection by port. The image doesn't contain mysql-client, we don't have the use when all datas are managed by Wordpress.

## Wordpress Docker

The second thing Wordpress needs is a HTTP server, with PHP enabled and zlib to uncompress modules, themes, updates, etc.

### Prerequisite

We will externalize the `wp-content` directory in order to not ship it inside the container. So, first thing to do is to retrieve the standard structure of this directory locally.

> You can skip this step if you don't care, in next steps, don't add the volume to the Wordpress container.

```bash
wget fr.wordpress.org/wordpress-latest-fr_FR.zip
unzip wordpress-latest-fr_FR.zip
rm -rf wordpress-latest-fr_FR.zip
mv ./wordpress/wp-content /wordpress/wp-content
rm -rf ./wordpress
chown -R nobody:nogroup /wordpress/wp-content
```

### Starting the container for Wordpress

```bash
docker run -d --name wordpress --link wpmysql:mysql -e DOMAIN_NAME=blog.vibioh.fr -v /wordpress/wp-content:/var/www/wordpress/wp-content vibioh/wordpress:latest
```

Some explanations are welcome:

* `--link wpmysql:mysql` option is the most interesting one. Our MySql container doesn't expose any port to the outside world and even if, we don't want to manage its IP. So we link the container `wpmysql` to our new container with the name `mysql`. What Docker do is to modify the `/etc/hosts` to match container's ip to the given alias.
* `-e DOMAIN_NAME=blog.vibioh.fr` option define an environment variable for nginx for configuring virtual host (meaningful when container is exposed directly)
* `-v [...]` option defines where the Wordpress content is on the host, like we previously made it for MySql.
* Again, we don't use the `-p` option for allowing external connections to the container with defaut port. We'll use a frontal server.

## Nginx Docker

You can map the Wordpress container directly to the host's port 80 but the interesting thing with Docker is the abilities to run many containers in one physical (or virtual !) machine. So, we choose to put a frontal nginx that will dispatch request based on domain's name. In clear, act as a reverse proxy.

### Configure the nging proxy

Create the file `/wordpress/blog.vibioh.fr.conf`

```
server {
  listen 80;
  server_name blog.vibioh.fr;

  location / {
    proxy_pass http://wordpress;
    proxy_set_header Host            blog.vibioh.fr;
    proxy_set_header X-Forwarded-For $remote_addr;
  }
}
```

### Starting the container for Nginx

```bash
docker run -d -p 80:80 --name nginx --link wordpress:wordpress -v /wordpress/blog.vibioh.fr.conf:/etc/nginx/sites-enabled/blog.vibioh.fr vibioh/nginx:latest
```

Some explanations are welcome:

* `-p 80:80` option defines that container's port **80** (second one) will be accessible via the host's public port **80** (first one). This is important for a web server to be accessible to the entire world.

## Configuring Wordpress

Connect to [Wordpress](http://blog.vibioh.fr/) and follow instructions to install Wordpress.

![](./wp_configure.png)

**Congratulations**, you can now browse to [Wordpress admin](http://blog.vibioh.fr/wp-admin/) to start configuring your blog :)

## With docker-compose ?

Starting and linking containers can be tedious and generate a lot of command line. Docker offers the possibility to start multiple related containers with **docker-compose**.

Create a `docker-compose.yml` file and put it all our configuration.

```yml
wpmysql:
  image: vibioh/mysql:latest
  environment:
    - MYSQL_ROOT_PASSWORD=s3cr3t!
    - MYSQL_DATABASE=wordpress
    - MYSQL_USER=wordpress
    - MYSQL_PASSWORD=W0RDPR3SS!
  volumes:
    - /wordpress/mysql-data:/var/lib/mysql
wordpress:
  image: vibioh/wordpress:latest
  environment:
    - DOMAIN_NAME=blog.vibioh.fr
  volumes:
    - /wordpress/wp-content:/var/www/vhosts/localhost/www/wp-content
  links:
    - wpmysql:mysql
nginx:
  image: vibioh/nginx:latest
  volumes:
    - /wordpress/blog.vibioh.fr.conf:/etc/nginx/sites-enabled/blog.vibioh.fr
  ports:
    - "80:80"
  links:
    - wordpress
```

## On an `armhf` infrastructure

This tutorial has been executed on a standard architecture (x68/x64) architecture. You can run it on an ARM infrastructure (e.g. a Raspberry Pi2 running [HypriotOS](http://blog.hypriot.com)).

To do that, you have to build your own ARM images from the same Dockerfile used for building standard images. The only thing that change is the base `alpine` image, an ARM one. All behave the same way if you don't forget to add the `-arm` to every image's name.

### Create a MySql image

```bash
git clone https://github.com/ViBiOh/docker-mysql.git
cd docker-mysql
sed -i "s/alpine/vibioh\/alpine-arm/" Dockerfile
docker build -t vibioh/mysql-arm --rm .
```

### Create a nginx image

```bash
git clone https://github.com/ViBiOh/docker-nginx.git
cd docker-nginx
sed -i "s/alpine/vibioh\/alpine-arm/" Dockerfile
docker build -t vibioh/nginx-arm --rm .
```

### Create a Wordpress image

```bash
git clone https://github.com/ViBiOh/docker-wordpress.git
cd docker-wordpress
sed -i "s/vibioh\/nginx/vibioh\/nginx-arm/" Dockerfile
docker build -t vibioh/wordpress-arm --rm .
```