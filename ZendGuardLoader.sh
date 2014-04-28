#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   SYSTEM REQUIRED:  CentOS-5 (32bit/64bit) or CentOS-6 (32bit/64bit)
#   DESCRIPTION:  ZendGuardLoader for LAMP
#   AUTHOR: Teddysun <i@teddysun.com>
#   VISIT:  http://teddysun.com/lamp
#===============================================================================================
cur_dir=`pwd`
cd $cur_dir
mkdir -p $cur_dir/untar/

clear
echo "#############################################################"
echo "# ZendGuardLoader for LAMP"
echo "# Intro: http://teddysun.com/lamp"
echo "#"
echo "# Author: Teddysun <i@teddysun.com>"
echo "#"
echo "#############################################################"
echo ""

#install ZendGuardLoader
echo "============================ZendGuardLoader install start====================================="
#download ZendGuardLoader
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

zg=`cat /usr/local/php/etc/php.ini |grep -q "Zend Guard" && echo "include" || echo "not"`
if [ "$zg" = "not" ]; then
echo "Zend Guard configuration not found, create it!"
cat >>/usr/local/php/etc/php.ini<<-EOF

[Zend Guard]
zend_extension = /usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/ZendGuardLoader.so
; Enables loading encoded scripts. The default value is On
zend_loader.enable = 1
; Optional: following lines can be added your php.ini file for ZendGuardLoader configuration
zend_loader.disable_licensing = 0
zend_loader.obfuscation_level_support = 3
zend_loader.license_path =
EOF
fi
service httpd restart
echo "============================ZendGuardLoader install completed================================="
exit
