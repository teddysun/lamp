#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   System Required:  CentOS / RedHat / Fedora 
#   Description:  Install LAMP(Linux + Apache + MySQL + PHP ) for CentOS / RedHat / Fedora
#   Author: Teddysun <i@teddysun.com>
#   Intro:  http://teddysun.com/lamp
#===============================================================================================

clear
echo "#############################################################"
echo "# LAMP Auto Install Script for CentOS / RedHat / Fedora"
echo "# Intro: http://teddysun.com/lamp"
echo "#"
echo "# Author: Teddysun <i@teddysun.com>"
echo "#"
echo "#############################################################"
echo ""

# Install time state
StartDate='';
StartDateSecond='';
# Current folder
cur_dir=`pwd`
# Get IP address
IP=`curl -s checkip.dyndns.com | cut -d' ' -f 6  | cut -d'<' -f 1`
if [ $? -ne 0 -o -z $IP ]; then
    yum install -y curl curl-devel
    IP=`curl -s ifconfig.me/ip`
fi
# CPU Number
Cpunum=`cat /proc/cpuinfo | grep 'processor' | wc -l`;
# Version
MySQLVersion='mysql-5.6.19';
MariaDBVersion='mariadb-5.5.38'
MariaDBVersion2='mariadb-10.0.12'
PHPVersion='php-5.4.31';
ApacheVersion='httpd-2.4.9';
phpMyAdminVersion='phpMyAdmin-4.2.6-all-languages';
aprVersion='apr-1.5.1';
aprutilVersion='apr-util-1.5.3';
libiconvVersion='libiconv-1.14';
libmcryptVersion='libmcrypt-2.5.8';
mhashVersion='mhash-0.9.9.9';
mcryptVersion='mcrypt-2.6.8';
re2cVersion='re2c-0.13.6';
pcreVersion='pcre-8.35';
libeditVersion='libedit-20140213-3.1';

#===============================================================================================
#Description:Install LAMP Script.
#Usage:install_lamp
#===============================================================================================
function install_lamp(){
    rootness
    disable_selinux
    pre_installation_settings
    download_all_files
    untar_all_files
    install_pcre
    install_apache
    install_database
    install_libiconv
    install_libmcrypt
    install_mhash
    install_mcrypt
    install_re2c
    install_libedit
    install_php
    install_phpmyadmin
    install_cleanup
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
    # Choose databese
    while true
    do
    echo "Please choose a version of the Database:"
    echo -e "\t\033[32m1\033[0m. Install MariaDB-5.5(recommend)"
    echo -e "\t\033[32m2\033[0m. Install MariaDB-10.0"
    echo -e "\t\033[32m3\033[0m. Install MySQL-5.6"
    read -p "Please input a number:(Default 1) " DB_version
    [ -z "$DB_version" ] && DB_version=1
    case $DB_version in
        1|2|3)
        echo ""
        echo "---------------------------"
        echo "You choose = $DB_version"
        echo "---------------------------"
        echo ""
        break
        ;;
        *)
        echo "Input error! Please only input number 1,2,3"
    esac
    done
    # Set MySQL or MariaDB root password
    echo "Please input the root password of MySQL or MariaDB:"
    read -p "(Default password: root):" dbrootpwd
    if [ "$dbrootpwd" = "" ]; then
        dbrootpwd="root"
    fi
    echo ""
    echo "---------------------------"
    echo "Password = $dbrootpwd"
    echo "---------------------------"
    echo ""
    if [ $DB_version -eq 1 -o $DB_version -eq 2 ]; then
        # Define the MariaDB data location.
        echo "Please input the MariaDB data location:"
        read -p "(leave blank for /usr/local/mariadb/data):" datalocation
        [ -z "$datalocation" ] && datalocation="/usr/local/mariadb/data"
        echo ""
        echo "---------------------------"
        echo "Data location = $datalocation"
        echo "---------------------------"
        echo ""
    elif [ $DB_version -eq 3 ]; then
        # Define the MySQL data location.
        echo "Please input the MySQL data location:"
        read -p "(leave blank for /usr/local/mysql/data):" datalocation
        [ -z "$datalocation" ] && datalocation="/usr/local/mysql/data"
        echo ""
        echo "---------------------------"
        echo "Data location = $datalocation"
        echo "---------------------------"
        echo ""
    fi

    get_char(){
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
    rpm -e --nodeps httpd
    rpm -e --nodeps mysql
    rpm -e --nodeps php
    yum -y remove httpd
    yum -y remove mysql
    yum -y remove php
    #Set timezone
    rm -f /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    yum -y install ntp
    ntpdate -d cn.pool.ntp.org
    StartDate=$(date);
    StartDateSecond=$(date +%s);
    echo "Start time: ${StartDate}";
    #Install necessary tools
    if [ ! -s /etc/yum.conf.bak ]; then
        cp /etc/yum.conf /etc/yum.conf.bak
    fi
    sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf
    packages="wget autoconf automake bison bzip2 bzip2-devel curl curl-devel cmake cpp crontabs diffutils elinks e2fsprogs-devel expat-devel file flex freetype-devel gcc gcc-c++ gd glibc-devel glib2-devel gettext-devel gmp-devel icu kernel-devel libaio libtool-libs libjpeg-devel libpng-devel libxslt libxslt-devel libxml2 libxml2-devel libidn-devel libcap-devel libtool-ltdl-devel libmcrypt-devel libc-client-devel libicu libicu-devel zip zlib-devel unzip patch mlocate make ncurses-devel readline readline-devel vim-minimal sendmail pam-devel pcre pcre-devel openldap openldap-devel openssl openssl-devel perl-DBD-MySQL"
    for package in $packages;
    do yum -y install $package; done
}

