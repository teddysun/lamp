#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   DESCRIPTION:  Block traffic from Russian and Turkey
#   AUTHOR: Teddysun
#   VISIT:http://teddysun.com/284.html
#===============================================================================================

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi

clear
echo '================================================================';
	echo 'DESCRIPTION:  Block traffic from Russian and Turkey';
	echo "AUTHOR: Teddysun";
	echo 'VISIT:http://teddysun.com/284.html';
echo '================================================================';
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
echo "Press any key to start...or Press Ctrl+C to cancel"
char=`get_char`

COUNTRY='ru tr';

for c in $COUNTRY
do
country_file=$c.zone

if [ ! -s $country_file ]; then
	echo "$country_file not found!!!download now......"
	wget -c http://teddysun.com/wp-content/uploads/$country_file
else
	echo "$country_file [found]"
fi

cat $country_file | while read line

do
	ip=$line
	if [ `/sbin/iptables -L -n|grep -v grep|grep $ip -c` -eq 0 ] ; then
        /sbin/iptables -A INPUT -s $ip -j DROP
        echo "blocking $ip"
		echo -e "$ip has been blocked!!" >> blockedip.log
    fi
done
done