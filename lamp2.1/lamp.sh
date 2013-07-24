#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   System Required:  CentOS5.x (32bit/64bit) or CentOS6.x (32bit/64bit)
#   Description:  Install LAMP(Linux + Apache + MySQL + PHP ) for CentOS
#   Author: Teddysun <i@teddysun.com>
#   Intro:  https://code.google.com/p/teddysun/
#           http://teddysun.com/lamp
#===============================================================================================

#===============================================================================================
#Description:Install LAMP Script.
#Usage:install_lamp
#===============================================================================================
function install_lamp(){
rootness
disable_selinux
pre_installation_settings
download_files "mysql-5.6.12.tar.gz" 
download_files "php-5.4.17.tar.gz"
download_files "httpd-2.4.6.tar.gz" 
download_files "phpMyAdmin-4.0.4.1-all-languages.tar.gz"
download_files "apr-1.4.8.tar.gz"
download_files "apr-util-1.5.2.tar.gz"
download_files "libiconv-1.14.tar.gz"
download_files "libmcrypt-2.5.8.tar.gz"
download_files "mhash-0.9.9.9.tar.gz"
download_files "mcrypt-2.6.8.tar.gz"
download_files "re2c-0.13.5.tar.gz"
#Untar all files
rm -rf $cur_dir/untar
mkdir -p $cur_dir/untar
echo "============================Untar all files,please wait a moment...======================="
for file in `ls *.tar.gz` ;
do
tar -zxf $file -C $cur_dir/untar
done
echo "============================Untar all files completed!===================================="
install_apache
install_mysql
install_libiconv
install_libmcrypt
install_mhash
install_mcrypt
install_re2c
install_php
install_phpmyadmin
cp -f $cur_dir/lamp.sh /usr/bin/lamp
cp -f $cur_dir/conf/httpd.logrotate /etc/logrotate.d/httpd
sed -i '/Order/,/All/d' /usr/bin/lamp
sed -i "/AllowOverride All/i\Require all granted" /usr/bin/lamp
rm -rf $cur_dir/untar
clear
echo "============================LAMP install completed!======================================="
echo ""
echo "MySQL root password:$mysqlrootpwd"
echo "MySQL data location:$mysqldata"
echo "Default Document Root:/data/www/default"
echo "Installed Apache version:2.4.6"
echo "Installed MySQL version:5.6.12"
echo "Installed PHP version:5.4.17"
echo "Installed phpMyAdmin version:4.0.4.1"
echo "Welcome to visit:http://teddysun.com/lamp"
echo "Enjoy it! ^_^"
echo ""
echo "=========================================================================================="
echo ""
}

#===============================================================================================
#Description:Make sure only root can run our script
#Usage:rootness
#===============================================================================================
function rootness(){
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi
}

#===============================================================================================
#Description:Disable selinux
#Usage:disable_selinux
#===============================================================================================
function disable_selinux(){
if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	setenforce 0
fi
}

#===============================================================================================
#Description:Pre-installation settings.
#Usage:pre_installation_settings
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
echo "Press any key to start...or Press Ctrl+C to cancel"
char=`get_char`
#Remove Packages
rpm -e httpd
rpm -e mysql
rpm -e php
yum -y remove httpd
yum -y remove mysql
yum -y remove php
#Set timezone
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
yum -y install ntp
ntpdate -d cn.pool.ntp.org
#Install necessary tools
if [ ! -s /etc/yum.conf.bak ]; then
	cp /etc/yum.conf /etc/yum.conf.bak
fi
sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf
for packages in autoconf automake bison bzip2 bzip2-devel curl curl-devel cmake cpp crontabs diffutils elinks e2fsprogs-devel expat-devel file flex freetype-devel gcc gcc-c++ gd glibc-devel glib2-devel gettext-devel icu kernel-devel libtool-libs libjpeg-devel libpng-devel libxml2-devel libidn-devel libcap-devel libtool-ltdl-devel libmcrypt-devel libc-client-devel libxml2 libxml2-devel libicu libicu-devel wget zlib-devel zip unzip patch mlocate make ncurses-devel readline-devel vim-minimal sendmail pam-devel pcre-devel openldap openldap-devel openssl-devel;
do yum -y install $packages; done
#Current folder
cur_dir=`pwd`
cd $cur_dir
}

#===============================================================================================
#Description:download files.
#Usage:download_files [filename]
#===============================================================================================
function download_files(){
if [ -s $1 ]; then
  echo "$1 [found]"
else
 echo "$1 not found!!!download now......"
 if ! wget -c http://teddysun.googlecode.com/files/$1;then
	echo "Failed to download $1,please download it to "$cur_dir" directory manually and rerun the install script."
	exit 1
 fi
fi
}

