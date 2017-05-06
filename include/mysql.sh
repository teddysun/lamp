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

#Pre-installation mysql or mariadb or percona
mysql_preinstall_settings(){

    display_menu mysql 6

    if [ "${mysql}" != "do_not_install" ];then
        if [ "${mysql}" == "${mysql5_5_filename}" ] || [ "${mysql}" == "${mysql5_6_filename}" ] || [ "${mysql}" == "${mysql5_7_filename}" ]; then
            #mysql data
            echo
            read -p "mysql data location(default:${mysql_location}/data, leave blank for default): " mysql_data_location
            mysql_data_location=${mysql_data_location:=${mysql_location}/data}
            mysql_data_location=`filter_location "${mysql_data_location}"`
            echo
            echo "${mysql} data location: ${mysql_data_location}"

            #set mysql root password
            echo
            read -p "mysql server root password (default:root, leave blank for default): " mysql_root_pass
            mysql_root_pass=${mysql_root_pass:=root}
            echo
            echo "${mysql} root password: ${mysql_root_pass}"

        elif [ "${mysql}" == "${mariadb5_5_filename}" ] || [ "${mysql}" == "${mariadb10_0_filename}" ] || [ "${mysql}" == "${mariadb10_1_filename}" ]; then
            #mariadb data
            echo
            read -p "mariadb data location(default:${mariadb_location}/data, leave blank for default): " mariadb_data_location
            mariadb_data_location=${mariadb_data_location:=${mariadb_location}/data}
            mariadb_data_location=`filter_location "${mariadb_data_location}"`
            echo
            echo "mariadb data location: ${mariadb_data_location}"

            #set mariadb root password
            echo
            read -p "mariadb server root password (default:root, leave blank for default): " mariadb_root_pass
            mariadb_root_pass=${mariadb_root_pass:=root}
            echo
            echo "${mysql} root password: $mariadb_root_pass"

        elif [ "${mysql}" == "${percona5_5_filename}" ] || [ "${mysql}" == "${percona5_6_filename}" ] || [ "${mysql}" == "${percona5_7_filename}" ]; then
            #percona data
            echo
            read -p "percona data location(default:${percona_location}/data, leave blank for default): " percona_data_location
            percona_data_location=${percona_data_location:=${percona_location}/data}
            percona_data_location=`filter_location "${percona_data_location}"`
            echo
            echo "percona data location: $percona_data_location"

            #set percona root password
            echo
            read -p "percona server root password (default:root, leave blank for default): " percona_root_pass
            percona_root_pass=${percona_root_pass:=root}
            echo
            echo "${mysql} root password: ${percona_root_pass}"

        fi
    fi
}

#Install Database common
common_install(){

    local apt_list=(libncurses5-dev cmake m4 bison libaio1 libaio-dev numactl)
    local yum_list=(ncurses-devel cmake m4 bison libaio libaio-devel numactl-devel)
    if is_64bit; then
        local perl_data_dumper_url="${download_root_url}/perl-Data-Dumper-2.125-1.el6.rf.x86_64.rpm"
    else
        local perl_data_dumper_url="${download_root_url}/perl-Data-Dumper-2.125-1.el6.rf.i686.rpm"
    fi
    log "Info" "Starting to install dependencies packages for Database..."
    if check_sys packageManager apt; then
        for depend in ${apt_list[@]}; do
            error_detect_depends "apt-get -y install ${depend}"
        done
    elif check_sys packageManager yum; then
        for depend in ${yum_list[@]}; do
            error_detect_depends "yum -y install ${depend}"
        done
        if centosversion 6; then
            rpm -q perl-Data-Dumper > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                log "Info" "Starting to install package perl-Data-Dumper"
                rpm -Uvh ${perl_data_dumper_url} > /dev/null 2>&1
                [ $? -ne 0 ] && log "Error" "Install package perl-Data-Dumper failed" && exit 1
            fi
        elif centosversion 7; then
            error_detect_depends "yum -y install perl-Data-Dumper"
        fi
    fi
    log "Info" "Install dependencies packages for Database completed..."

    id -u mysql >/dev/null 2>&1
    [ $? -ne 0 ] && useradd -M -s /sbin/nologin mysql

    if [[ "${mysql}" == "${mysql5_5_filename}" || "${mysql}" == "${mysql5_6_filename}" || "${mysql}" == "${mysql5_7_filename}" ]]; then
        mkdir -p ${mysql_location} ${mysql_data_location}
    elif [[ "${mysql}" == "${mariadb5_5_filename}" || "${mysql}" == "${mariadb10_0_filename}" || "${mysql}" == "${mariadb10_1_filename}" ]]; then
        mkdir -p ${mariadb_location} ${mariadb_data_location}
    elif [[ "${mysql}" == "${percona5_5_filename}" || "${mysql}" == "${percona5_6_filename}" || "${mysql}" == "${percona5_7_filename}" ]]; then
        mkdir -p ${percona_location} ${percona_data_location}
    fi
}

