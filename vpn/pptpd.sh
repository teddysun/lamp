#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   SYSTEM REQUIRED:  CentOS-5 (32bit/64bit) or CentOS-6 (32bit/64bit)
#   DESCRIPTION:  install pptpd
#===============================================================================================
cur_dir=`pwd`
#remove installed pptpd & ppp
yum remove -y pptpd ppp
iptables --flush POSTROUTING --table nat
iptables --flush FORWARD
rm -rf /etc/pptpd.conf
rm -rf /etc/ppp
arch=`uname -m`
#download pptpd-1.3.4-2
if [ -s pptpd-1.3.4-2.el6.$arch.rpm ]; then
  echo "pptpd-1.3.4-2.el6.$arch.rpm [found]"
else
  echo "pptpd-1.3.4-2.el6.$arch.rpm not found!!!download now......"
  if ! wget http://teddysun.googlecode.com/files/pptpd-1.3.4-2.el6.$arch.rpm;then
    echo "Failed to download pptpd-1.3.4-2.el6.$arch.rpm,please download it to $cur_dir directory manually and rerun the install script."
	exit 1
  fi
fi
#install some necessary tools
yum -y install make libpcap iptables gcc-c++ logrotate tar cpio perl pam tcp_wrappers dkms kernel_ppp_mppe ppp
rpm -ivh pptpd-1.3.4-2.el6.$arch.rpm

mknod /dev/ppp c 108 0
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "mknod /dev/ppp c 108 0" >> /etc/rc.local
echo "echo 1 > /proc/sys/net/ipv4/ip_forward" >> /etc/rc.local
echo "localip 172.16.36.1" >> /etc/pptpd.conf
echo "remoteip 172.16.36.2-254" >> /etc/pptpd.conf
echo "ms-dns 8.8.8.8" >> /etc/ppp/options.pptpd
echo "ms-dns 8.8.4.4" >> /etc/ppp/options.pptpd

pass=`openssl rand 6 -base64`
if [ "$1" != "" ]
then pass=$1
fi

echo "vpn pptpd ${pass} *" >> /etc/ppp/chap-secrets

iptables -t nat -A POSTROUTING -s 172.16.36.0/24 -j SNAT --to-source `ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk 'NR==1 { print $1}'`
iptables -A FORWARD -p tcp --syn -s 172.16.36.0/24 -j TCPMSS --set-mss 1356
service iptables save
chkconfig --add pptpd
chkconfig pptpd on
service iptables restart
service pptpd start
 
echo "VPN service is installed, your VPN username is vpn, VPN password is ${pass}"

exit
