#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   System Required:  CentOS5.x (32bit/64bit) or CentOS6.x (32bit/64bit)
#   Description:  Auto Update Script for PHP && phpMyAdmin
#   Author: Teddysun <i@teddysun.com>
#   Intro:  https://code.google.com/p/teddysun/
#===============================================================================================
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi
cur_dir=`pwd`
cd $cur_dir
yum install -y elinks

clear
echo "#############################################################"
echo "# Auto Update Script for PHP && phpMyAdmin"
echo "# System Required:  CentOS5.x (32bit/64bit) or CentOS6.x (32bit/64bit)"
echo "# Intro: https://code.google.com/p/teddysun/"
echo "#"
echo "# Author: Teddysun <i@teddysun.com>"
echo "#"
echo "#############################################################"
echo ""

#Description:PHP5 Update
if [ ! -s /usr/bin/php ]; then
	ln -s /usr/local/php/bin/php /usr/bin/php
fi

LATEST_PHP=$(curl -s http://www.php.net/downloads.php | awk '/Current stable/{print $3}')
INSTALLED_PHP=$(php -r 'echo PHP_VERSION;' 2>/dev/null);

echo -e "Latest version of PHP: \033[41;37m $LATEST_PHP \033[0m"
echo -e "Installed version of PHP: \033[41;37m $INSTALLED_PHP \033[0m"
echo ""
echo "Do you want to upgrade PHP5 ? (y/n)"
read -p "(Default: n):" UPGRADE_PHP
if [ -z $UPGRADE_PHP ]; then
	UPGRADE_PHP="n"
fi
echo "---------------------------"
echo "You choose = $UPGRADE_PHP"
echo "---------------------------"
echo ""

#Description:phpMyAdmin Update
if [ -d /data/www/default/phpmyadmin ]; then
	INSTALLED_PMA=$(awk '/Version/{print $2}' /data/www/default/phpmyadmin/README)
else
	if [ -s "$cur_dir/pmaversion.txt" ]; then
		INSTALLED_PMA=$(awk '/phpmyadmin/{print $2}' $cur_dir/pmaversion.txt)
	else
		echo -e "phpmyadmin\t0" > $cur_dir/pmaversion.txt
		INSTALLED_PMA=$(awk '/phpmyadmin/{print $2}' $cur_dir/pmaversion.txt)
	fi
fi

LATEST_PMA=$(elinks http://nchc.dl.sourceforge.net/project/phpmyadmin/phpMyAdmin/ | awk -F/ '{print $7F}' | sort -n | grep -iv '-' | tail -1)
echo -e "Latest version of phpmyadmin: \033[41;37m $LATEST_PMA \033[0m"
echo -e "Installed version of phpmyadmin: \033[41;37m $INSTALLED_PMA \033[0m"
echo ""
echo "Do you want to upgrade phpmyadmin ? (y/n)"
read -p "(Default: n):" UPGRADE_PMA
if [ -z $UPGRADE_PMA ]; then
	UPGRADE_PMA="n"
fi
echo "---------------------------"
echo "You choose = $UPGRADE_PMA"
echo "---------------------------"
echo ""
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

#Description:Download && Untar files
function untar(){
	local TARBALL_TYPE
	if [ -n $1 ]; then
		SOFTWARE_NAME=`echo $1 | awk -F/ '{print $NF}'`
		TARBALL_TYPE=`echo $1 | awk -F. '{print $NF}'`
		wget -c -t3 -T3 $1 -P $cur_dir/
		if [ $? != "0" ];then
			rm -rf $cur_dir/$SOFTWARE_NAME
			wget -c -t3 -T60 $2 -P $cur_dir/
			SOFTWARE_NAME=`echo $2 | awk -F/ '{print $NF}'`
			TARBALL_TYPE=`echo $2 | awk -F. '{print $NF}'`
		fi
	else
		SOFTWARE_NAME=`echo $2 | awk -F/ '{print $NF}'`
		TARBALL_TYPE=`echo $2 | awk -F. '{print $NF}'`
		wget -c -t3 -T3 $2 -P $cur_dir/ || exit
	fi
	EXTRACTED_DIR=`tar tf $cur_dir/$SOFTWARE_NAME | tail -n 1 | awk -F/ '{print $1}'`
	case $TARBALL_TYPE in
		gz|tgz)
			tar zxf $cur_dir/$SOFTWARE_NAME -C $cur_dir/ && cd $cur_dir/$EXTRACTED_DIR || return 1
		;;
		bz2|tbz)
			tar jxf $cur_dir/$SOFTWARE_NAME -C $cur_dir/ && cd $cur_dir/$EXTRACTED_DIR || return 1
		;;
		tar|Z)
			tar xf $cur_dir/$SOFTWARE_NAME -C $cur_dir/ && cd $cur_dir/$EXTRACTED_DIR || return 1
		;;
		*)
		echo "$SOFTWARE_NAME is wrong tarball type ! "
	esac
}

