#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   SYSTEM REQUIRED:  CentOS-5 (32bit/64bit) or CentOS-6 (32bit/64bit)
#   DESCRIPTION:  install Cisco IPsec
#   VERSION:   1.0
#   AUTHOR:    i@teddysun.com
#===============================================================================================
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root" 1>&2
   exit 1
fi

tmpip=`ifconfig |grep 'inet' | grep -Evi '(inet6|127.0.0.1)' | awk '{print $2}' | cut -d: -f2 | tail -1`

echo "Please input IP-Range:"
read -p "(Default Range: 10.0.88.100):" iprange
if [ "$iprange" = "" ]; then
	iprange="10.0.88.100"
fi

echo "Please input Group Name:"
read -p "(Default Group Name: vpn):" mygroup
if [ "$mygroup" = "" ]; then
	mygroup="vpn"
fi

echo "Please input Group Secret:"
read -p "(Default Group Secret: vpn.psk):" mypsk
if [ "$mypsk" = "" ]; then
	mypsk="vpn.psk"
fi

echo "Please input User Name:"
read -p "(Default User Name: vpn):" usernm
if [ "$usernm" = "" ]; then
	usernm="vpn"
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
echo "Server Local IP Range:"
echo "$iprange"
echo ""
echo "Group Name:"
echo "$mygroup"
echo ""
echo "Group Secret:"
echo "$mypsk"
echo ""
echo "Press any key to start...or Press Ctrl+c to cancel"
char=`get_char`
clear
#
cur_dir=`pwd`
rm -rf $cur_dir/ipsec
mkdir -p $cur_dir/ipsec
cd $cur_dir/ipsec
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	#download ipsec-tools-0.8.0-1.el5.pp.x86_64.rpm
	if ! wget http://teddysun.googlecode.com/files/ipsec-tools-0.8.0-1.el5.pp.x86_64.rpm;then
		echo "Failed to download ipsec-tools-0.8.0-1.el5.pp.x86_64.rpm, please download it to $cur_dir/ipsec directory manually and rerun the install script."
		exit 1
	fi
	#download ipsec-tools-libs-0.8.0-1.el5.pp.x86_64.rpm
	if ! wget http://teddysun.googlecode.com/files/ipsec-tools-libs-0.8.0-1.el5.pp.x86_64.rpm;then
		echo "Failed to download ipsec-tools-libs-0.8.0-1.el5.pp.x86_64.rpm, please download it to $cur_dir/ipsec directory manually and rerun the install script."
		exit 1
	fi
else
	#download ipsec-tools-0.8.0-1.el5.pp.i386.rpm
	if ! wget http://teddysun.googlecode.com/files/ipsec-tools-0.8.0-1.el5.pp.i386.rpm;then
		echo "Failed to download ipsec-tools-0.8.0-1.el5.pp.i386.rpm, please download it to $cur_dir/ipsec directory manually and rerun the install script."
		exit 1
	fi
	#download ipsec-tools-libs-0.8.0-1.el5.pp.i386.rpm
	if ! wget http://teddysun.googlecode.com/files/ipsec-tools-libs-0.8.0-1.el5.pp.i386.rpm;then
		echo "Failed to download ipsec-tools-libs-0.8.0-1.el5.pp.i386.rpm, please download it to $cur_dir/ipsec directory manually and rerun the install script."
		exit 1
	fi
fi
#
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	#yum localinstall
	yum -y localinstall --nogpgcheck ipsec-tools-0.8.0-1.el5.pp.x86_64.rpm ipsec-tools-libs-0.8.0-1.el5.pp.x86_64.rpm
else
	#yum localinstall
	yum -y localinstall --nogpgcheck ipsec-tools-0.8.0-1.el5.pp.i386.rpm ipsec-tools-libs-0.8.0-1.el5.pp.i386.rpm
fi

#configuation racoon.conf
rm -rf /etc/racoon/racoon.conf
touch /etc/racoon/racoon.conf
cat >>/etc/racoon/racoon.conf<<EOF
path pre_shared_key "/etc/racoon/psk.txt";
path certificate "/etc/racoon/certs";
listen {
isakmp $tmpip [500]; 
isakmp_natt $tmpip [4500]; 
}

remote anonymous {
exchange_mode aggressive, main, base;
mode_cfg on;
proposal_check obey;
nat_traversal on;
generate_policy unique;
ike_frag on;
passive on;
dpd_delay 30;

proposal {
lifetime time 28800 sec;
encryption_algorithm 3des;
hash_algorithm md5;
authentication_method xauth_psk_server;
dh_group 2;
}
}

sainfo anonymous {
encryption_algorithm aes, 3des, blowfish;
authentication_algorithm hmac_sha1, hmac_md5;
compression_algorithm deflate;
}

mode_cfg {
auth_source system;
dns4 8.8.8.8;
banner "/etc/racoon/motd";
save_passwd on;
network4 $iprange;
netmask4 255.255.255.0;
pool_size 100;
pfs_group 2;
}
EOF
#configuation psk.txt
rm -rf /etc/racoon/psk.txt
touch /etc/racoon/psk.txt
cat >>/etc/racoon/psk.txt<<EOF
# Group Name Group Secret
$mygroup $mypsk
EOF
#configuation motd
cat >>/etc/racoon/motd<<EOF
Welcome To VPN Service!
EOF
#
chmod +x /etc/racoon/racoon.conf /etc/racoon/psk.txt
#iptables config
iptables -A INPUT -p udp --dport 500 -j ACCEPT
iptables -A INPUT -p udp --dport 4500 -j ACCEPT
iptables -t nat -A POSTROUTING -s $iprange/24 -o eth0 -j MASQUERADE
iptables -A FORWARD -s $iprange/24 -j ACCEPT
service iptables save
service iptables restart
#ipv4 forward set
sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf
sysctl -p
#default user & password set
useradd -MN -b /tmp -s /sbin/nologin $usernm
echo "Please input $usernm password:"
passwd $usernm
#chkconfig racoon
chmod +x /etc/init.d/racoon
chkconfig --add racoon
chkconfig racoon on
#racoon start
service racoon start

echo "Cisco IPsec service is installed, username is $usernm"
echo "Enjoy it!"