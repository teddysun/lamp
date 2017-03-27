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

#upgrade apache
upgrade_apache(){

    if [ ! -d ${apache_location} ]; then
        echo "Error:Apache looks like not installed, please check it and try again."
        exit 1
    fi

    local installed_apache=`${apache_location}/bin/httpd -v | grep 'version' | awk -F/ '{print $2}' | cut -d' ' -f1`
    local apache_version=`echo ${installed_apache} | cut -d. -f1-2`
    local latest_apache22=`curl -s http://httpd.apache.org/download.cgi | awk '/#apache22/{print $2}' | head -n 1 | awk -F'>' '{print $2}' | cut -d'<' -f1`
    local latest_apache24=`curl -s http://httpd.apache.org/download.cgi | awk '/#apache24/{print $2}' | head -n 1 | awk -F'>' '{print $2}' | cut -d'<' -f1`

    if [ "${apache_version}" == "2.2" ];then
        echo -e "Latest version of Apache: \033[41;37m $latest_apache22 \033[0m"
        echo -e "Installed version of Apache: \033[41;37m $installed_apache \033[0m"
    elif [ "${apache_version}" == "2.4" ];then
        echo -e "Latest version of Apache: \033[41;37m $latest_apache24 \033[0m"
        echo -e "Installed version of Apache: \033[41;37m $installed_apache \033[0m"
    fi
    echo
    echo "Do you want to upgrade Apache ? (y/n)"
    read -p "(Default: n):" upgrade_apache
    if [ -z ${upgrade_apache} ]; then
        upgrade_apache="n"
    fi
    echo "----------------------------"
    echo "You choose = $upgrade_apache"
    echo "----------------------------"
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

    if [[ "${upgrade_apache}" = "y" || "${upgrade_apache}" = "Y" ]];then
        echo "Apache upgrade start..."
        apache_count=`ps -ef | grep -v grep | grep -c "httpd"`
        if [ ${apache_count} -ne 0 ]; then
            /etc/init.d/httpd stop
        fi

        if [[ -d ${apache_location}.bak && -d ${apache_location} ]];then
            rm -rf ${apache_location}.bak
        fi
        mv ${apache_location} ${apache_location}.bak

        if [ ! -d ${cur_dir}/software ];then
            mkdir -p ${cur_dir}/software
        fi
        cd ${cur_dir}/software

        if [ "${apache_version}" == "2.2" ];then
            apache_configure_args="--prefix=${apache_location} \
                --with-included-apr \
                --with-mpm=prefork \
                --with-ssl \
                --enable-so \
                --enable-suexec \
                --enable-deflate=shared \
                --enable-expires=shared \
                --enable-ssl=shared \
                --enable-headers=shared \
                --enable-rewrite=shared \
                --enable-static-support \
                --enable-modules=all \
                --enable-mods-shared=all"

            if [ ! -s httpd-${latest_apache22}.tar.gz ]; then
                latest_apache_link="http://www.us.apache.org/dist//httpd/httpd-${latest_apache22}.tar.gz"
                backup_apache_link="${download_root_url}/httpd-${latest_apache22}.tar.gz"
                untar ${latest_apache_link} ${backup_apache_link}
            else
                echo "httpd-${latest_apache22}.tar.gz [found]"
                tar -zxf httpd-${latest_apache22}.tar.gz
                cd httpd-${latest_apache22}/
            fi

            if grep -q -i "Ubuntu 12.04" /etc/issue;then
                sed -i '/SSL_PROTOCOL_SSLV2/d' modules/ssl/ssl_engine_io.c
            fi
            export LDFLAGS=-ldl
            
            error_detect "./configure ${apache_configure_args}"
            error_detect "parallel_make"
            error_detect "make install"
            unset LDFLAGS

        elif [ "${apache_version}" == "2.4" ];then
            apache_configure_args="--prefix=${apache_location} \
                --with-pcre=${depends_prefix}/pcre \
                --with-mpm=prefork \
                --with-included-apr \
                --with-ssl \
                --enable-so \
                --enable-dav \
                --enable-suexec \
                --enable-deflate=shared \
                --enable-ssl=shared \
                --enable-expires=shared  \
                --enable-headers=shared \
                --enable-rewrite=shared \
                --enable-static-support \
                --enable-modules=all \
                --enable-mods-shared=all"

            download_file "${apr_filename}.tar.gz"
            tar zxf ${apr_filename}.tar.gz
            download_file "${apr_util_filename}.tar.gz"
            tar zxf ${apr_util_filename}.tar.gz

            if [ ! -s httpd-${latest_apache24}.tar.gz ]; then
                latest_apache_link="http://www.us.apache.org/dist//httpd/httpd-${latest_apache24}.tar.gz"
                backup_apache_link="${download_root_url}/httpd-${latest_apache24}.tar.gz"
                untar ${latest_apache_link} ${backup_apache_link}
            else
                echo "httpd-${latest_apache24}.tar.gz [found]"
                tar -zxf httpd-${latest_apache24}.tar.gz
                cd httpd-${latest_apache24}/
            fi

            mv ${cur_dir}/software/${apr_filename} srclib/apr
            mv ${cur_dir}/software/${apr_util_filename} srclib/apr-util

            error_detect "./configure $apache_configure_args"
            error_detect "parallel_make"
            error_detect "make install"

        fi

        cp -rpf ${apache_location}.bak/logs/* ${apache_location}/logs/
        cp -rpf ${apache_location}.bak/conf/* ${apache_location}/conf/
        cp -rpf ${apache_location}.bak/modules/libphp* ${apache_location}/modules/

        echo "Clear up start..."
        cd ${cur_dir}/software
        rm -rf httpd-${latest_apache22}/ httpd-${latest_apache24}/
        rm -f httpd-${latest_apache22}.tar.gz httpd-${latest_apache24}.tar.gz ${apr_filename}.tar.gz ${apr_util_filename}.tar.gz
        echo "Clear up completed..."

        /etc/init.d/httpd start
        if [ $? -eq 0 ]; then
            echo "Apache start success!"
        else
            echo "Apache start failure!"
        fi

        echo "Apache upgrade completed..."
    else
        echo
        echo "Apache upgrade cancelled, nothing to do..."
        echo
    fi

}
