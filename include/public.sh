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

_red(){
    printf '\033[1;31;31m%b\033[0m' "$1"
}

_green(){
    printf '\033[1;31;32m%b\033[0m' "$1"
}

_yellow(){
    printf '\033[1;31;33m%b\033[0m' "$1"
}

_printargs(){
    printf -- "%s" "$1"
    printf "\n"
}

_info(){
    _printargs "$@"
}

_warn(){
    _yellow "$1"
    printf "\n"
}

_error(){
    _red "$1"
    printf "\n"
    exit 1
}

rootness(){
    if [[ ${EUID} -ne 0 ]]; then
        _error "This script must be run as root"
    fi
}

generate_password(){
    cat /dev/urandom | head -1 | md5sum | head -c 8
}

get_ip(){
    local ipv4=$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | \
    egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )
    [ -z "${ipv4}" ] && ipv4=$( wget -qO- -t1 -T2 ipv4.icanhazip.com )
    [ -z "${ipv4}" ] && ipv4=$( wget -qO- -t1 -T2 ipinfo.io/ip )
    printf -- "%s" "${ipv4}"
}

get_ip_country(){
    local country=$( wget -qO- -t1 -T2 ipinfo.io/$(get_ip)/country )
    printf -- "%s" "${country}"
}

get_libc_version(){
    getconf -a | grep GNU_LIBC_VERSION | awk '{print $NF}'
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
    local phpConfig="$1"
    ${phpConfig} --extension-dir
}

get_php_version(){
    local phpConfig="$1"
    ${phpConfig} --version | cut -d'.' -f1-2
}

get_char(){
    SAVEDSTTY=$(stty -g)
    stty -echo
    stty cbreak
    dd if=/dev/tty bs=1 count=1 2> /dev/null
    stty -raw
    stty echo
    stty ${SAVEDSTTY}
}

get_valid_valname(){
    local val="$1"
    local new_val=$(eval echo $val | sed 's/[-.]/_/g')
    echo ${new_val}
}

get_hint(){
    local val="$1"
    local new_val=$(get_valid_valname $val)
    eval echo "\$hint_${new_val}"
}

