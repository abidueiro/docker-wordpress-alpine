
```bash
docker run -d --name wp-mysql -e MYSQL_ROOT_PASSWORD=s3cr3t! -v /docker-wordpress/mysql-data:/var/lib/mysql hypriot/rpi-mysql:latest  
docker exec -it wp-mysql mysql --user=root --password=s3cr3t!
```

```sql
CREATE DATABASE wordpress;  
CREATE USER 'wordpress'@'%' IDENTIFIED BY 'W0RDPR3SS!';  
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'%' IDENTIFIED BY 'W0RDPR3SS!';  
FLUSH PRIVILEGES;
```

```bash
wget https://fr.wordpress.org/wordpress-4.2.2-fr_FR.tar.gz  
tar xzvf wordpress-4.2.2-fr_FR.tar.gz  
rm -rf wordpress-4.2.2-fr_FR.tar.gz  
chown -R nobody:nogroup wordpress/  
docker run -d -p 8000:80 --name wordpress -v /docker-wordpress/wordpress:/var/www/vhosts/localhost/www --link wp-mysql:mysql vibioh/wordpress-arm:latest
```

`wp-config.php`
```
$_SERVER['HTTP_HOST'] = $_SERVER['HTTP_X_FORWARDED_HOST'];
define('WP_HOME', 'http://blog.vibioh.fr');
define('WP_SITEURL', 'http://blog.vibioh.fr');
```

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
}
```

```bash
service nginx restart
``