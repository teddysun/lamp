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

#upgrade database
upgrade_db(){

    if [ ! -d "${mysql_location}" ] && [ ! -d "${mariadb_location}" ]; then
        _error "MySQL or MariaDB looks like not installed, please check it and try again"
    fi

    update_date=$(date +"%Y%m%d")
    bkup_file="mysqld_${update_date}.bak"

    if [ -d "${mysql_location}" ]; then
        db_name="MySQL"
        bkup_dir="${cur_dir}/mysql_bkup"
        mysql_dump="${bkup_dir}/mysql_all_backup_${update_date}.dump"
        installed_mysql="$(${mysql_location}/bin/mysql -V | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
        mysql_ver="$(echo ${installed_mysql} | cut -d. -f1-2)"
        if   [ "${mysql_ver}" == "5.5" ]; then
            latest_mysql="$(curl -4s https://dev.mysql.com/downloads/mysql/5.5.html | awk '/MySQL Community Server/{print $4}' | grep '5.5')"
        elif [ "${mysql_ver}" == "5.6" ]; then
            latest_mysql="$(curl -4s https://dev.mysql.com/downloads/mysql/5.6.html | awk '/MySQL Community Server/{print $4}' | grep '5.6')"
        elif [ "${mysql_ver}" == "5.7" ]; then
            latest_mysql="$(curl -4s https://dev.mysql.com/downloads/mysql/5.7.html | awk '/MySQL Community Server/{print $4}' | grep '5.7')"
        elif [ "${mysql_ver}" == "8.0" ]; then
            latest_mysql="$(curl -4s https://dev.mysql.com/downloads/mysql/8.0.html | awk '/MySQL Community Server/{print $4}' | grep '8.0')"
        fi

        _info "Latest version of MySQL   : $(_red ${latest_mysql})"
        _info "Installed version of MySQL: $(_red ${installed_mysql})"

    elif [ -d "${mariadb_location}" ]; then
        db_name="MariaDB"
        bkup_dir="${cur_dir}/mariadb_bkup"
        mysql_dump="${bkup_dir}/mariadb_all_backup_${update_date}.dump"
        installed_mariadb="$(${mariadb_location}/bin/mysql -V | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
        mariadb_ver="$(echo ${installed_mariadb} | cut -d. -f1-2)"
        if   [ "${mariadb_ver}" == "5.5" ]; then
            latest_mariadb="5.5.68"
        elif [ "${mariadb_ver}" == "10.0" ]; then
            latest_mariadb="10.0.38"
        elif [ "${mariadb_ver}" == "10.1" ]; then
            latest_mariadb="$(curl -4s https://downloads.mariadb.org/ | awk -F/ '/\/mariadb\/10.1/{print $3}')"
        elif [ "${mariadb_ver}" == "10.2" ]; then
            latest_mariadb="$(curl -4s https://downloads.mariadb.org/ | awk -F/ '/\/mariadb\/10.2/{print $3}')"
        elif [ "${mariadb_ver}" == "10.3" ]; then
            latest_mariadb="$(curl -4s https://downloads.mariadb.org/ | awk -F/ '/\/mariadb\/10.3/{print $3}')"
        elif [ "${mariadb_ver}" == "10.4" ]; then
            latest_mariadb="$(curl -4s https://downloads.mariadb.org/ | awk -F/ '/\/mariadb\/10.4/{print $3}')"
        elif [ "${mariadb_ver}" == "10.5" ]; then
            latest_mariadb="$(curl -4s https://downloads.mariadb.org/ | awk -F/ '/\/mariadb\/10.5/{print $3}')"
        fi

        _info "Latest version of MariaDB   : $(_red ${latest_mariadb})"
        _info "Installed version of MariaDB: $(_red ${installed_mariadb})"
    fi
    read -p "Do you want to upgrade ${db_name}? (y/n) (Default: n):" upgrade_db
    [ -z "${upgrade_db}" ] && upgrade_db="n"
    if [[ "${upgrade_db}" = "y" || "${upgrade_db}" = "Y" ]]; then
        _info "${db_name} upgrade start..."
        if [ $(ps -ef | grep -v grep | grep -c "mysqld") -eq 0 ]; then
            _info "${db_name} looks like not running, Try to starting ${db_name}..."
            /etc/init.d/mysqld start > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                _error "Starting ${db_name} failed"
            fi
        fi

        if [ ! -d "${bkup_dir}" ]; then
            mkdir -p ${bkup_dir}
        fi

        read -p "Please input your ${db_name} root password:" mysql_root_password
        /usr/bin/mysql -uroot -p${mysql_root_password} <<EOF
exit
EOF
        if [ $? -ne 0 ]; then
            _error "${db_name}  root password incorrect, Please check it and try again"
        fi

        _info "Starting backup all of databases, Please wait a moment..."
        /usr/bin/mysqldump -uroot -p${mysql_root_password} --all-databases > ${mysql_dump}
        if [ $? -eq 0 ]; then
            _info "${db_name} all of databases backup success"
        else
            _error "${db_name} all of databases backup failed, Please check it and try again"
        fi
        _info "Stopping ${db_name}..."
        /etc/init.d/mysqld stop > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            _info "${db_name} stop success"
        else
            _error "${db_name} stop failed, Please check it and try again"
        fi
        cp -pf /etc/init.d/mysqld ${bkup_dir}/${bkup_file}

        datalocation=$(cat ${bkup_dir}/${bkup_file} | grep -w 'datadir=' | awk -F= '{print $2}' | head -1)

        if [ ! -d ${cur_dir}/software ]; then
            mkdir -p ${cur_dir}/software
        fi
        cd ${cur_dir}/software

        if [ -d "${mysql_location}" ]; then
            if [ -d "${mysql_location}.bak" ]; then
                rm -rf ${mysql_location}.bak
            fi
            mv ${mysql_location} ${mysql_location}.bak
            mkdir -p ${mysql_location}
            [ ! -d ${datalocation} ] && mkdir -p ${datalocation}

            is_64bit && sys_bit=x86_64 || sys_bit=i686
            _info "Downloading and Extracting MySQL files..."

            mysql_filename="mysql-${latest_mysql}-linux-glibc2.12-${sys_bit}"
            if [ "${mysql_ver}" == "8.0" ]; then
                mysql_filename_url="https://cdn.mysql.com/Downloads/MySQL-${mysql_ver}/${mysql_filename}.tar.xz"
                download_file "${mysql_filename}.tar.xz" "${mysql_filename_url}"
                tar Jxf ${mysql_filename}.tar.xz
            else
                mysql_filename_url="https://cdn.mysql.com/Downloads/MySQL-${mysql_ver}/${mysql_filename}.tar.gz"
                download_file "${mysql_filename}.tar.gz" "${mysql_filename_url}"
                tar zxf ${mysql_filename}.tar.gz
            fi

            _info "Moving MySQL files..."
            mv ${mysql_filename}/* ${mysql_location}

            chown -R mysql:mysql ${mysql_location} ${datalocation}
            cp -f ${mysql_location}/support-files/mysql.server /etc/init.d/mysqld
            sed -i "s:^basedir=.*:basedir=${mysql_location}:g" /etc/init.d/mysqld
            sed -i "s:^datadir=.*:datadir=${datalocation}:g" /etc/init.d/mysqld
            chmod +x /etc/init.d/mysqld

            if [ "${mysql_ver}" == "5.5" ] || [ "${mysql_ver}" == "5.6" ]; then
                ${mysql_location}/scripts/mysql_install_db --basedir=${mysql_location} --datadir=${datalocation} --user=mysql
            elif [ "${mysql_ver}" == "5.7" ] || [ "${mysql_ver}" == "8.0" ]; then
                ${mysql_location}/bin/mysqld --initialize-insecure --basedir=${mysql_location} --datadir=${datalocation} --user=mysql
            fi

            create_lib64_dir "${mysql_location}"

        elif [ -d "${mariadb_location}" ]; then
            if [ -d "${mariadb_location}.bak" ]; then
                rm -rf ${mariadb_location}.bak
            fi
            mv ${mariadb_location} ${mariadb_location}.bak
            mkdir -p ${mariadb_location}
            [ ! -d ${datalocation} ] && mkdir -p ${datalocation}

            if [ "${mariadb_ver}" == "10.5" ] || version_lt $(get_libc_version) 2.14; then
                glibc_flag=linux
            else
                glibc_flag=linux-glibc_214
            fi
            is_64bit && sys_bit_a=x86_64 || sys_bit_a=x86
            is_64bit && sys_bit_b=x86_64 || sys_bit_b=i686

            mariadb_filename="mariadb-${latest_mariadb}-${glibc_flag}-${sys_bit_b}"
            if [ "$(get_ip_country)" == "CN" ]; then
                mariadb_filename_url="https://mirrors.ustc.edu.cn/mariadb/mariadb-${latest_mariadb}/bintar-${glibc_flag}-${sys_bit_a}/${mariadb_filename}.tar.gz"
            else
                mariadb_filename_url="http://sfo1.mirrors.digitalocean.com/mariadb/mariadb-${latest_mariadb}/bintar-${glibc_flag}-${sys_bit_a}/${mariadb_filename}.tar.gz"
            fi

            download_file "${mariadb_filename}.tar.gz" "${mariadb_filename_url}"

            _info "Extracting MariaDB files..."
            tar zxf ${mariadb_filename}.tar.gz
            _info "Moving MariaDB files..."
            mv ${mariadb_filename}/* ${mariadb_location}

            chown -R mysql:mysql ${mariadb_location} ${datalocation}
            cp -f ${mariadb_location}/support-files/mysql.server /etc/init.d/mysqld
            sed -i "s@^basedir=.*@basedir=${mariadb_location}@" /etc/init.d/mysqld
            sed -i "s@^datadir=.*@datadir=${datalocation}@" /etc/init.d/mysqld
            chmod +x /etc/init.d/mysqld

            ${mariadb_location}/scripts/mysql_install_db --basedir=${mariadb_location} --datadir=${datalocation} --user=mysql

            create_lib64_dir "${mariadb_location}"
        fi

        if [ -d "/proc/vz" ]; then
            ulimit -s unlimited
        fi
        _info "Starting ${db_name}..."
        /etc/init.d/mysqld start > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            _error "Starting ${db_name} failed, Please check it and try again"
        fi
        if [ "${mysql_ver}" == "8.0" ]; then
            /usr/bin/mysql -uroot -hlocalhost -e "create user root@'127.0.0.1' identified by \"${mysql_root_password}\";"
            /usr/bin/mysql -uroot -hlocalhost -e "grant all privileges on *.* to root@'127.0.0.1' with grant option;"
            /usr/bin/mysql -uroot -hlocalhost -e "grant all privileges on *.* to root@'localhost' with grant option;"
            /usr/bin/mysql -uroot -hlocalhost -e "alter user root@'localhost' identified by \"${mysql_root_password}\";"
        else
            /usr/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"${mysql_root_password}\" with grant option;"
            /usr/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"${mysql_root_password}\" with grant option;"
            /usr/bin/mysql -uroot -p${mysql_root_password} <<EOF
drop database if exists test;
delete from mysql.db where user='';
delete from mysql.user where user='';
delete from mysql.user where user='mysql';
flush privileges;
exit
EOF
        fi
        _info "Starting restore all of databases, Please wait a moment..."
        /usr/bin/mysql -uroot -p${mysql_root_password} < ${mysql_dump} > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            _info "${db_name} all of databases restore success"
        else
            _warn "${db_name} all of databases restore failed, Please restore it manually"
        fi
        _info "Restart ${db_name}..."
        /etc/init.d/mysqld restart > /dev/null 2>&1
        _info "Restart Apache..."
        /etc/init.d/httpd restart > /dev/null 2>&1

        _info "Clear up start..."
        cd ${cur_dir}/software
        rm -rf mysql-* mariadb-*
        _info "Clear up completed..."
        echo
        _info "${db_name} upgrade completed..."
    else
        _info "${db_name} upgrade cancelled, nothing to do..."
    fi

}