#===============================================================================================
#Description:download all files.
#Usage:download_all_files
#===============================================================================================
function download_all_files(){
    cd $cur_dir
    if [ $DB_version -eq 1 ]; then
        download_file "${MariaDBVersion}.tar.gz"
    elif [ $DB_version -eq 2 ]; then
        download_file "${MariaDBVersion2}.tar.gz"
    elif [ $DB_version -eq 3 ]; then
        download_file "${MySQLVersion}.tar.gz"
    fi
    download_file "${PHPVersion}.tar.gz"
    download_file "${ApacheVersion}.tar.gz"
    download_file "${phpMyAdminVersion}.tar.gz"
    download_file "${aprVersion}.tar.gz"
    download_file "${aprutilVersion}.tar.gz"
    download_file "${libiconvVersion}.tar.gz"
    download_file "${libmcryptVersion}.tar.gz"
    download_file "${mhashVersion}.tar.gz"
    download_file "${mcryptVersion}.tar.gz"
    download_file "${re2cVersion}.tar.gz"
    download_file "${pcreVersion}.tar.gz"
    download_file "${libeditVersion}.tar.gz"
}

#===============================================================================================
#Description:download file.
#Usage:download_file [filename]
#===============================================================================================
function download_file(){
if [ -s $1 ]; then
    echo "$1 [found]"
else
    echo "$1 not found!!!download now......"
    if ! wget -c http://lamp.teddysun.com/files/$1;then
        echo "Failed to download $1,please download it to "$cur_dir" directory manually and try again."
        exit 1
    fi
fi
}

#===============================================================================================
#Description:Install Apache.
#Usage:install_apache
#===============================================================================================
function untar_all_files(){
    echo "Untar all files, please wait a moment..."
    #Untar all files
    if [ -d $cur_dir/untar ]; then
        rm -rf $cur_dir/untar
    fi
    mkdir -p $cur_dir/untar
    for file in `ls *.tar.gz`;
    do
        tar -zxf $file -C $cur_dir/untar
    done
    echo "Untar all files completed!"
}

