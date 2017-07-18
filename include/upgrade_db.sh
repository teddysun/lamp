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

#upgrade database
upgrade_db(){

    if [ ! -d ${mysql_location} ] && [ ! -d ${mariadb_location} ] && [ ! -d ${percona_location} ]; then
        log "Error" "MySQL or MariaDB or Percona looks like not installed, please check it and try again."
        exit 1
    fi

    update_date=`date +"%Y%m%d"`
    bkup_file="mysqld_${update_date}.bak"

    if [ -d ${mysql_location} ]; then
        db_flg="mysql"
        bkup_dir="${cur_dir}/mysql_bkup"
        mysql_dump="${bkup_dir}/mysql_all_backup_${update_date}.dump"
        installed_mysql=`${mysql_location}/bin/mysql -V | awk '{print $5}' | tr -d ","`
        mysql_ver=`echo ${installed_mysql} | cut -d. -f1-2`
        if   [ "${mysql_ver}" == "5.5" ]; then
            latest_mysql=`curl -s https://dev.mysql.com/downloads/mysql/5.5.html | awk '/MySQL Community Server/{print $4}' | grep '5.5'`
        elif [ "${mysql_ver}" == "5.6" ]; then
            latest_mysql=`curl -s https://dev.mysql.com/downloads/mysql/5.6.html | awk '/MySQL Community Server/{print $4}' | grep '5.6'`
        elif [ "${mysql_ver}" == "5.7" ]; then
            latest_mysql=`curl -s https://dev.mysql.com/downloads/mysql/5.7.html | awk '/MySQL Community Server/{print $4}' | grep '5.7'`
        fi

        echo -e "Latest version of MySQL: \033[41;37m ${latest_mysql} \033[0m"
        echo -e "Installed version of MySQL: \033[41;37m ${installed_mysql} \033[0m"

    elif [ -d ${mariadb_location} ]; then
        db_flg="mariadb"
        bkup_dir="${cur_dir}/mariadb_bkup"
        mysql_dump="${bkup_dir}/mariadb_all_backup_${update_date}.dump"
        installed_mariadb=`${mariadb_location}/bin/mysql -V | awk '{print $5}' | tr -d "," | cut -d- -f1`
        mariadb_ver=`echo ${installed_mariadb} | cut -d. -f1-2`
        if   [ "${mariadb_ver}" == "5.5" ]; then
            latest_mariadb=`curl -s https://downloads.mariadb.org/ | awk -F/ '/\/mariadb\/5.5/{print $3}'`
        elif [ "${mariadb_ver}" == "10.0" ]; then
            latest_mariadb=`curl -s https://downloads.mariadb.org/ | awk -F/ '/\/mariadb\/10.0/{print $3}'`
        elif [ "${mariadb_ver}" == "10.1" ]; then
            latest_mariadb=`curl -s https://downloads.mariadb.org/ | awk -F/ '/\/mariadb\/10.1/{print $3}'`
        elif [ "${mariadb_ver}" == "10.2" ]; then
            latest_mariadb=`curl -s https://downloads.mariadb.org/ | awk -F/ '/\/mariadb\/10.2/{print $3}'`
        fi

        echo -e "Latest version of MariaDB: \033[41;37m ${latest_mariadb} \033[0m"
        echo -e "Installed version of MariaDB: \033[41;37m ${installed_mariadb} \033[0m"
    elif [ -d ${percona_location} ]; then
        db_flg="percona"
        bkup_dir="${cur_dir}/percona_bkup"
        mysql_dump="${bkup_dir}/percona_all_backup_${update_date}.dump"
        installed_percona=`${percona_location}/bin/mysql -V | awk '{print $5}' | tr -d ","`
        percona_ver=`echo ${installed_percona} | cut -d. -f1-2`
        if   [ "${percona_ver}" == "5.5" ]; then
            latest_percona=`curl -s https://www.percona.com/downloads/Percona-Server-5.5/LATEST/ | grep 'selected' | head -1 | awk -F '/Percona-Server-' '/Percona-Server-5.5/{print $2}' | cut -d'"' -f1`
        elif [ "${percona_ver}" == "5.6" ]; then
            latest_percona=`curl -s https://www.percona.com/downloads/Percona-Server-5.6/LATEST/ | grep 'selected' | head -1 | awk -F '/Percona-Server-' '/Percona-Server-5.6/{print $2}' | cut -d'"' -f1`
        elif [ "${percona_ver}" == "5.7" ]; then
            latest_percona=`curl -s https://www.percona.com/downloads/Percona-Server-5.7/LATEST/ | grep 'selected' | head -1 | awk -F '/Percona-Server-' '/Percona-Server-5.7/{print $2}' | cut -d'"' -f1`
        fi

        echo -e "Latest version of Percona: \033[41;37m ${latest_percona} \033[0m"
        echo -e "Installed version of Percona: \033[41;37m ${installed_percona} \033[0m"

    fi

    db_name(){
        if [ "${db_flg}" == "mysql" ]; then
            echo "MySQL"
        elif [ "${db_flg}" == "mariadb" ]; then
            echo "MariaDB"
        elif [ "${db_flg}" == "percona" ]; then
            echo "Percona Server"
        fi
    }

    echo
    echo "Do you want to upgrade $(db_name) ? (y/n)"

    read -p "(Default: n):" upgrade_db
    if [ -z ${upgrade_db} ]; then
        upgrade_db="n"
    fi
    echo "---------------------------"
    echo "You choose = ${upgrade_db}"
    echo "---------------------------"
    echo
    echo "Press any key to start...or Press Ctrl+C to cancel"
    char=`get_char`


    if [[ "${upgrade_db}" = "y" || "${upgrade_db}" = "Y" ]]; then
        log "Info" "$(db_name) upgrade start..."

        mysql_count=`ps -ef | grep -v grep | grep -c "mysqld"`
        if [ ${mysql_count} -eq 0 ]; then
            log "Info" "$(db_name) looks like not running, Try to starting $(db_name)..."
            /etc/init.d/mysqld start > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                log "Error" "$(db_name) starting failed!"
                exit 1
            fi
        fi

        if [ ! -d ${bkup_dir} ]; then
            mkdir -p ${bkup_dir}
        fi

        read -p "Please input your $(db_name) root password:" mysql_root_password
        /usr/bin/mysql -uroot -p${mysql_root_password} <<EOF
exit
EOF
        if [ $? -ne 0 ]; then
            log "Error" "$(db_name) root password incorrect! Please check it and try again!"
            exit 2
        fi

        log "Info" "Starting backup all of databases, Please wait a moment..."
        /usr/bin/mysqldump -uroot -p${mysql_root_password} --all-databases > ${mysql_dump}
        if [ $? -eq 0 ]; then
            log "Info" "$(db_name) all of databases backup success"
        else
            log "Error" "$(db_name) all of databases backup failed, Please check it and try again!"
            exit 3
        fi
        log "Info" "Stopping $(db_name)..."
        /etc/init.d/mysqld stop > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            log "Info" "$(db_name) stop success"
        else
            log "Error" "$(db_name) stop failed! Please check it and try again!"
            exit 4
        fi
        cp -pf /etc/init.d/mysqld ${bkup_dir}/${bkup_file}

        datalocation=`cat ${bkup_dir}/${bkup_file} | grep -w 'datadir=' | awk -F= '{print $2}' | head -1`

        if [ ! -d ${cur_dir}/software ]; then
            mkdir -p ${cur_dir}/software
        fi
        cd ${cur_dir}/software

        if [ -d ${mysql_location} ]; then

            if [ -d ${mysql_location}.bak ]; then
                rm -rf ${mysql_location}.bak
            fi
            mv ${mysql_location} ${mysql_location}.bak
            mkdir -p ${mysql_location}
            [ ! -d ${datalocation} ] && mkdir -p ${datalocation}

            is_64bit && sys_bit=x86_64 || sys_bit=i686
            url1="http://cdn.mysql.com/Downloads/MySQL-${mysql_ver}/mysql-${latest_mysql}-linux-glibc2.12-${sys_bit}.tar.gz"
            url2="${download_root_url}/mysql-${latest_mysql}-linux-glibc2.12-${sys_bit}.tar.gz"

            download_from_url "mysql-${latest_mysql}-linux-glibc2.12-${sys_bit}.tar.gz" "${url1}" "${url2}"
            log "Info" "Extracting MySQL files..."
            tar zxf mysql-${latest_mysql}-linux-glibc2.12-${sys_bit}.tar.gz
            log "Info" "Moving MySQL files..."
            mv mysql-${latest_mysql}-linux-glibc2.12-${sys_bit}/* ${mysql_location}

            chown -R mysql:mysql ${mysql_location} ${datalocation}
            cp -f ${mysql_location}/support-files/mysql.server /etc/init.d/mysqld
            sed -i "s:^basedir=.*:basedir=${mysql_location}:g" /etc/init.d/mysqld
            sed -i "s:^datadir=.*:datadir=${datalocation}:g" /etc/init.d/mysqld
            chmod +x /etc/init.d/mysqld

            if [ ${mysql_ver} == "5.5" ] || [ ${mysql_ver} == "5.6" ]; then
                ${mysql_location}/scripts/mysql_install_db --basedir=${mysql_location} --datadir=${datalocation} --user=mysql
            elif [ ${mysql_ver} == "5.7" ]; then
                ${mysql_location}/bin/mysqld --initialize-insecure --basedir=${mysql_location} --datadir=${datalocation} --user=mysql
            fi

            create_lib64_dir "${mysql_location}"

        elif [ -d ${mariadb_location} ]; then

            if [ -d ${mariadb_location}.bak ]; then
                rm -rf ${mariadb_location}.bak
            fi
            mv ${mariadb_location} ${mariadb_location}.bak
            mkdir -p ${mariadb_location}
            [ ! -d ${datalocation} ] && mkdir -p ${datalocation}

            if [ "$(get_ip_country)" == "CN" ]; then
                down_addr1=http://mirrors.aliyun.com/mariadb/
                down_addr2=http://sfo1.mirrors.digitalocean.com/mariadb/
            else
                down_addr1=http://sfo1.mirrors.digitalocean.com/mariadb/
                down_addr2=http://mirrors.aliyun.com/mariadb/
            fi

            libc_version=`getconf -a | grep GNU_LIBC_VERSION | awk '{print $NF}'`

            if version_lt ${libc_version} 2.14; then
                glibc_flag=linux
            else
                glibc_flag=linux-glibc_214
            fi
            
            is_64bit && sys_bit_a=x86_64 || sys_bit_a=x86
            is_64bit && sys_bit_b=x86_64 || sys_bit_b=i686

            download_from_url "mariadb-${latest_mariadb}-${glibc_flag}-${sys_bit_b}.tar.gz" \
            "${down_addr1}/mariadb-${latest_mariadb}/bintar-${glibc_flag}-${sys_bit_a}/mariadb-${latest_mariadb}-${glibc_flag}-${sys_bit_b}.tar.gz" \
            "${down_addr2}/mariadb-${latest_mariadb}/bintar-${glibc_flag}-${sys_bit_a}/mariadb-${latest_mariadb}-${glibc_flag}-${sys_bit_b}.tar.gz"

            log "Info" "Extracting MariaDB files..."
            tar zxf mariadb-${latest_mariadb}-${glibc_flag}-${sys_bit_b}.tar.gz
            log "Info" "Moving MariaDB files..."
            mv mariadb-${latest_mariadb}-*-${sys_bit_b}/* ${mariadb_location}

            chown -R mysql:mysql ${mariadb_location} ${datalocation}
            cp -f ${mariadb_location}/support-files/mysql.server /etc/init.d/mysqld
            sed -i "s@^basedir=.*@basedir=${mariadb_location}@" /etc/init.d/mysqld
            sed -i "s@^datadir=.*@datadir=${datalocation}@" /etc/init.d/mysqld
            chmod +x /etc/init.d/mysqld

            ${mariadb_location}/scripts/mysql_install_db --basedir=${mariadb_location} --datadir=${datalocation} --user=mysql

            create_lib64_dir "${mariadb_location}"

        elif [ -d ${percona_location} ]; then

            if [ -d ${percona_location}.bak ]; then
                rm -rf ${percona_location}.bak
            fi
            mv ${percona_location} ${percona_location}.bak
            mkdir -p ${percona_location}
            [ ! -d ${datalocation} ] && mkdir -p ${datalocation}

            is_64bit && sys_bit=x86_64 || sys_bit=i686
            if check_sys packageManager apt; then
                ssl_ver="ssl100"
            elif check_sys packageManager yum; then
                ssl_ver="ssl101"
            fi

            major_ver=$(echo "Percona-Server-${latest_percona}" | cut -d'-' -f1-3)
            rel_ver=$(echo "Percona-Server-${latest_percona}" | awk -F'-' '{print $4}')
            down_addr="https://www.percona.com/downloads/Percona-Server-${percona_ver}/Percona-Server-${latest_percona}/binary/tarball"

            if [[ "${percona_ver}" == "5.5" || "${percona_ver}" == "5.6" ]]; then
                tarball="${major_ver}-rel${rel_ver}-Linux.${sys_bit}.${ssl_ver}"
            fi
            if [[ "${percona_ver}" == "5.7" ]]; then
                tarball="Percona-Server-${latest_percona}-Linux.${sys_bit}.${ssl_ver}"
            fi

            url1="${down_addr}/${tarball}.tar.gz"
            url2="${download_root_url}/${tarball}.tar.gz"

            download_from_url "${tarball}.tar.gz" "${url1}" "${url2}"
            log "Info" "Extracting Percona Server files..."
            tar zxf ${tarball}.tar.gz
            log "Info" "Moving Percona Server files..."
            mv ${tarball}/* ${percona_location}

            chown -R mysql:mysql ${percona_location} ${datalocation}
            cp -f ${percona_location}/support-files/mysql.server /etc/init.d/mysqld
            sed -i "s:^basedir=.*:basedir=${percona_location}:g" /etc/init.d/mysqld
            sed -i "s:^datadir=.*:datadir=${datalocation}:g" /etc/init.d/mysqld
            chmod +x /etc/init.d/mysqld

            sed -ir "s@/usr/local/${tarball}@${percona_location}@g" ${percona_location}/bin/mysqld_safe
            sed -ir "s@/usr/local/${tarball}@${percona_location}@g" ${percona_location}/bin/mysql_config

            if [ ${percona_ver} == "5.5" ] || [ ${percona_ver} == "5.6" ]; then
                ${percona_location}/scripts/mysql_install_db --basedir=${percona_location} --datadir=${datalocation} --user=mysql
            elif [ ${percona_ver} == "5.7" ]; then
                ${percona_location}/bin/mysqld --initialize-insecure --basedir=${percona_location} --datadir=${datalocation} --user=mysql
            fi

            create_lib64_dir "${percona_location}"

            #Fix libmysqlclient issue
            cd ${percona_location}/lib/
            ln -s libperconaserverclient.a libmysqlclient.a
            ln -s libperconaserverclient.so libmysqlclient.so
            if [ ${percona_ver} != "5.7" ]; then
                ln -s libperconaserverclient_r.a libmysqlclient_r.a
                ln -s libperconaserverclient_r.so libmysqlclient_r.so
            fi

        fi

        if [ -d "/proc/vz" ]; then
            ulimit -s unlimited
        fi
        log "Info" "Starting $(db_name)..."
        /etc/init.d/mysqld start > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            log "Error" "Starting $(db_name) failed, Please check it and try again!"
            exit 5
        fi
        /usr/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"${mysql_root_password}\" with grant option;"
        /usr/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"${mysql_root_password}\" with grant option;"
        /usr/bin/mysql -uroot -p${mysql_root_password} <<EOF
drop database if exists test;
delete from mysql.user where user='';
delete from mysql.user where not (user='root');
flush privileges;
exit
EOF
        log "Info" "Starting restore all of databases, Please wait a moment..."
        /usr/bin/mysql -uroot -p${mysql_root_password} < ${mysql_dump} > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            log "Info" "$(db_name) all of databases restore success"
        else
            log "Error" "$(db_name) all of databases restore failed, Please restore it manually!"
            exit 6
        fi
        log "Info" "Restart $(db_name)..."
        /etc/init.d/mysqld restart > /dev/null 2>&1
        log "Info" "Restart Apache..."
        /etc/init.d/httpd restart > /dev/null 2>&1

        log "Info" "Clear up start..."
        cd ${cur_dir}/software
        rm -rf mysql-* mariadb-* Percona-Server-*
        log "Info" "Clear up completed..."
        echo
        log "Info" "$(db_name) upgrade completed..."
    else
        echo
        log "Info" "$(db_name) upgrade cancelled, nothing to do..."
        echo
    fi

}