common_setup(){

    rm -f /usr/bin/mysql /usr/bin/mysqldump
    rm -f /etc/ld.so.conf.d/mysql.conf

    if [ -d ${mysql_location} ]; then

        local db_name="MySQL"
        local db_pass="${mysql_root_pass}"
        ln -s ${mysql_location}/bin/mysql /usr/bin/mysql
        ln -s ${mysql_location}/bin/mysqldump /usr/bin/mysqldump
        cp -f ${mysql_location}/support-files/mysql.server /etc/init.d/mysqld
        sed -i "s:^basedir=.*:basedir=${mysql_location}:g" /etc/init.d/mysqld
        sed -i "s:^datadir=.*:datadir=${mysql_data_location}:g" /etc/init.d/mysqld
        create_lib64_dir "${mysql_location}"
        echo "${mysql_location}/lib" >> /etc/ld.so.conf.d/mysql.conf
        echo "${mysql_location}/lib64" >> /etc/ld.so.conf.d/mysql.conf

    elif [ -d ${mariadb_location} ]; then

        local db_name="MariaDB"
        local db_pass="${mariadb_root_pass}"
        ln -s ${mariadb_location}/bin/mysql /usr/bin/mysql
        ln -s ${mariadb_location}/bin/mysqldump /usr/bin/mysqldump
        cp -f ${mariadb_location}/support-files/mysql.server /etc/init.d/mysqld
        sed -i "s:^basedir=.*:basedir=${mariadb_location}:g" /etc/init.d/mysqld
        sed -i "s:^datadir=.*:datadir=${mariadb_data_location}:g" /etc/init.d/mysqld
        create_lib64_dir "${mariadb_location}"
        echo "${mariadb_location}/lib" >> /etc/ld.so.conf.d/mysql.conf
        echo "${mariadb_location}/lib64" >> /etc/ld.so.conf.d/mysql.conf

    elif [ -d ${percona_location} ]; then

        local db_name="Percona Server"
        local db_pass="${percona_root_pass}"
        ln -s ${percona_location}/bin/mysql /usr/bin/mysql
        ln -s ${percona_location}/bin/mysqldump /usr/bin/mysqldump
        cp -f ${percona_location}/support-files/mysql.server /etc/init.d/mysqld
        sed -i "s:^basedir=.*:basedir=${percona_location}:g" /etc/init.d/mysqld
        sed -i "s:^datadir=.*:datadir=${percona_data_location}:g" /etc/init.d/mysqld
        create_lib64_dir "${percona_location}"
        echo "${percona_location}/lib" >> /etc/ld.so.conf.d/mysql.conf
        echo "${percona_location}/lib64" >> /etc/ld.so.conf.d/mysql.conf

    fi

    ldconfig
    chmod +x /etc/init.d/mysqld
    boot_start mysqld

    log "Info" "Starting ${db_name}..."
    /etc/init.d/mysqld start > /dev/null 2>&1
    /usr/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"${db_pass}\" with grant option;"
    /usr/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"${db_pass}\" with grant option;"
    /usr/bin/mysql -uroot -p${db_pass} <<EOF
drop database if exists test;
delete from mysql.user where not (user='root');
delete from mysql.db where user='';
flush privileges;
exit
EOF
    log "Info" "Shutting down ${db_name}..."
    /etc/init.d/mysqld stop > /dev/null 2>&1

}

