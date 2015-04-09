#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   System Required:  CentOS / RedHat / Fedora
#   Description:  Auto Update Script for PHP && phpMyAdmin
#   Author: Teddysun <i@teddysun.com>
#   Intro:  http://teddysun.com/lamp
#===============================================================================================
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi

if [ ! -d /usr/local/php ]; then
    echo "Error:PHP looks like not installed, please check it and try again."
    exit 1
fi

cur_dir=`pwd`

clear
echo "#############################################################"
echo "# Auto Update Script for PHP && phpMyAdmin"
echo "# System Required:  CentOS / RedHat / Fedora"
echo "# Intro: http://teddysun.com/lamp"
echo ""
echo "# Author: Teddysun <i@teddysun.com>"
echo ""
echo "#############################################################"
echo ""

# Description:PHP Update

INSTALLED_PHP=$(php -r 'echo PHP_VERSION;' 2>/dev/null)
PHP_VER=$(echo $INSTALLED_PHP | awk -F. '{print $1$2}')
if [ $PHP_VER -eq 53 ]; then
    extDate='20090626'
    LATEST_PHP=$(curl -s http://php.net/downloads.php | awk '/Changelog/{print $2}' | grep '5.3')
elif [ $PHP_VER -eq 54 ]; then
    extDate='20100525'
    LATEST_PHP=$(curl -s http://php.net/downloads.php | awk '/Changelog/{print $2}' | grep '5.4')
elif [ $PHP_VER -eq 55 ]; then
    extDate='20121212'
    LATEST_PHP=$(curl -s http://php.net/downloads.php | awk '/Changelog/{print $2}' | grep '5.5')
fi

echo -e "Latest version of PHP: \033[41;37m $LATEST_PHP \033[0m"
echo -e "Installed version of PHP: \033[41;37m $INSTALLED_PHP \033[0m"
echo ""
echo "Do you want to upgrade PHP ? (y/n)"
read -p "(Default: n):" UPGRADE_PHP
if [ -z $UPGRADE_PHP ]; then
    UPGRADE_PHP="n"
fi
echo "---------------------------"
echo "You choose = $UPGRADE_PHP"
echo "---------------------------"
echo ""

# Description:phpMyAdmin Update
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

LATEST_PMA=$(elinks http://iweb.dl.sourceforge.net/project/phpmyadmin/phpMyAdmin/ | awk -F/ '{print $7F}' | grep -iv '-' | grep -iv 'rst' | grep -iv ';' | sort -V | tail -1)
if [ -z $LATEST_PMA ]; then
    LATEST_PMA=$(curl -s http://lamp.teddysun.com/pmalist.txt | tail -1 | awk -F- '{print $2}')
fi
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
get_char() {
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

# Get version
function getversion(){
    if [[ -s /etc/redhat-release ]];then
        grep -oE  "[0-9.]+" /etc/redhat-release
    else    
        grep -oE  "[0-9.]+" /etc/issue
    fi    
}

# CentOS version
function centosversion(){
    local code=$1
    local version="`getversion`"
    local main_ver=${version%%.*}
    if [ $main_ver == $code ];then
        return 0
    else
        return 1
    fi        
}

# PHP Update
if [[ "$UPGRADE_PHP" = "y" || "$UPGRADE_PHP" = "Y" ]];then
    echo "===================== PHP upgrade start===================="
    if [[ -d "/usr/local/php.bak" && -d "/usr/local/php" ]];then
        rm -rf /usr/local/php.bak/
    fi
    mv /usr/local/php /usr/local/php.bak
    cd $cur_dir
    if [ ! -s php-$LATEST_PHP.tar.gz ]; then
        LATEST_PHP_LINK="http://php.net/distributions/php-${LATEST_PHP}.tar.gz"
        BACKUP_PHP_LINK="http://lamp.teddysun.com/files/php-${LATEST_PHP}.tar.gz"
        untar $LATEST_PHP_LINK $BACKUP_PHP_LINK
    else
        tar -zxf php-$LATEST_PHP.tar.gz
        cd php-$LATEST_PHP/
    fi
    if [ -d /usr/local/mariadb ]; then
        WITH_MYSQL="--with-mysql=/usr/local/mariadb"
        WITH_MYSQLI="--with-mysqli=/usr/local/mariadb/bin/mysql_config"
    elif [ -d /usr/local/mysql ]; then
        WITH_MYSQL="--with-mysql=/usr/local/mysql"
        WITH_MYSQLI="--with-mysqli=/usr/local/mysql/bin/mysql_config"
    else
        echo "MySQL or MariaDB not installed, Please check it and try again."
        exit 1
    fi
    if centosversion 7; then
        WITH_IMAP="--with-imap=/usr/local/imap-2007f --with-imap-ssl"
    else
        WITH_IMAP="--with-imap --with-imap-ssl --with-kerberos"
    fi

    ./configure \
    --prefix=/usr/local/php \
    --with-apxs2=/usr/local/apache/bin/apxs \
    --with-config-file-path=/usr/local/php/etc \
    $WITH_MYSQL \
    $WITH_MYSQLI \
    --with-iconv-dir=/usr/local/libiconv \
    --with-pcre-dir=/usr/local/pcre \
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
    --with-jpeg-dir \
    $WITH_IMAP \
    --with-ldap \
    --with-ldap-sasl \
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
    --enable-zip
    if [ $? -ne 0 ]; then
        echo "PHP configure failed, Please visit http://teddysun.com/lamp and contact."
        exit 1
    fi
    make && make install
    if [ $? -ne 0 ]; then
        echo "Installing PHP failed, Please visit http://teddysun.com/lamp and contact."
        exit 1
    fi
    mkdir -p /usr/local/php/etc
    mkdir -p /usr/local/php/php.d
    mkdir -p /usr/local/php/lib/php/extensions/no-debug-non-zts-${extDate}/
    cp -f /usr/local/php.bak/etc/php.ini /usr/local/php/etc/php.ini
    cp -f /usr/local/php.bak/lib/php/extensions/no-debug-non-zts-${extDate}/* \
          /usr/local/php/lib/php/extensions/no-debug-non-zts-${extDate}/
    php_d=`ls /usr/local/php.bak/php.d/ | wc -l`
    if [ $php_d -ne 0 ]; then
        cp -f /usr/local/php.bak/php.d/* /usr/local/php/php.d/
    fi
    # Clean up
    cd $cur_dir
    rm -rf php-$LATEST_PHP/
    rm -f php-$LATEST_PHP.tar.gz
    # Restart httpd service
    /etc/init.d/httpd restart
    echo "===================== PHP update completed! ===================="
    echo ""
else
    echo ""
    echo "PHP upgrade cancelled, nothing to do..."
    echo ""
fi

# phpMyAdmin Update
if [[ "$UPGRADE_PMA" = "y" || "$UPGRADE_PMA" = "Y" ]];then
    echo "===================== phpMyAdmin upgrade start===================="
    if [ -d /data/www/default/phpmyadmin ]; then
        mv /data/www/default/phpmyadmin/config.inc.php $cur_dir/config.inc.php
        rm -rf /data/www/default/phpmyadmin
    else
        echo "===================== phpMyAdmin folder not found! ===================="
    fi
    if [ ! -s phpMyAdmin-$LATEST_PMA-all-languages.tar.gz ]; then
        LATEST_PMA_LINK="http://iweb.dl.sourceforge.net/project/phpmyadmin/phpMyAdmin/${LATEST_PMA}/phpMyAdmin-${LATEST_PMA}-all-languages.tar.gz"
        BACKUP_PMA_LINK="http://lamp.teddysun.com/files/phpMyAdmin-${LATEST_PMA}-all-languages.tar.gz"
        untar $LATEST_PMA_LINK $BACKUP_PMA_LINK
        mkdir -p /data/www/default/phpmyadmin
        mv * /data/www/default/phpmyadmin
    else
        tar -zxf phpMyAdmin-$LATEST_PMA-all-languages.tar.gz -C $cur_dir
        mv $cur_dir/phpMyAdmin-$LATEST_PMA-all-languages /data/www/default/phpmyadmin
    fi
    if [ -s $cur_dir/config.inc.php ]; then
        mv $cur_dir/config.inc.php /data/www/default/phpmyadmin/config.inc.php
    else
        mv /data/www/default/phpmyadmin/config.sample.inc.php /data/www/default/phpmyadmin/config.inc.php
    fi
    mkdir -p /data/www/default/phpmyadmin/upload/
    mkdir -p /data/www/default/phpmyadmin/save/
    if [ -s /data/www/default/phpmyadmin/examples/create_tables.sql ]; then
        cp -f /data/www/default/phpmyadmin/examples/create_tables.sql /data/www/default/phpmyadmin/upload/
    elif [ -s /data/www/default/phpmyadmin/sql/create_tables.sql ]; then
        cp -f /data/www/default/phpmyadmin/sql/create_tables.sql /data/www/default/phpmyadmin/upload/
    fi

    chown -R apache:apache /data/www/default/phpmyadmin
    # clean phpMyAdmin archive
    cd $cur_dir
    rm -rf $cur_dir/pmaversion.txt
    echo -e "phpmyadmin\t${LATEST_PMA}" > $cur_dir/pmaversion.txt
    rm -rf $cur_dir/phpMyAdmin-$LATEST_PMA-all-languages
    rm -f phpMyAdmin-$LATEST_PMA-all-languages.tar.gz
    #Restart httpd service
    /etc/init.d/httpd restart
    echo "===================== phpMyAdmin update completed! ===================="
else
    echo "phpMyAdmin upgrade cancelled, nothing to do..."
    echo ""
fi
