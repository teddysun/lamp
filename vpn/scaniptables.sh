#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#######################################################################
#   Description:  Scan /var/log/secure and block illegal ip by iptables
#   Author:       Teddysun
#######################################################################
if [ $(id -u) != "0" ]; then
	printf "Error: You must be root to run this script!"
	exit 1
fi

if [ ! -s "/var/log/loginFailIP.log" ]; then
	/sbin/iptables -N LOGINFAIL_LIST
	/sbin/iptables -A LOGINFAIL_LIST -j REJECT
else
	rm -rf /var/log/loginFailIP.log
fi

grep 'Failed password for .* from' /var/log/secure* | awk '{for (i=5;i<NF;i++)if ($i=="from") print $(i+1);}' | sort | uniq -c | awk '{if ($1>2) print $2;}' > /var/log/loginFailIP.log
grep 'Failed password for invalid user .* from' /var/log/secure* | awk '{for (i=5;i<NF;i++)if ($i=="from") print $(i+1);}' | sort | uniq -c | awk '{if ($1>2) print $2;}' >> /var/log/loginFailIP.log

sort /var/log/loginFailIP.log | uniq | while read line

do
    ip=$line
    if [ `/sbin/iptables -L -n|grep -v grep|grep $ip -c` -eq 0 ] ; then
        /sbin/iptables -A INPUT -s $ip -j LOGINFAIL_LIST
        echo "$ip has been blocked!!"
		echo -e "$ip has been blocked!!" >> /root/blockedip.log
    fi
done