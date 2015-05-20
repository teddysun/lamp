#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   SYSTEM REQUIRED:  CentOS / RedHat / Fedora
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

xcacheVer='xcache-3.2.0'

# get PHP version
PHP_VER=$(php -r 'echo PHP_VERSION;' 2>/dev/null | awk -F. '{print $1$2}')
if [ $? -ne 0 -o -z $PHP_VER ]; then
    echo "Error:PHP looks like not installed, please check it and try again."
    exit 1
fi
# get PHP extensions date
if   [ $PHP_VER -eq 53 ]; then
    extDate='20090626'
elif [ $PHP_VER -eq 54 ]; then
    extDate='20100525'
elif [ $PHP_VER -eq 55 ]; then
    extDate='20121212'
elif [ $PHP_VER -eq 56 ]; then
    extDate='20131226'
fi

# download xcache
if [ -s $xcacheVer.tar.gz ]; then
    echo "${xcacheVer}.tar.gz [found]"
else
    echo "${xcacheVer}.tar.gz not found!!!download now......"
    if ! wget -c -t3 http://lamp.teddysun.com/files/${xcacheVer}.tar.gz; then
        echo "Failed to download ${xcacheVer}.tar.gz, please download it to ${cur_dir} directory manually and retry."
        exit 1
    fi
fi

# install xcache
echo "============================Xcache install start====================================="
if [ ! -d $cur_dir/untar/ ]; then
    mkdir -p $cur_dir/untar/
fi
tar xzf $xcacheVer.tar.gz -C $cur_dir/untar/
cd $cur_dir/untar/$xcacheVer
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
extension = /usr/local/php/lib/php/extensions/no-debug-non-zts-${extDate}/xcache.so

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
rm -f $cur_dir/${xcacheVer}.tar.gz
# Restart httpd service
/etc/init.d/httpd restart
echo "============================Xcache install completed================================="
exit
