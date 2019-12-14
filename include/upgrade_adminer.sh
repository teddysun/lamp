# Copyright (C) 2013 - 2019 Teddysun <i@teddysun.com>
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

#upgrade adminer
upgrade_adminer(){

    if [ -f "${web_root_dir}/adminer.php" ]; then
        installed_adminer="$(grep -w "@version" ${web_root_dir}/adminer.php | awk '{print $3}')"
    else
        _error "Adminer not found, please check it and retry"
    fi

    latest_adminer="$(wget --no-check-certificate -qO- https://api.github.com/repos/vrana/adminer/tags | grep 'name' | head -1 | cut -d\" -f4 | grep -oE  "[0-9.]+")"
    [ -z "${latest_adminer}" ] && _error "Failed to get Adminer latest version from github, please check it and retry"
    _info "Latest version of Adminer   : $(_red ${latest_adminer})"
    _info "Installed version of Adminer: $(_red ${installed_adminer})"
    read -p "Do you want to upgrade Adminer? (y/n) (Default: n):" upgrade_adminer
    [ -z "${upgrade_adminer}" ] && upgrade_adminer="n"
    if [[ "${upgrade_adminer}" = "y" || "${upgrade_adminer}" = "Y" ]];then
        _info "Adminer upgrade start..."
        [ ! -d "${cur_dir}/software" ] && mkdir -p ${cur_dir}/software
        cd ${cur_dir}/software
        latest_adminer_link="https://github.com/vrana/adminer/releases/download/v${latest_adminer}/adminer-${latest_adminer}.php"
        download_file "adminer-${latest_adminer}.php" "${latest_adminer_link}"
        mv adminer-${latest_adminer}.php ${web_root_dir}/adminer.php
        chown apache:apache ${web_root_dir}/adminer.php
        _info "Adminer upgrade completed..."
    else
        _info "Adminer upgrade cancelled, nothing to do..."
    fi

}
