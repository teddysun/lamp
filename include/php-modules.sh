# Copyright (C) 2013 - 2020 Teddysun <i@teddysun.com>
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
        # delete some modules & change some module version
        if [ "${php}" == "${php5_6_filename}" ]; then
            php_modules_arr=(${php_modules_arr[@]#${php_libsodium_filename}})
            php_modules_arr=(${php_modules_arr[@]#${swoole_filename}})
            php_modules_arr=(${php_modules_arr[@]#${yaf_filename}})
            php_modules_arr=(${php_modules_arr[@]#${yar_filename}})
            php_modules_arr=(${php_modules_arr[@]#${pdflib_filename}})
            php_modules_arr=(${php_modules_arr[@]#${phalcon_filename}})
        else
            php_modules_arr=(${php_modules_arr[@]#${xcache_filename}})
            php_modules_arr=(${php_modules_arr[@]/#${xdebug_filename}/${xdebug_filename2}})
            php_modules_arr=(${php_modules_arr[@]/#${php_redis_filename}/${php_redis_filename2}})
            php_modules_arr=(${php_modules_arr[@]/#${php_memcached_filename}/${php_memcached_filename2}})
            php_modules_arr=(${php_modules_arr[@]/#${php_graphicsmagick_filename}/${php_graphicsmagick_filename2}})
        fi
        # PDFlib & Phalcon v4 supports only PHP 7.2 and above
        # Reference URL: https://docs.phalcon.io/4.0/en/installation
        if [[ "${php}" =~ ^php-7.[0-1].+$ ]]; then
            php_modules_arr=(${php_modules_arr[@]#${pdflib_filename}})
            php_modules_arr=(${php_modules_arr[@]#${phalcon_filename}})
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
    if_in_array "${xcache_filename}" "${php_modules_install}" && install_xcache "${phpConfig}"
    if_in_array "${php_libsodium_filename}" "${php_modules_install}" && install_php_libsodium "${phpConfig}"
    if_in_array "${swoole_filename}" "${php_modules_install}" && install_swoole "${phpConfig}"
    if_in_array "${yaf_filename}" "${php_modules_install}" && install_yaf "${phpConfig}"
    if_in_array "${yar_filename}" "${php_modules_install}" && install_yar "${phpConfig}"
    if_in_array "${grpc_filename}" "${php_modules_install}" && install_grpc "${phpConfig}"
    if_in_array "${phalcon_filename}" "${php_modules_install}" && install_phalcon "${phpConfig}"
    if  if_in_array "${php_graphicsmagick_filename}" "${php_modules_install}" || \
        if_in_array "${php_graphicsmagick_filename2}" "${php_modules_install}"; then
        install_php_graphicsmagick "${phpConfig}"
    fi
    if  if_in_array "${php_redis_filename}" "${php_modules_install}" || \
        if_in_array "${php_redis_filename2}" "${php_modules_install}"; then
        install_php_redis "${phpConfig}"
    fi
    if  if_in_array "${php_memcached_filename}" "${php_modules_install}" || \
        if_in_array "${php_memcached_filename2}" "${php_modules_install}"; then
        install_php_memcached "${phpConfig}"
    fi
    if  if_in_array "${xdebug_filename}" "${php_modules_install}" || \
        if_in_array "${xdebug_filename2}" "${php_modules_install}"; then
        install_xdebug "${phpConfig}"
    fi
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
        install_mhash
        install_libmcrypt
        install_mcrypt
        install_libzip
        # Fixed error: Autoconf version 2.68 or higher is required in CentOS 6
        if centosversion 6; then
            # Uninstall old autoconf
            if rpm -qa | grep -q autoconf; then
                rpm -e --nodeps autoconf-2.63
            fi
            install_autoconf
            # Fixed PHP 7.4 installation in CentOS 6
            if [[ "${php}" == "${php7_4_filename}" ]]; then
                install_php74_centos6
            fi
        fi
    fi
    install_libiconv
    install_re2c
    # Support Argon2 Password Hash (Only PHP 7.2+)
    # Reference URL: https://wiki.php.net/rfc/argon2_password_hash
    if [[ "${php}" =~ ^php-7.[2-4].+$ ]]; then
        install_argon2
    fi
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

install_php74_centos6(){
    local libdir=""
    is_64bit && libdir="lib64" || libdir="lib"
    # Fixed configure: error: Package requirements (sqlite3 > 3.7.4) were not met
    install_sqlite3
    cp -pf /usr/local/lib/pkgconfig/sqlite3.pc /usr/${libdir}/pkgconfig
    # Fixed configure: error: Package requirements (icu-uc >= 50.1 icu-io icu-i18n) were not met
    install_icu4c
    cp -pf /usr/local/lib/pkgconfig/icu*.pc /usr/${libdir}/pkgconfig
    # Fixed configure: error: Package requirements (krb5-gssapi krb5) were not met
    cat > /usr/${libdir}/pkgconfig/krb5-gssapi.pc <<EOF
prefix=/usr
exec_prefix=/usr
libdir=/usr/${libdir}
includedir=/usr/include

Name: krb5-gssapi
Description: Kerberos implementation of the GSSAPI
Version: 1.10.3
Libs: -L\${libdir} -lgssapi_krb5
Cflags: -I\${includedir}
EOF
    cat > /usr/${libdir}/pkgconfig/krb5.pc <<EOF
prefix=/usr
exec_prefix=/usr
libdir=/usr/${libdir}
includedir=/usr/include

Name: krb5
Description: An implementation of Kerberos network authentication
Version: 1.10.3
Libs: -L\${libdir} -lkrb5 -lk5crypto
Cflags: -I\${includedir}
EOF
    # Fixed configure: error: Package requirements (libjpeg) were not met
    cat > /usr/${libdir}/pkgconfig/libjpeg.pc <<EOF
prefix=/usr
exec_prefix=/usr
libdir=/usr/${libdir}
includedir=/usr/include

Name: libjpeg
Description: A SIMD-accelerated JPEG codec that provides the libjpeg API
Version: 1.2.1
Libs: -L\${libdir} -ljpeg
Cflags: -I\${includedir}
EOF
    # Fixed configure: error: Package requirements (libsasl2) were not met
    cat > /usr/${libdir}/pkgconfig/libsasl2.pc <<EOF
libdir = /usr/${libdir}

Name: Cyrus SASL
Description: Cyrus SASL implementation
URL: http://www.cyrussasl.org/
Version: 2.1.23
Libs: -L\${libdir} -lsasl2
Libs.private:  -ldl -lresolv -lcrypt -lgssapi_krb5 -lkrb5 -lk5crypto -lcom_err -lkrb5support
EOF
    # Fixed configure: error: Package requirements (oniguruma) were not met
    cat > /usr/${libdir}/pkgconfig/oniguruma.pc <<EOF
prefix=/usr
exec_prefix=/usr
libdir=/usr/${libdir}
includedir=/usr/include
datarootdir=/usr/share
datadir=/usr/share

Name: oniguruma
Description: Regular expression library
Version: 5.9.1
Requires:
Libs: -L\${libdir} -lonig
Cflags: -I\${includedir}
EOF

}

install_argon2(){
    if [ ! -e "/usr/lib/libargon2.a" ]; then
        cd ${cur_dir}/software/
        _info "${argon2_filename} install start..."
        download_file "${argon2_filename}.tar.gz" "${argon2_filename_url}"
        tar zxf ${argon2_filename}.tar.gz
        cd ${argon2_filename}

        error_detect "make"
        error_detect "make install"
        _info "${argon2_filename} install completed..."
    fi
}

install_autoconf(){
    cd ${cur_dir}/software/
    _info "${autoconf_filename} install start..."
    download_file  "${autoconf_filename}.tar.gz" "${autoconf_filename_url}"
    tar zxf ${autoconf_filename}.tar.gz
    cd ${autoconf_filename}

    error_detect "./configure --prefix=/usr"
    error_detect "parallel_make"
    error_detect "make install"
    _info "${autoconf_filename} install completed..."
}

install_sqlite3(){
    if [ ! -e "/usr/local/bin/sqlite3" ]; then
        cd ${cur_dir}/software/
        _info "${sqlite3_filename} install start..."
        download_file  "${sqlite3_filename}.tar.gz" "${sqlite3_filename_url}"
        tar zxf ${sqlite3_filename}.tar.gz
        cd ${sqlite3_filename}

        error_detect "./configure"
        error_detect "parallel_make"
        error_detect "make install"
        _info "${sqlite3_filename} install completed..."
    fi
}

install_icu4c(){
    if [ ! -e "/usr/local/bin/icu-config" ]; then
        cd ${cur_dir}/software/
        _info "${icu4c_filename} install start..."
        download_file  "${icu4c_filename}.tgz" "${icu4c_filename_url}"
        tar zxf ${icu4c_filename}.tgz
        cd ${icu4c_filename}/source/

        error_detect "./configure"
        error_detect "parallel_make"
        error_detect "make install"
        _info "${icu4c_filename} install completed..."
    fi
}

install_libiconv(){
    if [ ! -e "${depends_prefix}/libiconv/bin/iconv" ]; then
        cd ${cur_dir}/software/
        _info "${libiconv_filename} install start..."
        download_file  "${libiconv_filename}.tar.gz" "${libiconv_filename_url}"
        tar zxf ${libiconv_filename}.tar.gz
        patch -d ${libiconv_filename} -p0 < ${cur_dir}/src/libiconv-glibc-2.16.patch
        cd ${libiconv_filename}

        error_detect "./configure --prefix=${depends_prefix}/libiconv"
        error_detect "parallel_make"
        error_detect "make install"
        add_to_env "${depends_prefix}/libiconv"
        create_lib64_dir "${depends_prefix}/libiconv"
        _info "${libiconv_filename} install completed..."
    fi
}

install_re2c(){
    if [ ! -e "/usr/local/bin/re2c" ]; then
        cd ${cur_dir}/software/
        _info "${re2c_filename} install start..."
        download_file "${re2c_filename}.tar.gz" "${re2c_filename_url}"
        tar zxf ${re2c_filename}.tar.gz
        cd ${re2c_filename}

        error_detect "./configure"
        error_detect "make"
        error_detect "make install"
        _info "${re2c_filename} install completed..."
    fi
}

install_mhash(){
    if [ ! -e "/usr/local/lib/libmhash.a" ]; then
        cd ${cur_dir}/software/
        _info "${mhash_filename} install start..."
        download_file "${mhash_filename}.tar.gz" "${mhash_filename_url}"
        tar zxf ${mhash_filename}.tar.gz
        cd ${mhash_filename}

        error_detect "./configure"
        error_detect "parallel_make"
        error_detect "make install"
        _info "${mhash_filename} install completed..."
    fi
}

install_mcrypt(){
    if [ ! -e "/usr/local/bin/mcrypt" ]; then
        cd ${cur_dir}/software/
        _info "${mcrypt_filename} install start..."
        download_file "${mcrypt_filename}.tar.gz" "${mcrypt_filename_url}"
        tar zxf ${mcrypt_filename}.tar.gz
        cd ${mcrypt_filename}

        ldconfig
        error_detect "./configure"
        error_detect "parallel_make"
        error_detect "make install"
        _info "${mcrypt_filename} install completed..."
    fi
}

install_libmcrypt(){
    if [ ! -e "/usr/local/lib/libmcrypt.la" ]; then
        cd ${cur_dir}/software/
        _info "${libmcrypt_filename} install start..."
        download_file "${libmcrypt_filename}.tar.gz" "${libmcrypt_filename_url}"
        tar zxf ${libmcrypt_filename}.tar.gz
        cd ${libmcrypt_filename}

        error_detect "./configure"
        error_detect "parallel_make"
        error_detect "make install"
        _info "${libmcrypt_filename} install completed..."
    fi
}

install_libzip(){
    local cmake_bin="$(command -v cmake)"
    local cmake_ver="$(${cmake_bin} --version | head -1 | grep -oE "[0-9.]+")"
    if version_lt ${cmake_ver} 3.0.2; then
        cd ${cur_dir}/software/
        _info "${cmake_filename} install start..."
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
        _info "${cmake_filename} install completed..."
    fi
    if [ ! -e "/usr/local/bin/zipcmp" ]; then
        cd ${cur_dir}/software/
        _info "${libzip_filename} install start..."
        download_file "${libzip_filename}.tar.gz" "${libzip_filename_url}"
        tar zxf ${libzip_filename}.tar.gz
        cd ${libzip_filename} && mkdir build && cd build

        error_detect "${cmake_bin} .."
        error_detect "parallel_make"
        error_detect "make install"
        is_64bit && cp -pv libzip.pc /usr/lib64/pkgconfig || cp -pv libzip.pc /usr/lib/pkgconfig
        _info "${libzip_filename} install completed..."
    fi
}

install_phpmyadmin(){
    if [ -d "${web_root_dir}/phpmyadmin" ]; then
        rm -rf ${web_root_dir}/phpmyadmin
    fi

    cd ${cur_dir}/software

    _info "${phpmyadmin_filename} install start..."
    download_file "${phpmyadmin_filename}.tar.gz" "${phpmyadmin_filename_url}"
    tar zxf ${phpmyadmin_filename}.tar.gz
    mv ${phpmyadmin_filename} ${web_root_dir}/phpmyadmin
    cp -f ${cur_dir}/conf/config.inc.php ${web_root_dir}/phpmyadmin/config.inc.php
    mkdir -p ${web_root_dir}/phpmyadmin/{upload,save}
    chown -R apache:apache ${web_root_dir}/phpmyadmin
    _info "${phpmyadmin_filename} install completed..."
}

install_adminer(){
    _info "${adminer_filename} install start..."
    cd ${cur_dir}/software
    download_file "${adminer_filename}.php" "${adminer_filename_url}"
    mv ${adminer_filename}.php ${web_root_dir}/adminer.php
    chown apache:apache ${web_root_dir}/adminer.php
    _info "${adminer_filename} install completed..."
}

install_kodexplorer(){
    if [ -d "${web_root_dir}/kod" ]; then
        rm -rf ${web_root_dir}/kod
    fi

    cd ${cur_dir}/software

    _info "${kodexplorer_filename} install start..."
    download_file "${kodexplorer_filename}.tar.gz" "${kodexplorer_filename_url}"
    tar zxf ${kodexplorer_filename}.tar.gz
    mv ${kodexplorer_filename} ${web_root_dir}/kod
    chown -R apache:apache ${web_root_dir}/kod
    _info "${kodexplorer_filename} install completed..."
}

install_ionCube(){
    local phpConfig=${1}
    local php_version=$(get_php_version "${phpConfig}")
    local php_extension_dir=$(get_php_extension_dir "${phpConfig}")

    cd ${cur_dir}/software/
    _info "PHP extension ionCube Loader install start..."
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
        _info "PHP extension ionCube Loader configuration file not found, create it!"
        cat > ${php_location}/php.d/ioncube.ini<<EOF
[ionCube Loader]
zend_extension=ioncube_loader_lin_${php_version}_ts.so
EOF
    fi
    _info "PHP extension ionCube Loader install completed..."
}

install_pdflib(){
    local phpConfig=${1}
    local php_version=$(get_php_version "${phpConfig}" | sed 's/\.//g')
    local php_extension_dir=$(get_php_extension_dir "${phpConfig}")

    cd ${cur_dir}/software/
    _info "PHP extension ${pdflib_filename} install start..."
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
        _info "PHP extension ${pdflib_filename} configuration file not found, create it!"
        cat > ${php_location}/php.d/pdflib.ini<<EOF
[pdflib]
extension=php_pdflib.so
EOF
    fi
    _info "PHP extension ${pdflib_filename} install completed..."
}

install_xcache(){
    local phpConfig=${1}

    _info "PHP extension XCache install start..."
    cd ${cur_dir}/software/
    download_file "${xcache_filename}.tar.gz" "${xcache_filename_url}"
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

    if [ ! -f "${php_location}/php.d/xcache.ini" ]; then
        _info "PHP extension XCache configuration file not found, create it!"
        cat > ${php_location}/php.d/xcache.ini<<EOF
[xcache-common]
extension=xcache.so

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
    _info "PHP extension XCache install completed..."
}

install_php_libsodium(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "PHP extension libsodium install start..."
    download_file "${libsodium_filename}.tar.gz" "${libsodium_filename_url}"
    tar zxf ${libsodium_filename}.tar.gz
    cd ${libsodium_filename}
    error_detect "./configure --prefix=/usr"
    error_detect "make"
    error_detect "make install"

    cd ${cur_dir}/software/
    download_file "${php_libsodium_filename}.tar.gz" "${php_libsodium_filename_url}"
    tar zxf ${php_libsodium_filename}.tgz
    cd ${php_libsodium_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/sodium.ini" ]; then
        _info "PHP extension libsodium configuration file not found, create it!"
        cat > ${php_location}/php.d/sodium.ini<<EOF
[sodium]
extension=sodium.so
EOF
    fi
    _info "PHP extension libsodium install completed..."
}

install_php_imagesmagick(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "PHP extension imagemagick install start..."
    download_file "${ImageMagick_filename}.tar.gz" "${ImageMagick_filename_url}"
    tar zxf ${ImageMagick_filename}.tar.gz
    cd ${ImageMagick_filename}
    error_detect "./configure"
    error_detect "make"
    error_detect "make install"

    cd ${cur_dir}/software/
    download_file "${php_imagemagick_filename}.tgz" "${php_imagemagick_filename_url}"
    tar zxf ${php_imagemagick_filename}.tgz
    cd ${php_imagemagick_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-imagick=/usr/local --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/imagick.ini" ]; then
        _info "PHP extension imagemagick configuration file not found, create it!"
        cat > ${php_location}/php.d/imagick.ini<<EOF
[imagick]
extension=imagick.so
EOF
    fi
    _info "PHP extension imagemagick install completed..."
}

install_php_graphicsmagick(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "PHP extension graphicsmagick install start..."
    download_file "${GraphicsMagick_filename}.tar.gz" "${GraphicsMagick_filename_url}"
    tar zxf ${GraphicsMagick_filename}.tar.gz
    cd ${GraphicsMagick_filename}
    error_detect "./configure --enable-shared"
    error_detect "make"
    error_detect "make install"

    cd ${cur_dir}/software/
    if [ "$php" == "${php5_6_filename}" ]; then
        download_file "${php_graphicsmagick_filename}.tgz" "${php_graphicsmagick_filename_url}"
        tar zxf ${php_graphicsmagick_filename}.tgz
        cd ${php_graphicsmagick_filename}
    else
        download_file "${php_graphicsmagick_filename2}.tgz" "${php_graphicsmagick_filename2_url}"
        tar zxf ${php_graphicsmagick_filename2}.tgz
        cd ${php_graphicsmagick_filename2}
    fi

    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/gmagick.ini" ]; then
        _info "PHP extension graphicsmagick configuration file not found, create it!"
        cat > ${php_location}/php.d/gmagick.ini<<EOF
[gmagick]
extension=gmagick.so
EOF
    fi
    _info "PHP extension graphicsmagick install completed..."
}

install_php_memcached(){
    local phpConfig=${1}

    cd ${cur_dir}/software
    _info "libevent install start..."
    download_file "${libevent_filename}.tar.gz" "${libevent_filename_url}"
    tar zxf ${libevent_filename}.tar.gz
    cd ${libevent_filename}
    error_detect "./configure"
    error_detect "make"
    error_detect "make install"
    ldconfig
    _info "libevent install completed..."

    cd ${cur_dir}/software
    _info "${memcached_filename} install start..."
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
    _info "${memcached_filename} install completed..."

    cd ${cur_dir}/software
    _info "${libmemcached_filename} install start..."
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
    _info "${libmemcached_filename} install completed..."

    cd ${cur_dir}/software
    _info "PHP extension memcached extension install start..."
    if [ "$php" == "${php5_6_filename}" ]; then
        download_file "${php_memcached_filename}.tgz" "${php_memcached_filename_url}"
        tar zxf ${php_memcached_filename}.tgz
        cd ${php_memcached_filename}
    else
        download_file "${php_memcached_filename2}.tgz" "${php_memcached_filename2_url}"
        tar zxf ${php_memcached_filename2}.tgz
        cd ${php_memcached_filename2}
    fi
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/memcached.ini" ]; then
        _info "PHP extension memcached configuration file not found, create it!"
        cat > ${php_location}/php.d/memcached.ini<<EOF
[memcached]
extension=memcached.so
memcached.use_sasl = 1
EOF
    fi
    _info "PHP extension memcached install completed..."
}

install_php_redis(){
    local phpConfig=${1}
    local redis_install_dir=${depends_prefix}/redis
    local tram=$( free -m | awk '/Mem/ {print $2}' )
    local swap=$( free -m | awk '/Swap/ {print $2}' )
    local Mem=$(expr $tram + $swap)
    local RT=0

    cd ${cur_dir}/software/
    _info "redis-server install start..."
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
        _info "redis-server install completed!"
    else
        RT=1
        _error "redis-server install failed."
    fi

    if [ ${RT} -eq 0 ]; then
        cd ${cur_dir}/software/
        _info "PHP extension redis install start..."
        if [ "$php" == "${php5_6_filename}" ]; then
            download_file  "${php_redis_filename}.tgz" "${php_redis_filename_url}"
            tar zxf ${php_redis_filename}.tgz
            cd ${php_redis_filename}
        else
            download_file  "${php_redis_filename2}.tgz" "${php_redis_filename2_url}"
            tar zxf ${php_redis_filename2}.tgz
            cd ${php_redis_filename2}
        fi

        error_detect "${php_location}/bin/phpize"
        error_detect "./configure --enable-redis --with-php-config=${phpConfig}"
        error_detect "make"
        error_detect "make install"

        if [ ! -f "${php_location}/php.d/redis.ini" ]; then
            _info "PHP extension redis configuration file not found, create it!"
            cat > ${php_location}/php.d/redis.ini<<EOF
[redis]
extension=redis.so
EOF
        fi
        _info "PHP extension redis install completed..."
    fi
}

install_php_mongo(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "PHP extension mongodb install start..."
    download_file "${php_mongo_filename}.tgz" "${php_mongo_filename_url}"
    tar zxf ${php_mongo_filename}.tgz
    cd ${php_mongo_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/mongodb.ini" ]; then
        _info "PHP extension mongodb configuration file not found, create it!"
        cat > ${php_location}/php.d/mongodb.ini<<EOF
[mongodb]
extension=mongodb.so
EOF
    fi
    _info "PHP extension mongodb install completed..."
}

install_swoole(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "PHP extension swoole install start..."
    download_file "${swoole_filename}.tar.gz" "${swoole_filename_url}"
    tar zxf ${swoole_filename}.tar.gz
    cd ${swoole_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/swoole.ini" ]; then
        _info "PHP extension swoole configuration file not found, create it!"
        cat > ${php_location}/php.d/swoole.ini<<EOF
[swoole]
extension=swoole.so
EOF
    fi
    _info "PHP extension swoole install completed..."
}

install_xdebug(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "PHP extension xdebug install start..."
    if [ "$php" == "${php5_6_filename}" ]; then
        download_file "${xdebug_filename}.tgz" "${xdebug_filename_url}"
        tar zxf ${xdebug_filename}.tgz
        cd ${xdebug_filename}
    else
        download_file "${xdebug_filename2}.tgz" "${xdebug_filename2_url}"
        tar zxf ${xdebug_filename2}.tgz
        cd ${xdebug_filename2}
    fi
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --enable-xdebug --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/xdebug.ini" ]; then
        _info "PHP extension xdebug configuration file not found, create it!"
        cat > ${php_location}/php.d/xdebug.ini<<EOF
[xdebug]
zend_extension=xdebug.so
EOF
    fi
    _info "PHP extension xdebug install completed..."
}

install_yaf(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "PHP extension yaf install start..."
    download_file "${yaf_filename}.tgz" "${yaf_filename_url}"
    tar zxf ${yaf_filename}.tgz
    cd ${yaf_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/yaf.ini" ]; then
        _info "PHP extension yaf configuration file not found, create it!"
        cat > ${php_location}/php.d/yaf.ini<<EOF
[yaf]
extension=yaf.so
EOF
    fi
    _info "PHP extension yaf install completed..."
}

install_yar(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "PHP extension msgpack install start..."
    download_file "${msgpack_filename}.tgz" "${msgpack_filename_url}"
    tar zxf ${msgpack_filename}.tgz
    cd ${msgpack_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"
    if [ ! -f "${php_location}/php.d/msgpack.ini" ]; then
        _info "PHP extension msgpack configuration file not found, create it!"
        cat > ${php_location}/php.d/msgpack.ini<<EOF
[msgpack]
extension=msgpack.so
EOF
    fi
    _info "PHP extension msgpack install completed..."
    cd ${cur_dir}/software/
    _info "PHP extension yar install start..."
    download_file "${yar_filename}.tgz" "${yar_filename_url}"
    tar zxf ${yar_filename}.tgz
    cd ${yar_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig} --with-curl --enable-yar --enable-msgpack"
    error_detect "make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/yar.ini" ]; then
        _info "PHP extension yar configuration file not found, create it!"
        cat > ${php_location}/php.d/yar.ini<<EOF
[yar]
extension=yar.so
EOF
    fi
    _info "PHP extension yar install completed..."
}

install_phalcon(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "PHP extension psr install start..."
    download_file "${psr_filename}.tgz" "${psr_filename_url}"
    tar zxf ${psr_filename}.tgz
    cd ${psr_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"
    if [ ! -f "${php_location}/php.d/psr.ini" ]; then
        _info "PHP extension psr configuration file not found, create it!"
        cat > ${php_location}/php.d/psr.ini<<EOF
[psr]
extension=psr.so
EOF
    fi
    _info "PHP extension psr install completed..."
    cd ${cur_dir}/software/
    _info "PHP extension phalcon install start..."
    download_file "${phalcon_filename}.tgz" "${phalcon_filename_url}"
    tar zxf ${phalcon_filename}.tgz
    cd ${phalcon_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"
    if [ ! -f "${php_location}/php.d/phalcon.ini" ]; then
        _info "PHP extension phalcon configuration file not found, create it!"
        cat > ${php_location}/php.d/phalcon.ini<<EOF
[phalcon]
extension=phalcon.so
EOF
    fi
    _info "PHP extension phalcon install completed..."
}

install_apcu(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "PHP extension apcu install start..."
    download_file "${apcu_filename}.tgz" "${apcu_filename_url}"
    tar zxf ${apcu_filename}.tgz
    cd ${apcu_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig}"
    error_detect "make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/apcu.ini" ]; then
        _info "PHP extension apcu configuration file not found, create it!"
        cat > ${php_location}/php.d/apcu.ini<<EOF
[apcu]
extension=apcu.so
EOF
    fi
    _info "PHP extension apcu install completed..."
}

install_grpc(){
    local phpConfig=${1}

    cd ${cur_dir}/software/
    _info "PHP extension grpc install start..."
    download_file "${grpc_filename}.tgz" "${grpc_filename_url}"
    tar zxf ${grpc_filename}.tgz
    cd ${grpc_filename}
    error_detect "${php_location}/bin/phpize"
    error_detect "./configure --with-php-config=${phpConfig} --enable-grpc"
    error_detect "make"
    error_detect "make install"

    if [ ! -f "${php_location}/php.d/grpc.ini" ]; then
        _info "PHP extension grpc configuration file not found, create it!"
        cat > ${php_location}/php.d/grpc.ini<<EOF
[grpc]
extension=grpc.so
EOF
    fi
    _info "PHP extension grpc install completed..."
}
