#Pre-installation php
php_preinstall_settings(){

    display_menu php 4

    if [ "$php" != "do_not_install" ];then

        with_mysql=""
        if [ "$mysql" == "${mysql5_5_filename}" ] || [ "$mysql" == "${mysql5_6_filename}" ] || [ "$mysql" == "${mysql5_7_filename}" ];then
            if [ "$php" == "${php7_0_filename}" ];then
                with_mysql="--with-mysqli=$mysql_location/bin/mysql_config --with-mysql-sock=/tmp/mysql.sock  --with-pdo-mysql=$mysql_location"
            else
                with_mysql="--with-mysql=$mysql_location --with-mysqli=$mysql_location/bin/mysql_config --with-mysql-sock=/tmp/mysql.sock --with-pdo-mysql=$mysql_location"
            fi
        elif [ "$mysql" == "${mariadb5_5_filename}" ] || [ "$mysql" == "${mariadb10_0_filename}" ] || [ "$mysql" == "${mariadb10_1_filename}" ];then
            if [ "$php" == "${php7_0_filename}" ];then
                with_mysql="--with-mysqli=$mariadb_location/bin/mysql_config --with-mysql-sock=/tmp/mysql.sock  --with-pdo-mysql=$mariadb_location"
            else
                with_mysql="--with-mysql=$mariadb_location --with-mysqli=$mariadb_location/bin/mysql_config --with-mysql-sock=/tmp/mysql.sock --with-pdo-mysql=$mariadb_location"
            fi
        fi

        enable_opcache=""
        if [[ "$php" == "${php5_5_filename}" || "$php" == "${php5_6_filename}" || "$php" == "${php7_0_filename}" ]]; then
            enable_opcache="--enable-opcache"
        fi

        with_gmp="--with-gmp"
        with_icu_dir="--with-icu-dir=/usr"
        if centosversion 5; then
            if [[ "$php" == "${php5_5_filename}" || "$php" == "${php5_6_filename}" || "$php" == "${php7_0_filename}" ]];then
                with_gmp="--with-gmp=/usr/local"
                with_icu_dir="--with-icu-dir=/usr/local"
            fi
        fi

        is_64bit && with_libdir="--with-libdir=lib64" || with_libdir=""

        php_configure_args="--prefix=${php_location} \
        --with-apxs2=${apache_location}/bin/apxs \
        --with-config-file-path=${php_location}/etc \
        --with-config-file-scan-dir=${php_location}/php.d \
        --with-pcre-dir=${depends_prefix}/pcre \
        --with-iconv-dir=${depends_prefix}/libiconv \
        --with-mhash \
        ${with_icu_dir} \
        --with-bz2 \
        --with-curl \
        --with-freetype-dir \
        --with-gd \
        --with-gettext \
        ${with_gmp} \
        --with-imap=${depends_prefix}/imap-2007f \
        --with-imap-ssl \
        --with-jpeg-dir \
        --with-ldap \
        --with-ldap-sasl \
        --with-mcrypt \
        --with-pdo-sqlite \
        --with-sqlite3 \
        --with-openssl \
        --without-pear \
        --with-png-dir \
        --with-readline \
        --with-xmlrpc \
        --with-xsl \
        --with-zlib \
        ${with_mysql} \
        ${with_libdir} \
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
        ${enable_opcache} \
        ${disable_fileinfo}"
    fi
}

