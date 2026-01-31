#!/bin/bash
#
# LAMP (Linux + Apache + MariaDB + PHP) Installation Script
#
# Supported OS:
#   - Enterprise Linux 8/9/10 (CentOS Stream, RHEL, Rocky Linux, AlmaLinux, Oracle Linux)
#   - Debian 11/12/13
#   - Ubuntu 20.04/22.04/24.04
#
# Copyright (C) 2013 - 2026 Teddysun <i@teddysun.com>

set -euo pipefail
shopt -s inherit_errexit 2>/dev/null || true

#==============================================================================
# Configuration & Constants
#==============================================================================
SCRIPT_DIR="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_DIR
readonly DEFAULT_DB_PASS="Teddysun.com"
readonly LOG_FILE="/var/log/lamp-install.log"

#==============================================================================
# Color Output Functions
#==============================================================================
_red() { printf '\033[1;31m%b\033[0m' "$1"; }
_green() { printf '\033[1;32m%b\033[0m' "$1"; }
_yellow() { printf '\033[1;33m%b\033[0m' "$1"; }

#==============================================================================
# Logging Functions
#==============================================================================
_log() {
    local level="$1"
    shift 1
    local message="$*"
    local timestamp
    timestamp=$(date)
    echo "[${timestamp}] [${level}] ${message}" | tee -a "${LOG_FILE}" || echo "[${timestamp}] [${level}] ${message}"
}

_info() { _log "INFO" "$@"; }
_warn() { _log "WARN" "$(_yellow "$@")"; }
_error() { _log "ERROR" "$(_red "$@")" >&2; exit 2; }

#==============================================================================
# Signal Handlers
#==============================================================================
_exit_handler() {
    printf "\n"
    _red "Script $0 has been terminated."
    printf "\n"
    exit 1
}
trap _exit_handler INT QUIT TERM

#==============================================================================
# Utility Functions
#==============================================================================

# Check if a command exists
_exists() {
    command -v "$1" &>/dev/null
}

# Execute command with error detection
_error_detect() {
    local cmd="$1"
    _info "Executing: ${cmd}"
    if ! eval "${cmd}" >>"${LOG_FILE}" 2>&1; then
        _error "Command failed: ${cmd}"
    fi
}

# Compare versions (returns 0 if $1 >= $2)
_version_ge() {
    local ver1="$1"
    local ver2="$2"
    printf '%s\n%s\n' "${ver1}" "${ver2}" | sort -rV | head -n1 | grep -qx "${ver1}"
}

#==============================================================================
# OS Detection Functions
#==============================================================================

# Get OS ID from /etc/os-release
_get_os_id() {
    if [[ -f /etc/os-release ]]; then
        awk -F= '/^ID=/{gsub(/"/, ""); print $2}' /etc/os-release
    fi
}

# Get OS version ID
_get_os_version() {
    if [[ -f /etc/os-release ]]; then
        awk -F= '/^VERSION_ID=/{gsub(/"/, ""); print $2}' /etc/os-release
    fi
}

# Get pretty OS name
_get_opsy() {
    if [[ -f /etc/os-release ]]; then
        awk -F= '/^PRETTY_NAME=/{gsub(/^"|"$/, "", $2); print $2}' /etc/os-release
    elif [[ -f /etc/lsb-release ]]; then
        awk -F= '/^DISTRIB_DESCRIPTION=/{gsub(/^"|"$/, "", $2); print $2}' /etc/lsb-release
    elif [[ -f /etc/redhat-release ]]; then
        cat /etc/redhat-release
    fi
}

# Check OS type
_check_sys() {
    local os_type="$1"
    local os_id
    os_id=$(_get_os_id)
    case "${os_type}" in
        rhel)
            [[ "${os_id}" =~ ^(centos|rhel|rocky|almalinux|ol|fedora)$ ]] || \
            [[ -f /etc/redhat-release ]]
            ;;
        debian)
            [[ "${os_id}" == "debian" ]]
            ;;
        ubuntu)
            [[ "${os_id}" == "ubuntu" ]]
            ;;
        *)
            return 1
            ;;
    esac
}

# Get RHEL major version
get_rhelversion() {
    local target_ver="$1"
    local actual_ver
    actual_ver=$(_get_os_version)
    actual_ver="${actual_ver%%.*}"
    [[ "${actual_ver}" == "${target_ver}" ]]
}

# Get Debian major version
get_debianversion() {
    local target_ver="$1"
    local actual_ver
    actual_ver=$(_get_os_version)
    actual_ver="${actual_ver%%.*}"
    [[ "${actual_ver}" == "${target_ver}" ]]
}

