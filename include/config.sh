# Copyright (C) 2014 - 2017, Teddysun <i@teddysun.com>
# 
# This file is part of the LAMP script.
#
# LAMP is a powerful bash script for the installation of 
# Apache + PHP + MySQL/MariaDB/Percona and so on.
# You can install Apache + PHP + MySQL/MariaDB/Percona in an very easy way.
# Just need to input numbers to choose what you want to install before installation.
# And all things will be done in a few minutes.
#
# Website:  https://lamp.sh
# Github:   https://github.com/teddysun/lamp

load_config(){

#Install location
apache_location=/usr/local/apache
mysql_location=/usr/local/mysql
mariadb_location=/usr/local/mariadb
percona_location=/usr/local/percona
php_location=/usr/local/php
openssl_location=/usr/local/openssl

#Install depends location
depends_prefix=/usr/local

#Web root location
web_root_dir=/data/www/default

#Download root URL
download_root_url="http://dl.lamp.sh/files"

#parallel compile option,1:enable,0:disable
parallel_compile=1

##Software version
#nghttp2
nghttp2_filename="nghttp2-1.22.0"
#openssl
openssl_filename="openssl-1.0.2k"
#apache2.2
apache2_2_filename="httpd-2.2.32"
#apache2.4
apache2_4_filename="httpd-2.4.25"
#mysql5.5
mysql5_5_filename="mysql-5.5.56"
#mysql5.6
mysql5_6_filename="mysql-5.6.36"
#mysql5.7
mysql5_7_filename="mysql-5.7.18"
#mariadb5.5
mariadb5_5_filename="mariadb-5.5.56"
#mariadb10.0
mariadb10_0_filename="mariadb-10.0.31"
#mariadb10.1
mariadb10_1_filename="mariadb-10.1.23"
#percona5.5
percona5_5_filename="Percona-Server-5.5.55-38.8"
#percona5.6
percona5_6_filename="Percona-Server-5.6.36-82.0"
#percona5.7
percona5_7_filename="Percona-Server-5.7.18-14"
#php5.3
php5_3_filename="php-5.3.29"
#php5.4
php5_4_filename="php-5.4.45"
#php5.5
php5_5_filename="php-5.5.38"
#php5.6
php5_6_filename="php-5.6.30"
#php7.0
php7_0_filename="php-7.0.19"
#php7.1
php7_1_filename="php-7.1.5"
#phpMyAdmin
phpmyadmin_filename="phpMyAdmin-4.4.15.10-all-languages"
phpmyadmin_filename2="phpMyAdmin-4.7.0-all-languages"
#opcache
opcache_filename="zendopcache-7.0.5"

#apr
apr_filename="apr-1.5.2"
#apr-util
apr_util_filename="apr-util-1.5.4"
#mhash
mhash_filename="mhash-0.9.9.9"
#libmcrypt
libmcrypt_filename="libmcrypt-2.5.8"
#mcrypt
mcrypt_filename="mcrypt-2.6.8"
#pcre
pcre_filename="pcre-8.40"
#re2c
re2c_filename='re2c-0.16'
#imap
imap_filename='imap-2007f'
#libiconv
libiconv_filename="libiconv-1.15"
#swoole
swoole_filename="swoole-src-2.0.7"
set_hint ${swoole_filename} "php-swoole-2.0.7"
#xcache
xcache_filename="xcache-3.2.0"
#xdebug
xdebug_filename="xdebug-2.5.3"
#ImageMagick
ImageMagick_filename="ImageMagick-7.0.5-5"
php_imagemagick_filename="imagick-3.4.3"
set_hint ${php_imagemagick_filename} "php-${php_imagemagick_filename}"
#GraphicsMagick
GraphicsMagick_filename="GraphicsMagick-1.3.25"
php_graphicsmagick_filename="gmagick-1.1.7RC3"
php_graphicsmagick_filename2="gmagick-2.0.4RC1"
set_hint ${php_graphicsmagick_filename} "php-${php_graphicsmagick_filename}"
set_hint ${php_graphicsmagick_filename2} "php-${php_graphicsmagick_filename2}"
#ionCube
ionCube_filename="ioncube_loaders"
ionCube32_filename="ioncube_loaders_lin_x86"
ionCube64_filename="ioncube_loaders_lin_x86-64"
#ZendGuardLoader
ZendGuardLoader_filename="ZendGuardLoader"
ZendGuardLoader53_32_filename="ZendGuardLoader-php-5.3-linux-glibc23-i386"
ZendGuardLoader53_64_filename="ZendGuardLoader-php-5.3-linux-glibc23-x86_64"
ZendGuardLoader54_32_filename="ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386"
ZendGuardLoader54_64_filename="ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64"
ZendGuardLoader55_32_filename="zend-loader-php5.5-linux-i386"
ZendGuardLoader55_64_filename="zend-loader-php5.5-linux-x86_64"
ZendGuardLoader56_32_filename="zend-loader-php5.6-linux-i386"
ZendGuardLoader56_64_filename="zend-loader-php5.6-linux-x86_64"
#libevent
libevent_filename="libevent-2.0.22-stable"
#memcached
memcached_filename="memcached-1.4.36"
#libmemcached
libmemcached_filename="libmemcached-1.0.18"
#php-memcache
php_memcache_filename="memcache-3.0.8"
#php-memcached
php_memcached_filename="memcached-3.0.3"
set_hint ${php_memcached_filename} "php-${php_memcached_filename}"
#redis
redis_filename="redis-3.2.8"
#php-redis
php_redis_filename="redis-2.2.8"
php_redis_filename2="redis-3.1.2"
set_hint ${php_redis_filename} "php-${php_redis_filename}"
set_hint ${php_redis_filename2} "php-${php_redis_filename2}"
#php-mongodb
php_mongo_filename="mongodb-1.2.8"
set_hint ${php_mongo_filename} "php-${php_mongo_filename}"


#software array setting
apache_arr[0]=${apache2_2_filename}
apache_arr[1]=${apache2_4_filename}
apache_arr[2]="do_not_install"

mysql_arr[0]=${mysql5_5_filename}
mysql_arr[1]=${mysql5_6_filename}
mysql_arr[2]=${mysql5_7_filename}
mysql_arr[3]=${mariadb5_5_filename}
mysql_arr[4]=${mariadb10_0_filename}
mysql_arr[5]=${mariadb10_1_filename}
mysql_arr[6]=${percona5_5_filename}
mysql_arr[7]=${percona5_6_filename}
mysql_arr[8]=${percona5_7_filename}
mysql_arr[9]="do_not_install"

php_arr[0]=${php5_3_filename}
php_arr[1]=${php5_4_filename}
php_arr[2]=${php5_5_filename}
php_arr[3]=${php5_6_filename}
php_arr[4]=${php7_0_filename}
php_arr[5]=${php7_1_filename}
php_arr[6]="do_not_install"

phpmyadmin_arr[0]=${phpmyadmin_filename}
phpmyadmin_arr[1]="do_not_install"

php_modules_arr[0]=${opcache_filename}
php_modules_arr[1]=${ZendGuardLoader_filename}
php_modules_arr[2]=${ionCube_filename}
php_modules_arr[3]=${xcache_filename}
php_modules_arr[4]=${php_imagemagick_filename}
php_modules_arr[5]=${php_graphicsmagick_filename}
php_modules_arr[6]=${php_memcached_filename}
php_modules_arr[7]=${php_redis_filename}
php_modules_arr[8]=${php_mongo_filename}
php_modules_arr[9]=${swoole_filename}
php_modules_arr[10]=${xdebug_filename}
php_modules_arr[11]="do_not_install"

}
