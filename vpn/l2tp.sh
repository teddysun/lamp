#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   SYSTEM REQUIRED:  CentOS-5 (32bit/64bit) or CentOS-6 (32bit/64bit)
#   DESCRIPTION:  install L2TP
#   VERSION:   1.0
#   AUTHOR:    teddysun
#===============================================================================================
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root" 1>&2
   exit 1
fi

tmpip=`ifconfig |grep 'inet' | grep -Evi '(inet6|127.0.0.1)' | awk '{print $2}' | cut -d: -f2 | tail -1`

echo "Please input IP-Range:"
read -p "(Default Range: 10.1.2):" iprange
if [ "$iprange" = "" ]; then
	iprange="10.1.2"
fi

echo "Please input PSK:"
read -p "(Default PSK: vpn):" mypsk
if [ "$mypsk" = "" ]; then
	mypsk="vpn"
fi

clear
get_char()
{
SAVEDSTTY=`stty -g`
stty -echo
stty cbreak
dd if=/dev/tty bs=1 count=1 2> /dev/null
stty -raw
stty echo
stty $SAVEDSTTY
}
echo ""
echo "ServerIP:"
echo "$tmpip"
echo ""
echo "Server Local IP:"
echo "$iprange.1"
echo ""
echo "Client Remote IP Range:"
echo "$iprange.2-$iprange.254"
echo ""
echo "PSK:"
echo "$mypsk"
echo ""
echo "Press any key to start...or Press Ctrl+c to cancel"
char=`get_char`
clear

mknod /dev/random c 1 9
#install some necessary tools
yum install -y ppp iptables make gcc gmp-devel xmlto bison flex xmlto libpcap-devel lsof vim-enhanced
#
cur_dir=`pwd`
mkdir -p $cur_dir/l2tp
cd $cur_dir/l2tp
#download openswan-2.6.38.tar.gz
if [ -s openswan-2.6.38.tar.gz ]; then
  echo "openswan-2.6.38.tar.gz [found]"
else
  echo "openswan-2.6.38.tar.gz not found!!!download now......"
  if ! wget http://teddysun.googlecode.com/files/openswan-2.6.38.tar.gz;then
    echo "Failed to download openswan-2.6.38.tar.gz, please download it to $cur_dir directory manually and rerun the install script."
	exit 1
  fi
fi
#download rp-l2tp-0.4.tar.gz
if [ -s rp-l2tp-0.4.tar.gz ]; then
  echo "rp-l2tp-0.4.tar.gz [found]"
else
  echo "rp-l2tp-0.4.tar.gz not found!!!download now......"
  if ! wget http://teddysun.googlecode.com/files/rp-l2tp-0.4.tar.gz;then
    echo "Failed to download rp-l2tp-0.4.tar.gz, please download it to $cur_dir directory manually and rerun the install script."
	exit 1
  fi
fi
#download xl2tpd-1.2.4.tar.gz
if [ -s xl2tpd-1.2.4.tar.gz ]; then
  echo "xl2tpd-1.2.4.tar.gz [found]"
else
  echo "xl2tpd-1.2.4.tar.gz not found!!!download now......"
  if ! wget http://teddysun.googlecode.com/files/xl2tpd-1.2.4.tar.gz;then
    echo "Failed to download xl2tpd-1.2.4.tar.gz, please download it to $cur_dir directory manually and rerun the install script."
	exit 1
  fi
fi
#untar all files
rm -rf $cur_dir/l2tp/untar
mkdir -p $cur_dir/l2tp/untar
echo "============================untar all files,please wait a moment...======================="
for file in `ls *.tar.gz` ;
do
tar -zxf $file -C $cur_dir/l2tp/untar
done
echo "============================untar all files completed!...================================="
#make & install openswan-2.6.38
cd $cur_dir/l2tp/untar/openswan-2.6.38
make programs install

