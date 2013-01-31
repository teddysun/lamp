#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   SYSTEM REQUIRED:  CentOS-5 (32bit/64bit) or CentOS-6 (32bit/64bit)
#   DESCRIPTION:  Install LAMP for CentOS
#   AUTHOR: sunzh@bjbsh.com
#===============================================================================================

#===============================================================================================
#DESCRIPTION:Make sure only root can run our script
#USAGE:rootness
#===============================================================================================
function rootness(){
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
}

#===============================================================================================
#DESCRIPTION:monitor if there is an error.
#USAGE:errors_control [error code] [package name]
#===============================================================================================
function error_control(){
if [ $1 != 0 ];then
tail /root/lamp_errors.log
distro=`cat /etc/issue`
architecture=`uname -m`
cat >>/root/lamp_errors.log<<EOF
lamp errors:
php-version:$phpv
distributions:$distro
architecture:$architecture
issue:failed to install $2
EOF
echo "###########################################################"
echo "## failed to install $2.                                 ##"    
echo "## please contact your web administrator                 ##"
echo "###########################################################"
exit 1
fi
}

#===============================================================================================
#DESCRIPTION:Pre-installation settings.
#USAGE:pre_installation_settings
#===============================================================================================
function pre_installation_settings(){
#Set MySQL root password
	echo "Please input the root password of MySQL:"
	read -p "(Default password: root):" mysqlrootpwd
	if [ "$mysqlrootpwd" = "" ]; then
		mysqlrootpwd="root"
	fi
echo "MySQL password:$mysqlrootpwd"
echo "####################################"
#Define the MySQL data location.
echo "Please input the MySQL data location:"
	read -p "(leave blank for /usr/local/mysql/data):" mysqldata
	[ "$mysqldata" = "" ] && mysqldata="/usr/local/mysql/data"
echo "MySQL data location:$mysqldata"
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
	echo "Press any key to start...or Press Ctrl+c to cancel"
	char=`get_char`
#uninstall apache php httpd mysql
rpm -e httpd
rpm -e mysql
rpm -e php
yum -y remove httpd
yum -y remove php
yum -y remove mysql-server mysql
yum -y remove php-mysql
yum -y install yum-fastestmirror
#Set timezone
#rm -rf /etc/localtime
#\cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#[ -d /proc/xen ] && echo "xen.independent_wallclock=1" >>/etc/sysctl.conf && /sbin/sysctl -p && echo "/sbin/ntpdate  cn.pool.ntp.org" >>/etc/rc.local
#yum install -y ntp
#ntpdate cn.pool.ntp.org

#install some necessary tools
cp /etc/yum.conf /etc/yum.conf.lamp
sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf

for packages in wget gcc gcc-c++ libtool-libs autoconf freetype-devel gd libjpeg-devel libpng-devel libxml2-devel ncurses-devel zlib-devel zip unzip curl-devel crontabs file bison cmake patch mlocate flex diffutils automake make kernel-devel cpp readline-devel openssl-devel vim-minimal sendmail glibc-devel glib2-devel bzip2-devel e2fsprogs-devel libidn-devel  gettext-devel expat-devel libcap-devel libtool-ltdl-devel pam-devel pcre-devel libmcrypt-devel openldap openldap-devel libc-client-devel libxml2 libxml2-devel libicu* icu*;
do yum -y install $packages; done

mv -f /etc/yum.conf.lamp /etc/yum.conf

cur_dir=`pwd`
cd $cur_dir
}
#===============================================================================================
#DESCRIPTION:download files.
#USAGE:download_files [filename] [secondary url] 
#===============================================================================================
function download_files(){
if [ -s $1 ]; then
  echo "$1 [found]"
  else
  echo "$1 not found!!!download now......"
 if ! wget --tries=3 http://teddysun.googlecode.com/files/$1;then
 echo "Failed to download $1,please download it to "$cur_dir" directory manually and rerun the install script."
 exit 1
 fi
fi
}
#===============================================================================================
#DESCRIPTION:parallel make.
#USAGE:parallel_make
#===============================================================================================
function parallel_make(){
cpunum=`cat /proc/cpuinfo |grep 'processor'|wc -l`
make -j$cpunum
}