#===============================================================================================
#Description:Install Apache.
#Usage:install_apache
#===============================================================================================
function install_apache(){
    if [ ! -d /usr/local/apache/bin ];then
        #Install Apache
        echo "Start Installing ${ApacheVersion}"
        mv $cur_dir/untar/$aprVersion $cur_dir/untar/$ApacheVersion/srclib/apr
        mv $cur_dir/untar/$aprutilVersion $cur_dir/untar/$ApacheVersion/srclib/apr-util
        cd $cur_dir/untar/$ApacheVersion
        ./configure \
        --prefix=/usr/local/apache \
        --with-pcre=/usr/local/pcre \
        --with-mpm=prefork \
        --with-included-apr \
        --enable-so \
        --enable-dav \
        --enable-deflate=shared \
        --enable-ssl=shared \
        --enable-expires=shared  \
        --enable-headers=shared \
        --enable-rewrite=shared \
        --enable-static-support \
        --enable-modules=all \
        --enable-mods-shared=all
        make -j $Cpunum
        make install
        if [ $? -ne 0 ]; then
            echo "Installing Apache failed, Please visit http://teddysun.com/lamp and contact."
            exit 1
        fi
        cp -f $cur_dir/conf/httpd.init /etc/init.d/httpd
        chmod +x /etc/init.d/httpd
        chkconfig --add httpd
        chkconfig httpd on
        rm -rf /etc/httpd
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
        #Copy to config files
        cp -f $cur_dir/conf/httpd2.4.conf /usr/local/apache/conf/httpd.conf
        cp -f $cur_dir/conf/httpd-vhosts.conf /usr/local/apache/conf/extra/httpd-vhosts.conf
        cp -f $cur_dir/conf/httpd-default.conf /usr/local/apache/conf/extra/httpd-default.conf
        mkdir -p /usr/local/apache/conf/vhost/
        touch /usr/local/apache/conf/vhost/none.conf
        cp -f $cur_dir/conf/index.html /data/www/default/index.html
        cp -f $cur_dir/conf/lamp.gif /data/www/default/lamp.gif
        cp -f $cur_dir/conf/p.php /data/www/default/p.php
        cp -f $cur_dir/conf/jquery-1.11.1.min.js /data/www/default/jquery-1.11.1.min.js
        cp -f $cur_dir/conf/phpinfo.php /data/www/default/phpinfo.php
        echo "${ApacheVersion} Install completed!"
    else
        echo "Apache had been installed!"
    fi
}

#===============================================================================================
#Description:install database.
#Usage:install_database
#===============================================================================================
function install_database(){
    if [ $DB_version -eq 1 -o $DB_version -eq 2 ]; then
        install_mariadb
    elif [ $DB_version -eq 3 ]; then
        install_mysql
    fi
}

#===============================================================================================
#Description:install mariadb.
#Usage:install_mariadb
#===============================================================================================
function install_mariadb(){
    if [ ! -d /usr/local/mariadb ];then
        # Install MariaDB
        cd $cur_dir/
        if [ $DB_version -eq 1 ]; then
            echo "Start Installing ${MariaDBVersion}"
            cd $cur_dir/untar/$MariaDBVersion
        elif [ $DB_version -eq 2 ]; then
            echo "Start Installing ${MariaDBVersion2}"
            cd $cur_dir/untar/$MariaDBVersion2
        fi
        /usr/sbin/groupadd mysql
        /usr/sbin/useradd -s /sbin/nologin -M -g mysql mysql
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
        make -j $Cpunum
        make install
        if [ $? -ne 0 ]; then
            echo "Installing MariaDB failed, Please visit http://teddysun.com/lamp and contact."
            exit 1
        fi
        chmod +w /usr/local/mariadb
        chown -R mysql:mysql /usr/local/mariadb
        cp -f $cur_dir/conf/my5.6.cnf /etc/my.cnf
        cp support-files/mysql.server /etc/init.d/mysqld
        sed -i "s:^datadir=.*:datadir=$datalocation:g" /etc/init.d/mysqld
        chmod +x /etc/rc.d/init.d/mysqld
        chkconfig --add mysqld
        chkconfig mysqld on
        /usr/local/mariadb/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mariadb --datadir=$datalocation --user=mysql
        cat > /etc/ld.so.conf.d/mariadb.conf<<EOF
/usr/local/mariadb/lib/mysql
/usr/local/lib
EOF
        ldconfig
        if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
            ln -s /usr/local/mariadb/lib/mysql /usr/lib64/mysql
        else
            ln -s /usr/local/mariadb/lib/mysql /usr/lib/mysql
        fi
        for i in `ls /usr/local/mariadb/bin`
        do
            if [ ! -L /usr/bin/$i ]; then
                ln -s /usr/local/mariadb/bin/$i /usr/bin/$i
            fi
        done
        #Start mysqld service
        service mysqld start
        /usr/local/mariadb/bin/mysqladmin password $dbrootpwd
        /usr/local/mariadb/bin/mysql -uroot -p$dbrootpwd <<EOF
drop database if exists test;
delete from mysql.user where user='';
update mysql.user set password=password('$dbrootpwd') where user='root';
delete from mysql.user where not (user='root') ;
flush privileges;
exit
EOF
        echo "${MariaDBVersion} Install completed!"
    else
        echo "MariaDB had been installed!"
    fi
}

