#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   SYSTEM REQUIRED:  CentOS-5 (32bit/64bit) or CentOS-6 (32bit/64bit)
#   DESCRIPTION:  ionCube for LAMP
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
echo "# ionCube for LAMP"
echo "# Intro: http://teddysun.com/lamp"
echo "#"
echo "# Author: Teddysun <i@teddysun.com>"
echo "#"
echo "#############################################################"
echo ""

# Install ionCube
echo "============================ionCube install start====================================="
if [ ! -d $cur_dir/untar/ ]; then
    mkdir -p $cur_dir/untar/
fi
# Download ionCube
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
    if ! wget -c http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz; then
        echo "Failed to download ioncube_loaders_lin_x86-64.tar.gz, please download it to $cur_dir directory manually and try again."
        exit 1
    fi
    tar zxf ioncube_loaders_lin_x86-64.tar.gz -C $cur_dir/untar/
else
    if ! wget -c http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86.tar.gz; then
        echo "Failed to download ioncube_loaders_lin_x86.tar.gz, please download it to $cur_dir directory manually and try again."
        exit 1
    fi
    tar zxf ioncube_loaders_lin_x86.tar.gz -C $cur_dir/untar/
fi
# Copy file
cp -pf $cur_dir/untar/ioncube/ioncube_loader_lin_5.4.so /usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/
# Create configuration file
if [ ! -f /usr/local/php/php.d/ioncube.ini ]; then
    echo "ionCube configuration not found, create it!"
    cat > /usr/local/php/php.d/ioncube.ini<<-EOF
[ionCube Loader]
zend_extension = /usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/ioncube_loader_lin_5.4.so
EOF
fi
# Clean up
cd $cur_dir
rm -rf $cur_dir/untar/
service httpd restart
echo "============================ionCube install completed================================="
exit
