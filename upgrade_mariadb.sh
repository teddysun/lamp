#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   System Required:  CentOS / RedHat / Fedora
#   Description:  Auto Update Script for MariaDB
#   Author: Teddysun <i@teddysun.com>
#   Intro:  http://teddysun.com/lamp
#===============================================================================================
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi

if [ ! -d /usr/local/mariadb ]; then
    echo "Error:MariaDB looks like not installed, please check it and try again."
    exit 1
fi

clear
echo "#############################################################"
echo "# Auto Update Script for MariaDB"
echo "# System Required:  CentOS / RedHat / Fedora"
echo "# Intro: http://teddysun.com/lamp"
echo ""
echo "# Author: Teddysun <i@teddysun.com>"
echo ""
echo "#############################################################"
echo ""

cur_dir=`pwd`
bkup_dir="$cur_dir/mysql_bkup"
update_date=`date +"%Y%m%d"`
mysql_dump="/$bkup_dir/mysql_all_backup_$update_date.dump"

LATEST_MARIADB=$(curl -s https://downloads.mariadb.org/ | awk -F/ '/\/mariadb\/5.5/{print $3}' )
INSTALLED_MARIADB=$(/usr/local/mariadb/bin/mysql -V | awk '{print $5}' | tr -d "," | cut -d- -f1)

echo -e "Latest version of MariaDB: \033[41;37m $LATEST_MARIADB \033[0m"
echo -e "Installed version of MariaDB: \033[41;37m $INSTALLED_MARIADB \033[0m"
echo ""
echo "Do you want to upgrade MariaDB ? (y/n)"
read -p "(Default: n):" UPGRADE_MARIADB
if [ -z $UPGRADE_MARIADB ]; then
    UPGRADE_MARIADB="n"
fi

# Download && Untar files
function untar(){
    local TARBALL_TYPE
    if [ -n $1 ]; then
        SOFTWARE_NAME=`echo $1 | awk -F/ '{print $NF}'`
        TARBALL_TYPE=`echo $1 | awk -F. '{print $NF}'`
        wget -c -t3 -T3 $1 -P $cur_dir/
        if [ $? -ne 0 ];then
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
        xz)
            tar Jxf $cur_dir/$SOFTWARE_NAME -C $cur_dir/ && cd $cur_dir/$EXTRACTED_DIR || return 1
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
    read -p "Please input your MariaDB root password:" mysql_root_password
    /usr/local/mariadb/bin/mysql -uroot -p$mysql_root_password <<EOF
exit
EOF
    if [ $? -eq 0 ]; then
        echo "MariaDB root password is correct.";
    else
        echo "MariaDB root password incorrect! Please check it and try again!"
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

# Backup MariaDB
function backup_mariadb() {
    echo "Starting backup all of databases, Please wait a moment..."
    /usr/local/mariadb/bin/mysqldump -uroot -p$mysql_root_password --all-databases > $mysql_dump
    if [ $? -eq 0 ]; then
        echo "MariaDB all of databases backup success.";
    else
        echo "MariaDB all of databases backup failed, Please check it!"
        exit 1
    fi
    echo "Stoping MariaDB..."
    /etc/init.d/mysqld stop
    cp /etc/init.d/mysqld /$bkup_dir/mysqld_$update_date.bak
}

# Start all of services 
function startall() {
    # Apache
    /etc/init.d/httpd start
    # MariaDB
    if [ -d "/proc/vz" ]; then
        ulimit -s unlimited
    fi
    /etc/init.d/mysqld start
    if [ $? -ne 0 ]; then
        echo "Starting MariaDB failed, Please check it!"
        exit 1
    fi
    /usr/local/mariadb/bin/mysqladmin password $mysql_root_password
    /usr/local/mariadb/bin/mysql -uroot -p$mysql_root_password <<EOF
drop database if exists test;
delete from mysql.user where user='';
update mysql.user set password=password('$mysql_root_password') where user='root';
delete from mysql.user where not (user='root') ;
flush privileges;
exit
EOF
    echo "Starting restore all of databases, Please wait a moment..."
    /usr/local/mariadb/bin/mysql -u root -p$mysql_root_password < $mysql_dump
    if [ $? -eq 0 ]; then
        echo "MariaDB all of databases restore success.";
    else
        echo "MariaDB all of databases restore failed, Please restore manually!"
        exit 1
    fi
    echo "Restart MariaDB..."
    /etc/init.d/mysqld restart
}

# MariaDB Update
function upgrade_mariadb() {
    # Backup installed folder
    if [[ -d "/usr/local/mariadb.bak" && -d "/usr/local/mariadb" ]];then
        rm -rf /usr/local/mariadb.bak/
    fi
    mv /usr/local/mariadb /usr/local/mariadb.bak
    cd $cur_dir
    if [ ! -s mariadb-$LATEST_MARIADB.tar.gz ]; then
        LATEST_MARIADB_LINK="http://mirror.jmu.edu/pub/mariadb/mariadb-$LATEST_MARIADB/source/mariadb-$LATEST_MARIADB.tar.gz"
        BACKUP_MARIADB_LINK="http://lamp.teddysun.com/files/mariadb-$LATEST_MARIADB.tar.gz"
        untar $LATEST_MARIADB_LINK $BACKUP_MARIADB_LINK
    else
        tar -zxf mariadb-$LATEST_MARIADB.tar.gz
        cd mariadb-$LATEST_MARIADB/
    fi
    datalocation=$(cat /$bkup_dir/mysqld_$update_date.bak | grep -w 'datadir=' | awk -F= '{print $2}' | head -1)
    # Compile MariaDB
    cmake \
    -DCMAKE_INSTALL_PREFIX=/usr/local/mariadb \
    -DMYSQL_DATADIR=$datalocation \
    -DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
    -DWITH_ARIA_STORAGE_ENGINE=1 \
    -DWITH_XTRADB_STORAGE_ENGINE=1 \
    -DWITH_ARCHIVE_STORAGE_ENGINE=1 \
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    -DWITH_PARTITION_STORAGE_ENGINE=1 \
    -DWITH_FEDERATEDX_STORAGE_ENGINE=1 \
    -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
    -DWITH_MYISAM_STORAGE_ENGINE=1 \
    -DWITH_READLINE=1 \
    -DENABLED_LOCAL_INFILE=1 \
    -DDEFAULT_CHARSET=utf8 \
    -DDEFAULT_COLLATION=utf8_general_ci \
    -DWITH_EMBEDDED_SERVER=1
    make && make install
    chmod +w /usr/local/mariadb
    chown -R mysql:mysql /usr/local/mariadb
    /usr/local/mariadb/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mariadb --datadir=$datalocation --user=mysql
    cat > /etc/ld.so.conf.d/mariadb.conf<<EOF
/usr/local/mariadb/lib
/usr/local/lib
EOF
    ldconfig
    cp -f $cur_dir/mariadb-$LATEST_MARIADB/support-files/mysql.server /etc/init.d/mysqld
    sed -i "s:^datadir=.*:datadir=$datalocation:g" /etc/init.d/mysqld
    chmod 755 /etc/init.d/mysqld
}

# Clean up
function clear_up() {
    cd $cur_dir
    rm -rf mariadb-$LATEST_MARIADB/
    echo ""
    echo "MariaDB Upgrade completed!"
    echo "Welcome to visit:http://teddysun.com/lamp"
    echo "Enjoy it!"
    echo ""
}

if [[ "$UPGRADE_MARIADB" = "y" || "$UPGRADE_MARIADB" = "Y" ]];then
    pre_setting
    stopall
    backup_mariadb
    upgrade_mariadb
    startall
    clear_up
else
    echo "Upgrade cancelled, nothing to do"
fi