# Get Ubuntu version
get_ubuntuversion() {
    local target_ver="$1"
    local actual_ver
    actual_ver=$(_get_os_version)
    [[ "${actual_ver}" == "${target_ver}" ]]
}

# Get extra repository name for RHEL
get_rhel_extra_repo() {
    local ver="$1"
    case "${ver}" in
        8) echo "powertools" ;;
        9|10) echo "crb" ;;
        *) _error "Unsupported RHEL version: ${ver}" ;;
    esac
}

#==============================================================================
# System Configuration Functions
#==============================================================================

# Check kernel version for BBR support
check_kernel_version() {
    local kernel_version
    kernel_version=$(uname -r | cut -d- -f1)
    _version_ge "${kernel_version}" "4.9.0"
}

# Check if BBR is enabled
check_bbr_status() {
    local param
    param=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null || echo "")
    [[ "${param}" == "bbr" ]]
}

# Get single character input
get_char() {
    SAVEDSTTY=$(stty -g)
    stty -echo
    stty cbreak
    dd if=/dev/tty bs=1 count=1 2>/dev/null
    stty -raw
    stty echo
    stty "${SAVEDSTTY}"
}

#==============================================================================
# RHEL Initialization
#==============================================================================

set_rhel_inputrc() {
    local ver="$1"
    if [[ "${ver}" =~ ^(9|10)$ ]]; then
        if ! grep -q "set enable-bracketed-paste off" /etc/inputrc 2>/dev/null; then
            _error_detect "echo 'set enable-bracketed-paste off' >> /etc/inputrc"
        fi
    fi
}

initialize_rhel() {
    local rhel_ver=""

    for ver in 8 9 10; do
        if get_rhelversion "${ver}"; then
            rhel_ver="${ver}"
            break
        fi
    done

    [[ -z "${rhel_ver}" ]] && _error "Unsupported RHEL version"

    _info "Detected RHEL version: ${rhel_ver}"

    # Install EPEL
    _error_detect "dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-${rhel_ver}.noarch.rpm"

    # Enable CodeReady Builder repository
    if _exists "subscription-manager"; then
        _error_detect "subscription-manager repos --enable codeready-builder-for-rhel-${rhel_ver}-$(uname -m)-rpms"
    elif [[ -s "/etc/yum.repos.d/oracle-linux-ol${rhel_ver}.repo" ]]; then
        _error_detect "dnf config-manager --set-enabled ol${rhel_ver}_codeready_builder"
    else
        _error_detect "dnf config-manager --set-enabled $(get_rhel_extra_repo "${rhel_ver}")"
    fi

    set_rhel_inputrc "${rhel_ver}"

    # Install custom repository
    _error_detect "dnf install -y https://dl.lamp.sh/linux/rhel/el${rhel_ver}/x86_64/teddysun-release-1.0-1.el${rhel_ver}.noarch.rpm"

    # Update cache and install base packages
    _error_detect "dnf makecache"
    _error_detect "dnf install -y vim nano tar zip unzip net-tools screen git virt-what wget mtr traceroute iftop htop jq tree"
    _error_detect "dnf install -y libnghttp2 libnghttp2-devel c-ares c-ares-devel curl libcurl libcurl-devel"

    # Disable SELinux
    if [[ -s "/etc/selinux/config" ]] && grep -q 'SELINUX=enforcing' /etc/selinux/config; then
        sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
        setenforce 0 2>/dev/null || true
        _info "SELinux disabled"
    fi

    # Remove cockpit motd
    if [[ -s "/etc/motd.d/cockpit" ]]; then
        rm -f /etc/motd.d/cockpit
        _info "Removed /etc/motd.d/cockpit"
    fi

    # Configure firewall
    if systemctl is-active --quiet firewalld 2>/dev/null; then
        local default_zone
        default_zone=$(firewall-cmd --get-default-zone)
        firewall-cmd --permanent --add-service=https --zone="${default_zone}" &>/dev/null || true
        firewall-cmd --permanent --add-service=http --zone="${default_zone}" &>/dev/null || true
        firewall-cmd --permanent --zone="${default_zone}" --add-port=443/udp &>/dev/null || true
        firewall-cmd --reload &>/dev/null || true
        sed -i 's/AllowZoneDrifting=yes/AllowZoneDrifting=no/' /etc/firewalld/firewalld.conf 2>/dev/null || true
        _error_detect "systemctl restart firewalld"
        _info "Firewall configuration completed"
    else
        _warn "firewalld is not running, skipping firewall configuration"
    fi
}

#==============================================================================
# Debian/Ubuntu Initialization
#==============================================================================

