#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================
#   SYSTEM REQUIRED:  CentOS-5 (32bit/64bit) or CentOS-6 (32bit/64bit)
#   DESCRIPTION:  OCI8 for LAMP
#   AUTHOR: Teddysun <i@teddysun.com>
#   VISIT:  https://code.google.com/p/teddysun/
#===============================================================================

#===============================================================================
#DESCRIPTION:Make sure only root can run our script
#USAGE:rootness
#===============================================================================
function rootness(){
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
#
cur_dir=`pwd`
cd $cur_dir
#
yum -y install libaio
}

#===============================================================================
#DESCRIPTION:Download files.
#USAGE:download_files [filename] [secondary url] 
#===============================================================================
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

#===============================================================================
#DESCRIPTION:Install oracle instantclient11.2.
#USAGE:install_instant
#===============================================================================
function install_instant(){
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	rpm -ivh oracle-instantclient11.2-basic-11.2.0.3.0-1.x86_64.rpm
	rpm -ivh oracle-instantclient11.2-devel-11.2.0.3.0-1.x86_64.rpm
else
	rpm -ivh oracle-instantclient11.2-basic-11.2.0.3.0-1.i386.rpm
	rpm -ivh oracle-instantclient11.2-devel-11.2.0.3.0-1.i386.rpm
fi
}

#===============================================================================
#DESCRIPTION:Recompile PHP extension oci8.
#USAGE:recompile_oci8
#===============================================================================
function recompile_oci8(){
echo "============================oci8 install======================================================="
cd $cur_dir/untar/oci8-1.4.9
export PHP_PREFIX="/usr/local/php"
$PHP_PREFIX/bin/phpize
./configure --with-php-config=$PHP_PREFIX/bin/php-config
make && make install
cat >>/usr/local/php/etc/php.ini<<-EOF

[OCI8]
extension = /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/oci8.so

oci8.privileged_connect = Off
oci8.max_persistent = -1
oci8.persistent_timeout = -1
oci8.ping_interval = 60
oci8.connection_class =
oci8.events = Off
oci8.statement_cache_size = 20
oci8.default_prefetch = 100
oci8.old_oci_close_semantics = Off
EOF
#
service httpd restart
echo "============================oci8 install completed============================================"
exit
}
#===============================================================================
#DESCRIPTION:Install oci8.
#USAGE:install_oci8
#===============================================================================
function install_oci8(){
rootness
download_files "oci8-1.4.9.tgz"
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	download_files "oracle-instantclient11.2-basic-11.2.0.3.0-1.x86_64.rpm"
	download_files "oracle-instantclient11.2-devel-11.2.0.3.0-1.x86_64.rpm"
else
	download_files "oracle-instantclient11.2-basic-11.2.0.3.0-1.i386.rpm"
	download_files "oracle-instantclient11.2-devel-11.2.0.3.0-1.i386.rpm"
fi
rm -rf $cur_dir/untar
mkdir -p $cur_dir/untar
tar xzf oci8-1.4.9.tgz -C $cur_dir/untar/
install_instant
recompile_oci8
}

action=$1
[ -z $1 ] && action=install
case "$action" in
install)
    install_oci8
    ;;
*)
    echo "Usage: `basename $0` {install}"
    ;;
esac