#===============================================================================================
#DESCRIPTION:install apache.
#USAGE:install_apache
#===============================================================================================
function install_apache(){
if [ ! -d /usr/local/apache/bin ];then
echo "============================Start install apache2.4.3====================================="
mv $cur_dir/untar/apr-1.4.6 $cur_dir/untar/httpd-2.4.3/srclib/apr
mv $cur_dir/untar/apr-util-1.4.1 $cur_dir/untar/httpd-2.4.3/srclib/apr-util
cd $cur_dir/untar/httpd-2.4.3
./configure --prefix=/usr/local/apache --enable-so --enable-deflate=shared --enable-ssl=shared --enable-expires=shared  --enable-headers=shared --enable-rewrite=shared --enable-static-support  --with-included-apr --enable-modules=all --enable-mods-shared=all --with-mpm=prefork 2>/root/lamp_errors.log
code=$?
error_control $code "httpd-2.4.3"
parallel_make 2>/root/lamp_errors.log
code=$?
error_control $code "httpd-2.4.3"
make install
\cp -f $cur_dir/conf/httpd.init /etc/init.d/httpd
chmod +x /etc/init.d/httpd
chkconfig --add httpd
chkconfig httpd on
rm -f /etc/httpd
ln -s /usr/local/apache/ /etc/httpd
cd /usr/sbin/
ln -fs /usr/local/apache/bin/httpd
ln -fs /usr/local/apache/bin/apachectl
cd /var/log
rm -rf httpd/
ln -s /usr/local/apache/logs httpd
groupadd apache
useradd -g apache apache
mkdir -p /data/www/default/
chmod -R 755 /data/www/default/
#
\cp -f $cur_dir/conf/httpd2.4.conf /usr/local/apache/conf/httpd.conf
\cp -f $cur_dir/conf/httpd-default.conf /usr/local/apache/conf/extra/httpd-default.conf
\cp -f $cur_dir/conf/index.html /data/www/default/index.html
\cp -f $cur_dir/conf/lamp.gif /data/www/default/lamp.gif
\cp -f $cur_dir/conf/p.php /data/www/default/p.php
\cp -f $cur_dir/conf/jquery-1.9.0.min.js /data/www/default/jquery-1.9.0.min.js
\cp -f $cur_dir/conf/phpinfo.php /data/www/default/phpinfo.php
echo "============================apache2.4 install completed==================================="
else
echo "============================apache had been installed!===================================="
fi
}
#===============================================================================================
#DESCRIPTION:install mysql.
#USAGE:install_mysql
#===============================================================================================
function install_mysql(){
if [ ! -d /usr/local/mysql ];then
#install MySQL5.5.29
echo "============================Start install MySQL5.5.29====================================="
cd $cur_dir/
/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql
cd $cur_dir/untar/mysql-5.5.29

cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_UNIX_ADDR=/usr/local/mysql/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS=complex -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1 2>/root/lamp_errors.log
code=$?
error_control $code "mysql-5.5.29"
parallel_make 2>/root/lamp_errors.log
code=$?
error_control $code "mysql-5.5.29"
make install
chmod +w /usr/local/mysql
chown -R mysql:mysql /usr/local/mysql
cd support-files/
\cp -f $cur_dir/conf/my5.5.cnf /etc/my.cnf
#if [ -d "/proc/vz" ];then
#sed -i "/\[mysqld\]/a \
#default-storage-engine = MyISAM\n\
#innodb=OFF\n\
#skip-innodb " /etc/my.cnf
#fi
\cp -f mysql.server /etc/rc.d/init.d/mysqld
sed -i "s:^datadir=.*:datadir=$mysqldata:g" /etc/init.d/mysqld
/usr/local/mysql/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=$mysqldata --user=mysql

chmod +x /etc/rc.d/init.d/mysqld
chkconfig --add mysqld
chkconfig  mysqld on
cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib/mysql
/usr/local/lib
EOF
ldconfig
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
ln -s /usr/local/mysql/lib/mysql /usr/lib64/mysql
else
ln -s /usr/local/mysql/lib/mysql /usr/lib/mysql
fi
ln -s /usr/local/mysql/bin/mysql /usr/bin
ln -s /usr/local/mysql/bin/mysqladmin /usr/bin
#Start mysqld service
service mysqld start
/usr/local/mysql/bin/mysqladmin password $mysqlrootpwd
mysql -uroot -p$mysqlrootpwd <<EOF
drop database test;
delete from mysql.user where user='';
update mysql.user set password=password('$mysqlrootpwd') where user='root';
delete from mysql.user where not (user='root') ;
flush privileges;
exit
EOF
echo "============================MySQL5.5.29 install completed================================="
else
echo "============================MySQL5.5.29 had been installed!==============================="
fi
}

#===============================================================================================
#DESCRIPTION:install libiconv.
#USAGE:install_libiconv
#===============================================================================================
function install_libiconv(){
if [ ! -d /usr/local/libiconv ];then
cd $cur_dir/untar/libiconv-1.14
./configure --prefix=/usr/local/libiconv 2>/root/lamp_errors.log
code=$?
error_control $code "libiconv-1.14"
parallel_make 2>/root/lamp_errors.log
code=$?
error_control $code "libiconv-1.14"
make install
else
echo "============================libiconv had been installed!=================================="
fi
}

