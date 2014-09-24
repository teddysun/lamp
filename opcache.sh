#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   SYSTEM REQUIRED:  CentOS / RedHat / Fedora
#   DESCRIPTION:  OPcache for LAMP
#   AUTHOR: Teddysun <i@teddysun.com>
#   VISIT:  http://teddysun.com/lamp
#===============================================================================================
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi

cur_dir=`pwd`
cd $cur_dir

PHP_PREFIX='/usr/local/php'
opcacheVer='zendopcache-7.0.3'
extDate='20121212'

# Create opcache configuration file
function create_ini(){
if [ ! -f $PHP_PREFIX/php.d/opcache.ini ]; then
    echo "OpCache configuration not found, create it!"
    cat > $PHP_PREFIX/php.d/opcache.ini<<-EOF
[OPcache]
zend_extension=/usr/local/php/lib/php/extensions/no-debug-non-zts-${extDate}/opcache.so
opcache.enable_cli=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.save_comments=0
EOF
fi
}

# install opcache
echo "OPcache install start..."
# get PHP version
PHP_VER=$(php -r 'echo PHP_VERSION;' 2>/dev/null | awk -F. '{print $1$2}')
if [ $? -ne 0 -o -z $PHP_VER ]; then
    echo "Error:PHP looks like not installed, please check it and try again."
    exit 1
fi
# get PHP extensions date
if [ $PHP_VER -eq 53 ]; then
    extDate='20090626'
elif [ $PHP_VER -eq 54 ]; then
    extDate='20100525'
elif [ $PHP_VER -eq 55 ]; then
    if [ -s /usr/local/php/lib/php/extensions/no-debug-non-zts-${extDate}/opcache.so ]; then
        echo "opcache.so already exists."
        create_ini
        /etc/init.d/httpd restart
        echo "OPcache install completed..."
        exit 0
    fi
fi

# download opcache
if [ -s $opcacheVer.tgz ]; then
    echo "${opcacheVer}.tgz [found]"
else
    echo "${opcacheVer}.tgz not found!!!download now......"
    if ! wget http://lamp.teddysun.com/files/${opcacheVer}.tgz; then
        echo "Failed to download ${opcacheVer}.tgz,please download it to ${cur_dir} directory manually and try again."
        exit 1
    fi
fi

# install opcache
if [ ! -d $cur_dir/untar/ ]; then
    mkdir -p $cur_dir/untar/
fi
tar xzf $opcacheVer.tgz -C $cur_dir/untar/
cd $cur_dir/untar/$opcacheVer
$PHP_PREFIX/bin/phpize
./configure --with-php-config=$PHP_PREFIX/bin/php-config
make && make install
create_ini

# Clean up
cd $cur_dir
rm -rf $cur_dir/untar/
/etc/init.d/httpd restart
echo "OPcache install completed..."
exit 0
