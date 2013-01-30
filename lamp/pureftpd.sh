#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#pure-ftpd for CentOS/RadHat 5 or 6 Linux Server.
# Check if user is root
if [ $(id -u) != "0" ]; then
    quit "You must be root to run this script!"
fi
cur_dir=`pwd`
[ ! -d $cur_dir/untar ] && mkdir $cur_dir/untar
#download pure-ftpd 
cd $cur_dir
if [ -s pure-ftpd-1.0.36.tar.gz ]; then
  echo "pure-ftpd-1.0.36.tar.gz [found]"
  else
  echo "Error: pure-ftpd-1.0.36.tar.gz not found!!!download now......"
 if ! wget -c http://teddysun.googlecode.com/files/pure-ftpd-1.0.36.tar.gz;then
 echo "Failed to download pure-ftpd-1.0.36.tar.gz,please download it to /lamp directory manually and rerun the install script."
 exit 1
 fi
fi

#install pure-ftpd 
echo "============================pure-ftpd  install============================================"
cd $cur_dir
mkdir -p $cur_dir/untar/
rm -rf $cur_dir/untar/*
tar xzf pure-ftpd-1.0.36.tar.gz -C $cur_dir/untar/
cd $cur_dir/untar/pure-ftpd-1.0.36
./configure
make && make install
cp contrib/redhat.init /etc/init.d/pure-ftpd
chmod 755 /etc/init.d/pure-ftpd
chkconfig --add pure-ftpd
chkconfig --level 3 pure-ftpd on
cp $cur_dir/conf/pure-ftpd.conf /etc
cp configuration-file/pure-config.pl /usr/local/sbin/pure-config.pl
chmod 744 /etc/pure-ftpd.conf
chmod 755 /usr/local/sbin/pure-config.pl
service pure-ftpd start
#see if iptables is start
/sbin/service iptables status 1>/dev/null 2>&1
if [ $? -eq 0 ]; then
/sbin/iptables -A INPUT -p tcp -m tcp --dport 21 -j ACCEPT  
/etc/rc.d/init.d/iptables save
echo 'IPTABLES_MODULES="ip_conntrack_ftp"' >>/etc/sysconfig/iptables-config
/etc/init.d/iptables restart
fi
echo "============================pure-ftpd install completed============================================"