#===============================================================================================
#Description:Install Apache.
#Usage:install_apache
#===============================================================================================
function install_apache(){
if [ ! -d /usr/local/apache/bin ];then
#install Apache2.4.6
echo "============================Start install Apache2.4.6====================================="
mv $cur_dir/untar/apr-1.4.8 $cur_dir/untar/httpd-2.4.6/srclib/apr
mv $cur_dir/untar/apr-util-1.5.2 $cur_dir/untar/httpd-2.4.6/srclib/apr-util
cd $cur_dir/untar/httpd-2.4.6
./configure --prefix=/usr/local/apache --enable-so --enable-deflate=shared --enable-ssl=shared --enable-expires=shared  --enable-headers=shared --enable-rewrite=shared --enable-static-support  --with-included-apr --enable-modules=all --enable-mods-shared=all --with-mpm=prefork
make install
cp -f $cur_dir/conf/httpd.init /etc/init.d/httpd
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
cp -f $cur_dir/conf/httpd2.4.conf /usr/local/apache/conf/httpd.conf
cp -f $cur_dir/conf/httpd-vhosts.conf /usr/local/apache/conf/extra/httpd-vhosts.conf
cp -f $cur_dir/conf/httpd-default.conf /usr/local/apache/conf/extra/httpd-default.conf
mkdir -p /usr/local/apache/conf/vhost/
touch /usr/local/apache/conf/vhost/none.conf
cp -f $cur_dir/conf/index.html /data/www/default/index.html
cp -f $cur_dir/conf/lamp.gif /data/www/default/lamp.gif
cp -f $cur_dir/conf/p.php /data/www/default/p.php
cp -f $cur_dir/conf/jquery-1.9.0.min.js /data/www/default/jquery-1.9.0.min.js
cp -f $cur_dir/conf/phpinfo.php /data/www/default/phpinfo.php
echo "============================apache2.4.6 install completed==================================="
else
	echo "============================apache had been installed!===================================="
fi
}
#===============================================================================================
#Description:install mysql.
#Usage:install_mysql
#===============================================================================================
function install_mysql(){
if [ ! -d /usr/local/mysql ];then
#install MySQL5.6.12
echo "============================Start install MySQL5.6.12====================================="
cd $cur_dir/
/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql
cd $cur_dir/untar/mysql-5.6.12
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_UNIX_ADDR=/usr/local/mysql/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS=complex -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1
make install
chmod +w /usr/local/mysql
chown -R mysql:mysql /usr/local/mysql
cd support-files/
cp -f $cur_dir/conf/my5.6.cnf /etc/my.cnf
cp -f mysql.server /etc/init.d/mysqld
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
echo "============================MySQL5.6.12 install completed================================="
else
echo "============================MySQL had been installed!====================================="
fi
}

#===============================================================================================
#Description:install libiconv.
#Usage:install_libiconv
#===============================================================================================
function install_libiconv(){
if [ ! -d /usr/local/libiconv ];then
cd $cur_dir/untar/libiconv-1.14
./configure --prefix=/usr/local/libiconv
make install
else
echo "============================libiconv had been installed!=================================="
fi
}

#===============================================================================================
#Description:install libmcrypt.
#Usage:install_libmcrypt
#===============================================================================================
function install_libmcrypt(){
cd $cur_dir/untar/libmcrypt-2.5.8
./configure --prefix=/usr
make install
echo "============================libmcrypt-2.5.8 install completed!============================"
}

#===============================================================================================
#Description:install mhash.
#Usage:install_mhash
#===============================================================================================
function install_mhash(){
cd $cur_dir/untar/mhash-0.9.9.9
./configure --prefix=/usr
make install
echo "============================mhash-0.9.9.9 install completed!=============================="
}

#===============================================================================================
#Description:install mcrypt.
#Usage:install_mcrypt
#===============================================================================================
function install_mcrypt(){
/sbin/ldconfig
cd $cur_dir/untar/mcrypt-2.6.8 
./configure
make install
echo "============================mcrypt-2.6.8 install completed!==============================="
}

#===============================================================================================
#Description:install re2c.
#Usage:install_re2c
#===============================================================================================
function install_re2c(){
#install re2c-0.13.5
cd $cur_dir/untar/re2c-0.13.5
./configure
make install
echo "============================re2c-0.13.5 install completed!================================"
}

