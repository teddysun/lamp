#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================
#   SYSTEM REQUIRED:  CentOS / RedHat / Fedora
#   DESCRIPTION:  ImageMagick for LAMP
#   AUTHOR: Teddysun <i@teddysun.com>
#   VISIT:  http://teddysun.com/lamp
#===============================================================================

cur_dir=`pwd`
cd $cur_dir

ImageMagick_Ver='ImageMagick-6.9.0-10'
ImageMagick_ext_Ver='imagick-3.2.0RC1'

# get PHP version
PHP_VER=$(php -r 'echo PHP_VERSION;' 2>/dev/null | awk -F. '{print $1$2}')
if [ $? -ne 0 -o -z $PHP_VER ]; then
    echo "Error:PHP looks like not installed, please check it and try again."
    exit 1
fi
# get PHP extensions date
if [ $PHP_VER -eq 53 ]; then
    extDate='20090626'
elif [ $PHP_VER -eq 54 ]; then
    extDate='20100525'
elif [ $PHP_VER -eq 55 ]; then
    extDate='20121212'
fi

#===============================================================================
#DESCRIPTION:Make sure only root can run our script
#USAGE:rootness
#===============================================================================
function rootness(){
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" 1>&2
        exit 1
    fi
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
       if ! wget --tries=3 http://lamp.teddysun.com/files/$1; then
           echo "Failed to download $1,please download it to "$cur_dir" directory manually and rerun the install script."
           exit 1
       fi
    fi
}

#===============================================================================
#DESCRIPTION:Install imagemagick.
#USAGE:install_imagemagick_soft
#===============================================================================
function install_imagemagick_soft(){
    cd $cur_dir/untar/$ImageMagick_Ver
    ./configure
    make && make install
}

#===============================================================================
#DESCRIPTION:compile PHP extension imagemagick.
#USAGE:install_imagemagick_ext
#===============================================================================
function install_imagemagick_ext(){
    echo "imagemagick extension install start..."
    cd $cur_dir/untar/$ImageMagick_ext_Ver
    export PHP_PREFIX="/usr/local/php"
    $PHP_PREFIX/bin/phpize
    ./configure --with-php-config=$PHP_PREFIX/bin/php-config --with-imagick=/usr/local
    make && make install
    if [ ! -f $PHP_PREFIX/php.d/imagick.ini ]; then
        echo "imagemagick configuration not found, create it!"
        cat > $PHP_PREFIX/php.d/imagick.ini<<-EOF
[imagick]
extension = /usr/local/php/lib/php/extensions/no-debug-non-zts-${extDate}/imagick.so
EOF
    fi
    # Clean up
    cd $cur_dir
    rm -rf $cur_dir/untar/
    /etc/init.d/httpd restart
    echo "imagemagick extension install completed..."
exit
}
#===============================================================================
#DESCRIPTION:Install imagemagick.
#USAGE:install_imagemagick
#===============================================================================
function install_imagemagick(){
    rootness
    download_files "${ImageMagick_Ver}.tar.gz"
    download_files "${ImageMagick_ext_Ver}.tgz"
    if [ ! -d $cur_dir/untar/ ]; then
        mkdir -p $cur_dir/untar/
    fi
    tar xzf $ImageMagick_Ver.tar.gz -C $cur_dir/untar/
    tar xzf $ImageMagick_ext_Ver.tgz -C $cur_dir/untar/
    install_imagemagick_soft
    install_imagemagick_ext
}

action=$1
[ -z $1 ] && action=install
case "$action" in
install)
    install_imagemagick
    ;;
*)
    echo "Usage: `basename $0` {install}"
    ;;
esac
