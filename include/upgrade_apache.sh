# Copyright (C) 2013 - 2019 Teddysun <i@teddysun.com>
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

#upgrade apache
upgrade_apache(){

    if [ ! -d "${apache_location}" ]; then
        _error "Apache looks like not installed, please check it and try again."
    fi

    local installed_apache="$(${apache_location}/bin/httpd -v | grep 'version' | awk -F/ '{print $2}' | cut -d' ' -f1)"
    local latest_apache24="$(curl -s http://httpd.apache.org/download.cgi | awk '/#apache24/{print $2}' | head -n 1 | awk -F'>' '{print $2}' | cut -d'<' -f1)"

    _info "Latest version of Apache   : $(_red ${latest_apache24})"
    _info "Installed version of Apache: $(_red ${installed_apache})"
    read -p "Do you want to upgrade Apache? (y/n) (Default: n):" upgrade_apache
    [ -z "${upgrade_apache}" ] && upgrade_apache="n"
    if [[ "${upgrade_apache}" = "y" || "${upgrade_apache}" = "Y" ]]; then
        _info "Apache upgrade start..."
        if [ $(ps -ef | grep -v grep | grep -c "httpd") -gt 0 ]; then
            /etc/init.d/httpd stop > /dev/null 2>&1
        fi

        if [[ -d "${apache_location}".bak && -d "${apache_location}" ]]; then
            rm -rf ${apache_location}.bak
        fi
        mv ${apache_location} ${apache_location}.bak

        if [ ! -d ${cur_dir}/software ];then
            mkdir -p ${cur_dir}/software
        fi
        cd ${cur_dir}/software

        apache_configure_args="--prefix=${apache_location} \
            --with-pcre=${depends_prefix}/pcre \
            --with-mpm=event \
            --with-included-apr \
            --with-ssl \
            --with-nghttp2 \
            --enable-modules=reallyall \
            --enable-mods-shared=reallyall"

        download_file "${apr_filename}.tar.gz" "${apr_filename_url}"
        tar zxf ${apr_filename}.tar.gz
        download_file "${apr_util_filename}.tar.gz" "${apr_util_filename_url}"
        tar zxf ${apr_util_filename}.tar.gz

        if [ ! -s httpd-${latest_apache24}.tar.gz ]; then
            latest_apache_link="https://www-us.apache.org/dist//httpd/httpd-${latest_apache24}.tar.gz"
            backup_apache_link="${download_root_url}/httpd-${latest_apache24}.tar.gz"
            untar ${latest_apache_link} ${backup_apache_link}
        else
            _info "httpd-${latest_apache24}.tar.gz [found]"
            tar zxf httpd-${latest_apache24}.tar.gz
            cd httpd-${latest_apache24}
        fi

        mv ${cur_dir}/software/${apr_filename} srclib/apr
        mv ${cur_dir}/software/${apr_util_filename} srclib/apr-util

        LDFLAGS=-ldl
        if [ -d "${openssl_location}" ]; then
            apache_configure_args="$(echo ${apache_configure_args} | sed -e "s@--with-ssl@--with-ssl=${openssl_location}@")"
        fi
        error_detect "./configure ${apache_configure_args}"
        error_detect "parallel_make"
        error_detect "make install"
        unset LDFLAGS

        cp -rpf ${apache_location}.bak/logs/* ${apache_location}/logs/
        cp -rpf ${apache_location}.bak/conf/* ${apache_location}/conf/
        cp -rpf ${apache_location}.bak/modules/libphp* ${apache_location}/modules/
        cp -pf ${apache_location}.bak/bin/envvars ${apache_location}/bin/envvars
        if [ -f ${apache_location}.bak/modules/mod_wsgi.so ]; then
            cp -pf ${apache_location}.bak/modules/mod_wsgi.so ${apache_location}/modules/
        fi
        if [ -f ${apache_location}.bak/modules/mod_jk.so ]; then
            cp -pf ${apache_location}.bak/modules/mod_jk.so ${apache_location}/modules/
        fi
        if [ -f ${apache_location}.bak/modules/mod_security2.so ]; then
            cp -pf ${apache_location}.bak/modules/mod_security2.so ${apache_location}/modules/
        fi

        _info "Clear up start..."
        cd ${cur_dir}/software
        rm -rf httpd-${latest_apache24}
        rm -f httpd-${latest_apache24}.tar.gz ${apr_filename}.tar.gz ${apr_util_filename}.tar.gz
        _info "Clear up completed..."

        /etc/init.d/httpd start
        if [ $? -eq 0 ]; then
            _info "Apache start success"
        else
            _warn "Apache start failure"
        fi
        _info "Apache upgrade completed..."
    else
        _info "Apache upgrade cancelled, nothing to do..."
    fi

}