#Install mysql server
install_mysqld(){

    common_install

    is_64bit && sys_bit=x86_64 || sys_bit=i686
    mysql_ver=$(echo ${mysql} | sed 's/[^0-9.]//g' | cut -d. -f1-2)
    local url1="http://cdn.mysql.com/Downloads/MySQL-${mysql_ver}/${mysql}-linux-glibc2.5-${sys_bit}.tar.gz"
    local url2="${download_root_url}/${mysql}-linux-glibc2.5-${sys_bit}.tar.gz"

    cd ${cur_dir}/software/

    download_from_url "${mysql}-linux-glibc2.5-${sys_bit}.tar.gz" "${url1}" "${url2}"
    log "Info" "Extracting MySQL files..."
    tar zxf ${mysql}-linux-glibc2.5-${sys_bit}.tar.gz
    log "Info" "Moving MySQL files..."
    mv ${mysql}-linux-glibc2.5-${sys_bit}/* ${mysql_location}

    config_mysql ${mysql_ver}

    add_to_env "${mysql_location}"
}

#Configuration mysql
config_mysql(){
    local version=${1}

    if [ -f /etc/my.cnf ];then
        mv /etc/my.cnf /etc/my.cnf.bak
    fi
    [ -d '/etc/mysql' ] && mv /etc/mysql{,_bk}

    chown -R mysql:mysql ${mysql_location} ${mysql_data_location}

    #create my.cnf
    create_mysql_my_cnf "${mysql_data_location}" "false" "false" "/etc/my.cnf"

    if [ "${version}" == "5.5" ] || [ "${version}" == "5.6" ]; then
        ${mysql_location}/scripts/mysql_install_db --basedir=${mysql_location} --datadir=${mysql_data_location} --user=mysql
    elif [ "${version}" == "5.7" ]; then
        ${mysql_location}/bin/mysqld --initialize-insecure --basedir=${mysql_location} --datadir=${mysql_data_location} --user=mysql
    fi

    common_setup

}

#Install mariadb server
install_mariadb(){

    common_install

    if [ "$(get_ip_country)" == "CN" ]; then
        local down_addr1=http://mirrors.aliyun.com/mariadb/
        local down_addr2=http://sfo1.mirrors.digitalocean.com/mariadb/
    else
        local down_addr1=http://sfo1.mirrors.digitalocean.com/mariadb/
        local down_addr2=http://mirrors.aliyun.com/mariadb/
    fi

    local libc_version=`getconf -a | grep GNU_LIBC_VERSION | awk '{print $NF}'`

    if version_lt ${libc_version} 2.14; then
        glibc_flag=linux
    else
        glibc_flag=linux-glibc_214
    fi

    is_64bit && sys_bit_a=x86_64 || sys_bit_a=x86
    is_64bit && sys_bit_b=x86_64 || sys_bit_b=i686

    cd ${cur_dir}/software/

    download_from_url "${mysql}-${glibc_flag}-${sys_bit_b}.tar.gz" \
    "${down_addr1}/${mysql}/bintar-${glibc_flag}-${sys_bit_a}/${mysql}-${glibc_flag}-${sys_bit_b}.tar.gz" \
    "${down_addr2}/${mysql}/bintar-${glibc_flag}-${sys_bit_a}/${mysql}-${glibc_flag}-${sys_bit_b}.tar.gz"

    log "Info" "Extracting MariaDB files..."
    tar zxf ${mysql}-${glibc_flag}-${sys_bit_b}.tar.gz
    log "Info" "Moving MariaDB files..."
    mv ${mysql}-*-${sys_bit_b}/* ${mariadb_location}

    config_mariadb

    add_to_env "${mariadb_location}"
}

#Configuration mariadb
config_mariadb(){

    if [ -f /etc/my.cnf ];then
        mv /etc/my.cnf /etc/my.cnf.bak
    fi
    [ -d '/etc/mysql' ] && mv /etc/mysql{,_bk}

    chown -R mysql:mysql ${mariadb_location} ${mariadb_data_location}

    #create my.cnf
    create_mysql_my_cnf "${mariadb_data_location}" "false" "false" "/etc/my.cnf"

    ${mariadb_location}/scripts/mysql_install_db --basedir=${mariadb_location} --datadir=${mariadb_data_location} --user=mysql

    common_setup

}

#Install percona server
install_percona(){

    common_install

    is_64bit && sys_bit=x86_64 || sys_bit=i686
    if check_sys packageManager apt; then
        local ssl_ver="ssl100"
    elif check_sys packageManager yum; then
        local ssl_ver="ssl101"
    fi
    local percona_ver=$(echo ${mysql} | sed 's/[^0-9.]//g' | cut -d. -f1-2)
    local major_ver=$(echo ${mysql} | cut -d'-' -f1-3)
    local rel_ver=$(echo ${mysql} | awk -F'-' '{print $4}')
    local down_addr="https://www.percona.com/downloads/Percona-Server-${percona_ver}/${mysql}/binary/tarball"

    if [[ "${percona_ver}" == "5.5" || "${percona_ver}" == "5.6" ]]; then
        tarball="${major_ver}-rel${rel_ver}-Linux.${sys_bit}.${ssl_ver}"
    fi
    if [[ "${percona_ver}" == "5.7" ]]; then
        tarball="${mysql}-Linux.${sys_bit}.${ssl_ver}"
    fi

    local url1="${down_addr}/${tarball}.tar.gz"
    local url2="${download_root_url}/${tarball}.tar.gz"

    cd ${cur_dir}/software/

    download_from_url "${tarball}.tar.gz" "${url1}" "${url2}"
    log "Info" "Extracting Percona Server files..."
    tar zxf ${tarball}.tar.gz
    log "Info" "Moving Percona Server files..."
    mv ${tarball}/* ${percona_location}

    config_percona ${percona_ver}

    add_to_env "${percona_location}"
}

#Configuration percona
config_percona(){
    local version=${1}

    if [ -f /etc/my.cnf ];then
        mv /etc/my.cnf /etc/my.cnf.bak
    fi
    [ -d '/etc/mysql' ] && mv /etc/mysql{,_bk}

    chown -R mysql:mysql ${percona_location} ${percona_data_location}

    #create my.cnf
    create_mysql_my_cnf "${percona_data_location}" "false" "false" "/etc/my.cnf"

    sed -ir "s@/usr/local/${tarball}@${percona_location}@g" ${percona_location}/bin/mysqld_safe
    sed -ir "s@/usr/local/${tarball}@${percona_location}@g" ${percona_location}/bin/mysql_config

    if [ ${version} == "5.5" ] || [ ${version} == "5.6" ]; then
        ${percona_location}/scripts/mysql_install_db --basedir=${percona_location} --datadir=${percona_data_location} --user=mysql
    elif [ ${version} == "5.7" ]; then
        ${percona_location}/bin/mysqld --initialize-insecure --basedir=${percona_location} --datadir=${percona_data_location} --user=mysql
    fi

    common_setup

    #Fix libmysqlclient issue
    cd ${percona_location}/lib/
    ln -s libperconaserverclient.a libmysqlclient.a
    ln -s libperconaserverclient.so libmysqlclient.so
    if [ "$mysql" != "${percona5_7_filename}" ]; then
        ln -s libperconaserverclient_r.a libmysqlclient_r.a
        ln -s libperconaserverclient_r.so libmysqlclient_r.so
    fi
}
