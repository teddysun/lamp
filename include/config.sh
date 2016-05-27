load_config(){

#Install location
apache_location=/usr/local/apache
mysql_location=/usr/local/mysql
mariadb_location=/usr/local/mariadb
php_location=/usr/local/php

#Install depends location
depends_prefix=/usr/local

#Web root location
web_root_dir=/data/www/default

#Download root URL
download_root_url="http://lamp.teddysun.com/files"

#parallel compile option,1:enable,0:disable
parallel_compile=1

##Software version
#apache2.2
apache2_2_filename="httpd-2.2.31"
#apache2.4
apache2_4_filename="httpd-2.4.20"
#mysql5.5
mysql5_5_filename="mysql-5.5.49"
#mysql5.6
mysql5_6_filename="mysql-5.6.30"
#mysql5.7
mysql5_7_filename="mysql-5.7.12"
set_hint ${mysql5_7_filename} "${mysql5_7_filename} (need at least 2GB RAM when building)"
#boost
boost_filename="boost_1_59_0"
#mariadb5.5
mariadb5_5_filename="mariadb-5.5.49"
#mariadb10.0
mariadb10_0_filename="mariadb-10.0.25"
#mariadb10.1
mariadb10_1_filename="mariadb-10.1.14"
#php5.3
php5_3_filename="php-5.3.29"
#php5.4
php5_4_filename="php-5.4.45"
#php5.5
php5_5_filename="php-5.5.36"
#php5.6
php5_6_filename="php-5.6.22"
#php7.0
php7_0_filename="php-7.0.7"
#phpMyAdmin
phpmyadmin_filename="phpMyAdmin-4.4.15.6-all-languages"
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
pcre_filename="pcre-8.37"
#re2c
re2c_filename='re2c-0.13.6'
#libedit
libedit_filename='libedit-20150325-3.1'
#imap
imap_filename='imap-2007f'
#libiconv
libiconv_filename="libiconv-1.14"
#swoole
swoole_filename="swoole-src-swoole-1.8.5-stable"
set_hint ${swoole_filename} "php-swoole-1.8.5"
#xcache
xcache_filename="xcache-3.2.0"
#ImageMagick
ImageMagick_filename="ImageMagick-6.9.3-10"
php_imagemagick_filename="imagick-3.4.2"
set_hint ${php_imagemagick_filename} "php-${php_imagemagick_filename}"
#GraphicsMagick
GraphicsMagick_filename="GraphicsMagick-1.3.23"
php_graphicsmagick_filename="gmagick-1.1.7RC3"
set_hint ${php_graphicsmagick_filename} "php-${php_graphicsmagick_filename}"
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
memcached_filename="memcached-1.4.25"
#libmemcached
libmemcached_filename="libmemcached-1.0.18"
#php-memcache
php_memcache_filename="memcache-3.0.8"
#php-memcached
php_memcached_filename="memcached-2.2.0"
set_hint ${php_memcached_filename} "php-${php_memcached_filename}"
#redis
redis_filename="redis-3.2.0"
#php-redis
php_redis_filename="redis-2.2.7"
set_hint ${php_redis_filename} "php-${php_redis_filename}"
#php-mandodb
php_mongo_filename="mongo-1.6.14"
set_hint ${php_mongo_filename} "php-${php_mongo_filename}"
#ICU
icu_filename="icu4c-4_4_2-src"
#gmp
gmp_filename="gmp-6.1.0"


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
mysql_arr[6]="do_not_install"

php_arr[0]=${php5_3_filename}
php_arr[1]=${php5_4_filename}
php_arr[2]=${php5_5_filename}
php_arr[3]=${php5_6_filename}
php_arr[4]=${php7_0_filename}
php_arr[5]="do_not_install"

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
php_modules_arr[10]="do_not_install"

}
