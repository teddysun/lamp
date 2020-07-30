# Copyright (C) 2013 - 2020 Teddysun <i@teddysun.com>
# 
# This file is part of the LAMP script.
#
# LAMP is a powerful bash script for the installation of 
# Apache + PHP + MySQL/MariaDB and so on.
# You can install Apache + PHP + MySQL/MariaDB in an very easy way.
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
php_location=/usr/local/php
openssl_location=/usr/local/openssl

#Install depends location
depends_prefix=/usr/local

#Web root location
web_root_dir=/data/www/default

#Download root URL
download_root_url="https://dl.lamp.sh/files/"

#parallel compile option,1:enable,0:disable
parallel_compile=1

##Software version
#nghttp2
nghttp2_filename="nghttp2-1.41.0"
nghttp2_filename_url="https://github.com/nghttp2/nghttp2/releases/download/v1.41.0/nghttp2-1.41.0.tar.gz"
#openssl
openssl_filename="openssl-1.1.1g"
openssl_filename_url="https://www.openssl.org/source/openssl-1.1.1g.tar.gz"
#apache2.4
apache2_4_filename="httpd-2.4.43"
apache2_4_filename_url="http://ftp.jaist.ac.jp/pub/apache//httpd/httpd-2.4.43.tar.gz"
#mysql5.6
mysql5_6_filename="mysql-5.6.49"
#mysql5.7
mysql5_7_filename="mysql-5.7.31"
#mysql8.0
mysql8_0_filename="mysql-8.0.21"
#mariadb10.1
mariadb10_1_filename="mariadb-10.1.45"
#mariadb10.2
mariadb10_2_filename="mariadb-10.2.32"
#mariadb10.3
mariadb10_3_filename="mariadb-10.3.23"
#mariadb10.4
mariadb10_4_filename="mariadb-10.4.13"
#mariadb10.5
mariadb10_5_filename="mariadb-10.5.4"
#php5.6
php5_6_filename="php-5.6.40"
php5_6_filename_url="https://www.php.net/distributions/php-5.6.40.tar.gz"
#php7.0
php7_0_filename="php-7.0.33"
php7_0_filename_url="https://www.php.net/distributions/php-7.0.33.tar.gz"
#php7.1
php7_1_filename="php-7.1.33"
php7_1_filename_url="https://www.php.net/distributions/php-7.1.33.tar.gz"
#php7.2
php7_2_filename="php-7.2.32"
php7_2_filename_url="https://www.php.net/distributions/php-7.2.32.tar.gz"
#php7.3
php7_3_filename="php-7.3.20"
php7_3_filename_url="https://www.php.net/distributions/php-7.3.20.tar.gz"
#php7.4
php7_4_filename="php-7.4.8"
php7_4_filename_url="https://www.php.net/distributions/php-7.4.8.tar.gz"
#phpMyAdmin
phpmyadmin_filename="phpMyAdmin-4.9.5-all-languages"
phpmyadmin_filename_url="https://files.phpmyadmin.net/phpMyAdmin/4.9.5/phpMyAdmin-4.9.5-all-languages.tar.gz"
#Adminer
adminer_filename="adminer-4.7.7"
adminer_filename_url="https://github.com/vrana/adminer/releases/download/v4.7.7/adminer-4.7.7.php"
#kodexplorer
kod_version=$(wget --no-check-certificate -qO- https://api.github.com/repos/kalcaddle/kodfile/releases/latest | grep 'tag_name' | cut -d\" -f4)
[ -z "${kod_version}" ] && kod_version="4.35"
kodexplorer_filename="kodfile-${kod_version}"
kodexplorer_filename_url="https://github.com/kalcaddle/kodfile/archive/${kod_version}.tar.gz"
set_hint ${kodexplorer_filename} "kodexplorer-${kod_version}"

#apr
apr_filename="apr-1.7.0"
apr_filename_url="http://ftp.jaist.ac.jp/pub/apache//apr/apr-1.7.0.tar.gz"
#apr-util
apr_util_filename="apr-util-1.6.1"
apr_util_filename_url="http://ftp.jaist.ac.jp/pub/apache//apr/apr-util-1.6.1.tar.gz"
#mod_wsgi
mod_wsgi_filename="mod_wsgi-4.7.1"
mod_wsgi_filename_url="https://github.com/GrahamDumpleton/mod_wsgi/archive/4.7.1.tar.gz"
#mod_jk
mod_jk_filename="tomcat-connectors-1.2.46-src"
mod_jk_filename_url="http://ftp.jaist.ac.jp/pub/apache/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.46-src.tar.gz"
set_hint ${mod_jk_filename} "mod_jk-1.2.46"
#mod_security
mod_security_filename="modsecurity-2.9.3"
mod_security_filename_url="https://github.com/SpiderLabs/ModSecurity/releases/download/v2.9.3/modsecurity-2.9.3.tar.gz"
set_hint ${mod_security_filename} "mod_security-2.9.3"
#mhash
mhash_filename="mhash-0.9.9.9"
mhash_filename_url="https://sourceforge.net/projects/mhash/files/mhash/0.9.9.9/mhash-0.9.9.9.tar.gz/download"
#libmcrypt
libmcrypt_filename="libmcrypt-2.5.8"
libmcrypt_filename_url="https://sourceforge.net/projects/mcrypt/files/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz/download"
#mcrypt
mcrypt_filename="mcrypt-2.6.8"
mcrypt_filename_url="https://sourceforge.net/projects/mcrypt/files/MCrypt/2.6.8/mcrypt-2.6.8.tar.gz/download"
#pcre
pcre_filename="pcre-8.44"
pcre_filename_url="https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz"
#re2c
re2c_filename="re2c-2.0.1"
re2c_filename_url="${download_root_url}/re2c-2.0.1.tar.gz"
#cmake
cmake_filename="cmake-3.18.0"
cmake_filename_url="https://github.com/Kitware/CMake/releases/download/v3.18.0/cmake-3.18.0.tar.gz"
cmake_filename2="cmake-3.18.0-Linux-x86_64"
cmake_filename_url2="https://github.com/Kitware/CMake/releases/download/v3.18.0/cmake-3.18.0-Linux-x86_64.tar.gz"
#libzip
libzip_filename="libzip-1.7.3"
libzip_filename_url="https://libzip.org/download/libzip-1.7.3.tar.gz"
#libiconv
libiconv_filename="libiconv-1.16"
libiconv_filename_url="https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz"
#swoole
swoole_filename="swoole-4.5.2"
swoole_filename_url="https://pecl.php.net/get/swoole-4.5.2.tgz"
#yaf
yaf_filename="yaf-3.2.5"
yaf_filename_url="https://pecl.php.net/get/yaf-3.2.5.tgz"
#xcache
xcache_filename="xcache-3.2.0"
xcache_filename_url="https://xcache.lighttpd.net/pub/Releases/3.2.0/xcache-3.2.0.tar.gz"
#xdebug
xdebug_filename="xdebug-2.5.5"
xdebug_filename_url="https://xdebug.org/files/xdebug-2.5.5.tgz"
xdebug_filename2="xdebug-2.9.6"
xdebug_filename2_url="https://xdebug.org/files/xdebug-2.9.6.tgz"
#ImageMagick
ImageMagick_filename="ImageMagick-7.0.10-24"
ImageMagick_filename_url="https://www.imagemagick.org/download/releases/ImageMagick-7.0.10-24.tar.gz"
php_imagemagick_filename="imagick-3.4.4"
php_imagemagick_filename_url="https://pecl.php.net/get/imagick-3.4.4.tgz"
set_hint ${php_imagemagick_filename} "php-${php_imagemagick_filename}"
#GraphicsMagick
GraphicsMagick_filename="GraphicsMagick-1.3.35"
GraphicsMagick_filename_url="https://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/1.3.35/GraphicsMagick-1.3.35.tar.gz/download"
php_graphicsmagick_filename="gmagick-1.1.7RC3"
php_graphicsmagick_filename_url="https://pecl.php.net/get/gmagick-1.1.7RC3.tgz"
php_graphicsmagick_filename2="gmagick-2.0.5RC1"
php_graphicsmagick_filename2_url="https://pecl.php.net/get/gmagick-2.0.5RC1.tgz"
set_hint ${php_graphicsmagick_filename} "php-${php_graphicsmagick_filename}"
set_hint ${php_graphicsmagick_filename2} "php-${php_graphicsmagick_filename2}"
#ionCube
ionCube_filename="ioncube_loaders"
ionCube32_filename="ioncube_loaders_lin_x86"
ionCube32_filename_url="https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86.tar.gz"
ionCube64_filename="ioncube_loaders_lin_x86-64"
ionCube64_filename_url="https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz"
#libevent
libevent_filename="libevent-2.1.12-stable"
libevent_filename_url="https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz"
#memcached
memcached_filename="memcached-1.6.6"
memcached_filename_url="http://www.memcached.org/files/memcached-1.6.6.tar.gz"
#libmemcached
libmemcached_filename="libmemcached-1.0.18"
libmemcached_filename_url="https://launchpadlibrarian.net/165454254/libmemcached-1.0.18.tar.gz"
#php-memcached
php_memcached_filename="memcached-2.2.0"
php_memcached_filename_url="https://pecl.php.net/get/memcached-2.2.0.tgz"
php_memcached_filename2="memcached-3.1.5"
php_memcached_filename2_url="https://pecl.php.net/get/memcached-3.1.5.tgz"
set_hint ${php_memcached_filename} "php-${php_memcached_filename}"
set_hint ${php_memcached_filename2} "php-${php_memcached_filename2}"
#redis
redis_filename="redis-5.0.8"
redis_filename_url="http://download.redis.io/releases/redis-5.0.8.tar.gz"
#php-redis
php_redis_filename="redis-4.3.0"
php_redis_filename_url="https://pecl.php.net/get/redis-4.3.0.tgz"
php_redis_filename2="redis-5.3.1"
php_redis_filename2_url="https://pecl.php.net/get/redis-5.3.1.tgz"
set_hint ${php_redis_filename} "php-${php_redis_filename}"
set_hint ${php_redis_filename2} "php-${php_redis_filename2}"
#php-mongodb
php_mongo_filename="mongodb-1.7.5"
php_mongo_filename_url="https://pecl.php.net/get/mongodb-1.7.5.tgz"
set_hint ${php_mongo_filename} "php-${php_mongo_filename}"
#php-libsodium
libsodium_filename="libsodium-1.0.18"
libsodium_filename_url="https://download.libsodium.org/libsodium/releases/libsodium-1.0.18.tar.gz"
php_libsodium_filename="libsodium-php-2.0.22"
php_libsodium_filename_url="https://github.com/jedisct1/libsodium-php/archive/2.0.22.tar.gz"
#sqlite3
sqlite3_filename="sqlite-autoconf-3310000"
sqlite3_filename_url="${download_root_url}/sqlite-autoconf-3310000.tar.gz"
#icu4c
icu4c_filename="icu"
icu4c_filename_url="https://github.com/unicode-org/icu/releases/download/release-50-2/icu4c-50_2-src.tgz"
#autoconf
autoconf_filename="autoconf-2.69"
autoconf_filename_url="http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz"

#software array setting
apache_arr=(
${apache2_4_filename}
do_not_install
)

apache_modules_arr=(
${mod_wsgi_filename}
${mod_security_filename}
${mod_jk_filename}
do_not_install
)

mysql_arr=(
${mysql5_6_filename}
${mysql5_7_filename}
${mysql8_0_filename}
${mariadb10_1_filename}
${mariadb10_2_filename}
${mariadb10_3_filename}
${mariadb10_4_filename}
${mariadb10_5_filename}
do_not_install
)

php_arr=(
${php5_6_filename}
${php7_0_filename}
${php7_1_filename}
${php7_2_filename}
${php7_3_filename}
${php7_4_filename}
do_not_install
)

phpmyadmin_arr=(
${phpmyadmin_filename}
${adminer_filename}
do_not_install
)

kodexplorer_arr=(
${kodexplorer_filename}
do_not_install
)

php_modules_arr=(
${ionCube_filename}
${xcache_filename}
${php_imagemagick_filename}
${php_graphicsmagick_filename}
${php_memcached_filename}
${php_redis_filename}
${php_mongo_filename}
${php_libsodium_filename}
${swoole_filename}
${yaf_filename}
${xdebug_filename}
do_not_install
)

}
