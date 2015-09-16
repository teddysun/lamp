#!/bin/bash
#=========================================================#
#   System Required:  CentOS / RedHat / Fedora            #
#   Description:  ZendGuardLoader for LAMP                #
#   Author: Teddysun <i@teddysun.com>                     #
#   Visit:  https://lamp.sh                               #
#=========================================================#
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi

cur_dir=`pwd`

# is 64bit or not
function is_64bit(){
    if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
        return 0
    else
        return 1
    fi        
}

# get PHP version
INSTALLED_PHP=$(php -r 'echo PHP_VERSION;' 2>/dev/null | awk -F. '{print $1$2}')
if [ $? -ne 0 ] || [[ -z $INSTALLED_PHP ]]; then
    echo "Error: PHP looks like not installed, please check it and try again."
    exit 1
fi

# get PHP extensions date & ZendGuardLoader version
if   [ $INSTALLED_PHP -eq 53 ]; then
    if is_64bit; then
        zendVer="ZendGuardLoader-php-5.3-linux-glibc23-x86_64"
    else
        zendVer="ZendGuardLoader-php-5.3-linux-glibc23-i386"
    fi
    phpVer='5.3'
    extDate='20090626'
elif [ $INSTALLED_PHP -eq 54 ]; then
    if is_64bit; then
        zendVer="ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64"
    else
        zendVer="ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386"
    fi
    phpVer='5.4'
    extDate='20100525'
elif [ $INSTALLED_PHP -eq 55 ]; then
    if is_64bit; then
        zendVer="zend-loader-php5.5-linux-x86_64"
    else
        zendVer="zend-loader-php5.5-linux-i386"
    fi
    extDate='20121212'
elif [ $INSTALLED_PHP -eq 56 ]; then
    if is_64bit; then
        zendVer="zend-loader-php5.6-linux-x86_64"
    else
        zendVer="zend-loader-php5.6-linux-i386"
    fi
    extDate='20131226'
fi

# Install ZendGuardLoader
echo "ZendGuardLoader install start..."
if [ ! -d $cur_dir/untar/ ]; then
    mkdir -p $cur_dir/untar/
fi
# Download ZendGuardLoader
if [ -s ${zendVer}.tar.gz ]; then
    echo "${zendVer}.tar.gz [found]"
else
    echo "${zendVer}.tar.gz not found!!!download now......"
    if ! wget -c -t3 http://lamp.teddysun.com/files/${zendVer}.tar.gz; then
        echo "Failed to download ${zendVer}.tar.gz, please download it to ${cur_dir} directory manually and retry."
        exit 1
    fi
fi
tar zxf ${zendVer}.tar.gz -C $cur_dir/untar/
if [ $INSTALLED_PHP -eq 53 ] || [ $INSTALLED_PHP -eq 54 ]; then
    mv $cur_dir/untar/${zendVer}/php-${phpVer}.x/ZendGuardLoader.so /usr/local/php/lib/php/extensions/no-debug-non-zts-${extDate}/
else
    mv $cur_dir/untar/${zendVer}/ZendGuardLoader.so /usr/local/php/lib/php/extensions/no-debug-non-zts-${extDate}/
fi

if [ ! -f /usr/local/php/php.d/zend.ini ]; then
    echo "Zend Guard Loader configuration not found, create it!"
    cat > /usr/local/php/php.d/zend.ini<<-EOF
[Zend Guard]
zend_extension = /usr/local/php/lib/php/extensions/no-debug-non-zts-${extDate}/ZendGuardLoader.so

zend_loader.enable = 1
zend_loader.disable_licensing = 0
zend_loader.obfuscation_level_support = 3
zend_loader.license_path =
EOF
fi
# Clean up
cd $cur_dir
rm -rf $cur_dir/untar/
rm -f $cur_dir/${zendVer}.tar.gz
# Restart httpd service
/etc/init.d/httpd restart
echo "ZendGuardLoader install completed..."
exit
