#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#=======================================================================#
#   System Required:  CentOS/RadHat 5+ / Debian 7+ / Ubuntu 12+         #
#   Description:  Install LAMP(Linux + Apache + MySQL + PHP )           #
#   Author: Teddysun <i@teddysun.com>                                   #
#   Intro:  https://lamp.sh                                             #
#=======================================================================#

cur_dir=`pwd`

include(){
    local include=$1
    if [[ -s ${cur_dir}/include/${include}.sh ]];then
        . ${cur_dir}/include/${include}.sh
    else
        echo "Error:${cur_dir}/include/${include}.sh not found, shell can not be executed."
        exit 1
    fi
}

#lamp main process
lamp(){
    include config
    include public
    include apache
    include mysql
    include php
    include php-modules

    clear
    echo
    echo "#############################################################"
    echo "# Auto Install LAMP(Linux + Apache + MySQL + PHP )          #"
    echo "# Intro: https://lamp.sh                                    #"
    echo "# Author: Teddysun <i@teddysun.com>                         #"
    echo "#############################################################"
    echo
    rootness
    load_config
    pre_setting
}

#Run
rm -f /root/lamp.log
lamp 2>&1 | tee -a /root/lamp.log