#===============================================================================================
#Description:install mysql.
#Usage:install_mysql
#===============================================================================================
function install_mysql(){
    if [ ! -d /usr/local/mysql ];then
        # Install MySQL
        echo "Start Installing ${MySQLVersion}"
        cd $cur_dir/
        /usr/sbin/groupadd mysql
        /usr/sbin/useradd -s /sbin/nologin -M -g mysql mysql
        cd $cur_dir/untar/$MySQLVersion
        # Compile MySQL
        cmake \
        -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
        -DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
        -DDEFAULT_CHARSET=utf8 \
        -DDEFAULT_COLLATION=utf8_general_ci \
        -DWITH_EXTRA_CHARSETS=complex \
        -DWITH_INNOBASE_STORAGE_ENGINE=1 \
        -DWITH_READLINE=1 \
        -DENABLED_LOCAL_INFILE=1 \
        -DWITH_PARTITION_STORAGE_ENGINE=1 \
        -DWITH_FEDERATED_STORAGE_ENGINE=1 \
        -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
        -DWITH_MYISAM_STORAGE_ENGINE=1 \
        -DWITH_EMBEDDED_SERVER=1
        make -j $Cpunum
        make install
        if [ $? -ne 0 ]; then
            echo "Installing MySQL failed, Please visit http://teddysun.com/lamp and contact."
            exit 1
        fi
        chmod +w /usr/local/mysql
        chown -R mysql:mysql /usr/local/mysql
        cd support-files/
        cp -f $cur_dir/conf/my5.6.cnf /etc/my.cnf
        cp -f mysql.server /etc/init.d/mysqld
        sed -i "s:^datadir=.*:datadir=$datalocation:g" /etc/init.d/mysqld
        /usr/local/mysql/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=$datalocation --user=mysql
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
        for i in `ls /usr/local/mysql/bin`
        do
            if [ ! -L /usr/bin/$i ]; then
                ln -s /usr/local/mysql/bin/$i /usr/bin/$i
            fi
        done
        #Start mysqld service
        service mysqld start
        /usr/local/mysql/bin/mysqladmin password $dbrootpwd
        /usr/local/mysql/bin/mysql -uroot -p$dbrootpwd <<EOF
drop database if exists test;
delete from mysql.user where user='';
update mysql.user set password=password('$dbrootpwd') where user='root';
delete from mysql.user where not (user='root') ;
flush privileges;
exit
EOF
        echo "${MySQLVersion} Install completed!"
    else
        echo "MySQL had been installed!"
    fi
}

#===============================================================================================
#Description:install pcre.
#Usage:install_pcre
#===============================================================================================
function install_pcre(){
    cd $cur_dir/untar/$pcreVersion
    ./configure --prefix=/usr/local/pcre
    make && make install
    if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
        ln -s /usr/local/pcre/lib /usr/local/pcre/lib64
    fi
    [ -d "/usr/local/pcre/lib" ] && export LD_LIBRARY_PATH=/usr/local/pcre/lib:$LD_LIBRARY_PATH
    [ -d "/usr/local/pcre/bin" ] && export PATH=/usr/local/pcre/bin:$PATH
    echo "${pcreVersion} install completed!"
}

#===============================================================================================
#Description:install libiconv.
#Usage:install_libiconv
#===============================================================================================
function install_libiconv(){
    cd $cur_dir/untar/$libiconvVersion
    ./configure --prefix=/usr/local
    make && make install
    if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
        ln -s /usr/local/lib/libiconv.so.2 /usr/lib64/libiconv.so.2
    fi
    ln -s /usr/local/lib/libiconv.so.2 /usr/lib/libiconv.so.2
    echo "${libiconvVersion} install completed!"
}

#===============================================================================================
#Description:install libmcrypt.
#Usage:install_libmcrypt
#===============================================================================================
function install_libmcrypt(){
    cd $cur_dir/untar/$libmcryptVersion
    ./configure
    make && make install
    echo "${libmcryptVersion} install completed!"
}