initialize_deb() {
    _error_detect "apt-get update"
    _error_detect "apt-get -y install lsb-release ca-certificates curl gnupg"
    _error_detect "apt-get -y install vim nano tar zip unzip net-tools screen git virt-what wget mtr traceroute iftop htop jq tree"

    # Configure UFW
    if ufw status &>/dev/null; then
        _error_detect "ufw allow http"
        _error_detect "ufw allow https"
        _error_detect "ufw allow 443/udp"
    else
        _warn "ufw is not running, skipping firewall configuration"
    fi
}

#==============================================================================
# System Initialization
#==============================================================================

initialize_system() {
    if _check_sys rhel; then
        initialize_rhel
    elif _check_sys debian || _check_sys ubuntu; then
        initialize_deb
    else
        _error "Unsupported operating system"
    fi
}

#==============================================================================
# BBR Configuration
#==============================================================================

configure_bbr() {
    if ! check_kernel_version; then
        _warn "Kernel version < 4.9, skipping BBR configuration"
        return 0
    fi

    if check_bbr_status; then
        _info "BBR is already enabled"
        return 0
    fi

    # Backup and configure sysctl
    local sysctl_conf="/etc/sysctl.conf"

    # Remove old BBR settings
    if [[ -f "${sysctl_conf}" ]]; then
        sed -i '/net.core.default_qdisc/d' "${sysctl_conf}"
        sed -i '/net.ipv4.tcp_congestion_control/d' "${sysctl_conf}"
        sed -i '/net.core.rmem_max/d' "${sysctl_conf}"
    fi
    # Add new BBR settings
    cat >> "${sysctl_conf}" << EOF
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.core.rmem_max = 2500000
EOF

    sysctl -p &>/dev/null || _warn "Failed to apply sysctl settings"
    _info "BBR configuration completed"
}

#==============================================================================
# Journald Configuration
#==============================================================================

configure_journald() {
    local journald_config=""

    if ! systemctl is-active --quiet systemd-journald 2>/dev/null; then
        return 0
    fi

    if [[ -s "/etc/systemd/journald.conf" ]]; then
        journald_config="/etc/systemd/journald.conf"
    elif [[ -s "/usr/lib/systemd/journald.conf" ]]; then
        journald_config="/usr/lib/systemd/journald.conf"
    fi

    [[ -z "${journald_config}" ]] && return 0

    sed -i 's/^#\?Storage=.*/Storage=volatile/' "${journald_config}"
    sed -i 's/^#\?SystemMaxUse=.*/SystemMaxUse=16M/' "${journald_config}"
    sed -i 's/^#\?RuntimeMaxUse=.*/RuntimeMaxUse=16M/' "${journald_config}"

    _error_detect "systemctl restart systemd-journald"
}

select_mariadb_version() {
    local choice

    _info "Please choose a MariaDB version:"
    _info "$(_green "1"). MariaDB 10.11"
    _info "$(_green "2"). MariaDB 11.4"
    _info "$(_green "3"). MariaDB 11.8"
    while true; do
        read -r -p "[$(date)] [INFO] Please input a number (Default: 2): " choice
        choice="${choice:-2}"
        case "${choice}" in
            1) mariadb_ver="10.11"; return 0 ;;
            2) mariadb_ver="11.4"; return 0 ;;
            3) mariadb_ver="11.8"; return 0 ;;
            *) _warn "Invalid input. Please enter 1, 2, or 3" ;;
        esac
    done
}

select_php_version() {
    local choice

    _info "Please choose a PHP version:"
    _info "$(_green "1"). PHP 7.4"
    _info "$(_green "2"). PHP 8.0"
    _info "$(_green "3"). PHP 8.1"
    _info "$(_green "4"). PHP 8.2"
    _info "$(_green "5"). PHP 8.3"
    _info "$(_green "6"). PHP 8.4"
    _info "$(_green "7"). PHP 8.5"
    while true; do
        read -r -p "[$(date)] [INFO] Please input a number (Default: 6): " choice
        choice="${choice:-6}"
        case "${choice}" in
            1) php_ver="7.4"; return 0 ;;
            2) php_ver="8.0"; return 0 ;;
            3) php_ver="8.1"; return 0 ;;
            4) php_ver="8.2"; return 0 ;;
            5) php_ver="8.3"; return 0 ;;
            6) php_ver="8.4"; return 0 ;;
            7) php_ver="8.5"; return 0 ;;
            *) _warn "Invalid input. Please enter 1-7" ;;
        esac
    done
}

read_db_password() {
    local password

    _info "Please enter the MariaDB root password:"
    read -s -r -p "[$(date)] [INFO] (Default: ${DEFAULT_DB_PASS}, password will not shown): " password
    password="${password:-${DEFAULT_DB_PASS}}"
    echo
    db_pass="${password}"
    _info "---------------------------"
    _info "Password: $(_red "********")"
    _info "---------------------------"
}

