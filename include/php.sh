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

#Pre-installation php
php_preinstall_settings(){
    if [ "${apache}" == "do_not_install" ]; then
        php="do_not_install"
    else
        display_menu php 1
    fi
}

#Intall PHP
install_php(){

    is_64bit && with_libdir="--with-libdir=lib64" || with_libdir=""
    php_configure_args="
    --prefix=${php_location} \
    --with-apxs2=${apache_location}/bin/apxs \
    --with-config-file-path=${php_location}/etc \
    --with-config-file-scan-dir=${php_location}/php.d \
    --with-pcre-jit \
    --with-imap \
    --with-kerberos \
    --with-imap-ssl \
    --with-openssl \
    --with-snmp \
    ${with_libdir} \
    --enable-mysqlnd \
    --with-mysqli=mysqlnd \
    --with-mysql-sock=/tmp/mysql.sock \
    --with-pdo-mysql=mysqlnd \
    --enable-gd \
    --with-webp \
    --with-jpeg \
    --with-xpm \
    --with-freetype \
    --with-zlib \
    --with-bz2 \
    --with-curl=/usr \
    --with-gettext \
    --with-gmp \
    --with-mhash \
    --with-ldap \
    --with-ldap-sasl \
    --with-pspell=/usr \
    --with-enchant=/usr \
    --with-readline \
    --with-tidy=/usr \
    --with-xsl \
    --with-password-argon2 \
    --enable-zend-test \
    --enable-bcmath \
    --enable-calendar \
    --enable-dba \
    --enable-exif \
    --enable-ftp \
    --enable-gd-jis-conv \
    --enable-intl \
    --enable-mbstring \
    --enable-pcntl \
    --enable-shmop \
    --enable-soap \
    --enable-sockets \
    --with-zip \
    ${disable_fileinfo}"

    #Install PHP depends
    install_php_depends

    cd ${cur_dir}/software/
    if [ "${php}" == "${php7_4_filename}" ]; then
        download_file  "${php7_4_filename}.tar.gz" "${php7_4_filename_url}"
        tar zxf ${php7_4_filename}.tar.gz
        cd ${php7_4_filename}
        # Fixed a libenchant-2 error in PHP 7.4 for Debian or Ubuntu
        if dpkg -l 2>/dev/null | grep -q "libenchant-2-dev"; then
            patch -p1 < ${cur_dir}/src/remove-deprecated-call-and-deprecate-function.patch
            patch -p1 < ${cur_dir}/src/use-libenchant-2-when-available.patch
            ./buildconf -f
        fi
    elif [ "${php}" == "${php8_0_filename}" ]; then
        download_file  "${php8_0_filename}.tar.gz" "${php8_0_filename_url}"
        tar zxf ${php8_0_filename}.tar.gz
        cd ${php8_0_filename}
    elif [ "${php}" == "${php8_1_filename}" ]; then
        download_file  "${php8_1_filename}.tar.gz" "${php8_1_filename_url}"
        tar zxf ${php8_1_filename}.tar.gz
        cd ${php8_1_filename}
    fi

    ldconfig
    error_detect "./configure ${php_configure_args}"
    error_detect "parallel_make"
    error_detect "make install"

    mkdir -p ${php_location}/{etc,php.d}
    cp -f ${cur_dir}/conf/php.ini ${php_location}/etc/php.ini
    config_php
}

config_php(){
    rm -f /etc/php.ini /usr/bin/php /usr/bin/php-config /usr/bin/phpize
    ln -s ${php_location}/etc/php.ini /etc/php.ini
    ln -s ${php_location}/bin/php /usr/bin/
    ln -s ${php_location}/bin/php-config /usr/bin/
    ln -s ${php_location}/bin/phpize /usr/bin/
    cat > ${php_location}/php.d/opcache.ini<<EOF
[opcache]
zend_extension=opcache.so
opcache.enable_cli=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.save_comments=0
EOF

    cp -f ${cur_dir}/conf/ocp.php ${web_root_dir}
    cp -f ${cur_dir}/conf/jquery.js ${web_root_dir}
    cp -f ${cur_dir}/conf/phpinfo.php ${web_root_dir}
    wget -O ${web_root_dir}/p.php ${x_prober_url} > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        _warn "Download X-Prober failed, please manually download from ${x_prober_url} if necessary."
    fi
    chown -R apache.apache ${web_root_dir}

    if [[ -d "${mysql_data_location}" || -d "${mariadb_data_location}" ]]; then
        sock_location="/tmp/mysql.sock"
        sed -i "s#mysql.default_socket.*#mysql.default_socket = ${sock_location}#" ${php_location}/etc/php.ini
        sed -i "s#mysqli.default_socket.*#mysqli.default_socket = ${sock_location}#" ${php_location}/etc/php.ini
        sed -i "s#pdo_mysql.default_socket.*#pdo_mysql.default_socket = ${sock_location}#" ${php_location}/etc/php.ini
    fi
    if [[ -d "${apache_location}" ]]; then
        sed -i "s@AddType\(.*\)Z@AddType\1Z\n    AddType application/x-httpd-php .php .phtml\n    AddType appication/x-httpd-php-source .phps@" ${apache_location}/conf/httpd.conf
    fi

}
