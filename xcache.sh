#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   SYSTEM REQUIRED:  CentOS-5 (32bit/64bit) or CentOS-6 (32bit/64bit)
#   DESCRIPTION:  xcache for LAMP
#===============================================================================================
cur_dir=`pwd`
cd $cur_dir
#download xcache-1.3.2
if [ -s xcache-1.3.2.tar.gz ]; then
  echo "xcache-1.3.2.tar.gz [found]"
  else
  echo "xcache-1.3.2.tar.gz not found!!!download now......"
  if ! wget http://teddysun.googlecode.com/files/xcache-1.3.2.tar.gz;then
    echo "Failed to download xcache-1.3.2.tar.gz,please download it to $cur_dir directory manually and rerun the install script."
 exit 1
 fi
fi

#install xcache
echo "============================xcache install================================================"
mkdir -p $cur_dir/untar/
rm -rf $cur_dir/untar/*
tar xzf xcache-1.3.2.tar.gz -C $cur_dir/untar/
cd $cur_dir/untar/xcache-1.3.2
export PHP_PREFIX="/usr/local/php"
$PHP_PREFIX/bin/phpize
./configure --enable-xcache -with-php-config=$PHP_PREFIX/bin/php-config
make && make install
\cp -f $cur_dir/conf/xcache.ini /usr/local/php/php.d/xcache.ini
service httpd restart
echo "============================xcache install completed======================================"
exit