setup_debian_cnf() {
    local db_pass="$1"
    [[ ! -x "/etc/mysql/debian-start" ]] && return 0
    cat > "/etc/mysql/debian.cnf" << EOF
# THIS FILE IS OBSOLETE. STOP USING IT IF POSSIBLE.
[client]
host     = localhost
user     = root
password = '${db_pass}'
[mysql_upgrade]
host     = localhost
user     = root
password = '${db_pass}'
EOF
    chmod 600 /etc/mysql/debian.cnf
    _info "Debian maintenance credentials configuration completed"
}

configure_mariadb() {
    local db_pass="$1"
    local mariadb_cnf="$2"

    # Configure MariaDB settings
    local lnum
    lnum=$(sed -n '/\[mysqld\]/=' "${mariadb_cnf}" | head -1)
    if [[ -n "${lnum}" ]]; then
        sed -i "${lnum}a innodb_buffer_pool_size = 100M\nmax_allowed_packet = 1024M\nnet_read_timeout = 3600\nnet_write_timeout = 3600" "${mariadb_cnf}"
    fi

    lnum=$(sed -n '/\[mariadb\]/=' "${mariadb_cnf}" | tail -1)
    if [[ -n "${lnum}" ]]; then
        sed -i "${lnum}a character-set-server = utf8mb4\n\n[client-mariadb]\ndefault-character-set = utf8mb4" "${mariadb_cnf}"
    fi

    # Start MariaDB
    _error_detect "systemctl start mariadb"
    sleep 3

    # Create root user with new authentication method
    _info "Create root user with new authentication method"
    /usr/bin/mariadb -e "GRANT ALL PRIVILEGES ON *.* TO root@'127.0.0.1' IDENTIFIED BY '${db_pass}' WITH GRANT OPTION;"
    /usr/bin/mariadb -e "GRANT ALL PRIVILEGES ON *.* TO root@'localhost' IDENTIFIED BY '${db_pass}' WITH GRANT OPTION;"

    # Secure installation
    /usr/bin/mariadb -uroot -p"${db_pass}" 2>/dev/null << EOF
drop database if exists test;
delete from mysql.db where user='';
delete from mysql.db where user='PUBLIC';
delete from mysql.user where user='';
delete from mysql.user where user='mysql';
delete from mysql.user where user='PUBLIC';
flush privileges;
exit
EOF

    _info "MariaDB configuration completed"
}

configure_php_rhel() {
    local php_ver="$1"

    # Install Remi repository
    if get_rhelversion 8; then
        _error_detect "dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm"
    elif get_rhelversion 9; then
        _error_detect "dnf install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm"
    elif get_rhelversion 10; then
        _error_detect "dnf install -y https://rpms.remirepo.net/enterprise/remi-release-10.rpm"
    fi

    _error_detect "dnf module reset -y php"
    _error_detect "dnf module install -y php:remi-${php_ver}"

    # Install PHP packages
    _error_detect "dnf install -y php-common php-fpm php-cli php-bcmath php-embedded php-gd php-imap php-mysqlnd php-dba php-pdo php-pdo-dblib"
    _error_detect "dnf install -y php-pgsql php-odbc php-enchant php-gmp php-intl php-ldap php-snmp php-soap php-tidy php-opcache php-process"
    _error_detect "dnf install -y php-pspell php-shmop php-sodium php-ffi php-brotli php-lz4 php-xz php-zstd"
    _error_detect "dnf install -y php-pecl-imagick-im7 php-pecl-zip php-pecl-rar php-pecl-grpc php-pecl-yaml php-pecl-uuid"
}

