#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================
#   SYSTEM REQUIRED:  CentOS / RedHat / Fedora
#   DESCRIPTION:  memcached for LAMP
#   AUTHOR: Teddysun <i@teddysun.com>
#   VISIT:  http://teddysun.com/lamp
#===============================================================================
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi

cur_dir=`pwd`

PHP_PREFIX='/usr/local/php'
memcached_install_dir='/usr/local/memcached'
libevent_ver='libevent-2.0.21-stable'
memcached_ver='memcached-1.4.22'
memcached_ext_ver='memcached-2.2.0'
memcache_ext_ver='memcache-3.0.8'
libmemcached_ver='libmemcached-1.0.18'

# get PHP version
PHP_VER=$(php -r 'echo PHP_VERSION;' 2>/dev/null | awk -F. '{print $1$2}')
if [ $? -ne 0 ] || [[ -z $INSTALLED_PHP ]]; then
    echo "Error: PHP looks like not installed, please check it and try again."
    exit 1
fi

# get PHP extensions date
if   [ $PHP_VER -eq 53 ]; then
    extDate='20090626'
elif [ $PHP_VER -eq 54 ]; then
    extDate='20100525'
elif [ $PHP_VER -eq 55 ]; then
    extDate='20121212'
elif [ $PHP_VER -eq 56 ]; then
    extDate='20131226'
fi

# Download files
function download_files(){
    if [ -s $1 ]; then
        echo "$1 [found]"
    else
       echo "$1 not found!!!download now......"
       if ! wget --tries=3 http://lamp.teddysun.com/files/$1; then
           echo "Failed to download $1, please download it to "$cur_dir" directory manually and try again."
           exit 1
       fi
    fi
}

# Install libevent
function install_libevent(){
    echo "libevent install start..."
    cd $cur_dir/untar/$libevent_ver
    ./configure
    make && make install
    if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 64 ]; then
        if [ ! -L /usr/lib64/libevent-2.0.so.5 ]; then
            ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib64/libevent-2.0.so.5
        fi
    else
        if [ ! -L /usr/lib64/libevent-2.0.so.5 ]; then
            ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib/libevent-2.0.so.5
        fi
    fi
    echo "libevent install completed..."
}

# Install memcached software
function install_memcached_soft(){
    echo "memcached install start..."
    useradd -M -s /sbin/nologin memcached
    cd $cur_dir/untar/$memcached_ver
    ./configure --prefix=$memcached_install_dir
    make && make install
    if [ -d "$memcached_install_dir" ];then
        echo "memcached install successfully!"
        ln -s $memcached_install_dir/bin/memcached /usr/bin/memcached
        cp -f $cur_dir/conf/memcached /etc/init.d/memcached
        chmod +x /etc/init.d/memcached
        chkconfig --add memcached
        chkconfig memcached on
        /etc/init.d/memcached start
        echo "memcached install completed..."
    else
        echo "memcached install failed, Please check it and try again."
        exit 1
    fi
}

# Install memcache extension
function install_memcache_ext(){
    echo "memcache extension install start..."
    cd $cur_dir/untar/$memcache_ext_ver
    $PHP_PREFIX/bin/phpize
    ./configure --with-php-config=$PHP_PREFIX/bin/php-config
    make && make install
    if [ ! -f $PHP_PREFIX/php.d/memcache.ini ]; then
        echo "memcache configuration not found, create it!"
        cat > $PHP_PREFIX/php.d/memcache.ini<<-EOF
[memcache]
extension = /usr/local/php/lib/php/extensions/no-debug-non-zts-${extDate}/memcache.so
EOF
    fi
    echo "memcache extension install completed..."
}

# Install libmemcached
function install_libmemcached(){
    echo "libmemcached install start..."
    yum -y install cyrus-sasl-devel
    cd $cur_dir/untar/$libmemcached_ver
    ./configure --with-memcached=$memcached_install_dir
    make && make install
    echo "libmemcached install completed..."
}

# Install memcached extension
function install_memcached_ext(){
    echo "memcached extension install start..."
    cd $cur_dir/untar/$memcached_ext_ver
    $PHP_PREFIX/bin/phpize
    ./configure --with-php-config=$PHP_PREFIX/bin/php-config
    make && make install
    if [ ! -f $PHP_PREFIX/php.d/memcached.ini ]; then
        echo "memcached configuration not found, create it!"
        cat > $PHP_PREFIX/php.d/memcached.ini<<-EOF
[memcached]
extension = /usr/local/php/lib/php/extensions/no-debug-non-zts-${extDate}/memcached.so
EOF
    fi
    # Clean up
    cd $cur_dir
    rm -rf $cur_dir/untar/
    rm -f $cur_dir/${libevent_ver}.tar.gz
    rm -f $cur_dir/${memcached_ver}.tar.gz
    rm -f $cur_dir/${libmemcached_ver}.tar.gz
    rm -f $cur_dir/${memcached_ext_ver}.tgz
    rm -f $cur_dir/${memcache_ext_ver}.tgz
    # Restart httpd service
    /etc/init.d/httpd restart
    echo "memcached extension install completed..."
}

# Install memcached
function install_memcached(){
    download_files "${libevent_ver}.tar.gz"
    download_files "${memcached_ver}.tar.gz"
    download_files "${libmemcached_ver}.tar.gz"
    download_files "${memcached_ext_ver}.tgz"
    download_files "${memcache_ext_ver}.tgz"
    if [ -d $cur_dir/untar/ ]; then
        rm -rf $cur_dir/untar/
        mkdir -p $cur_dir/untar/
    else
        mkdir -p $cur_dir/untar/
    fi
    tar xzf $libevent_ver.tar.gz -C $cur_dir/untar/
    tar xzf $memcached_ver.tar.gz -C $cur_dir/untar/
    tar xzf $libmemcached_ver.tar.gz -C $cur_dir/untar/
    tar xzf $memcached_ext_ver.tgz -C $cur_dir/untar/
    tar xzf $memcache_ext_ver.tgz -C $cur_dir/untar/
    install_libevent
    install_memcached_soft
    install_memcache_ext
    install_libmemcached
    install_memcached_ext
}

action=$1
[ -z $1 ] && action=install
case "$action" in
install)
    install_memcached
    ;;
*)
    echo "Usage: `basename $0` {install}"
    ;;
esac