#===============================================================================================
#Description:install mhash.
#Usage:install_mhash
#===============================================================================================
function install_mhash(){
    cd $cur_dir/untar/$mhashVersion
    ./configure
    make && make install
    echo "${mhashVersion} install completed!"
}

#===============================================================================================
#Description:install mcrypt.
#Usage:install_mcrypt
#===============================================================================================
function install_mcrypt(){
    /sbin/ldconfig
    cd $cur_dir/untar/$mcryptVersion
    ./configure
    make && make install
    echo "${mcryptVersion} install completed!"
}

#===============================================================================================
#Description:install re2c.
#Usage:install_re2c
#===============================================================================================
function install_re2c(){
    cd $cur_dir/untar/$re2cVersion
    ./configure
    make && make install
    echo "${re2cVersion} install completed!"
}

#===============================================================================================
#Description:install_libedit.
#Usage:install_libedit
#===============================================================================================
function install_libedit(){
    cd $cur_dir/untar/$libeditVersion
    ./configure
    make && make install
    echo "${libeditVersion} install completed!"
}

#===============================================================================================
#Description:install php.
#Usage:install_php
#===============================================================================================
function install_php(){
    if [ ! -d /usr/local/php ];then
        #install PHP
        echo "Start Installing ${PHPVersion}"
        #ldap module 
        if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
            cp -frp /usr/lib64/libldap* /usr/lib/
            ln -s /usr/lib64/libc-client.so /usr/lib/libc-client.so
        fi
        if [ $DB_version -eq 1 -o $DB_version -eq 2 ]; then
            WITH_MYSQL="/usr/local/mariadb"
            WITH_MYSQLI="/usr/local/mariadb/bin/mysql_config"
        elif [ $DB_version -eq 3 ]; then
            WITH_MYSQL="/usr/local/mysql"
            WITH_MYSQLI="/usr/local/mysql/bin/mysql_config"
        fi
        cd $cur_dir/untar/$PHPVersion
        ./configure \
        --prefix=/usr/local/php \
        --with-apxs2=/usr/local/apache/bin/apxs \
        --with-config-file-path=/usr/local/php/etc \
        --with-mysql=$WITH_MYSQL \
        --with-mysqli=$WITH_MYSQLI \
        --with-pcre-dir=/usr/local/pcre \
        --with-iconv-dir=/usr/local \
        --with-mysql-sock=/tmp/mysql.sock \
        --with-config-file-scan-dir=/usr/local/php/php.d \
        --with-mhash=/usr \
        --with-icu-dir=/usr \
        --with-bz2 \
        --with-curl \
        --with-freetype-dir \
        --with-gd \
        --with-gettext \
        --with-gmp \
        --with-imap \
        --with-imap-ssl \
        --with-jpeg-dir \
        --with-kerberos \
        --with-ldap \
        --with-mcrypt \
        --with-openssl \
        --without-pear \
        --with-pdo-mysql \
        --with-png-dir \
        --with-readline \
        --with-xmlrpc \
        --with-xsl \
        --with-zlib \
        --enable-bcmath \
        --enable-calendar \
        --enable-ctype \
        --enable-dom \
        --enable-exif \
        --enable-ftp \
        --enable-gd-native-ttf \
        --enable-intl \
        --enable-json \
        --enable-mbstring \
        --enable-pcntl \
        --enable-session \
        --enable-shmop \
        --enable-simplexml \
        --enable-soap \
        --enable-sockets \
        --enable-tokenizer \
        --enable-wddx \
        --enable-xml \
        --enable-zip \
        --disable-fileinfo
        if [ $? -ne 0 ]; then
            echo "Installing PHP failed, Please visit http://teddysun.com/lamp and contact."
            exit 1
        fi
        make ZEND_EXTRA_LIBS='-liconv'
        make install
        mkdir -p /usr/local/php/etc
        mkdir -p /usr/local/php/php.d
        mkdir -p /usr/local/php/lib/php/extensions/no-debug-non-zts-20100525
        cp -f $cur_dir/conf/php5.4.ini /usr/local/php/etc/php.ini
        rm -f /etc/php.ini
        ln -s /usr/local/php/etc/php.ini /etc/php.ini
        ln -s /usr/local/php/bin/php /usr/bin/php
        ln -s /usr/local/php/bin/php-config /usr/bin/php-config
        ln -s /usr/local/php/bin/phpize /usr/bin/phpize
        echo "${PHPVersion} install completed!"
    else
        echo "PHP had been installed!"
    fi
}
#===============================================================================================
#Description:install phpmyadmin.
#Usage:install_phpmyadmin
#===============================================================================================
function install_phpmyadmin(){
    if [ ! -d /data/www/default/phpmyadmin ];then
        echo "Start Installing ${phpMyAdminVersion}"
        cd $cur_dir
        mv untar/$phpMyAdminVersion /data/www/default/phpmyadmin
        cp -f $cur_dir/conf/config.inc.php /data/www/default/phpmyadmin/config.inc.php
        #Create phpmyadmin database
        mysql -uroot -p$dbrootpwd < /data/www/default/phpmyadmin/examples/create_tables.sql
        chmod -R 755 /data/www/default/phpmyadmin
        mkdir -p /data/www/default/phpmyadmin/upload/
        mkdir -p /data/www/default/phpmyadmin/save/
        chown -R apache:apache /data/www/default
        echo "${phpMyAdminVersion} Install completed!"
    else
        echo "PHPMyAdmin had been installed!"
    fi
    #Start httpd service
    service httpd start
}