#===============================================================================================
#DESCRIPTION:install libmcrypt.
#USAGE:install_libmcrypt
#===============================================================================================
function install_libmcrypt(){
cd $cur_dir/untar/libmcrypt-2.5.8
./configure --prefix=/usr 2>/root/lamp_errors.log
code=$?
error_control $code "libmcrypt-2.5.8"
make  2>/root/lamp_errors.log
code=$?
error_control $code "libmcrypt-2.5.8"
make install
echo "============================libmcrypt-2.5.8 install completed!============================"
}

#===============================================================================================
#DESCRIPTION:install mhash.
#USAGE:install_mhash
#===============================================================================================
function install_mhash(){
cd $cur_dir/untar/mhash-0.9.9.9
./configure --prefix=/usr 2>/root/lamp_errors.log
code=$?
error_control $code "mhash-0.9.9.9"
parallel_make 2>/root/lamp_errors.log
code=$?
error_control $code "mhash-0.9.9.9"
make install
echo "============================mhash-0.9.9.9 install completed!=============================="
}

#===============================================================================================
#DESCRIPTION:install mcrypt.
#USAGE:install_mcrypt
#===============================================================================================
function install_mcrypt(){
/sbin/ldconfig
cd $cur_dir/untar/mcrypt-2.6.8 
./configure 2>/root/lamp_errors.log
code=$?
error_control $code "mcrypt-2.6.8"
parallel_make 2>/root/lamp_errors.log
code=$?
error_control $code "mcrypt-2.6.8"
make install
echo "============================mcrypt-2.6.8 install completed!==============================="
}

#===============================================================================================
#DESCRIPTION:install re2c.
#USAGE:install_re2c
#===============================================================================================
function install_re2c(){
#install re2c-0.13.5
cd $cur_dir/untar/re2c-0.13.5
./configure 2>/root/lamp_errors.log
code=$?
error_control $code "re2c-0.13.5"
parallel_make 2>/root/lamp_errors.log
code=$?
error_control $code "re2c-0.13.5"
make install
echo "============================re2c-0.13.5 install completed!================================"
}

