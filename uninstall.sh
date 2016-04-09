#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#=======================================================================#
#   System Required:  CentOS/RadHat 5+ / Debian 7+ / Ubuntu 12+         #
#   Description:  Uninstall LAMP(Linux + Apache + MySQL + PHP )         #
#   Author: Teddysun <i@teddysun.com>                                   #
#   Intro:  https://lamp.sh                                             #
#=======================================================================#

cur_dir=`pwd`


upcase_to_lowcase(){
    words=$1
    echo $words | tr '[A-Z]' '[a-z]'
}

#Check system
check_sys(){
    local checkType=$1
    local value=$2

    local release=''
    local systemPackage=''

    if [[ -f /etc/redhat-release ]];then
        release="centos"
        systemPackage="yum"
    elif cat /etc/issue | grep -q -E -i "debian";then
        release="debian"
        systemPackage="apt"
    elif cat /etc/issue | grep -q -E -i "ubuntu";then
        release="ubuntu"
        systemPackage="apt"
    elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat";then
        release="centos"
        systemPackage="yum"
    elif cat /proc/version | grep -q -E -i "debian";then
        release="debian"
        systemPackage="apt"
    elif cat /proc/version | grep -q -E -i "ubuntu";then
        release="ubuntu"
        systemPackage="apt"
    elif cat /proc/version | grep -q -E -i "centos|red hat|redhat";then
        release="centos"
        systemPackage="yum"
    fi

    if [[ ${checkType} == "sysRelease" ]]; then
        if [ "$value" == "$release" ];then
            return 0
        else
            return 1
        fi
    elif [[ ${checkType} == "packageManager" ]]; then
        if [ "$value" == "$systemPackage" ];then
            return 0
        else
            return 1
        fi
    fi
}


boot_stop(){
    if check_sys packageManager apt;then
        update-rc.d -f $1 remove
    elif check_sys packageManager yum;then
        chkconfig --del $1
    fi
}

uninstall(){

    echo "uninstalling Apache"
    [ -f /etc/init.d/httpd ] && /etc/init.d/httpd stop && boot_stop httpd
    rm -f /etc/init.d/httpd
    rm -rf /usr/local/apache /usr/sbin/httpd /var/log/httpd /etc/logrotate.d/httpd /var/spool/mail/apache
    echo "Sucess"

    echo "uninstalling MySQL/MariaDB"
    [ -f /etc/init.d/mysqld ] && /etc/init.d/mysqld stop && boot_stop mysqld
    rm -f /etc/init.d/mysqld
    rm -rf /usr/local/mysql /usr/local/mariadb /usr/bin/mysqldump /usr/bin/mysql /etc/my.cnf /etc/ld.so.conf.d/mysql.conf
    echo "Sucess"

    echo "uninstalling PHP"
    rm -rf /usr/local/php /usr/bin/php /usr/bin/php-config /usr/bin/phpize /etc/php.ini
    echo "Sucess"
    echo
    echo "uninstalling Others"
    [ -f /etc/init.d/memcached ] && /etc/init.d/memcached stop && boot_stop memcached
    rm -f /etc/init.d/memcached
    rm -fr /usr/local/memcached /usr/bin/memcached
    [ -f /etc/init.d/redis-server ] && /etc/init.d/redis-server stop && boot_stop redis-server
    rm -f /etc/init.d/redis-server
    rm -fr /etc/init.d/redis-server /usr/local/redis
    rm -rf /usr/local/libiconv /usr/lib64/libiconv.so.0 /usr/lib/libiconv.so.0
    rm -rf /usr/local/imap-2007f
    rm -rf /usr/local/pcre
    rm -rf /etc/ld.so.conf.d/local.conf
    rm -rf /data/www/default/phpmyadmin
    rm -rf /data/www/default/xcache /tmp/{pcov,phpcore}
    echo "Sucess"
    echo
    echo "Successfully uninstall LAMP!"
}

while :
do
    read -p "Are you sure uninstall LAMP? (Default: n) (y/n)" uninstall
    [ -z ${uninstall} ] && uninstall="n"
    uninstall="`upcase_to_lowcase ${uninstall}`"
    case ${uninstall} in
        y) uninstall ; break;;
        n) echo "Uninstall cancelled, nothing to do" ; break;;
        *) echo "input error";;
    esac
done