#===============================================================================================
#Description:install cleanup.
#Usage:install_cleanup
#===============================================================================================
function install_cleanup(){
    cp -f $cur_dir/lamp.sh /usr/bin/lamp
    cp -f $cur_dir/conf/httpd.logrotate /etc/logrotate.d/httpd
    sed -i '/Order/,/All/d' /usr/bin/lamp
    sed -i "/AllowOverride All/i\Require all granted" /usr/bin/lamp
    #Clean up
    rm -rf $cur_dir/untar

    clear
    #Install completed or not 
    if [ -s /usr/local/apache ] && [ -s /usr/local/php ] && [ -s /usr/local/mysql -o -s /usr/local/mariadb ]; then
        echo ""
        echo 'Congratulations, LAMP install completed!'
        echo "Your Default Website: http://${IP}"
        echo 'Default WebSite Root Dir: /data/www/default'
        echo 'Apache Dir: /usr/local/apache'
        echo 'PHP Dir: /usr/local/php'
        if [ $DB_version -eq 1 -o $DB_version -eq 2 ]; then
            echo "MariaDB root password:$dbrootpwd"
            echo "MariaDB data location:$datalocation"
        elif [ $DB_version -eq 3 ]; then
            echo "MySQL root password:$dbrootpwd"
            echo "MySQL data location:$datalocation"
        fi
        echo -e "Installed Apache version:\033[41;37m ${ApacheVersion} \033[0m"
        if [ $DB_version -eq 1 ]; then
            echo -e "Installed MariaDB version:\033[41;37m ${MariaDBVersion} \033[0m"
        elif [ $DB_version -eq 2 ]; then
            echo -e "Installed MariaDB version:\033[41;37m ${MariaDBVersion2} \033[0m"
        elif [ $DB_version -eq 3 ]; then
            echo -e "Installed MySQL version:\033[41;37m ${MySQLVersion} \033[0m"
        fi
        echo -e "Installed PHP version:\033[41;37m ${PHPVersion} \033[0m"
        echo -e "Installed phpMyAdmin version:\033[41;37m ${phpMyAdminVersion} \033[0m"
        echo ""
        echo "Start time: ${StartDate}"
        echo -e "Completion time: $(date) (Use:\033[41;37m $[($(date +%s)-StartDateSecond)/60] \033[0m minutes)"
        echo "Welcome to visit:http://teddysun.com/lamp"
        echo "Enjoy it!"
        echo ""
    else
        echo ""
        echo 'Sorry, Failed to install LAMP!';
        echo 'Please contact: http://teddysun.com/lamp';
    fi
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
    if [[ "$uninstall" = "y" || "$uninstall" = "Y" ]]; then
        clear
        echo "==========================="
        echo "Yes, I agreed to uninstall!"
        echo "==========================="
        echo ""
    else
        echo ""
        echo "============================"
        echo "You cancelled the uninstall!"
        echo "============================"
        exit
    fi

    get_char(){
        SAVEDSTTY=`stty -g`
        stty -echo
        stty cbreak
        dd if=/dev/tty bs=1 count=1 2> /dev/null
        stty -raw
        stty echo
        stty $SAVEDSTTY
    }
    echo "Press any key to start uninstall LAMP...or Press Ctrl+c to cancel"
    echo ""
    char=`get_char`

    if [[ "$uninstall" = "y" || "$uninstall" = "Y" ]]; then
        killall httpd
        killall mysqld
        chkconfig --del httpd
        chkconfig --del mysqld
        rm -rf /etc/init.d/httpd /usr/local/apache /usr/sbin/httpd /usr/sbin/apachectl /var/log/httpd /var/lock/subsys/httpd /var/spool/mail/apache /etc/logrotate.d/httpd
        if [ -d /usr/local/mysql ]; then
            for tmp1 in `ls /usr/local/mysql/bin`
            do
                rm -f /usr/bin/$tmp1
            done
        fi
        if [ -d /usr/local/mariadb ]; then
            for tmp2 in `ls /usr/local/mariadb/bin`
            do
                rm -f /usr/bin/$tmp2
            done
        fi
        rm -rf /usr/local/mysql /usr/local/mariadb /usr/lib64/mysql /usr/lib/mysql /etc/my.cnf /etc/rc.d/init.d/mysqld /etc/ld.so.conf.d/mysql.conf /etc/ld.so.conf.d/mariadb.conf /var/lock/subsys/mysql
        rm -rf /usr/local/php /usr/lib/php /usr/bin/php /usr/bin/php-config /usr/bin/phpize /etc/php.ini
        rm -rf /data/www/default/phpmyadmin
        rm -rf /data/www/default/xcache
        rm -f /etc/pure-ftpd.conf
        rm -f /usr/bin/lamp
        echo "Successfully uninstall LAMP!!"
    else
        echo "Uninstall cancelled, nothing to do"
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
        exit 1
    fi
    #Create database or not    
    while true
    do
    read -p "(Do you want to create database?[y/N]):" create
    case $create in
    y|Y|YES|yes|Yes)
    if [ -d /usr/local/mysql ]; then
        read -p "(Please input your MySQL root password):" mysqlroot_passwd
        mysql -uroot -p$mysqlroot_passwd <<EOF