#Description:PHP5 Update
if [[ "$UPGRADE_PHP" = "y" || "$UPGRADE_PHP" = "Y" ]];then
	echo "===================== PHP5 Upgrade ===================="
	if [[ -d "/usr/local/php.bak" && -d "/usr/local/php" ]];then
		rm -rf /usr/local/php.bak/
	fi
	\mv /usr/local/php /usr/local/php.bak
	cd $cur_dir
	if [ ! -s php-${LATEST_PHP}.tar.gz ]; then
		LATEST_PHP_LINK="http://us.php.net/distributions/php-${LATEST_PHP}.tar.gz"
		BACKUP_PHP_LINK="http://teddysun.googlecode.com/files/php-${LATEST_PHP}.tar.gz"
		untar ${LATEST_PHP_LINK} ${BACKUP_PHP_LINK}
	else
		tar -zxf php-${LATEST_PHP}.tar.gz
		cd php-${LATEST_PHP}/
	fi
	
	./configure \
	--prefix=/usr/local/php \
	--with-apxs2=/usr/local/apache/bin/apxs  \
	--with-config-file-path=/usr/local/php/etc \
	--with-mysqli=/usr/local/mysql/bin/mysql_config \
	--with-mysql-sock=/usr/local/mysql/mysql.sock \
	--with-config-file-scan-dir=/usr/local/php/php.d \
	--with-openssl \
	--with-zlib \
	--with-curl \
	--enable-ftp \
	--with-gd \
	--with-jpeg-dir \
	--with-png-dir \
	--with-freetype-dir \
	--with-xmlrpc \
	--enable-calendar \
	--with-imap \
	--with-kerberos \
	--with-imap-ssl \
	--with-ldap \
	--enable-bcmath \
	--enable-exif \
	--enable-wddx \
	--enable-tokenizer \
	--enable-simplexml \
	--enable-sockets \
	--enable-ctype \
	--enable-gd-native-ttf \
	--enable-mbstring \
	--enable-intl \
	--enable-xml \
	--enable-dom \
	--enable-json \
	--enable-session \
	--enable-soap \
	--with-mcrypt \
	--enable-zip \
	--with-iconv=/usr/local/libiconv \
	--with-mysql=/usr/local/mysql \
	--with-icu-dir=/usr \
	--with-mhash=/usr \
	--with-pcre-dir \
	--without-pear
	
	make && make install
	mkdir -p /usr/local/php/etc
	mkdir -p /usr/local/php/php.d
	\cp -f /usr/local/php.bak/etc/php.ini /usr/local/php/etc/php.ini
	\cp -f /usr/local/php.bak/php.d/* /usr/local/php/php.d/*
	#Restart httpd service
	service httpd restart
	echo "===================== PHP5 Update completed! ===================="
	echo ""
fi

#Description:phpMyAdmin Update
if [[ "$UPGRADE_PMA" = "y" || "$UPGRADE_PMA" = "Y" ]];then
	echo "===================== phpMyAdmin Upgrade ===================="
	if [ -d /data/www/default/phpmyadmin ]; then
		mv /data/www/default/phpmyadmin/config.inc.php $cur_dir/config.inc.php
		rm -rf /data/www/default/phpmyadmin
	else
		echo "===================== phpMyAdmin folder not found! ===================="
	fi
	if [ ! -s phpMyAdmin-${LATEST_PMA}-all-languages.tar.gz ]; then
		LATEST_PMA_LINK="http://nchc.dl.sourceforge.net/project/phpmyadmin/phpMyAdmin/${LATEST_PMA}/phpMyAdmin-${LATEST_PMA}-all-languages.tar.gz"
		BACKUP_PMA_LINK="http://teddysun.googlecode.com/files/phpMyAdmin-${LATEST_PMA}-all-languages.tar.gz"
		untar ${LATEST_PMA_LINK} ${BACKUP_PMA_LINK}
		mkdir -p /data/www/default/phpmyadmin
		mv * /data/www/default/phpmyadmin
	else
		tar -zxf phpMyAdmin-${LATEST_PMA}-all-languages.tar.gz -C $cur_dir
		mv $cur_dir/phpMyAdmin-${LATEST_PMA}-all-languages /data/www/default/phpmyadmin
	fi
	if [ -s $cur_dir/config.inc.php ]; then
		mv $cur_dir/config.inc.php /data/www/default/phpmyadmin/config.inc.php
	else
		mv /data/www/default/phpmyadmin/config.sample.inc.php /data/www/default/phpmyadmin/config.inc.php
	fi
	mkdir -p /data/www/default/phpmyadmin/upload/
	mkdir -p /data/www/default/phpmyadmin/save/
	chown -R apache:apache /data/www/default/phpmyadmin
	
	rm -rf $cur_dir/pmaversion.txt
	echo -e "phpmyadmin\t${LATEST_PMA}" > $cur_dir/pmaversion.txt
	rm -rf $cur_dir/phpMyAdmin-${LATEST_PMA}-all-languages
	echo "===================== phpMyAdmin Update completed! ===================="
	echo ""
fi