set_hint(){
    local val="$1"
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
    local soft="$1"
    local default="$2"
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
            _info "$(_green ${i}). $hint"
        done
        echo
        read -p "${prompt}" pick
        if [[ "$pick" == "" && "$default" != "" ]]; then
            pick=${default}
            break
        fi

        if ! is_digit "$pick"; then
            prompt="Input error, please only input a number: "
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
    local soft="$1"
    local default="$2"
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

    echo -e "\n-------------------------- ${soft} install --------------------------\n"
    for ((i=1;i<=${arr_len};i++ )); do
        vname="$(get_valid_valname ${arr[$i-1]})"
        hint="$(get_hint $vname)"
        [[ "$hint" == "" ]] && hint="${arr[$i-1]}"
        _info "$(_green ${i}). $hint"
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
                echo "Input error, please only input a number."
                correct=false
                break 1
            fi
            if [[ "$j" -lt 1 || "$j" -gt ${arr_len} ]]; then
                echo "Input error, please input one or more number between 1 and ${arr_len}${default_prompt}."
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
    echo "| Auto Install LAMP(Linux + Apache + MySQL/MariaDB + PHP )          |"
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

check_installed(){
    local cmd="$1"
    local location="$2"
    if [ -d "${location}" ]; then
        _info "${location} already exists, skipped the installation."
        add_to_env "${location}"
    else
        ${cmd}
    fi
}

check_os(){
    is_support_flg=0
    if check_sys packageManager yum || check_sys packageManager apt; then
        # Not support CentOS prior to 6 & Debian prior to 8 & Ubuntu prior to 14 versions
        if [ -n "$(get_centosversion)" ] && [ $(get_centosversion) -lt 6 ]; then
            is_support_flg=1
        fi
        if [ -n "$(get_debianversion)" ] && [ $(get_debianversion) -lt 8 ]; then
            is_support_flg=1
        fi
        if [ -n "$(get_ubuntuversion)" ] && [ $(get_ubuntuversion) -lt 14 ]; then
            is_support_flg=1
        fi
    else
        is_support_flg=1
    fi
    if [ ${is_support_flg} -eq 1 ]; then
        _error "Not supported OS, please change OS to CentOS 6+ or Debian 8+ or Ubuntu 14+ and try again."
    fi
}

check_ram(){
    get_os_info
    if [ ${ramsum} -lt 480 ]; then
        _error "Not enough memory. The LAMP installation needs memory: ${tram}MB*RAM + ${swap}MB*SWAP >= 480MB"
    fi
    [ ${ramsum} -lt 600 ] && disable_fileinfo="--disable-fileinfo" || disable_fileinfo=""
}

#Check system
check_sys(){
    local checkType="$1"
    local value="$2"
    local release=''
    local systemPackage=''
    if [[ -f /etc/redhat-release ]]; then
        release="centos"
        systemPackage="yum"
    elif grep -Eqi "debian" /etc/issue; then
        release="debian"
        systemPackage="apt"
    elif grep -Eqi "ubuntu" /etc/issue; then
        release="ubuntu"
        systemPackage="apt"
    elif grep -Eqi "centos|red hat|redhat" /etc/issue; then
        release="centos"
        systemPackage="yum"
    elif grep -Eqi "debian" /proc/version; then
        release="debian"
        systemPackage="apt"
    elif grep -Eqi "ubuntu" /proc/version; then
        release="ubuntu"
        systemPackage="apt"
    elif grep -Eqi "centos|red hat|redhat" /proc/version; then
        release="centos"
        systemPackage="yum"
    fi

    if [[ "${checkType}" == "sysRelease" ]]; then
        if [ "${value}" == "${release}" ]; then
            return 0
        else
            return 1
        fi
    elif [[ "${checkType}" == "packageManager" ]]; then
        if [ "${value}" == "${systemPackage}" ]; then
            return 0
        else
            return 1
        fi
    fi
}

create_lib_link(){
    local lib="$1"
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
    local dir="$1"
    if is_64bit; then
        if [ -s "$dir/lib/" ] && [ ! -s  "$dir/lib64/" ]; then
            cd ${dir}
            ln -s lib lib64
        fi
    fi
}

error_detect_depends(){
    local command="$1"
    local work_dir=$(pwd)
    local depend=$(echo "$1" | awk '{print $4}')
    _info "Installing package ${depend}"
    ${command} > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        distro=$(get_opsy)
        version=$(cat /proc/version)
        architecture=$(uname -m)
        mem=$(free -m)
        disk=$(df -ah)
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
    local command="$1"
    local work_dir=$(pwd)
    local cur_soft=$(echo ${work_dir#$cur_dir} | awk -F'/' '{print $3}')
    ${command}
    if [ $? -ne 0 ]; then
        distro=$(get_opsy)
        version=$(cat /proc/version)
        architecture=$(uname -m)
        mem=$(free -m)
        disk=$(df -ah)
        cat >>${cur_dir}/lamp.log<<EOF
        Errors Detail:
        Distributions:${distro}
        Architecture:${architecture}
        Version:${version}
        Memery:
        ${mem}
        Disk:
        ${disk}
        PHP Version: ${php}
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
    local cur_dir=$(pwd)
    if [ -n ${1} ]; then
        software_name=$(echo $1 | awk -F/ '{print $NF}')
        tarball_type=$(echo $1 | awk -F. '{print $NF}')
        wget --no-check-certificate -cv -t3 -T60 ${1} -P ${cur_dir}/
        if [ $? -ne 0 ]; then
            rm -rf ${cur_dir}/${software_name}
            wget --no-check-certificate -cv -t3 -T60 ${2} -P ${cur_dir}/
            software_name=$(echo ${2} | awk -F/ '{print $NF}')
            tarball_type=$(echo ${2} | awk -F. '{print $NF}')
        fi
    else
        software_name=$(echo ${2} | awk -F/ '{print $NF}')
        tarball_type=$(echo ${2} | awk -F. '{print $NF}')
        wget --no-check-certificate -cv -t3 -T60 ${2} -P ${cur_dir}/ || exit
    fi
    extracted_dir=$(tar tf ${cur_dir}/${software_name} | tail -n 1 | awk -F/ '{print $1}')
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

get_centosversion(){
    if check_sys sysRelease centos; then
        local version="$(versionget)"
        echo ${version%%.*}
    else
        echo ""
    fi
}

debianversion(){
    if check_sys sysRelease debian; then
        local version=$( get_opsy )
        local code=${1}
        local main_ver=$( echo ${version} | sed 's/[^0-9]//g')
        if [ "${main_ver}" == "${code}" ]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

get_debianversion(){
    if check_sys sysRelease debian; then
        local version=$( get_opsy )
        local main_ver=$( echo ${version} | grep -oE  "[0-9.]+")
        echo ${main_ver%%.*}
    else
        echo ""
    fi
}

ubuntuversion(){
    if check_sys sysRelease ubuntu; then
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

get_ubuntuversion(){
    if check_sys sysRelease ubuntu; then
        local version=$( get_opsy )
        local main_ver=$( echo ${version} | grep -oE  "[0-9.]+")
        echo ${main_ver%%.*}
    else
        echo ""
    fi
}

parallel_make(){
    local para="$1"
    cpunum=$(cat /proc/cpuinfo | grep 'processor' | wc -l)

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
        update-rc.d -f "$1" defaults
    elif check_sys packageManager yum; then
        chkconfig --add "$1"
        chkconfig "$1" on
    fi
}

boot_stop(){
    if check_sys packageManager apt; then
        update-rc.d -f "$1" remove
    elif check_sys packageManager yum; then
        chkconfig "$1" off
        chkconfig --del "$1"
    fi
}

filter_location(){
    local location="$1"
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

# Download a file
# $1: file name
# $2: primary url
download_file(){
    local cur_dir=$(pwd)
    if [ -s "$1" ]; then
        _info "$1 [found]"
    else
        _info "$1 not found, download now..."
        wget --no-check-certificate -cv -t3 -T60 -O ${1} ${2}
        if [ $? -eq 0 ]; then
            _info "$1 download completed..."
        else
            rm -f "$1"
            _info "$1 download failed, retrying download from secondary url..."
            wget --no-check-certificate -cv -t3 -T60 -O "$1" "${download_root_url}${1}"
            if [ $? -eq 0 ]; then
                _info "$1 download completed..."
            else
                _error "Failed to download $1, please download it to ${cur_dir} directory manually and try again."
            fi
        fi
    fi
}

is_64bit(){
    if [ $(getconf WORD_BIT) = '32' ] && [ $(getconf LONG_BIT) = '64' ]; then
        return 0
    else
        return 1
    fi
}

is_digit(){
    local input="$1"
    if [[ "$input" =~ ^[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

is_exist(){
    local cmd="$1"
    if eval type type > /dev/null 2>&1; then
        eval type "$cmd" > /dev/null 2>&1
    elif command > /dev/null 2>&1; then
        command -v "$cmd" > /dev/null 2>&1
    else
        which "$cmd" > /dev/null 2>&1
    fi
    local rt=$?
    return ${rt}
}

if_in_array(){
    local element="$1"
    local array="$2"
    for i in ${array}
    do
        if [ "$i" == "$element" ]; then
            return 0
        fi
    done
    return 1
}

add_to_env(){
    local location="$1"
    cd ${location} && [ ! -d lib ] && [ -d lib64 ] && ln -s lib64 lib
    [ -d "${location}/lib" ] && export LD_LIBRARY_PATH=${location}/lib:${LD_LIBRARY_PATH}
    [ -d "${location}/bin" ] && export PATH=${location}/bin:${PATH}
    [ -d "${location}/include" ] && export CPPFLAGS="-I${location}/include $CPPFLAGS"
}

firewall_set(){
    _info "Setting Firewall..."
    if centosversion 6; then
        if [ -e /etc/init.d/iptables ]; then
            if /etc/init.d/iptables status > /dev/null 2>&1; then
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
                _warn "iptables looks like not running, please manually set if necessary."
            fi
        else
            _warn "iptables looks like not installed."
        fi
    else
        if systemctl status firewalld > /dev/null 2>&1; then
            default_zone="$(firewall-cmd --get-default-zone)"
            firewall-cmd --permanent --zone=${default_zone} --add-service=http > /dev/null 2>&1
            firewall-cmd --permanent --zone=${default_zone} --add-service=https > /dev/null 2>&1
            firewall-cmd --reload > /dev/null 2>&1
        else
            _warn "firewalld looks like not running, please manually set if necessary."
        fi
    fi
    _info "Set Firewall completed..."
}

remove_packages(){
    _info "Removing the conflict packages..."
    if check_sys packageManager apt; then
        [ "${apache}" != "do_not_install" ] && apt-get -y remove --purge apache2 apache2-* &> /dev/null
        [ "${mysql}" != "do_not_install" ] && apt-get -y remove --purge mysql-client mysql-server mysql-common libmysqlclient18 &> /dev/null
        [ "${php}" != "do_not_install" ] && apt-get -y remove --purge php5 php5-* php7.0 php7.0-* php7.1 php7.1-* php7.2 php7.2-* php7.3 php7.3-* php7.4 php7.4-* &> /dev/null
    elif check_sys packageManager yum; then
        [ "${apache}" != "do_not_install" ] && yum -y remove httpd-* &> /dev/null
        [ "${mysql}" != "do_not_install" ] && yum -y remove mysql-* &> /dev/null
        [ "${php}" != "do_not_install" ] && yum -y remove php-* libzip-devel libzip &> /dev/null
    fi
    _info "Remove the conflict packages completed..."
}

sync_time(){
    _info "Sync time..."
    is_exist "ntpdate" && ntpdate -bv cn.pool.ntp.org
    rm -fv /etc/localtime
    ln -sv /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    _info "Sync time completed..."
    StartDate=$(date "+%Y-%m-%d %H:%M:%S")
    StartDateSecond=$(date +%s)
    _info "Start time: ${StartDate}"
}

start_install(){
    echo "Press any key to start...or Press Ctrl+C to cancel"
    echo
    char=$(get_char)
}

#Last confirm
last_confirm(){
    clear
    echo
    echo "------------------------- Install Overview --------------------------"
    echo
    echo "Apache: ${apache}"
    [ "${apache}" != "do_not_install" ] && echo "Apache Location: ${apache_location}"
    if [ "${apache_modules_install}" != "do_not_install" ]; then
        echo "Apache Additional Modules:"
        for a in ${apache_modules_install[@]}
        do
            echo "${a}"
        done
    else
        echo "Apache Additional Modules: do_not_install"
    fi
    echo
    echo "Database: ${mysql}"
    if echo "${mysql}" | grep -qi "mysql"; then
        echo "MySQL Location: ${mysql_location}"
        echo "MySQL Data Location: ${mysql_data_location}"
        echo "MySQL Root Password: ${mysql_root_pass}"
    elif echo "${mysql}" | grep -qi "mariadb"; then
        echo "MariaDB Location: ${mariadb_location}"
        echo "MariaDB Data Location: ${mariadb_data_location}"
        echo "MariaDB Root Password: ${mariadb_root_pass}"
    fi
    echo
    if [ "${phpmyadmin_install}" != "do_not_install" ]; then
        echo "Database Management Modules:"
        for a in ${phpmyadmin_install[@]}
        do
            echo "${a}"
        done
    else
        echo "Database Management Modules: do_not_install"
    fi
    echo
    echo "PHP: ${php}"
    [ "${php}" != "do_not_install" ] && echo "PHP Location: ${php_location}"
    if [ "${php_modules_install}" != "do_not_install" ]; then
        echo "PHP Additional Extensions:"
        for m in ${php_modules_install[@]}
        do
            echo "${m}"
        done
    else
        echo "PHP Additional Extensions: do_not_install"
    fi
    echo
    echo "KodExplorer: ${kodexplorer}"
    [ "${kodexplorer}" != "do_not_install" ] && echo "KodExplorer Location: ${web_root_dir}/kod"
    echo
    echo "---------------------------------------------------------------------"
    echo
}

#Finally to do
install_finally(){
    _info "Cleaning up..."
    cd ${cur_dir}
    rm -rf ${cur_dir}/software
    _info "Clean up completed..."

    if check_sys packageManager yum; then
        firewall_set
    fi

    echo
    echo "Congratulations, LAMP install completed!"
    echo
    echo "------------------------ Installed Overview -------------------------"
    echo
    echo "Apache: ${apache}"
    if [ "${apache}" != "do_not_install" ]; then
        echo "Default Website: http://$(get_ip)"
        echo "Apache Location: ${apache_location}"
    fi
    if [ "${apache_modules_install}" != "do_not_install" ]; then
        echo "Apache Additional Modules:"
        for a in ${apache_modules_install[@]}
        do
            echo "${a}"
        done
    else
        echo "Apache Additional Modules: do_not_install"
    fi
    echo
    echo "Database: ${mysql}"
    if [ -d ${mysql_location} ]; then
        echo "MySQL Location: ${mysql_location}"
        echo "MySQL Data Location: ${mysql_data_location}"
        echo "MySQL Root Password: ${mysql_root_pass}"
        dbrootpwd=${mysql_root_pass}
    elif [ -d ${mariadb_location} ]; then
        echo "MariaDB Location: ${mariadb_location}"
        echo "MariaDB Data Location: ${mariadb_data_location}"
        echo "MariaDB Root Password: ${mariadb_root_pass}"
        dbrootpwd=${mariadb_root_pass}
    fi
    echo
    if [ "${phpmyadmin_install}" != "do_not_install" ]; then
        echo "Database Management Modules:"
        for a in ${phpmyadmin_install[@]}
        do
            echo "${a}"
        done
    else
        echo "Database Management Modules: do_not_install"
    fi
    echo
    echo "PHP: ${php}"
    [ "${php}" != "do_not_install" ] && echo "PHP Location: ${php_location}"
    if [ "${php_modules_install}" != "do_not_install" ]; then
        echo "PHP Additional Extensions:"
        for m in ${php_modules_install[@]}
        do
            echo "${m}"
        done
    else
        echo "PHP Additional Extensions: do_not_install"
    fi
    echo
    echo "KodExplorer: ${kodexplorer}"
    [ "${kodexplorer}" != "do_not_install" ] && echo "KodExplorer Location: ${web_root_dir}/kod"
    echo
    echo "---------------------------------------------------------------------"
    echo

    cp -f ${cur_dir}/conf/lamp /usr/bin/lamp
    chmod +x /usr/bin/lamp
    sed -i "s@^apache_location=.*@apache_location=${apache_location}@" /usr/bin/lamp
    sed -i "s@^mysql_location=.*@mysql_location=${mysql_location}@" /usr/bin/lamp
    sed -i "s@^mariadb_location=.*@mariadb_location=${mariadb_location}@" /usr/bin/lamp
    sed -i "s@^web_root_dir=.*@web_root_dir=${web_root_dir}@" /usr/bin/lamp
    ldconfig
    # Add phpmyadmin Alias
    if [[ -d "${web_root_dir}/phpmyadmin" ]]; then
        if [[ $(grep -Ec "^\s*Alias /phpmyadmin" ${apache_location}/conf/httpd.conf) -eq 0 ]]; then
            cat >> ${apache_location}/conf/httpd.conf <<EOF
<IfModule alias_module>
    Alias /phpmyadmin ${web_root_dir}/phpmyadmin
</IfModule>
EOF
        fi
    fi
    # Add kodexplorer Alias
    if [[ -d "${web_root_dir}/kod" ]]; then
        if [[ $(grep -Ec "^\s*Alias /kod" ${apache_location}/conf/httpd.conf) -eq 0 ]]; then
            cat >> ${apache_location}/conf/httpd.conf <<EOF
<IfModule alias_module>
    Alias /kod ${web_root_dir}/kod
</IfModule>
EOF
        fi
    fi
    if [ "${apache}" != "do_not_install" ]; then
        echo "Starting Apache..."
        /etc/init.d/httpd start > /dev/null 2>&1
    fi
    if [ "${mysql}" != "do_not_install" ]; then
        echo "Starting Database..."
        /etc/init.d/mysqld start > /dev/null 2>&1
    fi
    if if_in_array "${php_memcached_filename}" "${php_modules_install}" || if_in_array "${php_memcached_filename2}" "${php_modules_install}"; then
        echo "Starting Memcached..."
        /etc/init.d/memcached start > /dev/null 2>&1
    fi
    if if_in_array "${php_redis_filename}" "${php_modules_install}" || if_in_array "${php_redis_filename2}" "${php_modules_install}"; then
        echo "Starting Redis-server..."
        /etc/init.d/redis-server start > /dev/null 2>&1
    fi
    # Install phpmyadmin database
    if [ -d "${web_root_dir}/phpmyadmin" ] && [ -f "/usr/bin/mysql" ]; then
        /usr/bin/mysql -uroot -p${dbrootpwd} < ${web_root_dir}/phpmyadmin/sql/create_tables.sql > /dev/null 2>&1
    fi

    sleep 1
    netstat -tunlp
    echo
    _info "Start time     : ${StartDate}"
    _info "Completion time: $(date "+%Y-%m-%d %H:%M:%S") (Use:$(_red $[($(date +%s)-StartDateSecond)/60]) minutes)"
    _info "Welcome to visit our website: https://lamp.sh"
    _info "Enjoy it"
    exit 0
}

#Install tools
install_tools(){
    _info "Installing development tools..."
    if check_sys packageManager apt; then
        apt-get -y update > /dev/null 2>&1
        apt_tools=(tar gcc g++ make wget perl curl bzip2 libreadline-dev net-tools python python-dev cron ca-certificates ntpdate)
        for tool in ${apt_tools[@]}; do
            error_detect_depends "apt-get -y install ${tool}"
        done
    elif check_sys packageManager yum; then
        yum makecache > /dev/null 2>&1
        yum_tools=(yum-utils tar gcc gcc-c++ make wget perl curl bzip2 readline readline-devel net-tools crontabs ca-certificates)
        for tool in ${yum_tools[@]}; do
            error_detect_depends "yum -y install ${tool}"
        done
        if centosversion 6 || centosversion 7 || centosversion 8; then
            error_detect_depends "yum -y install epel-release"
            yum-config-manager --enable epel > /dev/null 2>&1
        fi
        if centosversion 8; then
            error_detect_depends "yum -y install python3-devel"
            error_detect_depends "yum -y install chrony"
            yum-config-manager --enable PowerTools > /dev/null 2>&1
        else
            error_detect_depends "yum -y install python"
            error_detect_depends "yum -y install python-devel"
            error_detect_depends "yum -y install ntpdate"
        fi
    fi
    _info "Install development tools completed..."

}

#start install lamp
lamp_install(){
    disable_selinux
    install_tools
    sync_time
    remove_packages
    [ ! -d ${cur_dir}/software ] && mkdir -p ${cur_dir}/software
    [ "${apache}" != "do_not_install" ] && check_installed "install_apache" "${apache_location}"
    [ "${apache_modules_install}" != "do_not_install" ] && install_apache_modules
    if echo "${mysql}" | grep -qi "mysql"; then
        check_installed "install_mysqld" "${mysql_location}"
    elif echo "${mysql}" | grep -qi "mariadb"; then
        check_installed "install_mariadb" "${mariadb_location}"
    fi
    [ "${php}" != "do_not_install" ] && check_installed "install_php" "${php_location}"
    [ "${phpmyadmin_install}" != "do_not_install" ] && install_phpmyadmin_modules
    [ "${kodexplorer}" != "do_not_install" ] && install_kodexplorer
    [ "${php_modules_install}" != "do_not_install" ] && install_php_modules "${phpConfig}"
    install_finally
}

#Pre-installation
lamp_preinstall(){
    apache_preinstall_settings
    mysql_preinstall_settings
    php_preinstall_settings
    php_modules_preinstall_settings
    phpmyadmin_preinstall_settings
    kodexplorer_preinstall_settings
}

#Pre-installation settings
pre_setting(){
    check_os
    check_ram
    display_os_info
    lamp_preinstall
    last_confirm
    start_install
    lamp_install
}