exit
EOF
        if [ $? -eq 0 ]; then
            echo "MySQL root password is correct.";
        else
            echo "MySQL root password incorrect! Please check it and try again!"
            exit 1
        fi
    elif [ -d /usr/local/mariadb ]; then
        read -p "(Please input your MariaDB root password):" mysqlroot_passwd
        mysql -uroot -p$mysqlroot_passwd <<EOF
exit
EOF
        if [ $? -eq 0 ]; then
            echo "MariaDB root password is correct.";
        else
            echo "MariaDB root password incorrect! Please check it and try again!"
            exit 1
        fi
    fi

    read -p "(Please input the database name):" dbname
    read -p "(Please set the password for user $dbname):" mysqlpwd
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
    mysql -uroot -p$mysqlroot_passwd  <<EOF
CREATE DATABASE IF NOT EXISTS \`$dbname\`;
GRANT ALL PRIVILEGES ON \`$dbname\` . * TO '$dbname'@'localhost' IDENTIFIED BY '$mysqlpwd';
GRANT ALL PRIVILEGES ON \`$dbname\` . * TO '$dbname'@'127.0.0.1' IDENTIFIED BY '$mysqlpwd';
FLUSH PRIVILEGES;
EOF
    fi
    #Define website dir
    webdir="/data/www/$domain"
    DocumentRoot="$webdir/web"
    logsdir="$webdir/logs"
    mkdir -p $DocumentRoot $logsdir
    chown -R apache:apache $webdir
    #Create vhost configuration file
    cat >/usr/local/apache/conf/vhost/$domain.conf<<EOF
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
EOF
    service httpd reload > /dev/null 2>&1
    echo "Successfully create $domain vhost"
    echo "######################### information about your website ############################"
    echo "The DocumentRoot:$DocumentRoot"
    echo "The Logsdir:$logsdir"
    [ "$create" == "y" ] && echo "database name and user:$dbname, password:$mysqlpwd"
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
    get_char(){
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
    else
        mkdir -p $ftproot
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
