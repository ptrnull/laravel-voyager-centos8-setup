#!/bin/bash
# Script to automate the installation of laravel and voyager in a CentOS 8
# Author: Pedro Ibáñez

# User to grant access to the files in /var/www/hmtl...
export user=centos
# Dir inside /var/www/html/ (installation dir)
export idir=voyager
yum install httpd php php-curl php-common php-cli php-mysqlnd php-mbstring php-fpm php-xml php-zip php-json unzip policycoreutils-python-utils -y
systemctl enable httpd
firewall-cmd --permanent –add-port=80/tcp
firewall-cmd --permanent –add-port=443/tcp
yum install mariadb-server
systemctl start mariadb
systemctl enable mariadb
mysql_secure_installation
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
#cd /var/www/html
usermod -G apache $user
chmod g+w /var/www/html/
chgrp apache /var/www/html/
chmod -R 755 /var/www/html/$idir/storage/
chown -R apache:apache /var/www/html/$idir/
sed -i  "s+/var/www/html+/var/www/html/$idir/public+g" /etc/httpd/conf/httpd.conf
echo "#############################################"
echo "modify by hand the /etc/http/conf/httpd.confi to enable mod_rewrite do its job"
echo "and in  the dir of the public folder change the AllowOverride to:"
echo "AllowOverride all"
echo "And comment the line:"
echo "Require all granted"
echo "you got 60 secs..."
sleep 60
echo "#############################################"

systemctl start httpd
semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/html/$idir/storage/logs(/.*)?"
restorecon -Rv "/var/www/html/$idir/storage/logs"
semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/html/$idir/storage/framework/sessions(/.*)?"
restorecon -Rv "/var/www/html/$idir/storage/framework/sessions"
semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/html/$idir/storage/framework/views(/.*)?"
restorecon -Rv "/var/www/html/$idir/storage/framework/views"
semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/html/$idir/storage/framework/cache(/.*)?"
restorecon -Rv "/var/www/html/$idir/storage/framework/cache"
semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/html/$idir/storage/framework/cache/dbata(/.*)?"
restorecon -Rv "/var/www/html/$idir/storage/framework/cache/data"
setsebool -P httpd_can_network_connect=true

echo "Create the laravel DB by hand"
echo "mysql -u root -p"
echo "mysql> CREATE DATABASE laravel;"
echo "mysql> GRANT ALL ON laravel.* to 'laravel'@'localhost' IDENTIFIED BY 'new_password';"
echo "mysql> FLUSH PRIVILEGES;"
echo "mysql> quit"
read -p "press any key to continue...."

echo "edit the laravel environment: vim .env"
echo "modify your DB data"
echo "DB_CONNECTION=mysql"
echo "DB_HOST=127.0.0.1"
echo "DB_PORT=3306"
echo "DB_DATABASE=laravel"
echo "DB_USERNAME=laravel"
echo "DB_PASSWORD=new_password"
read -p "press any key to continue...."

cd /var/www/html/$idir/
chmod g+w /var/www/html/voyager/storage/logs/laravel.log
chmod g+w /var/www/html/voyager/bootstrap/cache
chmod g+w /var/www/html/voyager/storage/app/public/
composer require tcg/voyager
php artisan voyager:install --with-dummy

