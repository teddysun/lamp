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

# Define Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PLAIN='\033[0m'

log(){
    if   [ "${1}" == "Warning" ]; then
        echo -e "[${YELLOW}${1}${PLAIN}] ${2}"
    elif [ "${1}" == "Error" ]; then
        echo -e "[${RED}${1}${PLAIN}] ${2}"
    elif [ "${1}" == "Info" ]; then
        echo -e "[${GREEN}${1}${PLAIN}] ${2}"
    else
        echo -e "[${1}] ${2}"
    fi
}

rootness(){
    if [[ ${EUID} -ne 0 ]]; then
       log "Error" "This script must be run as root"
       exit 1
    fi
}

generate_password(){
    cat /dev/urandom | head -1 | md5sum | head -c 8
}

get_ip(){
    local IP=$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipv4.icanhazip.com )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipinfo.io/ip )
    [ ! -z ${IP} ] && echo ${IP} || echo
}

get_ip_country(){
    local country=$( wget -qO- -t1 -T2 ipinfo.io/$(get_ip)/country )
    [ ! -z ${country} ] && echo ${country} || echo
}

get_opsy(){
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

get_os_info(){
    cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
    cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
    freq=$( awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
    tram=$( free -m | awk '/Mem/ {print $2}' )
    swap=$( free -m | awk '/Swap/ {print $2}' )
    up=$( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60;d=$1%60} {printf("%ddays, %d:%d:%d\n",a,b,c,d)}' /proc/uptime )
    load=$( w | head -1 | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
    opsy=$( get_opsy )
    arch=$( uname -m )
    lbit=$( getconf LONG_BIT )
    host=$( hostname )
    kern=$( uname -r )
    ramsum=$( expr $tram + $swap )
}

get_php_extension_dir(){
    local phpConfig=${1}
    ${phpConfig} --extension-dir
}

get_php_version(){
    local phpConfig=${1}
    ${phpConfig} --version | cut -d'.' -f1-2
}

get_char(){
    SAVEDSTTY=`stty -g`
    stty -echo
    stty cbreak
    dd if=/dev/tty bs=1 count=1 2> /dev/null
    stty -raw
    stty echo
    stty ${SAVEDSTTY}
}

get_valid_valname(){
    local val=${1}
    local new_val=$(eval echo $val | sed 's/[-.]/_/g')
    echo ${new_val}
}

get_hint(){
    local val=${1}
    local new_val=$(get_valid_valname $val)
    eval echo "\$hint_${new_val}"
}

set_hint(){
    local val=${1}
    local hint="$2"
    local new_val=$(get_valid_valname $val)
    eval hint_${new_val}="\$hint"
}

disable_selinux(){
    if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        setenforce 0
    fi
}

#Display Memu
display_menu(){
    local soft=${1}
    local default=${2}
    eval local arr=(\${${soft}_arr[@]})
    local default_prompt
    if [[ "$default" != "" ]]; then
        if [[ "$default" == "last" ]]; then
            default=${#arr[@]}
        fi
        default_prompt="(default ${arr[$default-1]})"
    fi
    local pick
    local hint
    local vname
    local prompt="which ${soft} you'd select ${default_prompt}: "

    while :
    do
        echo -e "\n-------------------------- ${soft} setting ---------------------------\n"
        for ((i=1;i<=${#arr[@]};i++ )); do
            vname="$(get_valid_valname ${arr[$i-1]})"
            hint="$(get_hint $vname)"
            [[ "$hint" == "" ]] && hint="${arr[$i-1]}"
            echo -e "${GREEN}${i}${PLAIN}) $hint"
        done
        echo
        read -p "${prompt}" pick
        if [[ "$pick" == "" && "$default" != "" ]]; then
            pick=${default}
            break
        fi

        if ! is_digit "$pick"; then
            prompt="Input error, please input a number"
            continue
        fi

        if [[ "$pick" -lt 1 || "$pick" -gt ${#arr[@]} ]]; then
            prompt="Input error, please input a number between 1 and ${#arr[@]}: "
            continue
        fi

        break
    done

    eval ${soft}=${arr[$pick-1]}
    vname="$(get_valid_valname ${arr[$pick-1]})"
    hint="$(get_hint $vname)"
    [[ "$hint" == "" ]] && hint="${arr[$pick-1]}"
    echo -e "\nyour selection: $hint"
}

#Display multiple Menu
display_menu_multi(){
    local soft=${1}
    local default=${2}
    eval local arr=(\${${soft}_arr[@]})
    local arr_len=${#arr[@]}
    local pick
    local correct=true
    local prompt
    local vname
    local hint
    local default_prompt
    if [[ "$default" != "" ]]; then
        if [[ "$default" == "last" ]]; then
            default=${arr_len}
        fi
        default_prompt="(default ${arr[$default-1]})"
        
    fi
    prompt="Please input one or more number between 1 and ${arr_len} ${default_prompt} (for example: 1 2 3): "

    echo "-------------------------- $soft install --------------------------"
    echo
    for ((i=1;i<=${arr_len};i++ )); do
        vname="$(get_valid_valname ${arr[$i-1]})"
        hint="$(get_hint $vname)"
        [[ "$hint" == "" ]] && hint="${arr[$i-1]}"
        echo -e "${GREEN}${i}${PLAIN}) $hint"
    done
    echo
    while true
    do
        read -p "${prompt}" pick
        pick=(${pick})
        eval unset ${soft}_install
        if [[ "$pick" == "" ]]; then
            if [[ "$default" == "" ]]; then
                echo "Input can not be empty, please reinput."
                continue
            else
                eval ${soft}_install="${arr[$default-1]}"
                break
            fi
        fi

        for j in ${pick[@]}
        do
            if ! is_digit "$j"; then
                echo "Input error, please input a number"
                correct=false
                break 1
            fi    

            if [[ "$j" -lt 1 || "$j" -gt ${arr_len} ]]; then
                echo "Input error, please input the number between 1 and ${arr_len}${default_prompt}."
                correct=false
                break 1
            fi

            if [ "${arr[$j-1]}" == "do_not_install" ]; then
                eval ${soft}_install="do_not_install"
                break 2
            fi
                
            eval ${soft}_install="\"\$${soft}_install ${arr[$j-1]}\""
            correct=true

        done
        [[ "$correct" == true ]] && break

    done

    echo
    eval echo -e "your selection: \$${soft}_install"
}

display_os_info(){
    clear
    echo
    echo "+-------------------------------------------------------------------+"
    echo "| Auto Install LAMP(Linux + Apache + MySQL/MariaDB/Percona + PHP )  |"
    echo "| Website: https://lamp.sh                                          |"
    echo "| Author : Teddysun <i@teddysun.com>                                |"
    echo "+-------------------------------------------------------------------+"
    echo
    echo "--------------------- System Information ----------------------------"
    echo
    echo "CPU model            : ${cname}"
    echo "Number of cores      : ${cores}"
    echo "CPU frequency        : ${freq} MHz"
    echo "Total amount of ram  : ${tram} MB"
    echo "Total amount of swap : ${swap} MB"
    echo "System uptime        : ${up}"
    echo "Load average         : ${load}"
    echo "OS                   : ${opsy}"
    echo "Arch                 : ${arch} (${lbit} Bit)"
    echo "Kernel               : ${kern}"
    echo "Hostname             : ${host}"
    echo "IPv4 address         : $(get_ip)"
    echo
    echo "---------------------------------------------------------------------"
}

check_command_exist(){
    if [ ! "$(command -v "${1}")" ]; then
        log "Error" "${1} is not installed, please install it and try again."
        exit 1
    fi
}

check_installed(){
    local cmd=${1}
    local location=${2}
    if [ -d "${location}" ]; then
        log "Info" "${location} already exists, skipped the installation."
        add_to_env "${location}"
    else
        ${cmd}
    fi
}

check_ram(){
    get_os_info
    if [ ${ramsum} -lt 480 ]; then
        log "Error" "Not enough memory. The LAMP installation needs memory: ${tram}MB*RAM + ${swap}MB*SWAP >= 480MB"
        exit 1
    fi
    [ ${ramsum} -lt 600 ] && disable_fileinfo="--disable-fileinfo" || disable_fileinfo=""
}

#Check system
check_sys(){
    local checkType=${1}
    local value=${2}

    local release=''
    local systemPackage=''

    if [[ -f /etc/redhat-release ]]; then
        release="centos"
        systemPackage="yum"
    elif cat /etc/issue | grep -Eqi "debian"; then
        release="debian"
        systemPackage="apt"
    elif cat /etc/issue | grep -Eqi "ubuntu"; then
        release="ubuntu"
        systemPackage="apt"
    elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
        systemPackage="yum"
    elif cat /proc/version | grep -Eqi "debian"; then
        release="debian"
        systemPackage="apt"
    elif cat /proc/version | grep -Eqi "ubuntu"; then
        release="ubuntu"
        systemPackage="apt"
    elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
        systemPackage="yum"
    fi

    if [[ ${checkType} == "sysRelease" ]]; then
        if [ "$value" == "$release" ]; then
            return 0
        else
            return 1
        fi
    elif [[ ${checkType} == "packageManager" ]]; then
        if [ "$value" == "$systemPackage" ]; then
            return 0
        else
            return 1
        fi
    fi
}

#create mysql cnf
create_mysql_my_cnf(){

    local mysqlDataLocation=${1}
    local binlog=${2}
    local replica=${3}
    local my_cnf_location=${4}

    local memory=512M
    local storage=InnoDB
    local totalMemory=$(awk 'NR==1{print $2}' /proc/meminfo)
    if [[ ${totalMemory} -lt 393216 ]]; then
        memory=256M
        storage=MyISAM
    elif [[ ${totalMemory} -lt 786432 ]]; then
        memory=512M
        storage=MyISAM
    elif [[ ${totalMemory} -lt 1572864 ]]; then
        memory=1G
    elif [[ ${totalMemory} -lt 3145728 ]]; then
        memory=2G
    elif [[ ${totalMemory} -lt 6291456 ]]; then
        memory=4G
    elif [[ ${totalMemory} -lt 12582912 ]]; then
        memory=8G
    elif [[ ${totalMemory} -lt 25165824 ]]; then
        memory=16G
    else
        memory=32G
    fi

    case ${memory} in
        256M)innodb_log_file_size=32M;innodb_buffer_pool_size=64M;key_buffer_size=16M;open_files_limit=512;table_open_cache=200;max_connections=64;;
        512M)innodb_log_file_size=32M;innodb_buffer_pool_size=128M;key_buffer_size=32M;open_files_limit=512;table_open_cache=200;max_connections=128;;
        1G)innodb_log_file_size=64M;innodb_buffer_pool_size=256M;key_buffer_size=64M;open_files_limit=1024;table_open_cache=400;max_connections=256;;
        2G)innodb_log_file_size=64M;innodb_buffer_pool_size=512M;key_buffer_size=128M;open_files_limit=1024;table_open_cache=400;max_connections=300;;
        4G)innodb_log_file_size=128M;innodb_buffer_pool_size=1G;key_buffer_size=256M;open_files_limit=2048;table_open_cache=800;max_connections=400;;
        8G)innodb_log_file_size=256M;innodb_buffer_pool_size=2G;key_buffer_size=512M;open_files_limit=4096;table_open_cache=1600;max_connections=400;;
        16G)innodb_log_file_size=512M;innodb_buffer_pool_size=4G;key_buffer_size=1G;open_files_limit=8192;table_open_cache=2000;max_connections=512;;
        32G)innodb_log_file_size=512M;innodb_buffer_pool_size=8G;key_buffer_size=2G;open_files_limit=65535;table_open_cache=2048;max_connections=1024;;
        *) echo "input error, please input a number";;
    esac

    if ${binlog}; then
        binlog="# BINARY LOGGING #\nlog-bin = ${mysqlDataLocation}/mysql-bin\nserver-id = 1\nexpire-logs-days = 14\nsync-binlog = 1"
        binlog=$(echo -e $binlog)
    else
        binlog=""
    fi

    if ${replica}; then
        replica="# REPLICATION #\nrelay-log = ${mysqlDataLocation}/relay-bin\nslave-net-timeout = 60"
        replica=$(echo -e $replica)
    else
        replica=""
    fi

    if [ "$storage" == "InnoDB" ]; then
        key_buffer_size=32M
        if ! is_64bit && [[ `echo $innodb_buffer_pool_size | tr -d G` -ge 4 ]]; then
            innodb_buffer_pool_size=2G
        fi

    elif [ "$storage" == "MyISAM" ]; then
        innodb_log_file_size=32M
        innodb_buffer_pool_size=8M
        if ! is_64bit && [[ `echo $key_buffer_size | tr -d G` -ge 4 ]]; then
            key_buffer_size=2G
        fi
    fi

    log "Info" "create my.cnf file..."
    sleep 1
    cat >${my_cnf_location} <<EOF
[mysql]

# CLIENT #
port                           = 3306
socket                         = /tmp/mysql.sock

[mysqld]

# GENERAL #
port                           = 3306
user                           = mysql
default-storage-engine         = ${storage}
socket                         = /tmp/mysql.sock
pid-file                       = ${mysqlDataLocation}/mysql.pid
skip-name-resolve
skip-external-locking

# MyISAM #
key-buffer-size                = ${key_buffer_size}

# INNODB #
innodb-log-files-in-group      = 2
innodb-log-file-size           = ${innodb_log_file_size}
innodb-flush-log-at-trx-commit = 2
innodb-file-per-table          = 1
innodb-buffer-pool-size        = ${innodb_buffer_pool_size}

# CACHES AND LIMITS #
tmp-table-size                 = 32M
max-heap-table-size            = 32M
query-cache-type               = 0
query-cache-size               = 0
max-connections                = ${max_connections}
thread-cache-size              = 50
open-files-limit               = ${open_files_limit}
table-open-cache               = ${table_open_cache}


# SAFETY #
max-allowed-packet             = 16M
max-connect-errors             = 1000000

# DATA STORAGE #
datadir                        = ${mysqlDataLocation}

# LOGGING #
log-error                      = ${mysqlDataLocation}/mysql-error.log

${binlog}

${replica}

EOF

    log "Info" "create my.cnf file at ${my_cnf_location} completed."

}


create_lib_link(){
    local lib=${1}
    if [ ! -s "/usr/lib64/$lib" ] && [ ! -s "/usr/lib/$lib" ]; then
        libdir=$(find /usr/lib /usr/lib64 -name "$lib" | awk 'NR==1{print}')
        if [ "$libdir" != "" ]; then
            if is_64bit; then
                mkdir /usr/lib64
                ln -s ${libdir} /usr/lib64/${lib}
                ln -s ${libdir} /usr/lib/${lib}
            else
                ln -s ${libdir} /usr/lib/${lib}
            fi
        fi
    fi
    if is_64bit; then
        [ ! -d /usr/lib64 ] && mkdir /usr/lib64
        [ ! -s "/usr/lib64/$lib" ] && [ -s "/usr/lib/$lib" ] && ln -s /usr/lib/${lib}  /usr/lib64/${lib}
        [ ! -s "/usr/lib/$lib" ] && [ -s "/usr/lib64/$lib" ] && ln -s /usr/lib64/${lib} /usr/lib/${lib}
    fi
}

create_lib64_dir(){
    local dir=${1}
    if is_64bit; then
        if [ -s "$dir/lib/" ] && [ ! -s  "$dir/lib64/" ]; then
            cd ${dir}
            ln -s lib lib64
        fi
    fi
}

error_detect_depends(){
    local command=${1}
    local work_dir=`pwd`
    local depend=`echo "$1" | awk '{print $4}'`
    log "Info" "Starting to install package ${depend}"
    ${command} > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        distro=`get_opsy`
        version=`cat /proc/version`
        architecture=`uname -m`
        mem=`free -m`
        disk=`df -ah`
        cat >> ${cur_dir}/lamp.log<<EOF
        Errors Detail:
        Distributions:${distro}
        Architecture:${architecture}
        Version:${version}
        Memery:
        ${mem}
        Disk:
        ${disk}
        Issue:failed to install ${depend}
EOF
        echo
        echo "+------------------+"
        echo "|  ERROR DETECTED  |"
        echo "+------------------+"
        echo "Installation package ${depend} failed."
        echo "The Full Log is available at ${cur_dir}/lamp.log"
        echo "Please visit website: https://lamp.sh/faq.html for help"
        exit 1
    fi
}

error_detect(){
    local command=${1}
    local work_dir=`pwd`
    local cur_soft=`echo ${work_dir#$cur_dir} | awk -F'/' '{print $3}'`
    ${command}
    if [ $? -ne 0 ]; then
        distro=`get_opsy`
        version=`cat /proc/version`
        architecture=`uname -m`
        mem=`free -m`
        disk=`df -ah`
        cat >>${cur_dir}/lamp.log<<EOF
        Errors Detail:
        Distributions:$distro
        Architecture:$architecture
        Version:$version
        Memery:
        ${mem}
        Disk:
        ${disk}
        PHP Version: $php
        PHP compile parameter: ${php_configure_args}
        Issue:failed to install ${cur_soft}
EOF
        echo
        echo "+------------------+"
        echo "|  ERROR DETECTED  |"
        echo "+------------------+"
        echo "Installation ${cur_soft} failed."
        echo "The Full Log is available at ${cur_dir}/lamp.log"
        echo "Please visit website: https://lamp.sh/faq.html for help"
        exit 1
    fi
}

upcase_to_lowcase(){
    echo ${1} | tr '[A-Z]' '[a-z]'
}

untar(){
    local tarball_type
    local cur_dir=`pwd`
    if [ -n ${1} ]; then
        software_name=`echo $1 | awk -F/ '{print $NF}'`
        tarball_type=`echo $1 | awk -F. '{print $NF}'`
        wget -c -t3 -T3 ${1} -P ${cur_dir}/
        if [ $? -ne 0 ]; then
            rm -rf ${cur_dir}/${software_name}
            wget -c -t3 -T60 ${2} -P ${cur_dir}/
            software_name=`echo ${2} | awk -F/ '{print $NF}'`
            tarball_type=`echo ${2} | awk -F. '{print $NF}'`
        fi
    else
        software_name=`echo ${2} | awk -F/ '{print $NF}'`
        tarball_type=`echo ${2} | awk -F. '{print $NF}'`
        wget -c -t3 -T3 ${2} -P ${cur_dir}/ || exit
    fi
    extracted_dir=`tar tf ${cur_dir}/${software_name} | tail -n 1 | awk -F/ '{print $1}'`
    case ${tarball_type} in
        gz|tgz)
            tar zxf ${cur_dir}/${software_name} -C ${cur_dir}/ && cd ${cur_dir}/${extracted_dir} || return 1
        ;;
        bz2|tbz)
            tar jxf ${cur_dir}/${software_name} -C ${cur_dir}/ && cd ${cur_dir}/${extracted_dir} || return 1
        ;;
        xz)
            tar Jxf ${cur_dir}/${software_name} -C ${cur_dir}/ && cd ${cur_dir}/${extracted_dir} || return 1
        ;;
        tar|Z)
            tar xf ${cur_dir}/${software_name} -C ${cur_dir}/ && cd ${cur_dir}/${extracted_dir} || return 1
        ;;
        *)
        echo "${software_name} is wrong tarball type ! "
    esac
}

