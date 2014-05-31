#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   System Required:  CentOS5.x (32bit/64bit) or CentOS6.x (32bit/64bit)
#   Description:  Auto Update Script for MySQL
#   Author: Teddysun <i@teddysun.com>
#   Intro:  http://teddysun.com/lamp
#===============================================================================================
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi

clear
echo "#############################################################"
echo "# Auto Update Script for MySQL"
echo "# System Required:  CentOS5.x (32bit/64bit) or CentOS6.x (32bit/64bit)"
echo "# Intro: http://teddysun.com/lamp"
echo "#"
echo "# Author: Teddysun <i@teddysun.com>"
echo "#"
echo "#############################################################"
echo ""

cur_dir=`pwd`
bkup_dir="$cur_dir/mysql_bkup"
update_date=`date +"%Y%m%d"`
mysql_dump="/$bkup_dir/mysql_all_backup_$update_date.dump"

LATEST_MYSQL=$(curl -s http://dev.mysql.com/downloads/mysql/ | awk '/MySQL Community Server/{print $4}' | grep '5.6')
INSTALLED_MYSQL=$(/usr/local/mysql/bin/mysql -V | awk '{print $5}' | tr -d ",")

echo -e "Latest version of MYSQL: \033[41;37m $LATEST_MYSQL \033[0m"
echo -e "Installed version of MYSQL: \033[41;37m $INSTALLED_MYSQL \033[0m"
echo ""
echo "Do you want to upgrade MYSQL ? (y/n)"
read -p "(Default: n):" UPGRADE_MYSQL
if [ -z $UPGRADE_MYSQL ]; then
    UPGRADE_MYSQL="n"
fi

# Download && Untar files
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

# Prepare setting
function pre_setting() {
    if [ ! -d $bkup_dir ]; then
        mkdir -p $bkup_dir
    fi
    read -p "Please input your MySQL root password:" mysql_root_password
    /usr/local/mysql/bin/mysql -uroot -p$mysql_root_password <<EOF
exit
EOF
    if [ $? -eq 0 ]; then
        echo "MySQL root password is correct.";
    else
        echo "MySQL root password incorrect! Please check it and try again!"
        exit 1
    fi
}

# Stop all of services 
function stopall() {
    ps -ef | grep -v grep | grep -v ps | grep -i "/usr/local/apache/bin/httpd" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Stoping Apache..."
        /etc/init.d/httpd stop
    fi
}

# Backup MySQL
function backup_mysql() {
    echo "Starting backup all of databases, Please wait a moment..."
    /usr/local/mysql/bin/mysqldump -uroot -p$mysql_root_password --all-databases > $mysql_dump
    if [ $? -eq 0 ]; then
        echo "MySQL all of databases backup success.";
    else
        echo "MySQL all of databases backup failed, Please check it!"
        exit 1
    fi
    echo "Stoping MySQL..."
    /etc/init.d/mysqld stop
    cp /etc/init.d/mysqld /$bkup_dir/mysqld_$update_date.bak
}

# Start all of services 
function startall() {
    # Apache
    /etc/init.d/httpd start
    # MySQL
    if [ -d "/proc/vz" ]; then
        ulimit -s unlimited
    fi
    /etc/init.d/mysqld start
    if [ $? -ne 0 ]; then
        echo "Starting MySQL failed, Please check it!"
        exit 1
    fi
    /usr/local/mysql/bin/mysqladmin password $mysql_root_password
    /usr/local/mysql/bin/mysql -uroot -p$mysql_root_password <<EOF
drop database if exists test;
delete from mysql.user where user='';
update mysql.user set password=password('$mysql_root_password') where user='root';
delete from mysql.user where not (user='root') ;
flush privileges;
exit
EOF
    echo "Starting restore all of databases, Please wait a moment..."
    /usr/local/mysql/bin/mysql -u root -p$mysql_root_password < $mysql_dump
    if [ $? -eq 0 ]; then
        echo "MySQL all of databases restore success.";
    else
        echo "MySQL all of databases restore failed, Please restore manually!"
        exit 1
    fi
    echo "Restart MySQL..."
    /etc/init.d/mysqld restart
}

# MYSQL Update
function upgrade_mysql() {
    # Backup installed folder
    if [[ -d "/usr/local/mysql.bak" && -d "/usr/local/mysql" ]];then
        rm -rf /usr/local/mysql.bak/
    fi
    mv /usr/local/mysql /usr/local/mysql.bak
    cd $cur_dir
    if [ ! -s mysql-$LATEST_MYSQL.tar.gz ]; then
        LATEST_MYSQL_LINK="http://cdn.mysql.com/Downloads/MySQL-5.6/mysql-$LATEST_MYSQL.tar.gz"
        BACKUP_MYSQL_LINK="http://lamp.teddysun.com/files/mysql-$LATEST_MYSQL.tar.gz"
        untar $LATEST_MYSQL_LINK $BACKUP_MYSQL_LINK
    else
        tar -zxf mysql-$LATEST_MYSQL.tar.gz
        cd mysql-$LATEST_MYSQL/
    fi
    # Compile MySQL
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_UNIX_ADDR=/usr/local/mysql/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS=complex -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1
    make && make install
    chmod +w /usr/local/mysql
    chown -R mysql:mysql /usr/local/mysql
    mysqldata=$(cat /$bkup_dir/mysqld_$update_date.bak | grep -w 'datadir=' | awk -F= '{print $2}' | head -1)
    /usr/local/mysql/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=$mysqldata --user=mysql
    cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib
/usr/local/lib
EOF
    cp -f $cur_dir/mysql-$LATEST_MYSQL/support-files/mysql.server /etc/init.d/mysqld
    sed -i "s:^datadir=.*:datadir=$mysqldata:g" /etc/init.d/mysqld
    chmod 755 /etc/init.d/mysqld
    ldconfig
}

# Clean up
function clear_up() {
    cd $cur_dir
    rm -rf mysql-$LATEST_MYSQL/
    echo ""
    echo "MySQL Upgrade completed!"
    echo "Welcome to visit:http://teddysun.com/lamp"
    echo "Enjoy it! ^_^"
    echo ""
}

if [[ "$UPGRADE_MYSQL" = "y" || "$UPGRADE_MYSQL" = "Y" ]];then
    pre_setting
    stopall
    backup_mysql
    upgrade_mysql
    startall
    clear_up
else
    echo "Upgrade cancelled, nothing to do"
fi
