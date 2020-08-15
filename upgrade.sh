#!/usr/bin/env bash
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
# System Required:  CentOS 6+ / Fedora28+ / Debian 8+ / Ubuntu 14+
# Description:  Update LAMP(Linux + Apache + MySQL/MariaDB + PHP )
# Website:  https://lamp.sh
# Github:   https://github.com/teddysun/lamp

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

cur_dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

include(){
    local include=$1
    if [[ -s ${cur_dir}/include/${include}.sh ]];then
        . ${cur_dir}/include/${include}.sh
    else
        echo "Error:${cur_dir}/include/${include}.sh not found, shell can not be executed."
        exit 1
    fi
}

upgrade_menu(){

    echo
    echo "+-------------------------------------------------------------------+"
    echo "| Auto Update LAMP(Linux + Apache + MySQL/MariaDB + PHP )           |"
    echo "| Intro: https://lamp.sh                                            |"
    echo "| Author: Teddysun <i@teddysun.com>                                 |"
    echo "+-------------------------------------------------------------------+"
    echo

    while true
    do
    _info "$(_green 1). Upgrade Apache"
    _info "$(_green 2). Upgrade MySQL or MariaDB"
    _info "$(_green 3). Upgrade PHP"
    _info "$(_green 4). Upgrade phpMyAdmin"
    _info "$(_green 5). Upgrade Adminer"
    _info "$(_green 6). Exit"
    echo
    read -p "Please input a number: " number
    if [[ ! ${number} =~ ^[1-6]$ ]]; then
        _error "Input error, please only input 1~6"
    else
        case "${number}" in
        1)
            upgrade_apache 2>&1 | tee ${cur_dir}/upgrade_apache.log
            break
            ;;
        2)
            upgrade_db 2>&1 | tee ${cur_dir}/upgrade_db.log
            break
            ;;
        3)
            upgrade_php 2>&1 | tee ${cur_dir}/upgrade_php.log
            break
            ;;
        4)
            upgrade_phpmyadmin 2>&1 | tee ${cur_dir}/upgrade_phpmyadmin.log
            break
            ;;
        5)
            upgrade_adminer 2>&1 | tee ${cur_dir}/upgrade_adminer.log
            break
            ;;
        6)
            exit
            ;;
        esac
    fi
    done

}

display_usage(){
printf "

Usage: $0 [ apache | db | php | phpmyadmin | adminer ]
apache                    --->Upgrade Apache
db                        --->Upgrade MySQL or MariaDB
php                       --->Upgrade PHP
phpmyadmin                --->Upgrade phpMyAdmin
adminer                   --->Upgrade Adminer

"
}

include config
include public
include php-modules
include upgrade_apache
include upgrade_db
include upgrade_php
include upgrade_phpmyadmin
include upgrade_adminer
load_config
rootness

if [ ${#} -eq 0 ]; then
    upgrade_menu
elif [ ${#} -eq 1 ]; then
    case $1 in
    apache)
        upgrade_apache 2>&1 | tee ${cur_dir}/upgrade_apache.log
        ;;
    db)
        upgrade_db 2>&1 | tee ${cur_dir}/upgrade_db.log
        ;;
    php)
        upgrade_php 2>&1 | tee ${cur_dir}/upgrade_php.log
        ;;
    phpmyadmin)
        upgrade_phpmyadmin 2>&1 | tee ${cur_dir}/upgrade_phpmyadmin.log
        ;;
    adminer)
        upgrade_adminer 2>&1 | tee ${cur_dir}/upgrade_adminer.log
        ;;
    *)
        display_usage
        ;;
    esac
else
    display_usage
fi
