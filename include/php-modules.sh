# Copyright (C) 2014 - 2017, Teddysun <i@teddysun.com>
# 
# This file is part of the LAMP script.
#
# LAMP is a powerful bash script for the installation of 
# Apache + PHP + MySQL/MariaDB/Percona and so on.
# You can install Apache + PHP + MySQL/MariaDB/Percona in an very easy way.
# Just need to input numbers to choose what you want to install before installation.
# And all things will be done in a few minutes.
#
# Website:  https://lamp.sh
# Github:   https://github.com/teddysun/lamp

#Pre-installation php modules
php_modules_preinstall_settings(){

    if [[ "$php" == "do_not_install" ]];then
        php_modules_install="do_not_install"
    else
        phpConfig=${php_location}/bin/php-config

        echo "$php version available modules:"
        echo
        if [ "$php" == "${php5_5_filename}" ];then
            php_modules_arr=(${php_modules_arr[@]#${opcache_filename}})
        elif [ "$php" == "${php5_6_filename}" ];then
            php_modules_arr=(${php_modules_arr[@]#${opcache_filename}})
        elif [ "$php" == "${php7_0_filename}" ];then
            # delete some modules & change some module version
            php_modules_arr=(${php_modules_arr[@]#${opcache_filename}})
            php_modules_arr=(${php_modules_arr[@]#${xcache_filename}})
            php_modules_arr=(${php_modules_arr[@]#${ZendGuardLoader_filename}})
            php_modules_arr=(${php_modules_arr[@]#${php_memcached_filename}})
            php_modules_arr=(${php_modules_arr[@]#${php_mongo_filename}})
            php_modules_arr=(${php_modules_arr[@]/#${php_redis_filename}/${php_redis_filename2}})
            php_modules_arr=(${php_modules_arr[@]/#${php_graphicsmagick_filename}/${php_graphicsmagick_filename2}})
        elif [ "$php" == "${php7_1_filename}" ];then
            # delete some modules & change some module version
            php_modules_arr=(${php_modules_arr[@]#${opcache_filename}})
            php_modules_arr=(${php_modules_arr[@]#${xcache_filename}})
            php_modules_arr=(${php_modules_arr[@]#${ZendGuardLoader_filename}})
            php_modules_arr=(${php_modules_arr[@]#${ionCube_filename}})
            php_modules_arr=(${php_modules_arr[@]#${php_memcached_filename}})
            php_modules_arr=(${php_modules_arr[@]#${php_mongo_filename}})
            php_modules_arr=(${php_modules_arr[@]/#${php_redis_filename}/${php_redis_filename2}})
            php_modules_arr=(${php_modules_arr[@]/#${php_graphicsmagick_filename}/${php_graphicsmagick_filename2}})

        fi
        display_menu_multi php_modules last
    fi
}


#Pre-installation phpmyadmin
phpmyadmin_preinstall_settings(){
    if [[ "$php" == "do_not_install" ]];then
        phpmyadmin="do_not_install"
    else
        display_menu phpmyadmin 1
    fi
}


install_php_modules(){
    local phpConfig=$1
    if_in_array "${opcache_filename}" "$php_modules_install" && install_opcache "${phpConfig}"
    if_in_array "${ZendGuardLoader_filename}" "$php_modules_install" && install_ZendGuardLoader "${phpConfig}"
    if_in_array "${ionCube_filename}" "$php_modules_install" && install_ionCube "${phpConfig}"
    if_in_array "${xcache_filename}" "$php_modules_install" && install_xcache "${phpConfig}"
    if_in_array "${php_imagemagick_filename}" "$php_modules_install" && install_php_imagesmagick "${phpConfig}"
    if_in_array "${php_memcached_filename}" "$php_modules_install" && install_php_memcached "${phpConfig}"
    if_in_array "${php_mongo_filename}" "$php_modules_install" && install_php_mongo "${phpConfig}"
    if_in_array "${swoole_filename}" "$php_modules_install" && install_swoole "${phpConfig}"
    if [ "$php" == "${php7_0_filename}" ] || [ "$php" == "${php7_1_filename}" ]; then
        if_in_array "${php_graphicsmagick_filename2}" "$php_modules_install" && install_php_graphicsmagick "${phpConfig}"
        if_in_array "${php_redis_filename2}" "$php_modules_install" && install_php_redis "${phpConfig}"
    else
        if_in_array "${php_graphicsmagick_filename}" "$php_modules_install" && install_php_graphicsmagick "${phpConfig}"
        if_in_array "${php_redis_filename}" "$php_modules_install" && install_php_redis "${phpConfig}"
    fi
}


install_php_depends(){

    if check_sys packageManager apt;then

        apt_depends=(
            m4 autoconf bison libbz2-dev libgmp-dev libicu-dev libsasl2-dev libsasl2-modules-ldap
            libldap-2.4-2 libldap2-dev libldb-dev libpam0g-dev libcurl4-gnutls-dev snmp libsnmp-dev
            autoconf2.13 openssl pkg-config libxslt1-dev zlib1g-dev libpcre3-dev libtool
            libjpeg-dev libpng-dev libfreetype6-dev libmhash-dev libmcrypt-dev patch
        )
        for depend in ${apt_depends[@]}
        do
            error_detect_depends "apt-get -y install ${depend}"
        done

        if is_64bit;then
            [ ! -d /usr/lib64 ] && mkdir /usr/lib64
            if [ -f /usr/include/gmp-x86_64.h ];then
                ln -sf /usr/include/gmp-x86_64.h /usr/include/gmp.h
            elif [ -f /usr/include/x86_64-linux-gnu/gmp.h ];then
                ln -sf /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h
            fi
            ln -sf /usr/lib/x86_64-linux-gnu/libldap* /usr/lib64/
            ln -sf /usr/lib/x86_64-linux-gnu/liblber* /usr/lib64/

            if [ -d /usr/include/x86_64-linux-gnu/curl ] && [ ! -d /usr/include/curl ]; then
                ln -sf /usr/include/x86_64-linux-gnu/curl /usr/include/curl
            fi
        else
            if [ -f /usr/include/gmp-i386.h ];then
                ln -sf /usr/include/gmp-i386.h /usr/include/gmp.h
            elif [ -f /usr/include/i386-linux-gnu/gmp.h ];then
                ln -sf /usr/include/i386-linux-gnu/gmp.h /usr/include/gmp.h
            fi
            ln -sf /usr/lib/i386-linux-gnu/libldap* /usr/lib/
            ln -sf /usr/lib/i386-linux-gnu/liblber* /usr/lib/

            if [ -d /usr/include/i386-linux-gnu/curl ] && [ ! -d /usr/include/curl ]; then
                ln -sf /usr/include/i386-linux-gnu/curl /usr/include/curl
            fi
        fi

        check_installed "install_libiconv" "${depends_prefix}/libiconv"
        check_installed "install_imap" "${depends_prefix}/imap-2007f"
        install_re2c

    elif check_sys packageManager yum; then

        yum_depends=(
            m4 autoconf bison bzip2-devel pam-devel gmp-devel libicu-devel openldap openldap-devel patch
            curl-devel pcre-devel libtool-libs libtool-ltdl-devel
            libjpeg-devel libpng-devel freetype-devel libxslt libxslt-devel
            net-snmp net-snmp-devel net-snmp-utils net-snmp-perl
        )
        for depend in ${yum_depends[@]}
        do
            error_detect_depends "yum -y install ${depend}"
        done

        check_installed "install_libiconv" "${depends_prefix}/libiconv"
        check_installed "install_imap" "${depends_prefix}/imap-2007f"
        install_libmcrypt
        install_mhash
        install_mcrypt
        install_re2c
        install_libedit
        if centosversion 5; then
            if [[ "$php" != "${php5_3_filename}" && "$php" != "${php5_4_filename}" ]]; then
                update_icu
                update_gmp
            fi
        fi

    fi
}


install_libiconv(){
    cd ${cur_dir}/software/
    download_file  "${libiconv_filename}.tar.gz"
    tar zxf ${libiconv_filename}.tar.gz
    cd ${libiconv_filename}

    error_detect "./configure --prefix=${depends_prefix}/libiconv"

    if check_sys packageManager apt;then
        parallel_make
        sed -i "1010s/^/\/\/&/"  srclib/stdio.h
        parallel_make
    else
        parallel_make
    fi

    make install

    if is_64bit;then
        ln -s ${depends_prefix}/libiconv/lib/libiconv.so /usr/lib64/libiconv.so.0
    else
        ln -s ${depends_prefix}/libiconv/lib/libiconv.so /usr/lib/libiconv.so.0
    fi

    add_to_env "${depends_prefix}/libiconv"
}


install_re2c(){
    if [ ! -e "/usr/local/bin/re2c" ]; then
        cd ${cur_dir}/software/
        download_file "${re2c_filename}.tar.gz"
        tar zxf ${re2c_filename}.tar.gz
        cd ${re2c_filename}
        
        error_detect "./configure"
        error_detect "make"
        error_detect "make install"
    fi
}


install_imap(){
    cd ${cur_dir}/software/
    download_file "${imap_filename}.tar.gz"
    tar zxf ${imap_filename}.tar.gz
    cd ${imap_filename}

    if is_64bit;then
        error_detect "make lr5 PASSWDTYPE=std SSLTYPE=unix.nopwd EXTRACFLAGS=-fPIC IP=4"
    else
        error_detect "make lr5 PASSWDTYPE=std SSLTYPE=unix.nopwd IP=4"
    fi
    mkdir ${depends_prefix}/imap-2007f/
    mkdir ${depends_prefix}/imap-2007f/include/
    mkdir ${depends_prefix}/imap-2007f/lib/
    mkdir ${depends_prefix}/imap-2007f/c-client/
    cp c-client/*.h ${depends_prefix}/imap-2007f/include/
    cp c-client/*.c ${depends_prefix}/imap-2007f/lib/
    cp c-client/*.c ${depends_prefix}/imap-2007f/c-client/
    cp c-client/c-client.a ${depends_prefix}/imap-2007f/lib/libc-client.a
    cp c-client/c-client.a ${depends_prefix}/imap-2007f/c-client/libc-client.a
}


install_pcre(){
    cd ${cur_dir}/software/
    download_file "${pcre_filename}.tar.gz"
    tar zxf ${pcre_filename}.tar.gz
    cd ${pcre_filename}

    error_detect "./configure --prefix=${depends_prefix}/pcre"
    error_detect "parallel_make"
    error_detect "make install"
    add_to_env "${depends_prefix}/pcre"
    create_lib64_dir "${depends_prefix}/pcre"
}


install_mhash(){
    if [ ! -e "/usr/local/lib/libmhash.a" ]; then
        cd ${cur_dir}/software/
        download_file "${mhash_filename}.tar.gz"
        tar zxf ${mhash_filename}.tar.gz
        cd ${mhash_filename}

        error_detect "./configure"
        error_detect "parallel_make"
        error_detect "make install"
    fi
}


install_mcrypt(){
    if [ ! -f "/usr/local/bin/mcrypt" ]; then
        cd ${cur_dir}/software/
        download_file "${mcrypt_filename}.tar.gz"
        tar zxf ${mcrypt_filename}.tar.gz
        cd ${mcrypt_filename}

        ldconfig
        error_detect "./configure"
        error_detect "parallel_make"
        error_detect "make install"
    fi
}


install_libmcrypt(){
    if [ ! -e "/usr/local/lib/libmcrypt.la" ]; then
        cd ${cur_dir}/software/
        download_file "${libmcrypt_filename}.tar.gz"
        tar zxf ${libmcrypt_filename}.tar.gz
        cd ${libmcrypt_filename}

        error_detect "./configure"
        error_detect "parallel_make"
        error_detect "make install"
    fi
}


install_libedit(){
    if [ ! -e "/usr/local/lib/libedit.a" ]; then
        cd ${cur_dir}/software/
        download_file "${libedit_filename}.tar.gz"
        tar zxf ${libedit_filename}.tar.gz
        cd ${libedit_filename}
        
        error_detect "./configure"
        error_detect "parallel_make"
        error_detect "make install"
    fi
}


install_nghttp2(){
    if [ ! -e "/usr/lib/libnghttp2.a" ]; then
        cd ${cur_dir}/software/
        download_file "${nghttp2_filename}.tar.gz"
        tar zxf ${nghttp2_filename}.tar.gz
        cd ${nghttp2_filename}

        export OPENSSL_CFLAGS="-I${openssl_location}/include"
        export OPENSSL_LIBS="-L${openssl_location}/lib -lssl -lcrypto"
        error_detect "./configure --prefix=/usr --disable-examples"
        error_detect "parallel_make"
        error_detect "make install"
        unset OPENSSL_CFLAGS
        unset OPENSSL_LIBS
    fi
}


install_openssl(){
    cd ${cur_dir}/software/
    download_file "${openssl_filename}.tar.gz"
    tar zxf ${openssl_filename}.tar.gz
    cd ${openssl_filename}

    error_detect "./config --prefix=${openssl_location} -fPIC shared no-ssl2 zlib-dynamic"
    error_detect "parallel_make"
    error_detect "make install"

    if is_64bit; then
        ln -s ${openssl_location}/lib/libssl.so.1.0.0 /usr/lib64/
        ln -s ${openssl_location}/lib/libcrypto.so.1.0.0 /usr/lib64/
    else
        ln -s ${openssl_location}/lib/libssl.so.1.0.0 /usr/lib/
        ln -s ${openssl_location}/lib/libcrypto.so.1.0.0 /usr/lib/
    fi
}


install_phpmyadmin(){
    if [ -d ${web_root_dir}/phpmyadmin ];then
        rm -rf ${web_root_dir}/phpmyadmin
    fi

    cd ${cur_dir}/software

    echo "${phpmyadmin_filename} install start..."
    download_file "${phpmyadmin_filename}.tar.gz"
    tar zxf ${phpmyadmin_filename}.tar.gz
    mv ${phpmyadmin_filename} ${web_root_dir}/phpmyadmin
    cp -f ${cur_dir}/conf/config.inc.php ${web_root_dir}/phpmyadmin/config.inc.php
    mkdir -p ${web_root_dir}/phpmyadmin/{upload,save}
    chown -R apache:apache ${web_root_dir}/phpmyadmin
    echo "${phpmyadmin_filename} install completed..."
}


install_ZendGuardLoader(){
    local phpConfig=$1
    local php_version=`get_php_version "${phpConfig}"`
    local php_extension_dir=`get_php_extension_dir "${phpConfig}"`

    cd ${cur_dir}/software

    echo "ZendGuardLoader install start..."
    if is_64bit;then
        if [ "$php_version" == "5.3" ];then
            download_file "${ZendGuardLoader53_64_filename}.tar.gz"
            tar zxf ${ZendGuardLoader53_64_filename}.tar.gz
            cp -pf ${ZendGuardLoader53_64_filename}/php-${php_version}.x/ZendGuardLoader.so ${php_extension_dir}/
        elif [ "$php_version" == "5.4" ];then
            download_file "${ZendGuardLoader54_64_filename}.tar.gz"
            tar zxf ${ZendGuardLoader54_64_filename}.tar.gz
            cp -pf ${ZendGuardLoader54_64_filename}/php-${php_version}.x/ZendGuardLoader.so ${php_extension_dir}/
        elif [ "$php_version" == "5.5" ];then
            download_file "${ZendGuardLoader55_64_filename}.tar.gz"
            tar zxf ${ZendGuardLoader55_64_filename}.tar.gz
            cp -pf ${ZendGuardLoader55_64_filename}/ZendGuardLoader.so ${php_extension_dir}/
        elif [ "$php_version" == "5.6" ];then
            download_file "${ZendGuardLoader56_64_filename}.tar.gz"
            tar zxf ${ZendGuardLoader56_64_filename}.tar.gz
            cp -pf ${ZendGuardLoader56_64_filename}/ZendGuardLoader.so ${php_extension_dir}/
        fi
    else
        if [ "$php_version" == "5.3" ];then
            download_file  "${ZendGuardLoader53_32_filename}.tar.gz"
            tar zxf ${ZendGuardLoader53_32_filename}.tar.gz
            cp -pf ${ZendGuardLoader53_32_filename}/php-${php_version}.x/ZendGuardLoader.so ${php_extension_dir}/
        elif [ "$php_version" == "5.4" ];then
            download_file  "${ZendGuardLoader54_32_filename}.tar.gz"
            tar zxf ${ZendGuardLoader54_32_filename}.tar.gz
            cp -pf ${ZendGuardLoader54_32_filename}/php-${php_version}.x/ZendGuardLoader.so ${php_extension_dir}/
        elif [ "$php_version" == "5.5" ];then
            download_file "${ZendGuardLoader55_32_filename}.tar.gz"
            tar zxf ${ZendGuardLoader55_32_filename}.tar.gz
            cp -pf ${ZendGuardLoader55_32_filename}/ZendGuardLoader.so ${php_extension_dir}/
        elif [ "$php_version" == "5.6" ];then
            download_file "${ZendGuardLoader56_32_filename}.tar.gz"
            tar zxf ${ZendGuardLoader56_32_filename}.tar.gz
            cp -pf ${ZendGuardLoader56_32_filename}/ZendGuardLoader.so ${php_extension_dir}/
        fi
    fi

    if [ ! -f ${php_location}/php.d/zend.ini ]; then
        echo "ZendGuardLoader configuration file not found, create it!"
        cat > ${php_location}/php.d/zend.ini<<-EOF
[Zend Guard]
zend_extension = ${php_extension_dir}/ZendGuardLoader.so

zend_loader.enable = 1
zend_loader.disable_licensing = 0
zend_loader.obfuscation_level_support = 3
zend_loader.license_path =
EOF
    fi
    echo "ZendGuardLoader install completed..."
}


install_ionCube(){
    local phpConfig=$1
    local php_version=`get_php_version "${phpConfig}"`
    local php_extension_dir=`get_php_extension_dir "${phpConfig}"`

    cd ${cur_dir}/software/

    echo "ionCube install start..."
    if is_64bit; then
        download_file  "${ionCube64_filename}.tar.gz"
        tar zxf ${ionCube64_filename}.tar.gz
        cp -pf ioncube/ioncube_loader_lin_${php_version}.so ${php_extension_dir}/
    else
        download_file  "${ionCube32_filename}.tar.gz"
        tar zxf ${ionCube32_filename}.tar.gz
        cp -pf ioncube/ioncube_loader_lin_${php_version}.so ${php_extension_dir}/
    fi

    if [ ! -f ${php_location}/php.d/ioncube.ini ]; then
        echo "ionCube configuration file not found, create it!"
        cat > ${php_location}/php.d/ioncube.ini<<-EOF
[ionCube Loader]
zend_extension = ${php_extension_dir}/ioncube_loader_lin_${php_version}.so
EOF
    fi
    echo "ionCube install completed..."
}


install_opcache(){
    local phpConfig=$1
    local php_version=`get_php_version "${phpConfig}"`
    local php_extension_dir=`get_php_extension_dir "${phpConfig}"`

    cd ${cur_dir}/software/

    echo "opcache install start..."
    download_file "${opcache_filename}.tgz"
    tar zxf ${opcache_filename}.tgz
    cd ${opcache_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"
    if [ ! -f ${php_location}/php.d/opcache.ini ]; then
        echo "opcache configuration file not found, create it!"
        cat > ${php_location}/php.d/opcache.ini<<-EOF
[opcache]
zend_extension = ${php_extension_dir}/opcache.so
opcache.enable_cli=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.save_comments=0
EOF
    fi
    cp -f ${cur_dir}/conf/ocp.php ${web_root_dir}/ocp.php
    chown apache:apache ${web_root_dir}/ocp.php
    echo "opcache install completed..."
}


install_xcache(){
    local phpConfig=$1
    local php_version=`get_php_version "${phpConfig}"`
    local php_extension_dir=`get_php_extension_dir "${phpConfig}"`

    echo "XCache install start..."
    cd ${cur_dir}/software/
    download_file "${xcache_filename}.tar.gz"
    tar zxf ${xcache_filename}.tar.gz
    cd ${xcache_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --enable-xcache --enable-xcache-constant --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"
    
    rm -rf ${web_root_dir}/xcache
    cp -r htdocs/ ${web_root_dir}/xcache
    chown -R apache:apache ${web_root_dir}/xcache
    rm -rf /tmp/{pcov,phpcore}
    mkdir /tmp/{pcov,phpcore}
    chown -R apache:apache /tmp/{pcov,phpcore}
    chmod 700 /tmp/{pcov,phpcore}
    
    if [ ! -f ${php_location}/php.d/xcache.ini ]; then
        echo "XCache configuration file not found, create it!"
        cat > ${php_location}/php.d/xcache.ini<<-EOF
[xcache-common]
extension = ${php_extension_dir}/xcache.so

[xcache.admin]
xcache.admin.enable_auth = On
xcache.admin.user = "admin"
xcache.admin.pass = "e10adc3949ba59abbe56e057f20f883e"

[xcache]
xcache.shm_scheme = "mmap"
xcache.size = 64M
xcache.count = 1
xcache.slots = 8K
xcache.ttl = 3600
xcache.gc_interval = 60
xcache.var_size = 16M
xcache.var_count = 1
xcache.var_slots = 8K
xcache.var_ttl = 3600
xcache.var_maxttl = 0
xcache.var_gc_interval = 300
xcache.readonly_protection = Off
xcache.mmap_path = "/dev/zero"
xcache.coredump_directory = "/tmp/phpcore"
xcache.coredump_type = 0
xcache.disable_on_crash = Off
xcache.experimental = Off
xcache.cacher = On
xcache.stat = On
xcache.optimizer = Off

[xcache.coverager]
xcache.coverager = Off
xcache.coverager_autostart =  On
xcache.coveragedump_directory = "/tmp/pcov"
EOF
    fi
    echo "XCache install completed..."
}


install_php_imagesmagick(){
    local phpConfig=$1
    local php_version=`get_php_version "${phpConfig}"`
    local php_extension_dir=`get_php_extension_dir "${phpConfig}"`

    cd ${cur_dir}/software/

    echo "php-imagemagick install start..."
    download_file "${ImageMagick_filename}.tar.gz"
    tar zxf ${ImageMagick_filename}.tar.gz
    cd ${ImageMagick_filename}
    error_detect "./configure"
    error_detect "make"
    error_detect "make install"

    cd ${cur_dir}/software/

    download_file "${php_imagemagick_filename}.tgz"
    tar zxf ${php_imagemagick_filename}.tgz
    cd ${php_imagemagick_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-imagick=/usr/local --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"
    
    if [ ! -f ${php_location}/php.d/imagick.ini ]; then
        echo "imagemagick configuration file not found, create it!"
        cat > ${php_location}/php.d/imagick.ini<<-EOF
[imagick]
extension = ${php_extension_dir}/imagick.so
EOF
    fi
    echo "php-imagemagick install completed..."
}


install_php_graphicsmagick(){
    local phpConfig=$1
    local php_version=`get_php_version "${phpConfig}"`
    local php_extension_dir=`get_php_extension_dir "${phpConfig}"`

    cd ${cur_dir}/software/

    echo "php-graphicsmagick install start..."
    download_file "${GraphicsMagick_filename}.tar.gz"
    tar zxf ${GraphicsMagick_filename}.tar.gz
    cd ${GraphicsMagick_filename}
    error_detect "./configure --enable-shared"
    error_detect "make"
    error_detect "make install"

    cd ${cur_dir}/software/

    if [ "$php" == "${php7_0_filename}" ] || [ "$php" == "${php7_1_filename}" ]; then
        download_file "${php_graphicsmagick_filename2}.tgz"
        tar zxf ${php_graphicsmagick_filename2}.tgz
        cd ${php_graphicsmagick_filename2}
    else
        download_file "${php_graphicsmagick_filename}.tgz"
        tar zxf ${php_graphicsmagick_filename}.tgz
        cd ${php_graphicsmagick_filename}
    fi

    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"
    
    if [ ! -f ${php_location}/php.d/gmagick.ini ]; then
        echo "graphicsmagick configuration file not found, create it!"
        cat > ${php_location}/php.d/gmagick.ini<<-EOF
[gmagick]
extension = ${php_extension_dir}/gmagick.so
EOF
    fi
    echo "php-graphicsmagick install completed..."
}


install_php_memcached(){
    local phpConfig=$1
    local php_version=`get_php_version "${phpConfig}"`
    local php_extension_dir=`get_php_extension_dir "${phpConfig}"`

    cd ${cur_dir}/software

    echo "libevent install start..."
    download_file "${libevent_filename}.tar.gz"
    tar zxf ${libevent_filename}.tar.gz
    cd ${libevent_filename}
    error_detect "./configure"
    error_detect "make"
    error_detect "make install"

    if is_64bit;then
        ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib64/libevent-2.0.so.5
    else
        ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib/libevent-2.0.so.5
    fi
    echo "libevent install completed..."

    cd ${cur_dir}/software

    echo "memcached install start..."
    id -u memcached >/dev/null 2>&1
    [ $? -ne 0 ] && groupadd memcached && useradd -M -s /sbin/nologin -g memcached memcached
    download_file "${memcached_filename}.tar.gz"
    tar zxf ${memcached_filename}.tar.gz
    cd ${memcached_filename}
    error_detect "./configure --prefix=${depends_prefix}/memcached"
    sed -i "s/\-Werror//" Makefile
    error_detect "make"
    error_detect "make install"
    
    rm -f /usr/bin/memcached
    ln -s ${depends_prefix}/memcached/bin/memcached /usr/bin/memcached
    if check_sys packageManager apt;then
        cp -f ${cur_dir}/conf/memcached-init-debian /etc/init.d/memcached
    elif check_sys packageManager yum;then
        cp -f ${cur_dir}/conf/memcached-init-centos /etc/init.d/memcached
    fi
    chmod +x /etc/init.d/memcached
    boot_start memcached
    echo "memcached install completed..."

    cd ${cur_dir}/software

    echo "php-memcache install start..."
    download_file "${php_memcache_filename}.tgz"
    tar xzf ${php_memcache_filename}.tgz
    cd ${php_memcache_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --enable-memcache --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"
    
    if [ ! -f ${php_location}/php.d/memcache.ini ]; then
        echo "php-memcache configuration file not found, create it!"
        cat > ${php_location}/php.d/memcache.ini<<-EOF
[memcache]
extension = ${php_extension_dir}/memcache.so
EOF
    fi
    echo "php-memcache install completed..."
    
    cd ${cur_dir}/software
    
    echo "libmemcached install start..."
    if check_sys packageManager apt;then
        apt-get -y install libsasl2-dev
    elif check_sys packageManager yum;then
        yum -y install cyrus-sasl-plain cyrus-sasl cyrus-sasl-devel cyrus-sasl-lib
    fi
    download_file "${libmemcached_filename}.tar.gz"
    tar zxf ${libmemcached_filename}.tar.gz
    cd ${libmemcached_filename}
    error_detect "./configure --with-memcached=${depends_prefix}/memcached --enable-sasl"
    error_detect "make"
    error_detect "make install"
    echo "libmemcached install completed..."
    
    cd ${cur_dir}/software
    
    echo "php-memcached extension install start..."
    download_file "${php_memcached_filename}.tgz"
    tar zxf ${php_memcached_filename}.tgz
    cd ${php_memcached_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"

    if [ ! -f ${php_location}/php.d/memcached.ini ]; then
        echo "php-memcached configuration file not found, create it!"
        cat > ${php_location}/php.d/memcached.ini<<-EOF
[memcached]
extension = ${php_extension_dir}/memcached.so
memcached.use_sasl = 1
EOF
    fi
    echo "php-memcached install completed..."
}


install_php_redis(){
    local phpConfig=$1
    local php_version=`get_php_version "${phpConfig}"`
    local php_extension_dir=`get_php_extension_dir "${phpConfig}"`
    local redis_install_dir=${depends_prefix}/redis
    local tram=$( free -m | awk '/Mem/ {print $2}' )
    local swap=$( free -m | awk '/Swap/ {print $2}' )
    local Mem=`expr $tram + $swap`
    local RT=0

    cd ${cur_dir}/software/

    echo "redis-server install start..."
    download_file "${redis_filename}.tar.gz"
    tar zxf ${redis_filename}.tar.gz
    cd ${redis_filename}
    ! is_64bit && sed -i '1i\CFLAGS= -march=i686' src/Makefile && sed -i 's@^OPT=.*@OPT=-O2 -march=i686@' src/.make-settings
    error_detect "make"

    if [ -f "src/redis-server" ];then
        mkdir -p ${redis_install_dir}/{bin,etc,var}
        cp src/{redis-benchmark,redis-check-aof,redis-check-dump,redis-cli,redis-sentinel,redis-server} ${redis_install_dir}/bin/
        cp redis.conf ${redis_install_dir}/etc/
        ln -s ${redis_install_dir}/bin/* /usr/local/bin/
        sed -i 's@pidfile.*@pidfile /var/run/redis.pid@' ${redis_install_dir}/etc/redis.conf
        sed -i "s@logfile.*@logfile ${redis_install_dir}/var/redis.log@" ${redis_install_dir}/etc/redis.conf
        sed -i "s@^dir.*@dir ${redis_install_dir}/var@" ${redis_install_dir}/etc/redis.conf
        sed -i 's@daemonize no@daemonize yes@' ${redis_install_dir}/etc/redis.conf
        [ -z "`grep ^maxmemory ${redis_install_dir}/etc/redis.conf`" ] && sed -i "s@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory `expr ${Mem} / 8`000000@" ${redis_install_dir}/etc/redis.conf

        if check_sys packageManager apt;then
            id -u redis >/dev/null 2>&1
            [ $? -ne 0 ] && groupadd redis && useradd -M -s /sbin/nologin -g redis redis
            chown -R redis:redis ${redis_install_dir}
            cp -f ${cur_dir}/conf/redis-server-init-debian /etc/init.d/redis-server
        elif check_sys packageManager yum;then
            cp -f ${cur_dir}/conf/redis-server-init-centos /etc/init.d/redis-server
        fi
        chmod +x /etc/init.d/redis-server
        boot_start redis-server
        echo "redis-server install completed!"
    else
        RT=1
        echo "redis-server install failed."
    fi

    if [ ${RT} -eq 0 ];then
        cd ${cur_dir}/software/
        echo "php-redis install start..."
        if [ "$php" == "${php7_0_filename}" ] || [ "$php" == "${php7_1_filename}" ]; then
            download_file  "${php_redis_filename2}.tgz"
            tar zxf ${php_redis_filename2}.tgz
            cd ${php_redis_filename2}
        else
            download_file  "${php_redis_filename}.tgz"
            tar zxf ${php_redis_filename}.tgz
            cd ${php_redis_filename}
        fi

        error_detect "${php_location}/bin/phpize"
        error_detect "./configure --enable-redis --with-php-config=${phpConfig}"
        error_detect "make"
        error_detect "make install"
        
        if [ ! -f ${php_location}/php.d/redis.ini ]; then
            echo "php-redis configuration file not found, create it!"
            cat > ${php_location}/php.d/redis.ini<<-EOF
[redis]
extension = ${php_extension_dir}/redis.so
EOF
        fi
        echo "php-redis install completed..."
    fi
}


install_php_mongo(){
    local phpConfig=$1
    local php_version=`get_php_version "${phpConfig}"`
    local php_extension_dir=`get_php_extension_dir "${phpConfig}"`

    cd ${cur_dir}/software/

    echo "php-mongodb install start..."
    download_file "${php_mongo_filename}.tgz"
    tar zxf ${php_mongo_filename}.tgz
    cd ${php_mongo_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"

    if [ ! -f ${php_location}/php.d/mongodb.ini ]; then
        echo "php-mongodb configuration file not found, create it!"
        cat > ${php_location}/php.d/mongodb.ini<<-EOF
[mongodb]
extension = ${php_extension_dir}/mongodb.so
EOF
    fi
    echo "php-mongodb install completed..."
}


install_swoole(){
    local phpConfig=$1
    local php_version=`get_php_version "${phpConfig}"`
    local php_extension_dir=`get_php_extension_dir "${phpConfig}"`

    cd ${cur_dir}/software/

    echo "php-swoole install start..."
    download_file "${swoole_filename}.tar.gz"
    tar zxf ${swoole_filename}.tar.gz
    cd ${swoole_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"

    if [ ! -f ${php_location}/php.d/swoole.ini ]; then
        echo "php-swoole configuration file not found, create it!"
        cat > ${php_location}/php.d/swoole.ini<<-EOF
[swoole]
extension = ${php_extension_dir}/swoole.so
EOF
    fi
    echo "php-swoole install completed..."
}


update_icu(){
    echo "ICU version update start..."
    cd ${cur_dir}/software/

    download_file "${icu_filename}.tgz"
    tar zxf ${icu_filename}.tgz
    cd icu/source/
    error_detect "./configure"
    error_detect "parallel_make"
    error_detect "make install"

    echo "ICU version update completed!"
}


update_gmp(){
    echo "gmp version update start..."
    cd ${cur_dir}/software/

    download_file "${gmp_filename}.tar.bz2"
    tar jxf ${gmp_filename}.tar.bz2
    cd ${gmp_filename}
    error_detect "./configure"
    error_detect "parallel_make"
    error_detect "make install"

    echo "gmp version update completed!"
}