#configuation ipsec
rm -rf /etc/ipsec.conf
touch /etc/ipsec.conf
cat >>/etc/ipsec.conf<<EOF
config setup
    nat_traversal=yes
    virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12
    oe=off
    protostack=netkey

conn L2TP-PSK-NAT
    rightsubnet=vhost:%priv
    also=L2TP-PSK-noNAT

conn L2TP-PSK-noNAT
    authby=secret
    pfs=no
    auto=add
    keyingtries=3
    rekey=no
    ikelifetime=8h
    keylife=1h
    type=transport
    left=$tmpip
	leftid=$tmpip
    leftprotoport=17/1701
    right=%any
	rightid=%any
    rightprotoport=17/%any
EOF
cat >>/etc/ipsec.secrets<<EOF
$tmpip %any: PSK "$mypsk"
EOF
sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf
sed -i 's/net.ipv4.conf.default.rp_filter = 1/net.ipv4.conf.default.rp_filter = 0/g' /etc/sysctl.conf
sysctl -p
iptables --table nat --append POSTROUTING --jump MASQUERADE
for each in /proc/sys/net/ipv4/conf/*
do
echo 0 > $each/accept_redirects
echo 0 > $each/send_redirects
done

#make & install rp-l2tp-0.4
cd $cur_dir/l2tp/untar/rp-l2tp-0.4
./configure
make
cp handlers/l2tp-control /usr/local/sbin/
mkdir -p /var/run/xl2tpd/
ln -s /usr/local/sbin/l2tp-control /var/run/xl2tpd/l2tp-control
#make & install xl2tpd-1.2.4.tar.gz
cd $cur_dir/l2tp/untar/xl2tpd-1.2.4
make install
mkdir -p /etc/xl2tpd
rm -rf /etc/xl2tpd/xl2tpd.conf
touch /etc/xl2tpd/xl2tpd.conf
cat >>/etc/xl2tpd/xl2tpd.conf<<EOF
[global]
ipsec saref = yes
[lns default]
ip range = $iprange.2-$iprange.254
local ip = $iprange.1
refuse chap = yes
refuse pap = yes
require authentication = yes
ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF
rm -rf /etc/ppp/options.xl2tpd
touch /etc/ppp/options.xl2tpd
cat >>/etc/ppp/options.xl2tpd<<EOF
require-mschap-v2
ms-dns 8.8.8.8
ms-dns 8.8.4.4
asyncmap 0
auth
crtscts
lock
hide-password
modem
debug
name l2tpd
proxyarp
lcp-echo-interval 30
lcp-echo-failure 4
EOF

#default user & password set
pass=`openssl rand 6 -base64`
if [ "$1" != "" ]
then pass=$1
fi
echo "vpn l2tpd ${pass} *" >> /etc/ppp/chap-secrets

touch /usr/bin/zl2tpset
echo "#/bin/bash" >>/usr/bin/zl2tpset
echo "for each in /proc/sys/net/ipv4/conf/*" >>/usr/bin/zl2tpset
echo "do" >>/usr/bin/zl2tpset
echo "echo 0 > \$each/accept_redirects" >>/usr/bin/zl2tpset
echo "echo 0 > \$each/send_redirects" >>/usr/bin/zl2tpset
echo "done" >>/usr/bin/zl2tpset
chmod +x /usr/bin/zl2tpset
iptables --table nat --append POSTROUTING --jump MASQUERADE
zl2tpset
xl2tpd
cat >>/etc/rc.local<<EOF
iptables --table nat --append POSTROUTING --jump MASQUERADE
/etc/init.d/ipsec restart
/usr/bin/zl2tpset
/usr/local/sbin/xl2tpd
EOF
clear
ipsec verify
printf "
####################################################
#                                                  #
# Install L2TP bash script                         #
# Version: 1.0                                     #
# Author: teddysun                                 #
# enjoy it!!                                       #
####################################################
if there are no [FAILED] above, then you can
connect to your L2TP VPN Server with the default
user/password below:

ServerIP:$tmpip
username:vpn
password:${pass}
PSK:$mypsk
"