configure_php_deb() {
    local php_ver="$1"

    # Add PHP repository
    if _check_sys debian; then
        _error_detect "curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg"
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
    elif _check_sys ubuntu; then
        _error_detect "add-apt-repository -y ppa:ondrej/php"
    fi

    _error_detect "apt-get update"

    # Install PHP packages
    _error_detect "apt-get install -y php-common php${php_ver}-common php${php_ver}-cli php${php_ver}-fpm php${php_ver}-opcache php${php_ver}-readline"
    _error_detect "apt-get install -y libphp${php_ver}-embed php${php_ver}-bcmath php${php_ver}-gd php${php_ver}-imap php${php_ver}-mysql php${php_ver}-dba php${php_ver}-mongodb php${php_ver}-sybase"
    _error_detect "apt-get install -y php${php_ver}-pgsql php${php_ver}-odbc php${php_ver}-enchant php${php_ver}-gmp php${php_ver}-intl php${php_ver}-ldap php${php_ver}-snmp php${php_ver}-soap"
    _error_detect "apt-get install -y php${php_ver}-mbstring php${php_ver}-curl php${php_ver}-pspell php${php_ver}-xml php${php_ver}-zip php${php_ver}-bz2 php${php_ver}-lz4 php${php_ver}-zstd"
    _error_detect "apt-get install -y php${php_ver}-tidy php${php_ver}-sqlite3 php${php_ver}-imagick php${php_ver}-grpc php${php_ver}-yaml php${php_ver}-uuid"

    # Create PHP directories
    _error_detect "mkdir -m770 /var/lib/php/{session,wsdlcache,opcache}"

    # Install Apache PHP connector
    if [[ -f "${SCRIPT_DIR}/conf/php.conf" ]]; then
        _error_detect "cp -f ${SCRIPT_DIR}/conf/php.conf /etc/apache2/mods-available/"
        pushd /etc/apache2/mods-enabled/ >/dev/null 2>&1
        ln -sf ../mods-available/php.conf php.conf
        popd >/dev/null 2>&1
    fi

}

configure_php_settings() {
    local php_conf="$1"
    local php_ini="$2"
    local sock_location="$3"
    local is_rhel="$4"

    if [[ "${is_rhel}" == "true" ]]; then
        # RHEL specific settings
        sed -i "s@^user.*@user = apache@" "${php_conf}"
        sed -i "s@^group.*@group = apache@" "${php_conf}"
        sed -i "s@^listen.acl_users.*@listen.acl_users = apache,nginx@" "${php_conf}"
        sed -i "s@^;php_value\[opcache.file_cache\].*@php_value[opcache.file_cache] = /var/lib/php/opcache@" "${php_conf}"
    else
        # Debian/Ubuntu specific settings
        sed -i "s@^user.*@user = www-data@" "${php_conf}"
        sed -i "s@^group.*@group = www-data@" "${php_conf}"
        sed -i "s@^listen.owner.*@;&@" "${php_conf}"
        sed -i "s@^listen.group.*@;&@" "${php_conf}"
        sed -i "s@^;listen.acl_users.*@listen.acl_users = www-data@" "${php_conf}"
        sed -i "s@^;listen.allowed_clients.*@listen.allowed_clients = 127.0.0.1@" "${php_conf}"
        sed -i "s@^pm.max_children.*@pm.max_children = 50@" "${php_conf}"
        sed -i "s@^pm.start_servers.*@pm.start_servers = 5@" "${php_conf}"
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 5@" "${php_conf}"
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 35@" "${php_conf}"
        sed -i "s@^;slowlog.*@slowlog = /var/log/www-slow.log@" "${php_conf}"
        sed -i "s@^;php_admin_value\[error_log\].*@php_admin_value[error_log] = /var/log/www-error.log@" "${php_conf}"
        sed -i "s@^;php_admin_flag\[log_errors\].*@php_admin_flag[log_errors] = on@" "${php_conf}"

        cat >> "${php_conf}" << EOF
php_value[session.save_handler] = files
php_value[session.save_path]    = /var/lib/php/session
php_value[soap.wsdl_cache_dir]  = /var/lib/php/wsdlcache
php_value[opcache.file_cache]   = /var/lib/php/opcache
EOF
    fi

    # Update php.ini
    sed -i "s@^disable_functions.*@disable_functions = passthru,exec,shell_exec,system,chroot,chgrp,chown,proc_open,proc_get_status,ini_alter,ini_restore@" "${php_ini}"
    sed -i "s@^max_execution_time.*@max_execution_time = 300@" "${php_ini}"
    sed -i "s@^max_input_time.*@max_input_time = 300@" "${php_ini}"
    sed -i "s@^post_max_size.*@post_max_size = 128M@" "${php_ini}"
    sed -i "s@^upload_max_filesize.*@upload_max_filesize = 128M@" "${php_ini}"
    sed -i "s@^expose_php.*@expose_php = Off@" "${php_ini}"
    sed -i "s@^short_open_tag.*@short_open_tag = On@" "${php_ini}"
    sed -i "s#mysqli.default_socket.*#mysqli.default_socket = ${sock_location}#" "${php_ini}"
    sed -i "s#pdo_mysql.default_socket.*#pdo_mysql.default_socket = ${sock_location}#" "${php_ini}"

    _info "PHP configuration completed"
}

