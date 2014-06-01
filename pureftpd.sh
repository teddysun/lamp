#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   SYSTEM REQUIRED:  CentOS-5 (32bit/64bit) or CentOS-6 (32bit/64bit)
#   DESCRIPTION:  pure-ftpd for CentOS/RadHat 5 or 6 Linux Server
#   AUTHOR: Teddysun <i@teddysun.com>
#   VISIT:  http://teddysun.com/lamp
#===============================================================================================
# Check if user is root
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi
cur_dir=`pwd`
cd $cur_dir

# Download pure-ftpd 
if [ -s pure-ftpd-1.0.36.tar.gz ]; then
    echo "pure-ftpd-1.0.36.tar.gz [found]"
else
    echo "pure-ftpd-1.0.36.tar.gz not found!!!download now......"
    if ! wget -c http://teddysun.googlecode.com/files/pure-ftpd-1.0.36.tar.gz;then
        echo "Failed to download pure-ftpd-1.0.36.tar.gz, please download it to $cur_dir directory manually and try again."
        exit 1
    fi
fi

# Install pure-ftpd 
echo "============================pure-ftpd  install start============================"
if [ ! -d $cur_dir/untar/ ]; then
    mkdir -p $cur_dir/untar/
fi
tar xzf pure-ftpd-1.0.36.tar.gz -C $cur_dir/untar/
cd $cur_dir/untar/pure-ftpd-1.0.36
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
service pure-ftpd start
#see if iptables is start
/sbin/service iptables status 1>/dev/null 2>&1
if [ $? -eq 0 ]; then
    /sbin/iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 21 -j ACCEPT
    /etc/rc.d/init.d/iptables save
    /etc/init.d/iptables restart
fi
# Clean up
cd $cur_dir
rm -rf $cur_dir/untar/
echo "============================pure-ftpd install completed============================"
