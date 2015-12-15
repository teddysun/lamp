#!/bin/bash
#=========================================================#
#   System Required:  CentOS / RedHat / Fedora            #
#   Description:  Redis for LAMP                          #
#   Author: Teddysun <i@teddysun.com>                     #
#   Visit:  https://lamp.sh                               #
#=========================================================#
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi

cur_dir=`pwd`
redis_install_dir='/usr/local/redis'
tram=$( free -m | awk '/Mem/ {print $2}' )
swap=$( free -m | awk '/Swap/ {print $2}' )
Mem=`expr $tram + $swap`

redis_Ver='redis-3.0.5'
redis_ext_Ver='redis-2.2.7'

# get PHP version
PHP_VER=$(php -r 'echo PHP_VERSION;' 2>/dev/null | awk -F. '{print $1$2}')
if [ $? -ne 0 ] || [[ -z $PHP_VER ]]; then
    echo "Error:PHP looks like not installed, please check it and try again."
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
elif [ $PHP_VER -eq 70 ]; then
    extDate='20151012'
fi

# Download files
function download_files(){
    if [ -s $1 ]; then
        echo "$1 [found]"
    else
       echo "$1 not found!!!download now......"
       if ! wget -c -t3 http://lamp.teddysun.com/files/$1; then
           echo "Failed to download $1, please download it to ${cur_dir} directory manually and retry."
           exit 1
       fi
    fi
}

# Install redis server
function install_redis_server(){
    cd $cur_dir/untar/$redis_Ver
    if [ `getconf LONG_BIT` -eq 32 ];then
        sed -i '1i\CFLAGS= -march=i686' src/Makefile
        sed -i 's@^OPT=.*@OPT=-O2 -march=i686@' src/.make-settings
    fi
    make
    if [ -f "src/redis-server" ];then
        mkdir -p $redis_install_dir/{bin,etc,var}
        cp src/{redis-benchmark,redis-check-aof,redis-check-dump,redis-cli,redis-sentinel,redis-server} $redis_install_dir/bin/
        cp redis.conf $redis_install_dir/etc/
        ln -s $redis_install_dir/bin/* /usr/local/bin/
        sed -i 's@pidfile.*@pidfile /var/run/redis.pid@' $redis_install_dir/etc/redis.conf
        sed -i "s@logfile.*@logfile $redis_install_dir/var/redis.log@" $redis_install_dir/etc/redis.conf
        sed -i "s@^dir.*@dir $redis_install_dir/var@" $redis_install_dir/etc/redis.conf
        sed -i 's@daemonize no@daemonize yes@' $redis_install_dir/etc/redis.conf
        [ -z "`grep ^maxmemory $redis_install_dir/etc/redis.conf`" ] && sed -i "s@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory `expr $Mem / 8`000000@" $redis_install_dir/etc/redis.conf
        echo "redis-server install completed!"
        cp -f $cur_dir/conf/redis-server.init /etc/init.d/redis-server
        chmod +x /etc/init.d/redis-server
        chkconfig --add redis-server
        chkconfig redis-server on
        /etc/init.d/redis-server start
    else
        cd $cur_dir
        rm -rf $redis_install_dir
        rm -rf $cur_dir/untar
        echo "redis-server install failed, Please visit https://lamp.sh/support.html and contact."
        exit 1
    fi
}

# Install PHP extension redis
function install_redis_ext(){
    echo "redis extension install start..."
    cd $cur_dir/untar/$redis_ext_Ver
    export PHP_PREFIX="/usr/local/php"
    $PHP_PREFIX/bin/phpize
    ./configure --with-php-config=$PHP_PREFIX/bin/php-config
    make && make install
    if [ $? -ne 0 ]; then
        cd $cur_dir
        rm -rf $cur_dir/untar/
        echo "Installing PHP extension redis failed, Please visit https://lamp.sh/support.html and contact."
        exit 1
    fi
    if [ ! -f $PHP_PREFIX/php.d/redis.ini ]; then
        echo "redis configuration not found, create it!"
        cat > $PHP_PREFIX/php.d/redis.ini<<-EOF
[redis]
extension = /usr/local/php/lib/php/extensions/no-debug-non-zts-${extDate}/redis.so
EOF
    fi
    # Clean up
    cd $cur_dir
    rm -rf $cur_dir/untar/
    rm -f $cur_dir/${redis_Ver}.tar.gz
    rm -f $cur_dir/${redis_ext_Ver}.tgz
    # Restart httpd service
    /etc/init.d/httpd restart
    echo "redis extension install completed..."
exit
}

# Install redis
function install_redis(){
    download_files "${redis_Ver}.tar.gz"
    download_files "${redis_ext_Ver}.tgz"
    if [ ! -d $cur_dir/untar/ ]; then
        mkdir -p $cur_dir/untar/
    fi
    tar xzf $redis_Ver.tar.gz -C $cur_dir/untar/
    tar xzf $redis_ext_Ver.tgz -C $cur_dir/untar/
    install_redis_server
    install_redis_ext
}

install_redis