version_lt(){
    test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" != "$1"
}

version_gt(){
    test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"
}

version_le(){
    test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" == "$1"
}

version_ge(){
    test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"
}

versionget(){
    if [[ -s /etc/redhat-release ]]; then
        grep -oE  "[0-9.]+" /etc/redhat-release
    else
        grep -oE  "[0-9.]+" /etc/issue
    fi
}

centosversion(){
    if check_sys sysRelease centos; then
        local code=${1}
        local version="$(versionget)"
        local main_ver=${version%%.*}
        if [ "$main_ver" == "$code" ]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

debianversion(){
    if check_sys sysRelease debian;then
        local version=$( get_opsy )
        local code=${1}
        local main_ver=$( echo ${version} | sed 's/[^0-9]//g')
        if [ "${main_ver}" == "${code}" ];then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

ubuntuversion(){
    if check_sys sysRelease ubuntu;then
        local version=$( get_opsy )
        local code=${1}
        echo ${version} | grep -q "${code}"
        if [ $? -eq 0 ]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

parallel_make(){
    local para="${1}"
    cpunum=`cat /proc/cpuinfo |grep 'processor'|wc -l`

    if [ ${parallel_compile} -eq 0 ]; then
        cpunum=1
    fi

    if [ ${cpunum} -eq 1 ]; then
        [ "${para}" == "" ] && make || make "${para}"
    else
        [ "${para}" == "" ] && make -j${cpunum} || make -j${cpunum} "${para}"
    fi
}

boot_start(){
    if check_sys packageManager apt; then
        update-rc.d -f ${1} defaults
    elif check_sys packageManager yum; then
        chkconfig --add ${1}
        chkconfig ${1} on
    fi
}

boot_stop(){
    if check_sys packageManager apt; then
        update-rc.d -f ${1} remove
    elif check_sys packageManager yum; then
        chkconfig ${1} off
        chkconfig --remove ${1}
    fi
}

filter_location(){
    local location=${1}
    if ! echo ${location} | grep -q "^/"; then
        while true
        do
            read -p "Input error, please input location again: " location
            echo ${location} | grep -q "^/" && echo ${location} && break
        done
    else
        echo ${location}
    fi
}

download_file(){
    local cur_dir=`pwd`
    local url="${download_root_url}/${1}"
    if [ -s ${1} ]; then
        log "Info" "${1} [found]"
    else
        log "Info" "${1} not found, download now..."
        wget -cq -t3 -T60 ${url}
        if [ $? -eq 0 ]; then
            log "Info" "${1} download completed..."
        else
            log "Error" "Failed to download ${1}, please download it to ${cur_dir} directory manually and try again."
            exit 1
        fi
    fi
}

download_from_url(){
    local filename=${1}
    local cur_dir=`pwd`
    if [ -s ${filename} ]; then
        log "Info" "${filename} [found]"
    else
        log "Info" "${filename} not found, download now..."
        wget -cq -t3 -T3 ${2}
        if [ $? -eq 0 ]; then
            log "Info" "${filename} download completed..."
        else
            rm -f ${filename}
            log "Info" "${filename} download failed, retrying download from backup site..."
            wget -cq -t3 -T60 ${3}
            if [ $? -eq 0 ]; then
                log "Info" "${filename} download completed..."
            else
                log "Error" "Failed to download ${filename}, please download it to ${cur_dir} directory manually and try again."
                exit 1
            fi
        fi
    fi
}

is_64bit(){
    if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ]; then
        return 0
    else
        return 1
    fi
}

is_digit(){
    local input=${1}
    if [[ "$input" =~ ^[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

if_in_array(){
    local element=${1}
    local array=${2}
    for i in ${array}
    do
        if [ "$i" == "$element" ]; then
            return 0
        fi
    done
    return 1
}

add_to_env(){
    local location=${1}
    cd ${location} && [ ! -d lib ] && [ -d lib64 ] && ln -s lib64 lib
    [ -d "${location}/lib" ] && export LD_LIBRARY_PATH=${location}/lib:${LD_LIBRARY_PATH}
    [ -d "${location}/bin" ] && export PATH=${location}/bin:${PATH}
    [ -d "${location}/include" ] && export CPPFLAGS="-I${location}/include $CPPFLAGS"
}

firewall_set(){
    log "Info" "Starting set Firewall..."

    if centosversion 6; then
        if [ -e /etc/init.d/iptables ]; then
            /etc/init.d/iptables status > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                iptables -L -n | grep -qi 80
                if [ $? -ne 0 ]; then
                    iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
                fi
                iptables -L -n | grep -qi 443
                if [ $? -ne 0 ]; then
                    iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
                fi
                /etc/init.d/iptables save > /dev/null 2>&1
                /etc/init.d/iptables restart > /dev/null 2>&1
            else
                log "Warning" "iptables looks like not running, please manually set if necessary."
            fi
        else
            log "Warning" "iptables looks like not installed."
        fi
    elif centosversion 7; then
        systemctl status firewalld > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            firewall-cmd --permanent --zone=public --add-service=http > /dev/null 2>&1
            firewall-cmd --permanent --zone=public --add-service=https > /dev/null 2>&1
            firewall-cmd --reload > /dev/null 2>&1
        else
            log "Warning" "firewalld looks like not running, please manually set if necessary."
        fi
    fi
    log "Info" "Firewall set completed..."
}

remove_packages(){
    log "Info" "Starting remove the conflict packages..."
    if check_sys packageManager apt; then
        apt-get -y remove --purge apache2 apache2-* &> /dev/null
        apt-get -y remove --purge mysql-client mysql-server mysql-common libmysqlclient18 &> /dev/null
        apt-get -y remove --purge php5 php5-* &> /dev/null
    elif check_sys packageManager yum; then
        yum -y remove httpd-* &> /dev/null
        yum -y remove mysql-* &> /dev/null
        yum -y remove php-* &> /dev/null
    fi
    log "Info" "Remove the conflict packages completed..."
}

sync_time(){
    log "Info" "Starting to sync time..."
    if check_sys packageManager apt; then
        apt-get -y update > /dev/null 2>&1
        apt-get -y install ntpdate > /dev/null 2>&1
    elif check_sys packageManager yum; then
        yum -y install ntp > /dev/null 2>&1
    fi
    check_command_exist ntpdate
    ntpdate -d cn.pool.ntp.org > /dev/null 2>&1
    rm -f /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    hwclock -w > /dev/null 2>&1
    log "Info" "Sync time completed..."
}

#Last confirm
last_confirm(){
    clear
    echo
    echo "------------------------- Install Overview --------------------------"
    echo
    echo "Apache: ${apache}"
    [ "${apache}" != "do_not_install" ] && echo "Apache Location: ${apache_location}"
    echo
    if [ "${mysql}" == "${mysql5_5_filename}" ] || [ "${mysql}" == "${mysql5_6_filename}" ] || [ "${mysql}" == "${mysql5_7_filename}" ]; then
        echo "MySQL: ${mysql}"
        echo "MySQL Location: ${mysql_location}"
        echo "MySQL Data Location: ${mysql_data_location}"
        echo "MySQL Root Password: ${mysql_root_pass}"
    elif [ "${mysql}" == "${mariadb5_5_filename}" ] || [ "${mysql}" == "${mariadb10_0_filename}" ] || [ "${mysql}" == "${mariadb10_1_filename}" ]; then
        echo "MariaDB: ${mysql}"
        echo "MariaDB Location: ${mariadb_location}"
        echo "MariaDB Data Location: ${mariadb_data_location}"
        echo "MariaDB Root Password: ${mariadb_root_pass}"
    elif [ "${mysql}" == "${percona5_5_filename}" ] || [ "${mysql}" == "${percona5_6_filename}" ] || [ "${mysql}" == "${percona5_7_filename}" ]; then
        echo "Percona: ${mysql}"
        echo "Percona Location: ${percona_location}"
        echo "Percona Data Location: ${percona_data_location}"
        echo "Percona Root Password: ${percona_root_pass}"
    fi
    echo
    echo "PHP: ${php}"
    [ "${php}" != "do_not_install" ] && echo "PHP Location: ${php_location}"
    if [ "${php_modules_install}" != "do_not_install" ]; then
        echo "PHP Additional Modules:"
        for m in ${php_modules_install[@]}
        do
            echo "${m}"
        done
    fi
    echo
    echo "phpMyAdmin: ${phpmyadmin}"
    [ "${phpmyadmin}" != "do_not_install" ] && echo "phpMyAdmin Location: ${web_root_dir}/phpmyadmin"
    echo
    echo "---------------------------------------------------------------------"
    echo

    echo "Press any key to start...or Press Ctrl+C to cancel"
    echo
    char=`get_char`

    sync_time

    StartDate=$(date "+%Y-%m-%d %H:%M:%S")
    StartDateSecond=$(date +%s)
    log "Info" "Start time: ${StartDate}"

    if [ -d ${cur_dir}/software ]; then
        rm -rf ${cur_dir}/software/*
    else
        mkdir -p ${cur_dir}/software
    fi

}

#Finally to do
finally(){
    log "Info" "Starting clean up..."
    cd ${cur_dir}
    rm -rf ${cur_dir}/software
    log "Info" "Clean up completed..."

    if check_sys packageManager yum; then
        firewall_set
    fi

    echo
    echo "Congratulations, LAMP install completed!"
    echo
    echo "------------------------ Installed Overview -------------------------"
    echo
    echo "Default Website: http://$(get_ip)"
    echo "Apache: ${apache}"
    if [ "${apache}" != "do_not_install" ]; then
        echo "Apache Location: ${apache_location}"
    fi
    echo
    if [ -d ${mysql_location} ]; then
        echo "MySQL Server: ${mysql}"
        echo "MySQL Location: ${mysql_location}"
        echo "MySQL Data Location: ${mysql_data_location}"
        echo "MySQL Root Password: ${mysql_root_pass}"
        dbrootpwd=${mysql_root_pass}
    elif [ -d ${mariadb_location} ]; then
        echo "MariaDB Server: ${mysql}"
        echo "MariaDB Location: ${mariadb_location}"
        echo "MariaDB Data Location: ${mariadb_data_location}"
        echo "MariaDB Root Password: ${mariadb_root_pass}"
        dbrootpwd=${mariadb_root_pass}
    elif [ -d ${percona_location} ]; then
        echo "Percona Server: ${mysql}"
        echo "Percona Location: ${percona_location}"
        echo "Percona Data Location: ${percona_data_location}"
        echo "Percona Root Password: ${percona_root_pass}"
        dbrootpwd=${percona_root_pass}
    fi
    echo
    echo "PHP: ${php}"
    if [ "${php}" != "do_not_install" ]; then
        echo "PHP Location: ${php_location}"
    fi
    echo
    echo "PHP Modules: ${php_modules_install}"
    echo
    echo "phpMyAdmin: ${phpmyadmin}"
    [ "${phpmyadmin}" != "do_not_install" ] && echo "phpMyAdmin Location: ${web_root_dir}/phpmyadmin"
    echo
    echo "---------------------------------------------------------------------"
    echo

    cp -f ${cur_dir}/conf/lamp /usr/bin/lamp
    chmod +x /usr/bin/lamp
    sed -i "s@^apache_location=.*@apache_location=${apache_location}@" /usr/bin/lamp
    sed -i "s@^mysql_location=.*@mysql_location=${mysql_location}@" /usr/bin/lamp
    sed -i "s@^mariadb_location=.*@mariadb_location=${mariadb_location}@" /usr/bin/lamp
    sed -i "s@^percona_location=.*@percona_location=${percona_location}@" /usr/bin/lamp

    if [ "${apache}" != "do_not_install" ]; then
        echo "Starting Apache..."
        /etc/init.d/httpd start > /dev/null 2>&1
    fi
    if [ "${mysql}" != "do_not_install" ]; then
        echo "Starting Database..."
        /etc/init.d/mysqld start > /dev/null 2>&1
    fi
    if if_in_array "${php_memcached_filename}" "${php_modules_install}"; then
        echo "Starting Memcached..." 
        /etc/init.d/memcached start > /dev/null 2>&1
    fi
    if [[ "${php}" == "${php7_0_filename}" || "$php" == "${php7_1_filename}" ]]; then
        if if_in_array "${php_redis_filename2}" "${php_modules_install}"; then
            echo "Starting Redis-server..."
            /etc/init.d/redis-server start > /dev/null 2>&1
        fi
    else
        if if_in_array "${php_redis_filename}" "${php_modules_install}"; then
            echo "Starting Redis-server..."
            /etc/init.d/redis-server start > /dev/null 2>&1
        fi
    fi

    # Install phpmyadmin database
    if [ -d "${web_root_dir}/phpmyadmin" ]; then
        /usr/bin/mysql -uroot -p${dbrootpwd} < ${web_root_dir}/phpmyadmin/sql/create_tables.sql > /dev/null 2>&1
    fi
    sleep 3
    netstat -nxtlp

    echo
    echo "Start time     : ${StartDate}"
    echo -e "Completion time: $(date "+%Y-%m-%d %H:%M:%S") (Use:${RED} $[($(date +%s)-StartDateSecond)/60]${PLAIN} minutes)"
    echo "Welcome to visit our website: https://lamp.sh"
    echo "Enjoy it"

    exit 0
}

#Install tools
install_tool(){
    log "Info" "Starting to install tools..."
    if check_sys packageManager apt; then
        apt-get -y install gcc g++ make wget perl curl bzip2 libreadline-dev net-tools python python-dev > /dev/null 2>&1
    elif check_sys packageManager yum; then
        yum -y install gcc gcc-c++ make wget perl curl bzip2 readline readline-devel net-tools python python-devel > /dev/null 2>&1
    fi
    log "Info" "Install tools completed..."

    check_command_exist "gcc"
    check_command_exist "g++"
    check_command_exist "make"
    check_command_exist "wget"
    check_command_exist "perl"
    check_command_exist "netstat"
}

#start install lamp
install_lamp(){
    last_confirm
    disable_selinux
    install_tool
    remove_packages

    [ "${apache}" != "do_not_install" ] && check_installed "install_apache" "${apache_location}"
    if [ "${mysql}" == "${mysql5_5_filename}" ] || [ "${mysql}" == "${mysql5_6_filename}" ] || [ "${mysql}" == "${mysql5_7_filename}" ];then
        check_installed "install_mysqld" "${mysql_location}"
    elif [ "${mysql}" == "${mariadb5_5_filename}" ] || [ "${mysql}" == "${mariadb10_0_filename}" ] || [ "${mysql}" == "${mariadb10_1_filename}" ];then
        check_installed "install_mariadb" "${mariadb_location}"
    elif [ "${mysql}" == "${percona5_5_filename}" ] || [ "${mysql}" == "${percona5_6_filename}" ] || [ "${mysql}" == "${percona5_7_filename}" ];then
        check_installed "install_percona" "${percona_location}"
    fi
    [ "${php}" != "do_not_install" ] && check_installed "install_php" "${php_location}"
    [ "${phpmyadmin}" != "do_not_install" ] && install_phpmyadmin
    [ "${php_modules_install}" != "do_not_install" ] && install_php_modules "${phpConfig}"

    finally
}

#Pre-installation
preinstall_lamp(){
    check_ram
    display_os_info
    apache_preinstall_settings
    mysql_preinstall_settings
    php_preinstall_settings
    php_modules_preinstall_settings
    phpmyadmin_preinstall_settings
}

#Pre-installation settings
pre_setting(){
    if check_sys packageManager yum || check_sys packageManager apt; then
        # Not support CentOS 5 & Debian 6
        if centosversion 5 || debianversion 6; then
            log "Error" "Not supported OS, please change to CentOS 6+ or Debian 7+ or Ubuntu 12+ and try again."
            exit 1
        fi
        preinstall_lamp
        install_lamp
    else
        log "Error" "Not supported OS, please change to CentOS 6+ or Debian 7+ or Ubuntu 12+ and try again."
        exit 1
    fi
}