#===============================================================================================
#Description:install php.
#Usage:install_php
#===============================================================================================
function install_php(){
if [ ! -d /usr/local/php ];then
#install PHP5.4.17
echo "============================Start install PHP5.4.17======================================="
#ldap module 
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	cp -frp /usr/lib64/libldap* /usr/lib/
	ln -s /usr/lib64/libc-client.so /usr/lib/libc-client.so
fi
cd $cur_dir/untar/php-5.4.17
./configure --prefix=/usr/local/php --with-apxs2=/usr/local/apache/bin/apxs  --with-config-file-path=/usr/local/php/etc --with-mysqli=/usr/local/mysql/bin/mysql_config --with-mysql-sock=/usr/local/mysql/mysql.sock --with-config-file-scan-dir=/usr/local/php/php.d --with-openssl --with-zlib --with-curl --enable-ftp --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --with-xmlrpc --enable-calendar --with-imap --with-kerberos --with-imap-ssl --with-ldap --enable-bcmath --enable-exif --enable-wddx --enable-tokenizer --enable-simplexml --enable-sockets --enable-ctype --enable-gd-native-ttf --enable-mbstring --enable-intl --enable-xml --enable-dom --enable-json --enable-session --enable-soap --with-mcrypt --enable-zip --with-iconv=/usr/local/libiconv --with-mysql=/usr/local/mysql --with-icu-dir=/usr --with-mhash=/usr --with-pcre-dir --without-pear
make install
mkdir -p /usr/local/php/etc
mkdir -p /usr/local/php/php.d
cp -f $cur_dir/conf/php5.4.ini /usr/local/php/etc/php.ini
rm -rf /etc/php.ini
ln -s /usr/local/php/etc/php.ini  /etc/php.ini
ln -s /usr/local/php/bin/php /usr/bin/php
echo "============================PHP5.4.17 install completed!=================================="
else
echo "============================PHP had been installed!======================================="
fi
}
#===============================================================================================
#Description:install phpmyadmin.
#Usage:install_phpmyadmin
#===============================================================================================
function install_phpmyadmin(){
echo "============================phpMyAdmin4.0.4.1 install======================================="
cd $cur_dir
mv untar/phpMyAdmin-4.0.4.1-all-languages /data/www/default/phpmyadmin
cp -f $cur_dir/conf/config.inc.php /data/www/default/phpmyadmin/config.inc.php
chmod -R 755 /data/www/default/phpmyadmin
mkdir -p /data/www/default/phpmyadmin/upload/
mkdir -p /data/www/default/phpmyadmin/save/
chown -R apache:apache /data/www
#Start httpd service
service httpd start
echo "============================phpMyAdmin4.0.4.1 install completed============================="
}

#===============================================================================================
#Description:uninstall lamp.
#Usage:uninstall_lamp
#===============================================================================================
function uninstall_lamp(){
echo "Are you sure uninstall LAMP? (y/n)"
read -p "(Default: n):" uninstall
if [ -z $uninstall ]; then
	uninstall="n"
fi
if [ "$uninstall" != "y" ]; then
	clear
	echo "==========================="
	echo "You canceled the uninstall!"
	echo "==========================="
	exit
else
	echo "---------------------------"
	echo "Yes, I agreed to uninstall!"
	echo "---------------------------"
	echo ""
fi

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
echo "Press any key to start uninstall..."
echo "or Press Ctrl+c to cancel"
char=`get_char`
echo ""
if [ "$uninstall" == "y" ]  ;then
killall httpd
killall mysqld
rm -rf /usr/local/apache/ /etc/init.d/httpd /usr/local/apache /usr/sbin/httpd /usr/sbin/apachectl /var/log/httpd /var/lock/subsys/httpd /var/spool/mail/apache /etc/logrotate.d/httpd
rm -rf /usr/local/mysql/ /etc/my.cnf /etc/rc.d/init.d/mysqld /etc/ld.so.conf.d/mysql.conf /usr/bin/mysql /var/lock/subsys/mysql /var/spool/mail/mysql
rm -rf /usr/local/php/ /usr/lib/php 
#rm -rf /usr/local/zend/
rm -rf /data/www/default/phpmyadmin
rm -rf /etc/pure-ftpd.conf
rm -rf /usr/bin/lamp
echo "============================Successfully uninstall LAMP!!================================="
fi
}

