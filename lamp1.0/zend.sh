#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================
#   SYSTEM REQUIRED:  CentOS-5 (32bit/64bit)¡¢CentOS-6 (32bit/64bit)
#   DESCRIPTION:  ZendOptimizer for LAMP
#===============================================================================
#if php version is php5.3
phpv=`/usr/local/php/bin/php -v`
if echo $phpv | grep -q "5.3.*";then
echo "Your PHP version is php5.3.x,it isn't supported by ZendOptimizer!"
exit
fi
# Check if user is root
if [ $(id -u) != "0" ]; then
    quit "You must be root to run this script!"
fi
cur_dir=`pwd`
[ ! -d $cur_dir/untar ] && mkdir $cur_dir/untar
#download ZendOptimizer
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	if [ -s ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz ]; then
  echo "ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz [found]"
  else
  echo "ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz not found!!!download now......"
 if ! wget --tries=3 http://teddysun.googlecode.com/files/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz;then
 echo "Failed to download ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz,please download it to "$cur_dir" directory manually and rerun the install script."
 exit 0
 fi
fi
	tar xzf ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz -C $cur_dir/untar
else
	if [ -s ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz ]; then
  echo "ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz [found]"
  else
  echo "ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz not found!!!download now......"
 if ! wget --tries=3 http://teddysun.googlecode.com/files/ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz;then
 echo "Failed to download ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz,please download it to "$cur_dir" directory manually and rerun the install script."
 exit 0
 fi
fi
	tar xzf ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz -C $cur_dir/untar/
fi
#install ZendOptimizer
echo "============================ZendOptimizer install============================================"
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	cd $cur_dir/untar/ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/5_2_x_comp/
	mkdir -p /usr/local/Zend/lib/
	\cp ZendOptimizer.so /usr/local/Zend/lib
else
	cd $cur_dir/untar/ZendOptimizer-3.3.9-linux-glibc23-i386/data/5_2_x_comp/
	mkdir -p /usr/local/Zend/lib/
	\cp ZendOptimizer.so /usr/local/Zend/lib
fi
\cp $cur_dir/conf/zend.ini /usr/local/php/php.d/zend.ini
service httpd restart
echo "============================ZendOptimizer install completed============================================"
