# Copyright (C) 2013 - 2022 Teddysun <i@teddysun.com>
# 
# This file is part of the LAMP script.
#
# LAMP is a powerful bash script for the installation of 
# Apache + PHP + MySQL/MariaDB and so on.
# You can install Apache + PHP + MySQL/MariaDB in an very easy way.
# Just need to input numbers to choose what you want to install before installation.
# And all things will be done in a few minutes.
#
# Website:  https://lamp.sh
# Github:   https://github.com/teddysun/lamp

#Pre-installation php modules
php_modules_preinstall_settings(){
    if [ "${php}" == "do_not_install" ]; then
        php_modules_install="do_not_install"
    else
        phpConfig=${php_location}/bin/php-config
        echo
        echo "${php} available modules:"
        # Delete some modules (PHP 8 not support now) & change some module version
        if [[ "${php}" =~ ^php-8.[0-1].+$ ]]; then
            php_modules_arr=(${php_modules_arr[@]#${phalcon_filename}})
            php_modules_arr=(${php_modules_arr[@]#${ionCube_filename}})
            php_modules_arr=(${php_modules_arr[@]#${php_memcached_filename}})
        fi
        if [[ "${php}" =~ ^php-8.1.+$ ]]; then
            php_modules_arr=(${php_modules_arr[@]#${php_libsodium_filename}})
        fi
        display_menu_multi php_modules last
    fi
}

#Pre-installation phpmyadmin
phpmyadmin_preinstall_settings(){
    if [ "${php}" == "do_not_install" ]; then
        phpmyadmin="do_not_install"
    else
        display_menu_multi phpmyadmin 1
    fi
}

#Pre-installation kodexplorer
kodexplorer_preinstall_settings(){
    if [ "${php}" == "do_not_install" ]; then
        kodexplorer="do_not_install"
    else
        display_menu kodexplorer 1
    fi
}

install_php_modules(){
    local phpConfig=${1}
    if_in_array "${ionCube_filename}" "${php_modules_install}" && install_ionCube "${phpConfig}"
    if_in_array "${pdflib_filename}" "${php_modules_install}" && install_pdflib "${phpConfig}"
    if_in_array "${apcu_filename}" "${php_modules_install}" && install_apcu "${phpConfig}"
    if_in_array "${php_imagemagick_filename}" "${php_modules_install}" && install_php_imagesmagick "${phpConfig}"
    if_in_array "${php_mongo_filename}" "${php_modules_install}" && install_php_mongo "${phpConfig}"
    if_in_array "${php_libsodium_filename}" "${php_modules_install}" && install_php_libsodium "${phpConfig}"
    if_in_array "${swoole_filename}" "${php_modules_install}" && install_swoole "${phpConfig}"
    if_in_array "${yaf_filename}" "${php_modules_install}" && install_yaf "${phpConfig}"
    if_in_array "${yar_filename}" "${php_modules_install}" && install_yar "${phpConfig}"
    if_in_array "${grpc_filename}" "${php_modules_install}" && install_grpc "${phpConfig}"
    if_in_array "${phalcon_filename}" "${php_modules_install}" && install_phalcon "${phpConfig}"
    if_in_array "${php_redis_filename}" "${php_modules_install}" && install_php_redis "${phpConfig}"
    if_in_array "${php_memcached_filename}" "${php_modules_install}" && install_php_memcached "${phpConfig}"
    if_in_array "${xdebug_filename}" "${php_modules_install}" && install_xdebug "${phpConfig}"
}

install_phpmyadmin_modules(){
    if_in_array "${phpmyadmin_filename}" "${phpmyadmin_install}" && install_phpmyadmin
    if_in_array "${adminer_filename}" "${phpmyadmin_install}" && install_adminer
}

install_php_depends(){
    _info "Installing dependencies for PHP..."
    if check_sys packageManager apt; then
        apt_depends=(
            cmake autoconf patch m4 bison pkg-config autoconf2.13 libbz2-dev libgmp-dev libicu-dev libldb-dev
            libldap-2.4-2 libldap2-dev libsasl2-dev libsasl2-modules-ldap libc-client2007e-dev libkrb5-dev
            libpam0g-dev libonig-dev libxslt1-dev zlib1g-dev libpcre3-dev libtool libtidy-dev libsqlite3-dev
            libjpeg-dev libpng-dev libfreetype6-dev libpspell-dev libmhash-dev libenchant-dev libmcrypt-dev
            libcurl4-gnutls-dev libwebp-dev libxpm-dev libvpx-dev libreadline-dev snmp libsnmp-dev libzip-dev
        )
        debianversion 11 && apt_depends=(${apt_depends[@]/#libenchant-dev/libenchant-2-dev})
        for depend in ${apt_depends[@]}; do
            error_detect_depends "apt-get -y install ${depend}"
        done
        if is_64bit; then
            if [ ! -d /usr/lib64 ] && [ -d /usr/lib ]; then
                ln -sf /usr/lib /usr/lib64
            fi
            if [ -f /usr/include/gmp-x86_64.h ]; then
                ln -sf /usr/include/gmp-x86_64.h /usr/include/
            elif [ -f /usr/include/x86_64-linux-gnu/gmp.h ]; then
                ln -sf /usr/include/x86_64-linux-gnu/gmp.h /usr/include/
            fi
            ln -sf /usr/lib/x86_64-linux-gnu/libldap* /usr/lib64/
            ln -sf /usr/lib/x86_64-linux-gnu/liblber* /usr/lib64/
            if [ -d /usr/include/x86_64-linux-gnu/curl ] && [ ! -d /usr/include/curl ]; then
                ln -sf /usr/include/x86_64-linux-gnu/curl /usr/include/
            fi
            create_lib_link libc-client.a
            create_lib_link libc-client.so
        else
            if [ -f /usr/include/gmp-i386.h ]; then
                ln -sf /usr/include/gmp-i386.h /usr/include/
            elif [ -f /usr/include/i386-linux-gnu/gmp.h ]; then
                ln -sf /usr/include/i386-linux-gnu/gmp.h /usr/include/
            fi
            ln -sf /usr/lib/i386-linux-gnu/libldap* /usr/lib/
            ln -sf /usr/lib/i386-linux-gnu/liblber* /usr/lib/
            if [ -d /usr/include/i386-linux-gnu/curl ] && [ ! -d /usr/include/curl ]; then
                ln -sf /usr/include/i386-linux-gnu/curl /usr/include/
            fi
        fi
        # Fixed older PHP installation in Debian 10 or Ubuntu 20
        if debianversion 10 || ubuntuversion 20; then
            install_older_php_pre
        fi
    elif check_sys packageManager yum; then
        yum_depends=(
            cmake autoconf patch m4 bison bzip2-devel pam-devel gmp-devel libicu-devel
            curl-devel pcre-devel libtool-libs libtool-ltdl-devel libwebp-devel libXpm-devel
            libvpx-devel libjpeg-devel libpng-devel freetype-devel oniguruma-devel
            aspell-devel enchant-devel readline-devel libtidy-devel sqlite-devel
            openldap-devel libxslt-devel net-snmp net-snmp-devel krb5-devel
        )
        for depend in ${yum_depends[@]}; do
            error_detect_depends "yum -y install ${depend}"
        done
        if yum list 2>/dev/null | grep -q "libc-client-devel"; then
            error_detect_depends "yum -y install libc-client-devel"
        elif yum list 2>/dev/null | grep -q "uw-imap-devel"; then
            error_detect_depends "yum -y install uw-imap-devel"
        else
            _error "There is no rpm package libc-client-devel or uw-imap-devel, please check it and try again."
        fi
        # Fixed No rule to make target '/usr/include/libpng15/png.h', needed by 'ext/gd/libgd/gd_png.lo'.
        if [ ! -d "/usr/include/libpng15" ] && [ -d "/usr/include/libpng16" ]; then
            ln -sf /usr/include/libpng16/ /usr/include/libpng15
        fi
        install_mhash
        install_libmcrypt
        install_mcrypt
        install_libzip
    fi
    install_libiconv
    install_re2c
    install_argon2
    _info "Install dependencies for PHP completed..."
}

install_older_php_pre(){
    # Fixed configure: error: freetype-config not found
    if [ ! -f "/usr/local/bin/freetype-config" ] && [ ! -f "/usr/bin/freetype-config" ]; then
        { echo '#!/bin/sh'; echo 'exec pkg-config "$@" freetype2'; } > /usr/local/bin/freetype-config
        chmod +x /usr/local/bin/freetype-config
    fi
    # Fixed configure: error: Unable to detect ICU prefix or /usr/bin/icu-config failed. Please verify ICU install prefix and make sure icu-config works.
    if is_64bit; then
        debianversion 10 && cp -f ${cur_dir}/conf/icu-config_debian10_amd64 /usr/bin/icu-config
        ubuntuversion 20 && cp -f ${cur_dir}/conf/icu-config_ubuntu20_amd64 /usr/bin/icu-config
    else
        debianversion 10 && cp -f ${cur_dir}/conf/icu-config_debian10_i386 /usr/bin/icu-config
        ubuntuversion 20 && cp -f ${cur_dir}/conf/icu-config_ubuntu20_i386 /usr/bin/icu-config
    fi
    chmod +x /usr/bin/icu-config
}

install_argon2(){
    if [ ! -e "/usr/lib/libargon2.a" ]; then
        local libargon2_path=""
        cd ${cur_dir}/software/
        _info "Installing ${argon2_filename}..."
        download_file "${argon2_filename}.tar.gz" "${argon2_filename_url}"
        tar zxf ${argon2_filename}.tar.gz
        cd ${argon2_filename}

        error_detect "make"
        error_detect "make install"
        if check_sys packageManager apt; then
            is_64bit && libargon2_path="/usr/lib/x86_64-linux-gnu/pkgconfig/libargon2.pc" || libargon2_path="/usr/lib/i386-linux-gnu/pkgconfig/libargon2.pc"
        elif check_sys packageManager yum; then
            is_64bit && libargon2_path="/usr/lib64/pkgconfig/libargon2.pc" || libargon2_path="/usr/lib/pkgconfig/libargon2.pc"
        fi
        cat > ${libargon2_path} <<EOF
# libargon2 info for pkg-config

prefix=/usr
exec_prefix=${prefix}
libdir=${prefix}/lib
includedir=${prefix}/include

Name: libargon2
Description: Development libraries for libargon2
Version: 20171227
Libs: -L${libdir} -largon2 -lrt -ldl
Cflags:
URL: https://github.com/P-H-C/phc-winner-argon2
EOF
        _info "Install ${argon2_filename} completed..."
    fi
}

install_libiconv(){
    if [ ! -e "${depends_prefix}/libiconv/bin/iconv" ]; then
        cd ${cur_dir}/software/
        _info "Installing ${libiconv_filename}..."
        download_file  "${libiconv_filename}.tar.gz" "${libiconv_filename_url}"
        tar zxf ${libiconv_filename}.tar.gz
        patch -d ${libiconv_filename} -p0 < ${cur_dir}/src/libiconv-glibc-2.16.patch
        cd ${libiconv_filename}

        error_detect "./configure --prefix=${depends_prefix}/libiconv"
        error_detect "parallel_make"
        error_detect "make install"
        create_lib64_dir "${depends_prefix}/libiconv"
        if ! grep -qE "^${depends_prefix}/libiconv/lib" /etc/ld.so.conf.d/*.conf; then
            echo "${depends_prefix}/libiconv/lib" > /etc/ld.so.conf.d/libiconvlib.conf
        fi
        _info "Install ${libiconv_filename} completed..."
    fi
}

install_re2c(){
    if [ ! -e "/usr/local/bin/re2c" ]; then
        cd ${cur_dir}/software/
        _info "Installing ${re2c_filename}..."
        download_file "${re2c_filename}.tar.gz" "${re2c_filename_url}"
        tar zxf ${re2c_filename}.tar.gz
        cd ${re2c_filename}

        error_detect "./configure"
        error_detect "parallel_make"
        error_detect "make install"
        _info "Install ${re2c_filename} completed..."
    fi
}

install_mhash(){
    if [ ! -e "/usr/local/lib/libmhash.a" ]; then
        cd ${cur_dir}/software/
        _info "Installing ${mhash_filename}..."
        download_file "${mhash_filename}.tar.gz" "${mhash_filename_url}"
        tar zxf ${mhash_filename}.tar.gz
        cd ${mhash_filename}

        error_detect "./configure"
        error_detect "parallel_make"
        error_detect "make install"
        _info "Install ${mhash_filename} completed..."
    fi
}

install_mcrypt(){
    if [ ! -e "/usr/local/bin/mcrypt" ]; then
        cd ${cur_dir}/software/
        _info "Installing ${mcrypt_filename}..."
        download_file "${mcrypt_filename}.tar.gz" "${mcrypt_filename_url}"
        tar zxf ${mcrypt_filename}.tar.gz
        cd ${mcrypt_filename}

        ldconfig
        error_detect "./configure"
        error_detect "parallel_make"
        error_detect "make install"
        _info "Install ${mcrypt_filename} completed..."
    fi
}

install_libmcrypt(){
    if [ ! -e "/usr/local/lib/libmcrypt.la" ]; then
        cd ${cur_dir}/software/
        _info "Installing ${libmcrypt_filename}..."
        download_file "${libmcrypt_filename}.tar.gz" "${libmcrypt_filename_url}"
        tar zxf ${libmcrypt_filename}.tar.gz
        cd ${libmcrypt_filename}

        error_detect "./configure"
        error_detect "parallel_make"
        error_detect "make install"
        _info "Install ${libmcrypt_filename} completed..."
    fi
}

install_libzip(){
    local cmake_bin="$(command -v cmake)"
    local cmake_ver="$(${cmake_bin} --version | head -1 | grep -oE "[0-9.]+")"
    if version_lt ${cmake_ver} 3.0.2; then
        cd ${cur_dir}/software/
        _info "Installing ${cmake_filename}..."
        if is_64bit; then
            if [ ! -d "${depends_prefix}/cmake" ]; then
                download_file "${cmake_filename2}.tar.gz" "${cmake_filename_url2}"
                tar zxf ${cmake_filename2}.tar.gz -C ${depends_prefix}
                mv ${depends_prefix}/${cmake_filename2} ${depends_prefix}/cmake
            fi
            [ -x "${depends_prefix}/cmake/bin/cmake" ] && cmake_bin="${depends_prefix}/cmake/bin/cmake"
        else
            download_file "${cmake_filename}.tar.gz" "${cmake_filename_url}"
            tar zxf ${cmake_filename}.tar.gz
            cd ${cmake_filename}
            error_detect "./bootstrap --prefix=${depends_prefix}"
            error_detect "parallel_make"
            error_detect "make install"
            cmake_bin="${depends_prefix}/bin/cmake"
        fi
        _info "Install ${cmake_filename} completed..."
    fi
    if [ ! -e "/usr/local/bin/zipcmp" ]; then
        cd ${cur_dir}/software/
        _info "Installing ${libzip_filename}..."
        download_file "${libzip_filename}.tar.gz" "${libzip_filename_url}"
        tar zxf ${libzip_filename}.tar.gz
        cd ${libzip_filename} && mkdir build && cd build

        error_detect "${cmake_bin} .."
        error_detect "parallel_make"
        error_detect "make install"
        is_64bit && cp -pv libzip.pc /usr/lib64/pkgconfig || cp -pv libzip.pc /usr/lib/pkgconfig
        _info "Install ${libzip_filename} completed..."
    fi
}

install_phpmyadmin(){
    local pma_file=""
    local pma_file_url=""
    if [ -d "${web_root_dir}/phpmyadmin" ]; then
        rm -rf ${web_root_dir}/phpmyadmin
    fi
    pma_file=${phpmyadmin_filename}
    pma_file_url=${phpmyadmin_filename_url}
    cd ${cur_dir}/software
    _info "Installing ${pma_file}..."
    download_file "${pma_file}.tar.gz" "${pma_file_url}"
    tar zxf ${pma_file}.tar.gz
    mv ${pma_file} ${web_root_dir}/phpmyadmin
    cp -f ${cur_dir}/conf/config.inc.php ${web_root_dir}/phpmyadmin/config.inc.php
    mkdir -p ${web_root_dir}/phpmyadmin/{upload,save}
    chown -R apache.apache ${web_root_dir}/phpmyadmin
    _info "Install ${pma_file} completed..."
}

install_adminer(){
    _info "Installing ${adminer_filename}..."
    cd ${cur_dir}/software
    download_file "${adminer_filename}.php" "${adminer_filename_url}"
    mv ${adminer_filename}.php ${web_root_dir}/adminer.php
    chown apache:apache ${web_root_dir}/adminer.php
    _info "Install ${adminer_filename} completed..."
}

install_kodexplorer(){
    if [ -d "${web_root_dir}/kod" ]; then
        rm -rf ${web_root_dir}/kod
    fi

    cd ${cur_dir}/software
    _info "Installing ${kodexplorer_filename}..."
    download_file "${kodexplorer_filename}.tar.gz" "${kodexplorer_filename_url}"
    tar zxf ${kodexplorer_filename}.tar.gz
    mv ${kodexplorer_filename} ${web_root_dir}/kod
    chown -R apache:apache ${web_root_dir}/kod
    _info "Install ${kodexplorer_filename} completed..."
}

install_ionCube(){
    local phpConfig=${1}
    local php_version=$(get_php_version "${phpConfig}")
    local php_extension_dir=$(get_php_extension_dir "${phpConfig}")

    cd ${cur_dir}/software/
    _info "Installing PHP extension ionCube Loader..."
    if is_64bit; then
        download_file "${ionCube64_filename}.tar.gz" "${ionCube64_filename_url}"
        tar zxf ${ionCube64_filename}.tar.gz
        cp -pf ioncube/ioncube_loader_lin_${php_version}_ts.so ${php_extension_dir}/
    else
        download_file "${ionCube32_filename}.tar.gz" "${ionCube32_filename_url}"
        tar zxf ${ionCube32_filename}.tar.gz
        cp -pf ioncube/ioncube_loader_lin_${php_version}_ts.so ${php_extension_dir}/
    fi

    if [ ! -f "${php_location}/php.d/ioncube.ini" ]; then
        cat > ${php_location}/php.d/ioncube.ini<<EOF
[ionCube Loader]
zend_extension=ioncube_loader_lin_${php_version}_ts.so
EOF
    fi
    _info "Install PHP extension ionCube Loader completed..."
}

install_pdflib(){
    local phpConfig=${1}
    local php_version=$(get_php_version "${phpConfig}" | sed 's/\.//g')
    local php_extension_dir=$(get_php_extension_dir "${phpConfig}")

    cd ${cur_dir}/software/
    _info "Installing PHP extension pdflib..."
    if is_64bit; then
        download_file "${pdflib64_filename}.tar.gz" "${pdflib64_filename_url}"
        tar zxf ${pdflib64_filename}.tar.gz
        cp -pf ${pdflib64_filename}/bind/php/php-${php_version}0/php_pdflib.so ${php_extension_dir}/
    else
        download_file "${pdflib32_filename}.tar.gz" "${pdflib32_filename_url}"
        tar zxf ${pdflib32_filename}.tar.gz
        cp -pf ${pdflib32_filename}/bind/php/php-${php_version}0/php_pdflib.so ${php_extension_dir}/
    fi

    if [ ! -f "${php_location}/php.d/pdflib.ini" ]; then
        cat > ${php_location}/php.d/pdflib.ini<<EOF
[pdflib]
extension=php_pdflib.so
EOF
    fi
    _info "Install PHP extension pdflib completed..."
}

install_php_libsodium(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "Installing ${libsodium_filename}..."
    download_file "${libsodium_filename}.tar.gz" "${libsodium_filename_url}"
    tar zxf ${libsodium_filename}.tar.gz
    cd ${libsodium_filename}
    error_detect "./configure --prefix=/usr"
    error_detect "parallel_make"
    error_detect "make install"
    _info "Install ${libsodium_filename} completed..."

    cd ${cur_dir}/software/
    _info "Installing PHP extension sodium..."
    download_file "${php_libsodium_filename}.tgz" "${php_libsodium_filename_url}"
    tar zxf ${php_libsodium_filename}.tgz
    cd ${php_libsodium_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/sodium.ini" ]; then
        cat > ${php_location}/php.d/sodium.ini<<EOF
[sodium]
extension=sodium.so
EOF
    fi
    _info "Install PHP extension sodium completed..."
}

install_php_imagesmagick(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "Installing ${ImageMagick_filename}..."
    download_file "${ImageMagick_filename}.tar.gz" "${ImageMagick_filename_url}"
    tar zxf ${ImageMagick_filename}.tar.gz
    cd ${ImageMagick_filename}
    error_detect "./configure"
    error_detect "parallel_make"
    error_detect "make install"
    _info "Install ${ImageMagick_filename} completed..."

    cd ${cur_dir}/software/
    _info "Installing PHP extension imagick..."
    download_file "${php_imagemagick_filename}.tgz" "${php_imagemagick_filename_url}"
    tar zxf ${php_imagemagick_filename}.tgz
    cd ${php_imagemagick_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-imagick=/usr/local --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/imagick.ini" ]; then
        cat > ${php_location}/php.d/imagick.ini<<EOF
[imagick]
extension=imagick.so
EOF
    fi
    _info "Install PHP extension imagick completed..."
}

install_php_memcached(){
    local phpConfig=${1}

    cd ${cur_dir}/software
    _info "Installing ${libevent_filename}..."
    download_file "${libevent_filename}.tar.gz" "${libevent_filename_url}"
    tar zxf ${libevent_filename}.tar.gz
    cd ${libevent_filename}
    error_detect "./configure"
    error_detect "make"
    error_detect "make install"
    ldconfig
    _info "Install ${libevent_filename} completed..."

    cd ${cur_dir}/software
    _info "Installing ${memcached_filename}..."
    id -u memcached >/dev/null 2>&1
    [ $? -ne 0 ] && groupadd memcached && useradd -M -s /sbin/nologin -g memcached memcached
    download_file "${memcached_filename}.tar.gz" "${memcached_filename_url}"
    tar zxf ${memcached_filename}.tar.gz
    cd ${memcached_filename}
    error_detect "./configure --prefix=${depends_prefix}/memcached"
    sed -i "s/\-Werror//" Makefile
    error_detect "make"
    error_detect "make install"

    [ -f "/usr/bin/memcached" ] && rm -f /usr/bin/memcached
    ln -s ${depends_prefix}/memcached/bin/memcached /usr/bin/memcached
    if check_sys packageManager apt; then
        cp -f ${cur_dir}/init.d/memcached-init-debian /etc/init.d/memcached
    elif check_sys packageManager yum; then
        cp -f ${cur_dir}/init.d/memcached-init-centos /etc/init.d/memcached
    fi
    chmod +x /etc/init.d/memcached
    boot_start memcached
    _info "Install ${memcached_filename} completed..."

    cd ${cur_dir}/software
    _info "Installing ${libmemcached_filename}..."
    if check_sys packageManager apt; then
        apt-get -y install libsasl2-dev
    elif check_sys packageManager yum; then
        yum -y install cyrus-sasl-plain cyrus-sasl cyrus-sasl-devel cyrus-sasl-lib
    fi
    download_file "${libmemcached_filename}.tar.gz" "${libmemcached_filename_url}"
    tar zxf ${libmemcached_filename}.tar.gz
    patch -d ${libmemcached_filename} -p0 < ${cur_dir}/src/libmemcached-build.patch
    cd ${libmemcached_filename}
    error_detect "./configure --with-memcached=${depends_prefix}/memcached --enable-sasl"
    error_detect "make"
    error_detect "make install"
    _info "Install ${libmemcached_filename} completed..."

    cd ${cur_dir}/software
    _info "Installing PHP extension memcached..."
    download_file "${php_memcached_filename}.tgz" "${php_memcached_filename_url}"
    tar zxf ${php_memcached_filename}.tgz
    cd ${php_memcached_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/memcached.ini" ]; then
        cat > ${php_location}/php.d/memcached.ini<<EOF
[memcached]
extension=memcached.so
memcached.use_sasl = 1
EOF
    fi
    _info "Install PHP extension memcached completed..."
}

install_php_redis(){
    local phpConfig=${1}
    local redis_install_dir=${depends_prefix}/redis
    local tram=$( free -m | awk '/Mem/ {print $2}' )
    local swap=$( free -m | awk '/Swap/ {print $2}' )
    local Mem=$(expr $tram + $swap)
    local RT=0

    cd ${cur_dir}/software/
    _info "Installing ${redis_filename}..."
    download_file "${redis_filename}.tar.gz" "${redis_filename_url}"
    tar zxf ${redis_filename}.tar.gz
    cd ${redis_filename}
    ! is_64bit && sed -i '1i\CFLAGS= -march=i686' src/Makefile && sed -i 's@^OPT=.*@OPT=-O2 -march=i686@' src/.make-settings
    error_detect "make"

    if [ -f "src/redis-server" ]; then
        mkdir -p ${redis_install_dir}/{bin,etc,var}
        cp src/{redis-benchmark,redis-check-aof,redis-check-rdb,redis-cli,redis-sentinel,redis-server} ${redis_install_dir}/bin/
        cp redis.conf ${redis_install_dir}/etc/
        ln -s ${redis_install_dir}/bin/* /usr/local/bin/
        sed -i 's@pidfile.*@pidfile /var/run/redis.pid@' ${redis_install_dir}/etc/redis.conf
        sed -i "s@logfile.*@logfile ${redis_install_dir}/var/redis.log@" ${redis_install_dir}/etc/redis.conf
        sed -i "s@^dir.*@dir ${redis_install_dir}/var@" ${redis_install_dir}/etc/redis.conf
        sed -i 's@daemonize no@daemonize yes@' ${redis_install_dir}/etc/redis.conf
        sed -i "s@^# bind 127.0.0.1@bind 127.0.0.1@" ${redis_install_dir}/etc/redis.conf
        [ -z "$(grep ^maxmemory ${redis_install_dir}/etc/redis.conf)" ] && sed -i "s@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory $(expr ${Mem} / 8)000000@" ${redis_install_dir}/etc/redis.conf

        if check_sys packageManager apt; then
            cp -f ${cur_dir}/init.d/redis-server-init-debian /etc/init.d/redis-server
        elif check_sys packageManager yum; then
            cp -f ${cur_dir}/init.d/redis-server-init-centos /etc/init.d/redis-server
        fi
        id -u redis >/dev/null 2>&1
        [ $? -ne 0 ] && groupadd redis && useradd -M -s /sbin/nologin -g redis redis
        chown -R redis:redis ${redis_install_dir}
        chmod +x /etc/init.d/redis-server
        boot_start redis-server
        _info "Install ${redis_filename} completed!"
    else
        RT=1
        _error "Install ${redis_filename} failed."
    fi

    if [ ${RT} -eq 0 ]; then
        cd ${cur_dir}/software/
        _info "Installing PHP extension redis..."
        download_file  "${php_redis_filename}.tgz" "${php_redis_filename_url}"
        tar zxf ${php_redis_filename}.tgz
        cd ${php_redis_filename}

        error_detect "${php_location}/bin/phpize"
        error_detect "./configure --enable-redis --with-php-config=${phpConfig}"
        error_detect "make"
        error_detect "make install"

        if [ ! -f "${php_location}/php.d/redis.ini" ]; then
            cat > ${php_location}/php.d/redis.ini<<EOF
[redis]
extension=redis.so
EOF
        fi
        _info "Install PHP extension redis completed..."
    fi
}

install_php_mongo(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "Installing PHP extension mongodb..."
    download_file "${php_mongo_filename}.tgz" "${php_mongo_filename_url}"
    tar zxf ${php_mongo_filename}.tgz
    cd ${php_mongo_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "parallel_make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/mongodb.ini" ]; then
        cat > ${php_location}/php.d/mongodb.ini<<EOF
[mongodb]
extension=mongodb.so
EOF
    fi
    _info "Install PHP extension mongodb completed..."
}

install_swoole(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "Installing PHP extension swoole..."
    download_file "${swoole_filename}.tgz" "${swoole_filename_url}"
    tar zxf ${swoole_filename}.tgz
    cd ${swoole_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig} --enable-http2 --enable-swoole-json"
    error_detect "parallel_make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/swoole.ini" ]; then
        cat > ${php_location}/php.d/swoole.ini<<EOF
[swoole]
extension=swoole.so
EOF
    fi
    _info "Install PHP extension swoole completed..."
}

install_xdebug(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "Installing PHP extension xdebug..."
    download_file "${xdebug_filename}.tgz" "${xdebug_filename_url}"
    tar zxf ${xdebug_filename}.tgz
    cd ${xdebug_filename}

    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --enable-xdebug --with-php-config=${phpConfig}"
    error_detect "parallel_make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/xdebug.ini" ]; then
        cat > ${php_location}/php.d/xdebug.ini<<EOF
[xdebug]
zend_extension=xdebug.so
EOF
    fi
    _info "Install PHP extension xdebug completed..."
}

install_yaf(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "Installing PHP extension yaf..."
    download_file "${yaf_filename}.tgz" "${yaf_filename_url}"
    tar zxf ${yaf_filename}.tgz
    cd ${yaf_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "parallel_make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/yaf.ini" ]; then
        cat > ${php_location}/php.d/yaf.ini<<EOF
[yaf]
extension=yaf.so
EOF
    fi
    _info "Install PHP extension yaf completed..."
}

install_yar(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "Installing PHP extension msgpack..."
    download_file "${msgpack_filename}.tgz" "${msgpack_filename_url}"
    tar zxf ${msgpack_filename}.tgz
    cd ${msgpack_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "parallel_make"
    error_detect "make install"
    if [ ! -f "${php_location}/php.d/msgpack.ini" ]; then
        cat > ${php_location}/php.d/msgpack.ini<<EOF
[msgpack]
extension=msgpack.so
EOF
    fi
    _info "Install PHP extension msgpack completed..."
    cd ${cur_dir}/software/
    _info "Installing PHP extension yar..."
    download_file "${yar_filename}.tgz" "${yar_filename_url}"
    tar zxf ${yar_filename}.tgz
    cd ${yar_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig} --with-curl --enable-yar --enable-msgpack"
    error_detect "parallel_make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/yar.ini" ]; then
        cat > ${php_location}/php.d/yar.ini<<EOF
[yar]
extension=yar.so
EOF
    fi
    _info "Install PHP extension yar completed..."
}

install_phalcon(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "Installing PHP extension psr..."
    download_file "${psr_filename}.tgz" "${psr_filename_url}"
    tar zxf ${psr_filename}.tgz
    cd ${psr_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "parallel_make"
    error_detect "make install"
    if [ ! -f "${php_location}/php.d/psr.ini" ]; then
        cat > ${php_location}/php.d/psr.ini<<EOF
[psr]
extension=psr.so
EOF
    fi
    _info "Install PHP extension psr completed..."
    cd ${cur_dir}/software/
    _info "Installing PHP extension phalcon..."
    download_file "${phalcon_filename}.tgz" "${phalcon_filename_url}"
    tar zxf ${phalcon_filename}.tgz
    cd ${phalcon_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "parallel_make"
    error_detect "make install"
    if [ ! -f "${php_location}/php.d/phalcon.ini" ]; then
        cat > ${php_location}/php.d/phalcon.ini<<EOF
[phalcon]
extension=phalcon.so
EOF
    fi
    _info "Install PHP extension phalcon completed..."
}

install_apcu(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "Installing PHP extension apcu..."
    download_file "${apcu_filename}.tgz" "${apcu_filename_url}"
    tar zxf ${apcu_filename}.tgz
    cd ${apcu_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "parallel_make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/apcu.ini" ]; then
        cat > ${php_location}/php.d/apcu.ini<<EOF
[apcu]
extension=apcu.so
EOF
    fi
    _info "Install PHP extension apcu completed..."
}

install_grpc(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "Installing PHP extension grpc..."
    download_file "${grpc_filename}.tgz" "${grpc_filename_url}"
    tar zxf ${grpc_filename}.tgz
    cd ${grpc_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig} --enable-grpc"
    error_detect "parallel_make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/grpc.ini" ]; then
        cat > ${php_location}/php.d/grpc.ini<<EOF
[grpc]
extension=grpc.so
EOF
    fi
    _info "Install PHP extension grpc completed..."
}
