#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   SYSTEM REQUIRED:  CentOS-5 (32bit/64bit) or CentOS-6 (32bit/64bit)
#   DESCRIPTION:  ZendGuardLoader for LAMP
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
echo "# ZendGuardLoader for LAMP"
echo "# Intro: http://teddysun.com/lamp"
echo "#"
echo "# Author: Teddysun <i@teddysun.com>"
echo "#"
echo "#############################################################"
echo ""

# Install ZendGuardLoader
echo "============================ZendGuardLoader install start====================================="
if [ ! -d $cur_dir/untar/ ]; then
    mkdir -p $cur_dir/untar/
fi
# Download ZendGuardLoader
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
    if ! wget -c http://lamp.teddysun.com/files/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz;then
        echo "Failed to download ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz, please download it to "$cur_dir" directory manually and rerun the install script."
        exit 1
    fi
    tar zxf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz -C $cur_dir/untar/
    mv $cur_dir/untar/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so /usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/
else
    if ! wget -c http://lamp.teddysun.com/files/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz;then
        echo "Failed to download ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz, please download it to "$cur_dir" directory manually and rerun the install script."
        exit 1
    fi
    tar zxf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz -C $cur_dir/untar/
    mv $cur_dir/untar/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386/php-5.4.x/ZendGuardLoader.so /usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/
fi

if [ ! -f /usr/local/php/php.d/zend.ini ]; then
    echo "Zend Guard Loader configuration not found, create it!"
    cat > /usr/local/php/php.d/zend.ini<<-EOF
[Zend Guard]
extension = /usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/ZendGuardLoader.so

zend_loader.enable = 1
zend_loader.disable_licensing = 0
zend_loader.obfuscation_level_support = 3
zend_loader.license_path =
EOF
fi
# Clean up
cd $cur_dir
rm -rf $cur_dir/untar/
service httpd restart
echo "============================ZendGuardLoader install completed================================="
exit
