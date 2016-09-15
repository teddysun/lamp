#upgrade database
upgrade_db(){

    if [ ! -d ${mysql_location} ] && [ ! -d ${mariadb_location} ] && [ ! -d ${percona_location} ]; then
        echo "Error:MySQL or MariaDB or Percona looks like not installed, please check it and try again."
        exit 1
    fi

    update_date=`date +"%Y%m%d"`
    bkup_file="mysqld_${update_date}.bak"

    if [ -d ${mysql_location} ];then
        db_flg="mysql"
        bkup_dir="${cur_dir}/mysql_bkup"
        mysql_dump="${bkup_dir}/mysql_all_backup_${update_date}.dump"
        installed_mysql=`${mysql_location}/bin/mysql -V | awk '{print $5}' | tr -d ","`
        mysql_ver=`echo ${installed_mysql} | cut -d. -f1-2`
        if   [ "${mysql_ver}" == "5.5" ]; then
            latest_mysql=`curl -s http://dev.mysql.com/downloads/mysql/5.5.html | awk '/MySQL Community Server/{print $4}' | grep '5.5'`
        elif [ "${mysql_ver}" == "5.6" ]; then
            latest_mysql=`curl -s http://dev.mysql.com/downloads/mysql/5.6.html | awk '/MySQL Community Server/{print $4}' | grep '5.6'`
        elif [ "${mysql_ver}" == "5.7" ]; then
            latest_mysql=`curl -s http://dev.mysql.com/downloads/mysql/5.7.html | awk '/MySQL Community Server/{print $4}' | grep '5.7'`
        fi

        echo -e "Latest version of MySQL: \033[41;37m ${latest_mysql} \033[0m"
        echo -e "Installed version of MySQL: \033[41;37m ${installed_mysql} \033[0m"

    elif [ -d ${mariadb_location} ];then
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
        fi

        echo -e "Latest version of MariaDB: \033[41;37m ${latest_mariadb} \033[0m"
        echo -e "Installed version of MariaDB: \033[41;37m ${installed_mariadb} \033[0m"
    elif [ -d ${percona_location} ];then
        db_flg="percona"
        bkup_dir="${cur_dir}/percona_bkup"
        mysql_dump="${bkup_dir}/percona_all_backup_${update_date}.dump"
        installed_percona=`${percona_location}/bin/mysql -V | awk '{print $5}' | tr -d ","`
        percona_ver=`echo ${installed_percona} | cut -d. -f1-2`
        if   [ "${percona_ver}" == "5.5" ]; then
            latest_percona=`curl -s https://www.percona.com/downloads/Percona-Server-5.5/LATEST/ | grep "title" | awk -F 'Percona-Server-' '/Percona-Server-5.5/{print $2}' | cut -d'<' -f1`
        elif [ "${percona_ver}" == "5.6" ]; then
            latest_percona=`curl -s https://www.percona.com/downloads/Percona-Server-5.6/LATEST/ | grep "title" | awk -F 'Percona-Server-' '/Percona-Server-5.6/{print $2}' | cut -d'<' -f1`
        elif [ "${percona_ver}" == "5.7" ]; then
            latest_percona=`curl -s https://www.percona.com/downloads/Percona-Server-5.7/LATEST/ | grep "title" | awk -F 'Percona-Server-' '/Percona-Server-5.7/{print $2}' | cut -d'<' -f1`
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
            echo "Percona"
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


    if [[ "${upgrade_db}" = "y" || "${upgrade_db}" = "Y" ]];then
        echo "$(db_name) upgrade start..."

        mysql_count=`ps -ef | grep -v grep | grep -c "mysqld"`
        if [ ${mysql_count} -eq 0 ]; then
            echo "$(db_name) looks like not running, Try to starting $(db_name)..."
            /etc/init.d/mysqld start
            if [ $? -ne 0 ]; then
                echo "$(db_name) starting failed!"
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
            echo "$(db_name) root password incorrect! Please check it and try again!"
            exit 2
        fi

        echo "Starting backup all of databases, Please wait a moment..."
        /usr/bin/mysqldump -uroot -p${mysql_root_password} --all-databases > ${mysql_dump}
        if [ $? -eq 0 ]; then
            echo "$(db_name) all of databases backup success"
        else
            echo "$(db_name) all of databases backup failed, Please check it and try again!"
            exit 3
        fi
        echo "Stoping $(db_name)..."
        /etc/init.d/mysqld stop
        if [ $? -eq 0 ]; then
            echo "$(db_name) stop success"
        else
            echo "$(db_name) stop failed! Please check it and try again!"
            exit 4
        fi
        cp -pf /etc/init.d/mysqld ${bkup_dir}/${bkup_file}

        datalocation=`cat ${bkup_dir}/${bkup_file} | grep -w 'datadir=' | awk -F= '{print $2}' | head -1`
        [ ! -d ${datalocation} ] && mkdir -p ${datalocation} && chown -R mysql:mysql ${datalocation}

        if [ ! -d ${cur_dir}/software ];then
            mkdir -p ${cur_dir}/software
        fi
        cd ${cur_dir}/software

        if [ -d ${mysql_location} ];then

            if [ -d ${mysql_location}.bak ];then
                rm -rf ${mysql_location}.bak
            fi
            mv ${mysql_location} ${mysql_location}.bak

            if [ "${mysql_ver}" == "5.7" ]; then
                download_file "${boost_filename}.tar.gz"
                tar zxf ${boost_filename}.tar.gz
                mysql_configure_args="-DCMAKE_INSTALL_PREFIX=${mysql_location} \
                -DWITH_BOOST=${cur_dir}/software/${boost_filename}  \
                -DMYSQL_DATADIR=${datalocation} \
                -DSYSCONFDIR=/etc \
                -DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
                -DDEFAULT_CHARSET=utf8mb4 \
                -DDEFAULT_COLLATION=utf8mb4_general_ci \
                -DWITH_EXTRA_CHARSETS=complex \
                -DWITH_EMBEDDED_SERVER=1 \
                -DENABLED_LOCAL_INFILE=1"
            else
                mysql_configure_args="-DCMAKE_INSTALL_PREFIX=${mysql_location} \
                -DMYSQL_DATADIR=${datalocation} \
                -DSYSCONFDIR=/etc \
                -DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
                -DDEFAULT_CHARSET=utf8mb4 \
                -DDEFAULT_COLLATION=utf8mb4_general_ci \
                -DWITH_EXTRA_CHARSETS=complex \
                -DWITH_READLINE=1 \
                -DENABLED_LOCAL_INFILE=1"
            fi

            if [ ! -s mysql-${latest_mysql}.tar.gz ]; then
                latest_mysql_link="http://cdn.mysql.com/Downloads/MySQL-${mysql_ver}/mysql-${latest_mysql}.tar.gz"
                backup_mysql_link="${download_root_url}/mysql-${latest_mysql}.tar.gz"
                untar ${latest_mysql_link} ${backup_mysql_link}
            else
                tar -zxf mysql-${latest_mysql}.tar.gz
                cd mysql-${latest_mysql}
            fi

            error_detect "cmake ${mysql_configure_args}"
            error_detect "parallel_make"
            error_detect "make install"
            if [ -d "${mysql_location}/lib" ] && [ ! -d "${mysql_location}/lib64" ];then
                cd ${mysql_location}
                ln -s lib lib64
            fi
            chown -R mysql:mysql ${mysql_location} ${datalocation}
            cp -f ${mysql_location}/support-files/mysql.server /etc/init.d/mysqld
            sed -i "s:^basedir=.*:basedir=${mysql_location}:g" /etc/init.d/mysqld
            sed -i "s:^datadir=.*:datadir=${datalocation}:g" /etc/init.d/mysqld
            chmod +x /etc/init.d/mysqld

            if [ ${mysql_ver} == "5.5" ] || [ ${mysql_ver} == "5.6" ];then
                ${mysql_location}/scripts/mysql_install_db --basedir=${mysql_location} --datadir=${datalocation} --user=mysql
            elif [ ${mysql_ver} == "5.7" ];then
                ${mysql_location}/bin/mysqld --initialize-insecure --basedir=${mysql_location} --datadir=${datalocation} --user=mysql
            fi

        elif [ -d ${mariadb_location} ];then

            if [ -d ${mariadb_location}.bak ];then
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

            echo "Extracting MariaDB files..."
            tar zxf mariadb-${latest_mariadb}-${glibc_flag}-${sys_bit_b}.tar.gz
            echo "Moving MariaDB files..."
            mv mariadb-${latest_mariadb}-*-${sys_bit_b}/* ${mariadb_location}
            if [ -d "${mariadb_location}/lib" ] && [ ! -d "${mariadb_location}/lib64" ];then
                cd ${mariadb_location}
                ln -s lib lib64
            fi
            chown -R mysql:mysql ${mariadb_location} ${datalocation}
            cp -f ${mariadb_location}/support-files/mysql.server /etc/init.d/mysqld
            sed -i "s@^basedir=.*@basedir=${mariadb_location}@" /etc/init.d/mysqld
            sed -i "s@^datadir=.*@datadir=${datalocation}@" /etc/init.d/mysqld
            chmod +x /etc/init.d/mysqld

            ${mariadb_location}/scripts/mysql_install_db --basedir=${mariadb_location} --datadir=${datalocation} --user=mysql

        elif [ -d ${percona_location} ];then
            if [ -d ${percona_location}.bak ];then
                rm -rf ${percona_location}.bak
            fi
            mv ${percona_location} ${percona_location}.bak

            if [ "${percona_ver}" == "5.7" ]; then
                download_file "${boost_filename}.tar.gz"
                tar zxf ${boost_filename}.tar.gz
                percona_configure_args="-DCMAKE_INSTALL_PREFIX=${percona_location} \
                -DWITH_BOOST=${cur_dir}/software/${boost_filename} \
                -DMYSQL_DATADIR=${datalocation} \
                -DSYSCONFDIR=/etc \
                -DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
                -DDEFAULT_CHARSET=utf8mb4 \
                -DDEFAULT_COLLATION=utf8mb4_general_ci \
                -DWITH_EXTRA_CHARSETS=complex \
                -DWITH_EMBEDDED_SERVER=1 \
                -DENABLE_DTRACE=0 \
                -DENABLED_LOCAL_INFILE=1"
            else
                percona_configure_args="-DCMAKE_INSTALL_PREFIX=${percona_location} \
                -DMYSQL_DATADIR=${datalocation} \
                -DSYSCONFDIR=/etc \
                -DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
                -DDEFAULT_CHARSET=utf8mb4 \
                -DDEFAULT_COLLATION=utf8mb4_general_ci \
                -DWITH_EXTRA_CHARSETS=complex \
                -DWITH_READLINE=1 \
                -DENABLE_DTRACE=0 \
                -DENABLED_LOCAL_INFILE=1"
            fi

            if [ ! -s percona-server-${latest_percona}.tar.gz ]; then
                latest_percona_link="https://www.percona.com/downloads/Percona-Server-${percona_ver}/Percona-Server-${latest_percona}/source/tarball/percona-server-${latest_percona}.tar.gz"
                backup_percona_link="${download_root_url}/percona-server-${latest_percona}.tar.gz"
                untar ${latest_percona_link} ${backup_percona_link}
            else
                tar -zxf percona-server-${latest_percona}.tar.gz
                cd percona-server-${latest_percona}
            fi

            error_detect "cmake ${percona_configure_args}"
            error_detect "parallel_make"
            error_detect "make install"
            if [ -d "${percona_location}/lib" ] && [ ! -d "${percona_location}/lib64" ];then
                cd ${percona_location}
                ln -s lib lib64
            fi
            chown -R mysql:mysql ${percona_location} ${datalocation}
            cp -f ${percona_location}/support-files/mysql.server /etc/init.d/mysqld
            sed -i "s:^basedir=.*:basedir=${percona_location}:g" /etc/init.d/mysqld
            sed -i "s:^datadir=.*:datadir=${datalocation}:g" /etc/init.d/mysqld
            chmod +x /etc/init.d/mysqld

            if [ ${percona_ver} == "5.5" ] || [ ${percona_ver} == "5.6" ];then
                ${percona_location}/scripts/mysql_install_db --basedir=${percona_location} --datadir=${datalocation} --user=mysql
            elif [ ${percona_ver} == "5.7" ];then
                ${percona_location}/bin/mysqld --initialize-insecure --basedir=${percona_location} --datadir=${datalocation} --user=mysql
            fi
            #Fix libmysqlclient issue
            ln -sv ${percona_location}/lib/libperconaserverclient.a ${percona_location}/lib/libmysqlclient.a
            if [ ${percona_ver} != "5.7" ]; then
                ln -sv ${percona_location}/lib/libperconaserverclient_r.a ${percona_location}/lib/libmysqlclient_r.a
            fi

        fi

        if [ -d "/proc/vz" ]; then
            ulimit -s unlimited
        fi
        /etc/init.d/mysqld start
        if [ $? -ne 0 ]; then
            echo "Starting $(db_name) failed, Please check it and try again!"
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
        echo "Starting restore all of databases, Please wait a moment..."
        /usr/bin/mysql -uroot -p${mysql_root_password} < ${mysql_dump}
        if [ $? -eq 0 ]; then
            echo "$(db_name) all of databases restore success"
        else
            echo "$(db_name) all of databases restore failed, Please restore it manually!"
            exit 6
        fi
        echo "Restart $(db_name)..."
        /etc/init.d/mysqld restart
        echo "Restart Apache..."
        /etc/init.d/httpd restart
        
        echo "Clear up start..."
        cd ${cur_dir}/software
        rm -rf mysql-* mariadb-*
        echo "Clear up completed..."
        echo
        echo "$(db_name) upgrade completed..."
        echo "Welcome to visit:https://lamp.sh"
        echo "Enjoy it!"
        echo
    else
        echo
        echo "$(db_name) upgrade cancelled, nothing to do..."
        echo
    fi

}
