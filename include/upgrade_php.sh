#upgrade php
upgrade_php(){

    if [ ! -d ${php_location} ]; then
        echo "Error:PHP looks like not installed, please check it and try again."
        exit 1
    fi

    local tram=$( free -m | awk '/Mem/ {print $2}' )
    local swap=$( free -m | awk '/Swap/ {print $2}' )
    local ramsum=$( expr $tram + $swap )
    [ ${ramsum} -lt 600 ] && disable_fileinfo="--disable-fileinfo" || disable_fileinfo=""

    local phpConfig=${php_location}/bin/php-config
    local php_version=`get_php_version "${phpConfig}"`
    local php_extension_dir=`get_php_extension_dir "${phpConfig}"`
    local installed_php=`${php_location}/bin/php -r 'echo PHP_VERSION;' 2>/dev/null`

    if   [ "${php_version}" == "5.3" ];then
        latest_php='5.3.29'
    elif [ "${php_version}" == "5.4" ];then
        latest_php='5.4.45'
    elif [ "${php_version}" == "5.5" ];then
        latest_php='5.5.38'
    elif [ "${php_version}" == "5.6" ];then
        latest_php=$(curl -s http://php.net/downloads.php | awk '/Changelog/{print $2}' | grep '5.6')
    elif [ "${php_version}" == "7.0" ];then
        latest_php=$(curl -s http://php.net/downloads.php | awk '/Changelog/{print $2}' | grep '7.0')
    fi

    echo -e "Latest version of PHP: \033[41;37m ${latest_php} \033[0m"
    echo -e "Installed version of PHP: \033[41;37m ${installed_php} \033[0m"
    echo
    echo "Do you want to upgrade PHP ? (y/n)"
    read -p "(Default: n):" upgrade_php
    if [ -z ${upgrade_php} ]; then
        upgrade_php="n"
    fi
    echo "---------------------------"
    echo "You choose = ${upgrade_php}"
    echo "---------------------------"
    echo
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

    if [[ "${upgrade_php}" = "y" || "${upgrade_php}" = "Y" ]];then

        if [ "${php_version}" == "5.3" ] || [ "${php_version}" == "5.4" ] || [ "${php_version}" == "5.5" ];then
            if [ "${installed_php}" == "${latest_php}" ]; then
                echo "${installed_php} is already the latest version and not need to upgrade, nothing to do..."
                exit
            fi
        fi

        echo "PHP upgrade start..."
        if [[ -d ${php_location}.bak && -d ${php_location} ]];then
            rm -rf ${php_location}.bak
        fi
        mv ${php_location} ${php_location}.bak

        if [ ! -d ${cur_dir}/software ];then
            mkdir -p ${cur_dir}/software
        fi
        cd ${cur_dir}/software

        if [ ! -s php-${latest_php}.tar.gz ]; then
            latest_php_link="http://php.net/distributions/php-${latest_php}.tar.gz"
            backup_php_link="${download_root_url}/php-${latest_php}.tar.gz"
            untar ${latest_php_link} ${backup_php_link}
        else
            tar -zxf php-${latest_php}.tar.gz
            cd php-${latest_php}/
        fi

        with_mysql=""
        if [ -d ${mariadb_location} ]; then
            if [ "${php_version}" == "7.0" ];then
                with_mysql="--with-mysqli=${mariadb_location}/bin/mysql_config --with-mysql-sock=/tmp/mysql.sock"
            else
                with_mysql="--with-mysql=${mariadb_location} --with-mysqli=${mariadb_location}/bin/mysql_config --with-mysql-sock=/tmp/mysql.sock"
            fi
        elif [ -d ${mysql_location} ]; then
            if [ "${php_version}" == "7.0" ];then
                with_mysql="--with-mysqli=${mysql_location}/bin/mysql_config --with-mysql-sock=/tmp/mysql.sock"
            else
                with_mysql="--with-mysql=${mysql_location} --with-mysqli=${mysql_location}/bin/mysql_config --with-mysql-sock=/tmp/mysql.sock"
            fi
        elif [ -d ${percona_location} ]; then
            if [ "${php_version}" == "7.0" ];then
                with_mysql="--with-mysqli=${percona_location}/bin/mysql_config --with-mysql-sock=/tmp/mysql.sock"
            else
                with_mysql="--with-mysql=${percona_location} --with-mysqli=${percona_location}/bin/mysql_config --with-mysql-sock=/tmp/mysql.sock"
            fi
        fi

        enable_opcache=""
        if [[ "${php_version}" == "5.5" || "${php_version}" == "5.6" || "${php_version}" == "7.0" ]]; then
            enable_opcache="--enable-opcache"
        fi

        with_gmp="--with-gmp"
        with_icu_dir="--with-icu-dir=/usr"
        if centosversion 5; then
            if [[ "${php_version}" == "5.5" || "${php_version}" == "5.6" || "${php_version}" == "7.0" ]];then
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
        --with-pdo_sqlite \
        --with-sqlite3 \
        --with-openssl \
        --with-snmp \
        --without-pear \
        --with-pdo-mysql \
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
        
        error_detect "./configure ${php_configure_args}"
        error_detect "parallel_make"
        error_detect "make install"

        mkdir -p ${php_location}/etc
        mkdir -p ${php_location}/php.d
        cp -pf ${php_location}.bak/etc/php.ini ${php_location}/etc/php.ini
        cp -pf ${php_location}.bak/lib/php/extensions/no-debug-non-zts-*/* ${php_extension_dir}/
        if [ `ls ${php_location}.bak/php.d/ | wc -l` -ne 0 ]; then
            cp -pf ${php_location}.bak/php.d/* ${php_location}/php.d/
        fi
        echo "Clear up start..."
        cd ${cur_dir}/software
        rm -rf php-${latest_php}/
        rm -f php-${latest_php}.tar.gz
        echo "Clear up completed..."

        /etc/init.d/httpd restart

        echo "PHP upgrade completed..."
    else
        echo
        echo "PHP upgrade cancelled, nothing to do..."
        echo
    fi

}