#===============================================================================================
#DESCRIPTION:install php.
#USAGE:install_php
#===============================================================================================
function install_php(){
if [ ! -d /usr/local/php ];then
#install PHP5.3.20
echo "============================Start install PHP5.3.20======================================="
#ldap module 
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
cp -frp /usr/lib64/libldap* /usr/lib/
ln -s /usr/lib64/libc-client.so /usr/lib/libc-client.so
fi
cd $cur_dir/untar/php-5.3.20
mkdir -p /usr/local/php
./configure --prefix=/usr/local/php --with-apxs2=/usr/local/apache/bin/apxs  --with-config-file-path=/usr/local/php/etc --with-mysqli=/usr/local/mysql/bin/mysql_config --with-mysql-sock=/usr/local/mysql/mysql.sock --with-config-file-scan-dir=/usr/local/php/php.d --with-openssl --with-zlib --with-curl --enable-ftp --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --with-xmlrpc --enable-calendar --with-imap --with-kerberos --with-imap-ssl --with-ldap --enable-bcmath --enable-exif --enable-wddx --enable-tokenizer --enable-simplexml --enable-sockets --enable-ctype --enable-gd-native-ttf --enable-mbstring --enable-intl --enable-xml --enable-dom --enable-json --enable-session --enable-soap --with-mcrypt --enable-zip --with-iconv=/usr/local/libiconv --with-mysql=/usr/local/mysql --with-icu-dir=/usr --with-mhash=/usr --with-pcre-dir --without-pear 2>/root/lamp_errors.log
code=$?
error_control $code
parallel_make 2>/root/lamp_errors.log
code=$?
error_control $code
make install
mkdir -p /usr/local/php/etc
mkdir -p /usr/local/php/php.d
\cp -f $cur_dir/conf/php5.3.ini /usr/local/php/etc/php.ini
rm -rf /etc/php.ini
ln -s /usr/local/php/etc/php.ini  /etc/php.ini
echo "============================PHP5.3.20 install completed!=================================="

#install ZendGuardLoader
cd $cur_dir
echo "============================ZendGuardLoader install======================================="
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	mkdir -p /usr/local/zend/
	cp $cur_dir/untar/ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so /usr/local/zend/
else
	mkdir -p /usr/local/zend/
	cp $cur_dir/untar/ZendGuardLoader-php-5.3-linux-glibc23-i386/php-5.3.x/ZendGuardLoader.so /usr/local/zend/
fi
#update php.ini
cat >>/usr/local/php/etc/php.ini<<EOF
[Zend Guard Loader] 

zend_extension="/usr/local/zend/ZendGuardLoader.so"
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
zend_loader.license_path=
EOF
chmod +x /usr/local/zend/*.so
echo "============================ZendGuardLoader install completed============================="

else
echo "============================PHP had been installed!======================================="
fi
}
#===============================================================================================
#DESCRIPTION:install phpmyadmin.
#USAGE:install_phpmyadmin
#===============================================================================================
function install_phpmyadmin(){
echo "============================phpMyAdmin3.5.6 install======================================="
cd $cur_dir
mv untar/phpMyAdmin-3.5.6-all-languages /data/www/default/phpmyadmin
\cp -f $cur_dir/conf/config.inc.php /data/www/default/phpmyadmin/config.inc.php
chmod -R 755 /data/www/default/phpmyadmin
mkdir -p /data/www/default/phpmyadmin/upload/
mkdir -p /data/www/default/phpmyadmin/save/
chmod 755 -R /data/www/default/phpmyadmin/upload/
chmod 755 -R /data/www/default/phpmyadmin/save/
chown -R apache:apache /data/www/default/phpmyadmin
chown -R apache:apache /data/www
#Start httpd service
service httpd start
echo "============================phpMyAdmin3.5.6 install completed============================="
}

#===============================================================================================
#DESCRIPTION:install lamp.
#USAGE:install_lamp
#===============================================================================================
function install_lamp(){
rootness
pre_installation_settings
download_files "mysql-5.5.29.tar.gz" 
download_files "php-5.3.20.tar.gz"
download_files "httpd-2.4.3.tar.gz" 
download_files "apr-1.4.6.tar.gz"
download_files "apr-util-1.4.1.tar.gz"
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
download_files "ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz"
else
download_files "ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz"
fi
download_files "phpMyAdmin-3.5.6-all-languages.tar.gz"
download_files "libiconv-1.14.tar.gz"
download_files "libmcrypt-2.5.8.tar.gz"
download_files "mhash-0.9.9.9.tar.gz"
download_files "mcrypt-2.6.8.tar.gz"
download_files "re2c-0.13.5.tar.gz"
#untar all files
rm -rf $cur_dir/untar
mkdir -p $cur_dir/untar
echo "============================untar all files,please wait a moment...======================="
for file in `ls *.tar.gz` ;
do
tar -zxf $file -C $cur_dir/untar
done
echo "============================untar all files completed!...================================="
install_apache
install_mysql
install_libiconv
install_libmcrypt
install_mhash
install_mcrypt
install_re2c
install_php
install_phpmyadmin
\cp -f $cur_dir/lamp.sh /usr/bin/lamp
\cp -f $cur_dir/conf/httpd.logrotate /etc/logrotate.d/httpd
sed -i '/Order/,/All/d' /usr/bin/lamp
sed -i "/AllowOverride All/i\Require all granted" /usr/bin/lamp
rm -rf $cur_dir/untar
echo "============================LAMP install completed!======================================="
echo "MySQL root password:$mysqlrootpwd"
echo "Default Documentroot:/data/www/default"
echo "Installed Apache version:2.4.3"
echo "Installed PHP version:5.3.20"
echo "Installed phpMyAdmin version:3.5.6"
echo "enjoy it!"
exit 0
}

#===============================================================================================
#DESCRIPTION:uninstall lamp.
#USAGE:uninstall_lamp
#===============================================================================================
function uninstall_lamp(){
while true
do
read -p "(Before uninstall,please backup your data!Are you sure uninstall the lamp?[y/N]):" uninstall
case $uninstall in
y|Y|YES|yes|Yes)
uninstall=y
break
;;
n|N|no|NO|No)
uninstall=n
break
;;
*) echo Please enter only y or n
esac
done
if [ "$uninstall" = "y" ]  ;then
killall httpd
killall mysqld
rm -rf /usr/local/apache/ /etc/init.d/httpd /usr/local/apache /usr/sbin/httpd /usr/sbin/apachectl /var/log/httpd /var/lock/subsys/httpd /var/spool/mail/apache /etc/logrotate.d/httpd
rm -rf /usr/local/mysql/ /etc/my.cnf /etc/rc.d/init.d/mysqld /etc/ld.so.conf.d/mysql.conf /usr/bin/mysql /var/lock/subsys/mysql /var/spool/mail/mysql
rm -rf /usr/local/php/ /usr/lib/php 
rm -rf /usr/local/zend/
rm -rf /data/www/default/phpmyadmin
rm -rf /etc/pure-ftpd.conf
rm -rf /usr/bin/lamp
rm -rf /root/my.cnf
echo "============================Successfully uninstall LAMP!!================================="
fi
}

action=$1
[  -z $1 ] && action=install
case "$action" in
install)
    install_lamp
    ;;
uninstall)
    uninstall_lamp
    ;;
*)
    echo "Usage: `basename $0` {install|uninstall}"
    ;;
esac
