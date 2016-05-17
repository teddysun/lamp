#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#=======================================================================#
#   System Required:  CentOS/RadHat 5+ / Debian 7+ / Ubuntu 12+         #
#   Description:  Update LAMP(Linux + Apache + MySQL + PHP )            #
#   Author: Teddysun <i@teddysun.com>                                   #
#   Intro:  https://lamp.sh                                             #
#=======================================================================#
cur_dir=`pwd`

[[ $EUID -ne 0 ]] && echo "Error:This script must be run as root!" && exit 1

include(){
    local include=$1
    if [[ -s ${cur_dir}/include/${include}.sh ]];then
        . ${cur_dir}/include/${include}.sh
    else
        echo "Error:${cur_dir}/include/${include}.sh not found, shell can not be executed."
        exit 1
    fi
}

include config
include public
include upgrade_apache
include upgrade_db
include upgrade_php
include upgrade_phpmyadmin


display_menu(){

    echo
    echo "#############################################################"
    echo "# Auto Update LAMP(Linux + Apache + MySQL + PHP )           #"
    echo "# Intro: https://lamp.sh                                    #"
    echo "# Author: Teddysun <i@teddysun.com>                         #"
    echo "#############################################################"
    echo
    rootness
    load_config

    while :
    do
    echo -e "\t\033[32m1\033[0m. Upgrade Apache"
    echo -e "\t\033[32m2\033[0m. Upgrade MySQL/MariaDB"
    echo -e "\t\033[32m3\033[0m. Upgrade PHP"
    echo -e "\t\033[32m4\033[0m. Upgrade phpMyAdmin"
    echo -e "\t\033[32m5\033[0m. Exit"
    echo
    read -p "Please input a number: " Number
    if [[ ! $Number =~ ^[1-5]$ ]];then
        echo "Input error! Please only input 1,2,3,4,5"
    else
        case "$Number" in
        1)
            upgrade_apache 2>&1 | tee -a /root/upgrade_apache.log
            ;;
        2)
            upgrade_db 2>&1 | tee -a /root/upgrade_db.log
            ;;
        3)
            upgrade_php 2>&1 | tee -a /root/upgrade_php.log
            ;;
        4)
            upgrade_phpmyadmin 2>&1 | tee -a /root/upgrade_phpmyadmin.log
            ;;
        5)
            exit 0
            ;;
        esac
    fi
    done

}


display_usage(){
printf "

Usage: $0 [ apache | db | php | phpmyadmin ]
apache                    --->Upgrade Apache
db                        --->Upgrade MySQL/MariaDB
php                       --->Upgrade PHP
phpmyadmin                --->Upgrade phpMyAdmin

"
}


if   [ $# == 0 ];then
    display_menu
elif [ $# == 1 ];then
    rootness
    load_config

    case $1 in
    apache)
        upgrade_apache 2>&1 | tee -a /root/upgrade_apache.log
        ;;
    db)
        upgrade_db 2>&1 | tee -a /root/upgrade_db.log
        ;;
    php)
        upgrade_php 2>&1 | tee -a /root/upgrade_php.log
        ;;
    phpmyadmin)
        upgrade_phpmyadmin 2>&1 | tee -a /root/upgrade_phpmyadmin.log
        ;;
    *)
        display_usage
        ;;
    esac
else
    display_usage
fi