#===============================================================================
#Description:Add apache virtualhost.
#Usage:vhost_add
#===============================================================================
function vhost_add(){
#Define domain name
read -p "(Please input domains such as:www.example.com):" domains
if [ "$domains" = "" ]; then
	echo "You need input a domain."
	exit 1
fi
domain=`echo $domains | awk '{print $1}'`
if [ -f "/usr/local/apache/conf/vhost/$domain.conf" ]; then
	echo "$domain is exist!"
	exit
fi
#Define website dir
webdir="/data/www/$domain"
DocumentRoot="$webdir/web"
logsdir="$webdir/logs"
mkdir -p $DocumentRoot $logsdir
#Create database or not	
while true
do
read -p "(Do you want to create database?[y/N]):" create
case $create in
y|Y|YES|yes|Yes)
read -p "(Please input the user root password of MySQL):" mysqlroot_passwd
read -p "(Please input the database name):" dbname
read -p "(Please set the password for mysql user $dbname):" mysqlpwd
create=y
break
;;
n|N|no|NO|No)
echo "Not create database, you entered $create"
create=n
break
;;
*) echo Please input only y or n
esac
done
#Create database
if [ "$create" == "y" ];then
mysql -uroot -p"$mysqlroot_passwd"  <<EOF
CREATE DATABASE IF NOT EXISTS \`$dbname\`;
GRANT ALL PRIVILEGES ON \`$dbname\` . * TO '$dbname'@'localhost' IDENTIFIED BY '$mysqlpwd';
GRANT ALL PRIVILEGES ON \`$dbname\` . * TO '$dbname'@'127.0.0.1' IDENTIFIED BY '$mysqlpwd';
FLUSH PRIVILEGES;
EOF
fi
#Create vhost configuration file
cat >/usr/local/apache/conf/vhost/$domain.conf<<eof
<virtualhost *:80>
ServerName  $domain
ServerAlias  $domains 
DocumentRoot  $DocumentRoot
CustomLog $logsdir/access.log combined
DirectoryIndex index.php index.html
<Directory $DocumentRoot>
Options +Includes -Indexes
AllowOverride All
Order Deny,Allow
Allow from All
php_admin_value open_basedir $DocumentRoot:/tmp
</Directory>
</virtualhost>
eof
service httpd reload > /dev/null 2>&1
echo "Successfully create $domain vhost"
echo "######################### information about your website ############################"
echo "The DocumentRoot:$DocumentRoot"
echo "The Logsdir:$logsdir"
[ "$create" == "y" ] && echo "MySQL dbname and user:$dbname and password:$mysqlpwd"
}

#===============================================================================
#Description:Remove apache virtualhost.
#Usage:vhost_del
#===============================================================================
function vhost_del(){
read -p "(Please input a domain you want to delete):" vhost_domain
if [ "$vhost_domain" = "" ]; then
	echo "You need input a domain."
	exit 1
fi
echo "---------------------------"
echo "vhost account = $vhost_domain"
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
echo "Press any key to start delete vhost..."
echo "or Press Ctrl+c to cancel"
echo ""
char=`get_char`

if [ -f "/usr/local/apache/conf/vhost/$vhost_domain.conf" ]; then
	rm -rf /usr/local/apache/conf/vhost/$vhost_domain.conf
	rm -rf /data/www/$vhost_domain
else
	echo "Error!!No such domain file.Please check your input domain again..."
	exit 1
fi

service httpd reload > /dev/null 2>&1
echo "Successfully delete $vhost_domain vhost"
echo "You need to remove site directory manually!"
}

#===============================================================================
#Description:List apache virtualhost.
#Usage:vhost_list
#===============================================================================
function vhost_list(){
ls /usr/local/apache/conf/vhost/ | cut -f 1,2,3 -d "."
}

#===============================================================================
#Description:add,del,list ftp user.
#Usage:ftp (add|del|list)
#===============================================================================
function ftp(){
case "$faction" in
add)
read -p "(Please input ftpuser name):" ftpuser
read -p "(Please input ftpuser password):" ftppwd
read -p "(Please input ftpuser root directory):" ftproot
useradd -d $ftproot -g ftp -c pure-ftpd -s /sbin/nologin  $ftpuser
echo $ftpuser:$ftppwd |chpasswd
if [ -d "$ftproot" ]; then
	chmod -R 755 $ftproot
	chown -R $ftpuser:ftp $ftproot
fi
echo "Successfully create ftpuser $ftpuser"
echo "ftp root directory is $ftproot"
;;
del)
read -p "(Please input the ftpuser you want to delete):" ftpuser
userdel $ftpuser
echo "Successfully delete ftpuser $ftpuser"
;;
list)
printf "FTPUser\t\tRoot Directory\n"
cat /etc/passwd | grep pure-ftpd | awk 'BEGIN {FS=":"} {print $1"\t\t"$6}'
;;
*)
echo "Usage:add|del|list"
exit 1
esac
}

#===============================================================================================
#Description:Initialization step
#Usage:none
#===============================================================================================
action=$1
[  -z $1 ] && action=install
case "$action" in
install)
    install_lamp
    ;;
uninstall)
    uninstall_lamp
    ;;
add)
   vhost_add
    ;;
del)
   vhost_del
    ;;
list)
   vhost_list
    ;;
ftp)
  faction=$2
    ftp
        ;;
*)
    echo "Usage: `basename $0` {install|uninstall|add|del|list|ftp(add,del,list))"
    ;;
esac
