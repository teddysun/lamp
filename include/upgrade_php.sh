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

#upgrade php
upgrade_php(){

    if [ ! -d "${php_location}" ]; then
        _error "PHP looks like not installed, please check it and try again."
    fi

    local tram=$( free -m | awk '/Mem/ {print $2}' )
    local swap=$( free -m | awk '/Swap/ {print $2}' )
    local ramsum=$( expr $tram + $swap )
    [ ${ramsum} -lt 1025 ] && disable_fileinfo="--disable-fileinfo" || disable_fileinfo=""

    local phpConfig=${php_location}/bin/php-config
    local php_version=$(get_php_version "${phpConfig}")
    local php_extension_dir=$(get_php_extension_dir "${phpConfig}")
    local installed_php=$(${php_location}/bin/php -r 'echo PHP_VERSION;' 2>/dev/null)
    local configure_options=$(${phpConfig} --configure-options)

    case "${php_version}" in
        5.6)
            latest_php="5.6.40"
            ;;
        7.0)
            latest_php="7.0.33"
            ;;
        7.1)
            latest_php="7.1.33"
            ;;
        7.2)
            latest_php="7.2.34"
            ;;
        7.3)
            latest_php="7.3.33"
            ;;
        7.4)
            latest_php="$(curl -4s https://www.php.net/downloads.php | awk '/Changelog/{print $2}' | grep '7.4')"
            ;;
        8.0)
            latest_php="$(curl -4s https://www.php.net/downloads.php | awk '/Changelog/{print $2}' | grep '8.0')"
            ;;
        8.1)
            latest_php="$(curl -4s https://www.php.net/downloads.php | awk '/Changelog/{print $2}' | grep '8.1')"
            ;;
        *)
        # do nothing
    esac

    _info "Latest version of PHP   : $(_red ${latest_php})"
    _info "Installed version of PHP: $(_red ${installed_php})"
    read -p "Do you want to upgrade PHP? (y/n) (Default: n):" upgrade_php
    [ -z "${upgrade_php}" ] && upgrade_php="n"
    if [[ "${upgrade_php}" = "y" || "${upgrade_php}" = "Y" ]]; then
        _info "PHP upgrade start..."
        if [[ -d "${php_location}.bak" && -d "${php_location}" ]]; then
            rm -rf ${php_location}.bak
        fi
        mv ${php_location} ${php_location}.bak

        if [ ! -d ${cur_dir}/software ]; then
            mkdir -p ${cur_dir}/software
        fi

        [ ! -e "${depends_prefix}/libiconv/bin/iconv" ] && install_libiconv
        if ! grep -qE "^${depends_prefix}/libiconv/lib" /etc/ld.so.conf.d/*.conf; then
            echo "${depends_prefix}/libiconv/lib" > /etc/ld.so.conf.d/libiconvlib.conf
        fi

        cd ${cur_dir}/software
        if [ -s "php-${latest_php}.tar.gz" ]; then
            rm -fr php-${latest_php}/
            tar zxf php-${latest_php}.tar.gz
            cd php-${latest_php}/
        else
            latest_php_link="https://www.php.net/distributions/php-${latest_php}.tar.gz"
            backup_php_link="${download_root_url}/php-${latest_php}.tar.gz"
            untar ${latest_php_link} ${backup_php_link}
        fi

        # Fixed a libenchant-2 error in PHP 7.4 for Debian or Ubuntu
        if [ "${php_version}" == "7.4" ] && apt-cache show libenchant-2-dev 2> /dev/null | grep -q "libenchant-2-dev"; then
            patch -p1 < ${cur_dir}/src/remove-deprecated-call-and-deprecate-function.patch
            patch -p1 < ${cur_dir}/src/use-libenchant-2-when-available.patch
            ./buildconf -f
        fi
        ldconfig
        error_detect "./configure ${configure_options}"
        error_detect "parallel_make"
        error_detect "make install"

        mkdir -p ${php_location}/{etc,php.d}
        cp -pf ${php_location}.bak/etc/php.ini ${php_location}/etc/php.ini
        cp -pn ${php_location}.bak/lib/php/extensions/no-debug-zts-*/* ${php_extension_dir}/
        if [ $(ls ${php_location}.bak/php.d/ | wc -l) -gt 0 ]; then
            cp -pf ${php_location}.bak/php.d/* ${php_location}/php.d/
        fi
        _info "Restart Apache..."
        /etc/init.d/httpd stop > /dev/null 2>&1
        sleep 3
        /etc/init.d/httpd start > /dev/null 2>&1
        _info "Clear up start..."
        cd ${cur_dir}/software
        rm -rf php-${latest_php}/
        rm -f php-${latest_php}.tar.gz
        _info "Clear up completed..."
        echo
        _info "PHP upgrade completed..."
    else
        _info "PHP upgrade cancelled, nothing to do..."
    fi

}
