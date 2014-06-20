#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   SYSTEM REQUIRED:  CentOS-5 (32bit/64bit) or CentOS-6 (32bit/64bit)
#   DESCRIPTION:  Xcache for LAMP
#   AUTHOR: Teddysun <i@teddysun.com>
#   VISIT:  http://teddysun.com/lamp
#===============================================================================================
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi

cur_dir=`pwd`
cd $cur_dir

clear
echo "#############################################################"
echo "# Xcache for LAMP"
echo "# Intro: http://teddysun.com/lamp"
echo "#"
echo "# Author: Teddysun <i@teddysun.com>"
echo "#"
echo "#############################################################"
echo ""
#download xcache-3.1.0
if [ -s xcache-3.1.0.tar.gz ]; then
  echo "xcache-3.1.0.tar.gz [found]"
else
  echo "xcache-3.1.0.tar.gz not found!!!download now......"
  if ! wget http://lamp.teddysun.com/files/xcache-3.1.0.tar.gz;then
    echo "Failed to download xcache-3.1.0.tar.gz,please download it to $cur_dir directory manually and rerun the install script."
 exit 1
 fi
fi

#install xcache
echo "============================Xcache3.1.0 install start====================================="
if [ ! -d $cur_dir/untar/ ]; then
    mkdir -p $cur_dir/untar/
fi
tar xzf xcache-3.1.0.tar.gz -C $cur_dir/untar/
cd $cur_dir/untar/xcache-3.1.0
export PHP_PREFIX="/usr/local/php"
$PHP_PREFIX/bin/phpize
./configure --enable-xcache -with-php-config=$PHP_PREFIX/bin/php-config
make install
rm -rf /data/www/default/xcache
cp -r htdocs/ /data/www/default/xcache
chown -R apache:apache /data/www/default/xcache
rm -rf /tmp/{pcov,phpcore}
mkdir /tmp/{pcov,phpcore}
chown -R apache:apache /tmp/{pcov,phpcore}
chmod 700 /tmp/{pcov,phpcore}
if [ ! -f $PHP_PREFIX/php.d/xcache.ini ]; then
    echo "Xcache configuration not found, create it!"
    cat > $PHP_PREFIX/php.d/xcache.ini<<-EOF
[xcache-common]
extension = /usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/xcache.so

[xcache.admin]
xcache.admin.enable_auth = On
xcache.admin.user = "admin"
xcache.admin.pass = "e10adc3949ba59abbe56e057f20f883e"

[xcache]
xcache.shm_scheme = "mmap"
xcache.size = 64M
xcache.count = 1
xcache.slots = 8K
xcache.ttl = 3600
xcache.gc_interval = 60
xcache.var_size = 16M
xcache.var_count = 1
xcache.var_slots = 8K
xcache.var_ttl = 3600
xcache.var_maxttl = 0
xcache.var_gc_interval = 300
xcache.readonly_protection = Off
xcache.mmap_path = "/dev/zero"
xcache.coredump_directory = "/tmp/phpcore"
xcache.coredump_type = 0
xcache.disable_on_crash = Off
xcache.experimental = Off
xcache.cacher = On
xcache.stat = On
xcache.optimizer = Off

[xcache.coverager]
xcache.coverager = Off
xcache.coverager_autostart =  On
xcache.coveragedump_directory = "/tmp/pcov"
EOF
fi
# Clean up
cd $cur_dir
rm -rf $cur_dir/untar/
service httpd restart
echo "============================Xcache3.1.0 install completed================================="
exit
