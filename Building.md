# Wordpress on an ARM

    HypriotOS: root@black-pearl in ~ $ docker images  
    REPOSITORY             TAG                 VIRTUAL SIZE  
    vibioh/wordpress-arm   latest              23.5 MB  
    vibioh/nginx-arm       latest              15 MB  
    vibioh/alpine-arm      latest              4.303 MB  
    hypriot/rpi-mysql      latest              211.9 MB

## Mysql Docker

### Starting the container for Mysql

Note the use of the follow options:
* `-v` for externalizing `mysql-data`. You can destruct the container, datas are stored in the host, not in the container.
* `--name` in order to link the container with the HTTP server, you have to name it.

We don't use the '-p' options for port forwarding, nobody can access to container using `mysql://ip:3306` except linked containers

```bash
docker run -d --name wp-mysql -e MYSQL_ROOT_PASSWORD=s3cr3t! -v /docker-wordpress/mysql-data:/var/lib/mysql hypriot/rpi-mysql:latest
```

### Initializing database

Connect to the MySql client inside the container with the `exec` command.

```bash
docker exec -it wp-mysql mysql --user=root --password=s3cr3t!
```

Execute the following statements once connected. As no use of `-p`, usage of wildcard for connection's origin is safe.

```sql
CREATE DATABASE wordpress;
CREATE USER 'wordpress'@'%' IDENTIFIED BY 'W0RDPR3SS!';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'%' IDENTIFIED BY 'W0RDPR3SS!';
FLUSH PRIVILEGES;
quit
```

## Nginx Docker

If you're on an ARM infrastructure, you need to replace base image with an `armhf`'s compatible image.

```bash
git clone https://github.com/ViBiOh/docker-nginx.git
cd docker-nginx
sed -i "s/alpine/vibioh\/alpine-arm/" Dockerfile
docker build -t vibioh/nginx-arm --rm .
```

## Wordpress Docker

```bash
git clone https://github.com/ViBiOh/docker-wordpress.git
cd docker-wordpress
sed -i "s/vibioh\/nginx/vibioh\/nginx-arm/" Dockerfile
docker build -t vibioh/wordpress-arm --rm .
```

### Downloading & extracting Wordpress

```bash
wget https://fr.wordpress.org/wordpress-4.2.2-fr_FR.tar.gz
tar xzvf wordpress-4.2.2-fr_FR.tar.gz  
rm -rf wordpress-4.2.2-fr_FR.tar.gz  
chown -R nobody:nogroup wordpress/
```

### Starting the container for Wordpress

Note the use of `--link` with pattern `[container-name]:[alias]`. This options modify the `/etc/hosts` file in container to map *container-name*'s ip with given *alias*.

```bash
docker run -d -p 8000:80 --name wordpress -v /docker-wordpress/wordpress:/var/www/vhosts/localhost/www --link wp-mysql:mysql vibioh/wordpress-arm:latest
```

## Nginx to dispatch

We will use nginx as a reverse proxy. It will redirect requests base on domain's name to right port.

```bash
apt-get install -y nginx
cd /etc/nginx/sites-available/
cp default localhost
ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/localhost
```

Edit the /etc/nginx/sites-enabled/localhost to this:

```
server {
  listen 80;
  server_name blog.vibioh.fr;

  location / {
    proxy_pass http://127.0.0.1:8000;
  }
}
```

Restart the nginx's service

```bash
service nginx restart
``

## Configuring Wordpress

Connect to your-ip:8000 and follow the instruction to install Wordpress. We previously have linked wp-mysql container with wordpress container, the alias for it is `mysql`. So, database's url is simply `mysql`.

`wp-config.php`
```
$_SERVER['HTTP_HOST'] = $_SERVER['HTTP_X_FORWARDED_HOST'];
define('WP_HOME', 'http://blog.vibioh.fr');
define('WP_SITEURL', 'http://blog.vibioh.fr');
```