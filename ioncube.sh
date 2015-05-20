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

# is 64bit or not
function is_64bit(){
    if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
        return 0
    else
        return 1
    fi        
}

clear
echo "#############################################################"
echo "# ionCube for LAMP"
echo "# Intro: http://teddysun.com/lamp"
echo "#"
echo "# Author: Teddysun <i@teddysun.com>"
echo "#"
echo "#############################################################"
echo ""

# get PHP version
INSTALLED_PHP=$(php -r 'echo PHP_VERSION;' 2>/dev/null | awk -F. '{print $1$2}')
if [ $? -ne 0 -o -z $INSTALLED_PHP ]; then
    echo "Error:PHP looks like not installed, please check it and try again."
    exit 1
fi

# get PHP extensions date
if   [ $INSTALLED_PHP -eq 53 ]; then
    phpVer='5.3'
    extDate='20090626'
elif [ $INSTALLED_PHP -eq 54 ]; then
    phpVer='5.4'
    extDate='20100525'
elif [ $INSTALLED_PHP -eq 55 ]; then
    phpVer='5.5'
    extDate='20121212'
elif [ $INSTALLED_PHP -eq 56 ]; then
    phpVer='5.6'
    extDate='20131226'
fi
if is_64bit; then
    ionCubeVer='ioncube_loaders_lin_x86-64.tar.gz'
else
    ionCubeVer='ioncube_loaders_lin_x86.tar.gz'
fi

# Install ionCube
echo "============================ionCube install start====================================="
if [ ! -d $cur_dir/untar/ ]; then
    mkdir -p $cur_dir/untar/
fi
# Download ionCube
if [ -s ${ionCubeVer} ]; then
    echo "${ionCubeVer} [found]"
else
    echo "${ionCubeVer} not found!!!download now......"
    if ! wget -c -t3 http://lamp.teddysun.com/files/${ionCubeVer}; then
        echo "Failed to download ${ionCubeVer}, please download it to ${cur_dir} directory manually and retry."
        exit 1
    fi
fi

tar zxf ${ionCubeVer} -C $cur_dir/untar/

# Copy file
cp -pf $cur_dir/untar/ioncube/ioncube_loader_lin_$phpVer.so /usr/local/php/lib/php/extensions/no-debug-non-zts-$extDate/

# Create configuration file
if [ ! -f /usr/local/php/php.d/ioncube.ini ]; then
    echo "ionCube configuration not found, create it!"
    cat > /usr/local/php/php.d/ioncube.ini<<-EOF
[ionCube Loader]
zend_extension = /usr/local/php/lib/php/extensions/no-debug-non-zts-${extDate}/ioncube_loader_lin_${phpVer}.so
EOF
fi
# Clean up
cd $cur_dir
rm -rf $cur_dir/untar/
rm -f $cur_dir/${ionCubeVer}
# Restart httpd service
/etc/init.d/httpd restart
echo "============================ionCube install completed================================="
exit
