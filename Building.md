# Wordpress on an ARM

    HypriotOS: root@black-pearl in ~ $ docker images  
    REPOSITORY             TAG                 VIRTUAL SIZE  
    vibioh/wordpress-arm   latest              23.5 MB  
    vibioh/nginx-arm       latest              15 MB  
    vibioh/alpine-arm      latest              4.303 MB  
    hypriot/rpi-mysql      latest              211.9 MB

## Mysql Docker
```bash
docker run -d --name wp-mysql -e MYSQL_ROOT_PASSWORD=s3cr3t! -v /docker-wordpress/mysql-data:/var/lib/mysql hypriot/rpi-mysql:latest  
docker exec -it wp-mysql mysql --user=root --password=s3cr3t!
```

```sql
CREATE DATABASE wordpress;  
CREATE USER 'wordpress'@'%' IDENTIFIED BY 'W0RDPR3SS!';  
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'%' IDENTIFIED BY 'W0RDPR3SS!';  
FLUSH PRIVILEGES;
quit
```

## Nginx Docker

```bash
git clone https://github.com/ViBiOh/docker-nginx.git
cd docker-nginx
sed -i "s/alpine/vibioh\/alpine-arm/" Dockerfile
docker build -t vibioh/nginx-arm --rm .
``

## Wordpress Docker

```bash
git clone https://github.com/ViBiOh/docker-wordpress.git
cd docker-wordpress
sed -i "s/vibioh:nginx/vibioh:nginx-arm/" Dockerfile
docker build -t vibioh/wordpress-arm --rm .
wget https://fr.wordpress.org/wordpress-4.2.2-fr_FR.tar.gz  
tar xzvf wordpress-4.2.2-fr_FR.tar.gz  
rm -rf wordpress-4.2.2-fr_FR.tar.gz  
chown -R nobody:nogroup wordpress/  
docker run -d -p 8000:80 --name wordpress -v /docker-wordpress/wordpress:/var/www/vhosts/localhost/www --link wp-mysql:mysql vibioh/wordpress-arm:latest
```
## Nginx to dispatch

```bash
apt-get install -y nginx
cd /etc/nginx/sites-available/
cp default localhost
ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/localhost
```

```
server {
  listen 80;
  server_name blog.vibioh.fr;

  location / {
    proxy_pass http://127.0.0.1:8000;
  }
  include /docker-wordpress/wordpress/*.conf;
}
```

```bash
service nginx restart
``

## Configuring Wordpress

`wp-config.php`
```
$_SERVER['HTTP_HOST'] = $_SERVER['HTTP_X_FORWARDED_HOST'];
define('WP_HOME', 'http://blog.vibioh.fr');
define('WP_SITEURL', 'http://blog.vibioh.fr');
```