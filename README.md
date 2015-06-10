# Wordpress on less than 140MB Docker's image

    HypriotOS: root@black-pearl in ~ $ docker images  
    REPOSITORY             VIRTUAL SIZE
    vibioh/wordpress-arm   23.5 MB
    vibioh/nginx-arm       15 MB
    vibioh/mysql-arm       115.1 MB
    vibioh/alpine-arm      4.303 MB

## Mysql Docker

In order to run Wordpress, the first thing we need is a database. Wordpress works pretty well with MySql, so we will start a container for it.

### Starting the container for Mysql

The entrypoint of MySql's image allows us to create a database and user with credentials to connect (largely inspired by [MySQL official image](https://github.com/docker-library/mysql) and [Hypriot MySql image](https://github.com/hypriot/rpi-mysql))

```bash
docker run -d --name wpmysql -e MYSQL_ROOT_PASSWORD=s3cr3t! -e MYSQL_DATABASE=wordpress -e MYSQL_USER=wordpress -e MYSQL_PASSWORD=W0RDPR3SS! -v $(pwd)/wpmysql-data:/var/lib/mysql vibioh/mysql:latest
```

Some explanations are welcome:

* `-d` option start the container as a *daemon*
* `--name wpmysql` option gives a name to the container. It's specially important in our case. Next, we will link containers and they must be referenced by name
* `-e MYSQL_ROOT_PASSWORD=s3cr3t!` option defines the root's password of MySql (MariaDB) used to initialize database structure
* `-e MYSQL_DATABASE=wordpress` option defines the database's name that will be created when the container starts
* `-e MYSQL_USER=wordpress -e MYSQL_PASSWORD=W0RDPR3SS!` option defines the username with its credentials that will have access to database created
* `-v /docker-mysql/wpmysql-data:/var/lib/mysql` option is an important part too. Here we define the place in the host machine where MySql will store its data so that the container can die, your datas are safe.
* We don't use the `-p` to expose port 3306 for allowing external connection by port. The image doesn't contain mysql-client, we don't have the use when all datas are managed by Wordpress.

## Wordpress Docker

The second thing Wordpress needs is a HTTP server, with PHP enabled and zlib to uncompress modules, themes, updates, etc.

### Starting the container for Wordpress

```bash
docker run -d -p 8000:80 --name wordpress -v $(pwd)/wp-content:/var/www/vhosts/localhost/www/wp-content --link wpmysql:mysql vibioh/wordpress:latest
```

Some explanations are welcome:

* `-p 8080:80` option defines that container's port **80** will be accessible via the host's public port **8000**. This is important for a web server to be accessible to the entire world.
* `-v [...]` option defines where the Wordpress source are on the host, like we previously made it for MySql. This also include the `wp-content` directory which contains all your cat gif.
* `--link wpmysql:mysql` option is the most interesting one. Our MySql container doesn't expose any port to the outside world and even if, we don't want to manage its IP. So we link the container `wpmysql` to our new container with the name `mysql`. What Docker do is to modify the `/etc/hosts` to match container's ip to the given alias.

## Nginx Docker

You can map the Wordpress container directly to the host's port 80 but the interesting thing with Docker is the abilities to run many containers in one physical (or virtual !) machine. So, we choose to put a frontal nginx that will dispatch request based on domain's name. In clear, act as a reverse proxy.

### Starting the container for Nginx

```bash
docker run -d -p 80:80 --name nginx --link wordpress:wordpress vibioh/nginx:latest
```

Connect to running container to edit configuration files.

```bash
docker exec -it nginx /bin/sh
```

You're now inside the container. Edit the `/etc/nginx/sites-enabled/localhost` to this:

```
server {
  listen 80;
  server_name blog.vibioh.fr;

  location / {
    proxy_pass http://wordpress:8000;
  }
}
```

Restart the nginx's container

```bash
docker stop nginx
docker start nginx
```

## Configuring Wordpress

Connect to [host-ip]:8000 and follow instructions to install Wordpress.

![](./wp_configure.png)

### Define domain's name in Wordpress

Edit the file `wp-config.php` to configure domain's name in Wordpress.

```php
$_SERVER['HTTP_HOST'] = $_SERVER['HTTP_X_FORWARDED_HOST'];
define('WP_HOME', 'http://blog.vibioh.fr');
define('WP_SITEURL', 'http://blog.vibioh.fr');
```

## With docker-compose ?

Starting and linking containers can be tedious and generate a lot of command line. Docker offers the possibility to script starting of multiple containers with **docker-compose**.

Create a `docker-compose.yml` file and put it all our configuration

```yml
wpmysql:
  image: vibioh/mysql:latest
  environment:
    - MYSQL_ROOT_PASSWORD=s3cr3t!
    - MYSQL_DATABASE=wordpress
    - MYSQL_USER=wordpress
    - MYSQL_PASSWORD=W0RDPR3SS!
  volumes:
    - wpmysql-data:/var/lib/mysql
wordpress:
  image: vibioh/wordpress:latest
  ports:
    - "8000:80"
  volumes:
    - wp-content:/var/www/vhosts/localhost/www/wp-content
  links:
    - wpmysql:mysql
nginx:
  image: vibioh/nginx:latest
  ports:
    - "80:80"
  links:
    - wordpress
```

## On an `armhf` infrastructure

> This tutorial will be executed on an ARM infrastructure (a Raspberry Pi2 running [HypriotOS](http://blog.hypriot.com)). If you want to run it on a standard architecture (i.e. not an armhf), don't do the `sed` commands and remove the `-arm` on image's name.

> The standard images are available on [my Docker Hub](https://hub.docker.com/repos/vibioh/) so you don't need to recreate them.

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

### Installing & configuring the frontal nginx

```bash
apt-get install -y nginx
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/localhost
ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/localhost
```