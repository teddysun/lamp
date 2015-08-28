#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   SYSTEM REQUIRED:  CentOS / RedHat / Fedora
#   DESCRIPTION:  MongoDB extension for LAMP
#   AUTHOR: Teddysun <i@teddysun.com>
#   VISIT:  http://teddysun.com/lamp
#===============================================================================================
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi

cur_dir=`pwd`

mongoVer=$(curl -s http://pecl.php.net/package/mongo | awk -F'>' '/mongo-.+.tgz/{print $3}' | cut -d'<' -f1 | sort -V | tail -1)
if [[ -z $mongoVer ]]; then
    mongoVer="mongo-1.6.6.tgz"
fi
mongoFolder=$(echo $mongoVer | cut -d. -f1-3)

# Get PHP version
PHP_VER=$(php -r 'echo PHP_VERSION;' 2>/dev/null | awk -F. '{print $1$2}')
if [ $? -ne 0 ] || [[ -z $PHP_VER ]]; then
    echo "Error: PHP looks like not installed, please check it and try again."
    exit 1
fi
# Get PHP extensions date
if   [ $PHP_VER -eq 53 ]; then
    extDate='20090626'
elif [ $PHP_VER -eq 54 ]; then
    extDate='20100525'
elif [ $PHP_VER -eq 55 ]; then
    extDate='20121212'
elif [ $PHP_VER -eq 56 ]; then
    extDate='20131226'
fi

# Download mongodb extension
if [ -s $mongoVer ]; then
    echo "${mongoVer} [found]"
else
    echo "${mongoVer} not found!!!download now......"
    if ! wget http://pecl.php.net/get/${mongoVer}; then
        echo "Failed to download ${mongoVer},please download it to ${cur_dir} directory manually and retry."
        exit 1
    fi
fi

# Install mongodb extension
echo "Mongodb extension install start..."
if [ ! -d $cur_dir/untar/ ]; then
    mkdir -p $cur_dir/untar/
fi
tar xzf $mongoVer -C $cur_dir/untar/
cd $cur_dir/untar/$mongoFolder
export PHP_PREFIX="/usr/local/php"
$PHP_PREFIX/bin/phpize
./configure -with-php-config=$PHP_PREFIX/bin/php-config
make && make install
# Create ini file
if [ -s /usr/local/php/lib/php/extensions/no-debug-non-zts-${extDate}/mongo.so ]; then
    if [ ! -f $PHP_PREFIX/php.d/mongo.ini ]; then
        echo "mongodb configuration not found, create it!"
        cat > $PHP_PREFIX/php.d/mongo.ini<<-EOF
[mongodb]
extension = /usr/local/php/lib/php/extensions/no-debug-non-zts-${extDate}/mongo.so
EOF
    fi
else
    echo "Mongodb extension install failed!"
    exit 1
fi
# Clean up
cd $cur_dir
rm -rf $cur_dir/untar/
rm -f $cur_dir/$mongoVer
# Restart httpd service
/etc/init.d/httpd restart
echo "Mongodb extension install completed..."
exit 0