install_apache_rhel() {

    # Install Apache
    _error_detect "dnf install -y httpd mod_ssl mod_http2 mod_md mod_session mod_lua pcre2"
    _info "Apache installation completed"

    # Create directories
    _error_detect "mkdir -p /data/www/default"
    _error_detect "mkdir -p /data/wwwlog"
    _error_detect "mkdir -p /etc/httpd/conf.d/vhost"
    _error_detect "mkdir -p /etc/httpd/ssl"

    # Copy configuration files
    if [[ -f "${SCRIPT_DIR}/conf/httpd.conf" ]]; then
        _error_detect "cp -f ${SCRIPT_DIR}/conf/httpd.conf /etc/httpd/conf/httpd.conf"
    fi
    if [[ -f "${SCRIPT_DIR}/conf/httpd-info.conf" ]]; then
        _error_detect "cp -f ${SCRIPT_DIR}/conf/httpd-info.conf /etc/httpd/conf.d/"
    fi
    if [[ -f "${SCRIPT_DIR}/conf/ssl_rpm.conf" ]]; then
        _error_detect "cp -f ${SCRIPT_DIR}/conf/ssl_rpm.conf /etc/httpd/conf.d/ssl.conf"
    fi
    if [[ -f "${SCRIPT_DIR}/conf/vhosts.conf" ]]; then
        _error_detect "cp -f ${SCRIPT_DIR}/conf/vhosts.conf /etc/httpd/conf.d/"
    fi
    if [[ -f "${SCRIPT_DIR}/conf/welcome.conf" ]]; then
        _error_detect "cp -f ${SCRIPT_DIR}/conf/welcome.conf /etc/httpd/conf.d/"
    fi

    # Create default virtual host
    cat > "/etc/httpd/conf.d/vhost/_default.conf" << EOF
<VirtualHost _default_:80>
ServerName localhost
DocumentRoot /data/www/default
<Directory /data/www/default>
    SetOutputFilter DEFLATE
    Options FollowSymLinks
    AllowOverride All
    Order Deny,Allow
    Allow from All
    DirectoryIndex index.html index.htm index.php
</Directory>
</VirtualHost>
EOF
}

install_apache_deb() {

    # Install Apache
    _error_detect "apt-get install -y apache2 libapache2-mod-perl2 libapache2-mod-md"
    _error_detect "systemctl stop apache2"
    _error_detect "a2enmod ssl http2 brotli data unique_id vhost_alias echo expires info"
    _error_detect "a2enmod headers perl rewrite lua request md mime_magic remoteip userdir"
    _error_detect "a2enmod auth*"
    _error_detect "a2enmod cache*"
    _error_detect "a2enmod dav*"
    _error_detect "a2enmod proxy*"
    _error_detect "a2enmod session*"
    sed -i "s@^ServerTokens.*@ServerTokens Minimal@" "/etc/apache2/conf-available/security.conf"
    sed -i "s@^ServerSignature.*@ServerSignature Off@" "/etc/apache2/conf-available/security.conf"
    _info "Apache installation completed"

    # Create directories
    _error_detect "mkdir -p /data/www/default"
    _error_detect "mkdir -p /data/wwwlog"
    _error_detect "mkdir -p /etc/apache2/ssl"

    # Copy configuration files
    if [[ -f "${SCRIPT_DIR}/conf/apache2.conf" ]]; then
        _error_detect "cp -f ${SCRIPT_DIR}/conf/apache2.conf /etc/apache2/apache2.conf"
    fi
    if [[ -f "${SCRIPT_DIR}/conf/ssl_deb.conf" ]]; then
        _error_detect "cp -f ${SCRIPT_DIR}/conf/ssl_deb.conf /etc/apache2/mods-available/ssl.conf"
    fi

    # Create default virtual host
    cat > "/etc/apache2/sites-available/000-default.conf" << EOF
<VirtualHost _default_:80>
ServerName localhost
DocumentRoot /data/www/default
<Directory /data/www/default>
    SetOutputFilter DEFLATE
    Options FollowSymLinks
    AllowOverride All
    Order Deny,Allow
    Allow from All
    DirectoryIndex index.html index.htm index.php
</Directory>
</VirtualHost>
EOF
}

install_apache() {
    local is_rhel="$1"

    if [[ "${is_rhel}" == "true" ]]; then
        install_apache_rhel
    else
        install_apache_deb
    fi

    # Copy default files
    if [[ -f "${SCRIPT_DIR}/conf/favicon.ico" ]]; then
        _error_detect "cp -f ${SCRIPT_DIR}/conf/favicon.ico /data/www/default/"
    fi
    if [[ -f "${SCRIPT_DIR}/conf/index.html" ]]; then
        _error_detect "cp -f ${SCRIPT_DIR}/conf/index.html /data/www/default/"
    fi
    if [[ -f "${SCRIPT_DIR}/conf/lamp.png" ]]; then
        _error_detect "cp -f ${SCRIPT_DIR}/conf/lamp.png /data/www/default/"
    fi

    _info "Apache configuration completed"
}

