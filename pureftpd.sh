#!/bin/bash
#=========================================================#
#   System Required:  CentOS / RedHat / Fedora            #
#   Description:  pure-ftpd for LAMP                      #
#   Author: Teddysun <i@teddysun.com>                     #
#   Visit:  https://lamp.sh                               #
#=========================================================#
# Check if user is root
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi

cur_dir=`pwd`

pureftpdVer='pure-ftpd-1.0.42'

# Download pure-ftpd 
if [ -s $pureftpdVer.tar.gz ]; then
    echo "$pureftpdVer.tar.gz [found]"
else
    echo "$pureftpdVer.tar.gz not found!!!download now......"
    if ! wget -c -t3 http://lamp.teddysun.com/files/$pureftpdVer.tar.gz; then
        echo "Failed to download $pureftpdVer.tar.gz, please download it to $cur_dir directory manually and retry."
        exit 1
    fi
fi

# Install pure-ftpd 
echo "pure-ftpd  install start..."
if [ ! -d $cur_dir/untar/ ]; then
    mkdir -p $cur_dir/untar/
fi
tar xzf $pureftpdVer.tar.gz -C $cur_dir/untar/
cd $cur_dir/untar/$pureftpdVer
./configure
make && make install
cp contrib/redhat.init /etc/init.d/pure-ftpd
chmod 755 /etc/init.d/pure-ftpd
chkconfig --add pure-ftpd
chkconfig --level 3 pure-ftpd on
if ! wget --no-check-certificate https://github.com/teddysun/lamp/raw/master/conf/pure-ftpd.conf -O /etc/pure-ftpd.conf;then
    echo "Failed to download pure-ftpd.conf, please download it to /etc directory manually and try again."
    exit 1
fi
cp configuration-file/pure-config.pl /usr/local/sbin/pure-config.pl
chmod 744 /etc/pure-ftpd.conf
chmod 755 /usr/local/sbin/pure-config.pl
/etc/init.d/pure-ftpd start
# Clean up
cd $cur_dir
rm -rf $cur_dir/untar/
rm -f $cur_dir/$pureftpdVer.tar.gz
echo "pure-ftpd install completed..."