#Intall PHP
install_php(){
    #Install PHP depends
    install_php_depends

    cd ${cur_dir}/software/

    if [ "$php" == "${php5_3_filename}" ];then
        download_file  "${php5_3_filename}.tar.gz"
        tar zxf ${php5_3_filename}.tar.gz
        cd ${php5_3_filename}
        cp ${cur_dir}/conf/php-5.3.patch ./
        patch -p1 < php-5.3.patch

        error_detect "./configure ${php_configure_args}"
        error_detect "parallel_make ZEND_EXTRA_LIBS='-liconv'"
        error_detect "make install"

        mkdir -p ${php_location}/etc
        mkdir -p ${php_location}/php.d

    elif [ "$php" == "${php5_4_filename}" ];then
        download_file  "${php5_4_filename}.tar.gz"
        tar zxf ${php5_4_filename}.tar.gz
        cd ${php5_4_filename}

        error_detect "./configure ${php_configure_args}"
        error_detect "parallel_make ZEND_EXTRA_LIBS='-liconv'"
        error_detect "make install"

        mkdir -p ${php_location}/etc
        mkdir -p ${php_location}/php.d

    elif [ "$php" == "${php5_5_filename}" ];then
        download_file  "${php5_5_filename}.tar.gz"
        tar zxf ${php5_5_filename}.tar.gz
        cd ${php5_5_filename}

        error_detect "./configure ${php_configure_args}"
        error_detect "parallel_make ZEND_EXTRA_LIBS='-liconv'"
        error_detect "make install"

        mkdir -p ${php_location}/etc
        mkdir -p ${php_location}/php.d

    elif [ "$php" == "${php5_6_filename}" ];then
        download_file  "${php5_6_filename}.tar.gz"
        tar zxf ${php5_6_filename}.tar.gz
        cd ${php5_6_filename}

        error_detect "./configure ${php_configure_args}"
        error_detect "parallel_make ZEND_EXTRA_LIBS='-liconv'"
        error_detect "make install"

        mkdir -p ${php_location}/etc
        mkdir -p ${php_location}/php.d

    elif [ "$php" == "${php7_0_filename}" ];then
        download_file  "${php7_0_filename}.tar.gz"
        tar zxf ${php7_0_filename}.tar.gz
        cd ${php7_0_filename}

        error_detect "./configure ${php_configure_args}"
        error_detect "parallel_make ZEND_EXTRA_LIBS='-liconv'"
        error_detect "make install"

        mkdir -p ${php_location}/etc
        mkdir -p ${php_location}/php.d
    fi

    cp -f ${cur_dir}/conf/php.ini ${php_location}/etc/php.ini
    config_php
}


config_php(){

    rm -f /etc/php.ini /usr/bin/php /usr/bin/php-config /usr/bin/phpize
    ln -s /usr/local/php/etc/php.ini /etc/php.ini
    ln -s /usr/local/php/bin/php /usr/bin/php
    ln -s /usr/local/php/bin/php-config /usr/bin/php-config
    ln -s /usr/local/php/bin/phpize /usr/bin/phpize
    
    if [[ "$php" == "${php5_5_filename}" || "$php" == "${php5_6_filename}" || "$php" == "${php7_0_filename}" ]]; then
        extension_dir=`php-config --extension-dir`
        cat > ${php_location}/php.d/opcache.ini<<-EOF
[opcache]
zend_extension=${extension_dir}/opcache.so
opcache.enable_cli=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.save_comments=0
EOF

        cp -f ${cur_dir}/conf/ocp.php ${web_root_dir}/ocp.php
        chown apache:apache ${web_root_dir}/ocp.php
    fi

    if [ -d ${mysql_data_location} ];then
        sock_location=/tmp/mysql.sock
        sed -i "s#mysql.default_socket.*#mysql.default_socket = ${sock_location}#" ${php_location}/etc/php.ini
        sed -i "s#mysqli.default_socket.*#mysqli.default_socket = ${sock_location}#" ${php_location}/etc/php.ini
        sed -i "s#pdo_mysql.default_socket.*#pdo_mysql.default_socket = ${sock_location}#" ${php_location}/etc/php.ini
    fi

    if [ -d ${apache_location} ];then
        sed -i "s@AddType\(.*\)Z@AddType\1Z\n    AddType application/x-httpd-php .php .phtml\n    AddType appication/x-httpd-php-source .phps@" ${apache_location}/conf/httpd.conf
    fi

}