install_phpmyadmin() {
    local db_pass="$1"

    _error_detect "wget -qO pma.tar.gz https://dl.lamp.sh/files/pma.tar.gz"
    _error_detect "tar zxf pma.tar.gz -C /data/www/default/"
    _error_detect "rm -f pma.tar.gz"

    # Import phpMyAdmin tables
    if [[ -f "/data/www/default/pma/sql/create_tables.sql" ]]; then
        /usr/bin/mariadb -uroot -p"${db_pass}" 2>/dev/null < /data/www/default/pma/sql/create_tables.sql || \
            _warn "Failed to import phpMyAdmin tables"
    fi

    _info "phpMyAdmin installation completed"
}

install_mariadb() {
    local mariadb_ver="$1"
    # shellcheck disable=SC2034
    local -n cnf_path_ref="$2"

    _info "Setting up MariaDB repository"
    _error_detect "curl -sLo mariadb_repo_setup.sh https://dl.lamp.sh/files/mariadb_repo_setup.sh"
    _error_detect "chmod +x mariadb_repo_setup.sh"

    # Fix crypto policy for RHEL 10
    if get_rhelversion 10 && _exists "update-crypto-policies"; then
        _error_detect "update-crypto-policies --set LEGACY"
    fi

    _info "Executing: ./mariadb_repo_setup.sh --mariadb-server-version=mariadb-${mariadb_ver}"
    ./mariadb_repo_setup.sh --mariadb-server-version="mariadb-${mariadb_ver}" &>/dev/null || \
        _warn "MariaDB repo setup may have issues"
    _error_detect "rm -f mariadb_repo_setup.sh"

    if _check_sys rhel; then
        _error_detect "dnf config-manager --disable mariadb-maxscale"
        _error_detect "dnf install -y MariaDB-common MariaDB-server MariaDB-client MariaDB-shared MariaDB-backup"
        cnf_path_ref="/etc/my.cnf.d/server.cnf"
    elif _check_sys debian || _check_sys ubuntu; then
        if [[ -f "/etc/apt/sources.list.d/mariadb.list" ]]; then
            sed -i 's|^deb \[arch=amd64,arm64\] https://dlm.mariadb.com/repo/maxscale/latest/apt|#&|' /etc/apt/sources.list.d/mariadb.list
        fi
        _error_detect "apt-get update"
        _error_detect "DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-common mariadb-server mariadb-client mariadb-backup"
        cnf_path_ref="/etc/mysql/mariadb.conf.d/50-server.cnf"
    fi

    _info "MariaDB installation completed"
}

install_php() {
    local php_ver="$1"
    # shellcheck disable=SC2034
    local -n php_conf_ref="$2"
    # shellcheck disable=SC2034
    local -n php_ini_ref="$3"
    # shellcheck disable=SC2034
    local -n php_fpm_ref="$4"
    # shellcheck disable=SC2034
    local -n sock_location_ref="$5"

    local is_rhel="false"

    if _check_sys rhel; then
        is_rhel="true"
        php_conf_ref="/etc/php-fpm.d/www.conf"
        php_ini_ref="/etc/php.ini"
        php_fpm_ref="php-fpm"
        sock_location_ref="/var/lib/mysql/mysql.sock"
        configure_php_rhel "${php_ver}"
    elif _check_sys debian || _check_sys ubuntu; then
        php_conf_ref="/etc/php/${php_ver}/fpm/pool.d/www.conf"
        php_ini_ref="/etc/php/${php_ver}/fpm/php.ini"
        php_fpm_ref="php${php_ver}-fpm"
        sock_location_ref="/run/mysqld/mysqld.sock"
        configure_php_deb "${php_ver}"
    fi

    _info "PHP installation completed"

    configure_php_settings "${php_conf_ref}" "${php_ini_ref}" "${sock_location_ref}" "${is_rhel}"
}

set_permissions() {
    local is_rhel="$1"

    if [[ "${is_rhel}" == "true" ]]; then
        _error_detect "chown -R apache:apache /data/www /data/wwwlog"
        _error_detect "chown -R apache:apache /var/lib/php/opcache"
    else
        _error_detect "chown -R www-data:www-data /data/www /data/wwwlog"
        _error_detect "chown root:www-data /var/lib/php/{session,wsdlcache,opcache}"
    fi
}

