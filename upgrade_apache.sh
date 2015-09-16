#!/bin/bash
#=========================================================#
#   System Required:  CentOS / RedHat / Fedora            #
#   Description:  Auto Update Script for Apache           #
#   Author: Teddysun <i@teddysun.com>                     #
#   Visit:  https://lamp.sh                               #
#=========================================================#
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi

if [ ! -d /usr/local/apache ]; then
    echo "Error:Apache looks like not installed, please check it and try again."
    exit 1
fi

cur_dir=`pwd`

clear
echo "#############################################################"
echo "# Auto Update Script for Apache                             #"
echo "# System Required:  CentOS / RedHat / Fedora                #"
echo "# Intro: https://lamp.sh                                    #"
echo "# Author: Teddysun <i@teddysun.com>                         #"
echo "#############################################################"
echo ""

# Description:Apache Update
aprVersion='apr-1.5.2'
aprutilVersion='apr-util-1.5.4'

INSTALLED_APACHE=$(/usr/local/apache/bin/httpd -v | grep 'version' | awk -F/ '{print $2}' | cut -d' ' -f1)
LATEST_APACHE=$(curl -s http://httpd.apache.org/download.cgi | awk '/#apache24/{print $2}' | head -n 1 | awk -F'>' '{print $2}' | cut -d'<' -f1)

echo -e "Latest version of Apache: \033[41;37m $LATEST_APACHE \033[0m"
echo -e "Installed version of Apache: \033[41;37m $INSTALLED_APACHE \033[0m"
echo ""
echo "Do you want to upgrade Apache ? (y/n)"
read -p "(Default: n):" UPGRADE_APACHE
if [ -z $UPGRADE_APACHE ]; then
    UPGRADE_APACHE="n"
fi
echo "---------------------------"
echo "You choose = $UPGRADE_APACHE"
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

# Apache Update
if [[ "$UPGRADE_APACHE" = "y" || "$UPGRADE_APACHE" = "Y" ]];then
    echo "===================== Apache upgrade start===================="
    # Stop Apache
    /etc/init.d/httpd status > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        /etc/init.d/httpd stop
    fi
    # Backup
    if [[ -d "/usr/local/apache.bak" && -d "/usr/local/apache" ]];then
        rm -rf /usr/local/apache.bak/
    fi
    mv /usr/local/apache /usr/local/apache.bak
    cd $cur_dir
    echo "Download apr and apr-util..."
    if [ -s ${aprVersion}.tar.gz ]; then
        echo "${aprVersion}.tar.gz [found]"
    else
        wget -c http://lamp.teddysun.com/files/${aprVersion}.tar.gz
    fi
    if [ -s ${aprutilVersion}.tar.gz ]; then
        echo "${aprutilVersion}.tar.gz [found]"
    else
        wget -c http://lamp.teddysun.com/files/${aprutilVersion}.tar.gz
    fi

    tar zxf ${aprVersion}.tar.gz -C $cur_dir/
    tar zxf ${aprutilVersion}.tar.gz -C $cur_dir/
    
    if [ ! -s httpd-$LATEST_APACHE.tar.gz ]; then
        LATEST_APACHE_LINK="http://www.us.apache.org/dist//httpd/httpd-${LATEST_APACHE}.tar.gz"
        BACKUP_APACHE_LINK="http://lamp.teddysun.com/files/httpd-${LATEST_APACHE}.tar.gz"
        untar $LATEST_APACHE_LINK $BACKUP_APACHE_LINK
    else
        echo "httpd-${LATEST_APACHE}.tar.gz [found]"
        tar -zxf httpd-$LATEST_APACHE.tar.gz
        cd httpd-$LATEST_APACHE/
    fi
    mv $cur_dir/$aprVersion $cur_dir/httpd-$LATEST_APACHE/srclib/apr
    mv $cur_dir/$aprutilVersion $cur_dir/httpd-$LATEST_APACHE/srclib/apr-util
    # Compiles Apache
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
    make && make install
    if [ $? -ne 0 ]; then
        echo "Installing Apache failed, Please visit http://teddysun.com/lamp and contact."
        exit 1
    fi
    # Restore files
    cp -rpf /usr/local/apache.bak/logs/* /usr/local/apache/logs/
    cp -rpf /usr/local/apache.bak/conf/* /usr/local/apache/conf/
    cp -rpf /usr/local/apache.bak/modules/libphp5.so /usr/local/apache/modules/
    # Clean up
    cd $cur_dir
    rm -rf httpd-$LATEST_APACHE/
    rm -f httpd-$LATEST_APACHE.tar.gz ${aprVersion}.tar.gz ${aprutilVersion}.tar.gz
    # Start httpd service
    /etc/init.d/httpd start
    if [ $? -eq 0 ]; then
        echo "Apache start success!"
    else
        echo "Apache start failure!"
    fi
    echo "===================== Apache update completed! ===================="
    echo ""
else
    echo ""
    echo "Apache upgrade cancelled, nothing to do..."
    echo ""
fi