main() {

    # Check root
    if [[ ${EUID} -ne 0 ]]; then
        _red "This script must be run as root!\n"
        exit 1
    fi

    # Initialize log
    mkdir -p "$(dirname "${LOG_FILE}")"
    if [[ ! -f "${LOG_FILE}" ]]; then touch "${LOG_FILE}"; fi
    chmod 600 "${LOG_FILE}"

    _info "+-------------------------------------------+"
    _info "|   LAMP Installation, Written by Teddysun  |"
    _info "+-------------------------------------------+"
    _info "OS: $(_get_opsy)"
    _info "Arch: $(uname -m)"
    _info "Kernel: $(uname -r)"
    _info "Starting LAMP installation script"

    # Check OS support
    local supported="false"
    local is_rhel="false"
    if _check_sys rhel; then
        for ver in 8 9 10; do
            get_rhelversion "${ver}" && supported="true" && break
        done
        is_rhel="true"
    fi
    if _check_sys debian; then
        for ver in 11 12 13; do
            get_debianversion "${ver}" && supported="true" && break
        done
    fi
    if _check_sys ubuntu; then
        for ver in 20.04 22.04 24.04; do
            get_ubuntuversion "${ver}" && supported="true" && break
        done
    fi

    [[ "${supported}" != "true" ]] && _error "Unsupported OS. Please use Enterprise Linux 8+, Debian 11+, or Ubuntu 20.04+"

    # Get user input
    select_mariadb_version
    read_db_password
    select_php_version

    _info "---------------------------"
    _info "MariaDB version: $(_green "${mariadb_ver}")"
    _info "PHP version: $(_green "${php_ver}")"
    _info "---------------------------"

    # Confirm installation
    _info "Press any key to start installation, or Ctrl+C to cancel"
    get_char > /dev/null

    # System initialization
    _info "Starting system initialization"
    configure_bbr
    configure_journald
    initialize_system

    echo
    netstat -nxtulpe 2>/dev/null || ss -tunlp
    echo
    _info "System initialization completed"
    sleep 3
    clear

    # LAMP Installation
    _info "Starting LAMP (Linux + Apache + MariaDB + PHP) installation"

    # Install Apache
    install_apache "${is_rhel}"

    # Install MariaDB
    local mariadb_cnf
    install_mariadb "${mariadb_ver}" mariadb_cnf
    configure_mariadb "${db_pass}" "${mariadb_cnf}"

    # Setup Debian maintenance credentials
    if _check_sys debian || _check_sys ubuntu; then
        setup_debian_cnf "${db_pass}"
    fi

    # Install phpMyAdmin
    install_phpmyadmin "${db_pass}"

    # Install PHP
    local php_conf php_ini php_fpm sock_location
    install_php "${php_ver}" php_conf php_ini php_fpm sock_location

    # Set permissions
    set_permissions "${is_rhel}"

    # Install lamp helper script
    if [[ -f "${SCRIPT_DIR}/conf/lamp" ]]; then
        _error_detect "cp -f ${SCRIPT_DIR}/conf/lamp /usr/bin/"
        _error_detect "chmod +x /usr/bin/lamp"
    fi

    # Start services
    _error_detect "systemctl daemon-reload"
    _error_detect "systemctl start ${php_fpm}"
    if [[ "${is_rhel}" == "true" ]]; then
        _error_detect "systemctl start httpd"
    else
        _error_detect "systemctl start apache2"
    fi
    sleep 3
    _error_detect "systemctl restart ${php_fpm}"
    _error_detect "systemctl restart mariadb"
    if [[ "${is_rhel}" == "true" ]]; then
        _error_detect "systemctl restart httpd"
    else
        _error_detect "systemctl restart apache2"
    fi
    sleep 1

    # Enable services
    _error_detect "systemctl enable mariadb"
    _error_detect "systemctl enable ${php_fpm}"
    if [[ "${is_rhel}" == "true" ]]; then
        _error_detect "systemctl enable httpd"
    else
        _error_detect "systemctl enable apache2"
    fi

    # Cleanup
    pkill -9 gpg-agent 2>/dev/null || true

    # Show status
    echo
    _info "systemctl --no-pager -l status mariadb"
    systemctl --no-pager -l status mariadb || true
    _info "systemctl --no-pager -l status ${php_fpm}"
    systemctl --no-pager -l status "${php_fpm}" || true
    if [[ "${is_rhel}" == "true" ]]; then
        _info "systemctl --no-pager -l status httpd"
        systemctl --no-pager -l status httpd || true
    else
        _info "systemctl --no-pager -l status apache2"
        systemctl --no-pager -l status apache2 || true
    fi

    echo
    _info "netstat -nxtulpe"
    netstat -nxtulpe 2>/dev/null || ss -tunlp
    echo
    _info "LAMP (Linux + Apache + MariaDB + PHP) installation completed"
    _info "Log file: ${LOG_FILE}"
}

# Run main function
main "$@"
