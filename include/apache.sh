# Copyright (C) 2013 - 2022 Teddysun <i@teddysun.com>
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

#Pre-installation apache
apache_preinstall_settings(){
    display_menu apache 1
    if [ "${apache}" == "do_not_install" ]; then
        apache_modules_install="do_not_install"
    else
        display_menu_multi apache_modules last
    fi
}

#Install apache
install_apache(){
    apache_configure_args="--prefix=${apache_location} \
    --with-pcre=${depends_prefix}/pcre \
    --with-mpm=event \
    --with-included-apr \
    --with-ssl \
    --with-nghttp2 \
    --enable-modules=reallyall \
    --enable-mods-shared=reallyall"

    _info "Installing dependencies for Apache..."
    local apt_list=(zlib1g-dev openssl libssl-dev libxml2-dev lua-expat-dev libjansson-dev)
    local yum_list=(zlib-devel openssl-devel libxml2-devel expat-devel lua-devel lua jansson-devel)
    if check_sys packageManager apt; then
        for depend in ${apt_list[@]}; do
            error_detect_depends "apt-get -y install ${depend}"
        done
    elif check_sys packageManager yum; then
        for depend in ${yum_list[@]}; do
            error_detect_depends "yum -y install ${depend}"
        done
    fi
    _info "Install dependencies for Apache completed..."

    if ! grep -qE "^/usr/local/lib" /etc/ld.so.conf.d/*.conf; then
        echo "/usr/local/lib" > /etc/ld.so.conf.d/locallib.conf
    fi
    ldconfig

    check_installed "install_pcre" "${depends_prefix}/pcre"
    check_installed "install_openssl" "${openssl_location}"
    install_nghttp2

    cd ${cur_dir}/software/
    download_file "${apr_filename}.tar.gz" "${apr_filename_url}"
    tar zxf ${apr_filename}.tar.gz
    download_file "${apr_util_filename}.tar.gz" "${apr_util_filename_url}"
    tar zxf ${apr_util_filename}.tar.gz
    download_file "${apache2_4_filename}.tar.gz" "${apache2_4_filename_url}"
    tar zxf ${apache2_4_filename}.tar.gz
    cd ${apache2_4_filename}
    mv ${cur_dir}/software/${apr_filename} srclib/apr
    mv ${cur_dir}/software/${apr_util_filename} srclib/apr-util

    LDFLAGS=-ldl
    if [ -d "${openssl_location}" ]; then
        apache_configure_args=$(echo ${apache_configure_args} | sed -e "s@--with-ssl@--with-ssl=${openssl_location}@")
    fi
    error_detect "./configure ${apache_configure_args}"
    error_detect "parallel_make"
    error_detect "make install"
    unset LDFLAGS
    config_apache
}


config_apache(){
    id -u apache >/dev/null 2>&1
    [ $? -ne 0 ] && groupadd apache && useradd -M -s /sbin/nologin -g apache apache
    [ ! -d "${web_root_dir}" ] && mkdir -p ${web_root_dir} && chmod -R 755 ${web_root_dir}
    if [ -f "${apache_location}/conf/httpd.conf" ]; then
        cp -f ${apache_location}/conf/httpd.conf ${apache_location}/conf/httpd.conf.bak
    fi
    mv ${apache_location}/conf/extra/httpd-vhosts.conf ${apache_location}/conf/extra/httpd-vhosts.conf.bak
    mkdir -p ${apache_location}/conf/ssl/
    mkdir -p ${apache_location}/conf/vhost/
    grep -qE "^\s*#\s*Include conf/extra/httpd-vhosts.conf" ${apache_location}/conf/httpd.conf && \
    sed -i 's#^\s*\#\s*Include conf/extra/httpd-vhosts.conf#Include conf/extra/httpd-vhosts.conf#' ${apache_location}/conf/httpd.conf || \
    sed -i '$aInclude conf/extra/httpd-vhosts.conf' ${apache_location}/conf/httpd.conf
    sed -i 's/^User.*/User apache/i' ${apache_location}/conf/httpd.conf
    sed -i 's/^Group.*/Group apache/i' ${apache_location}/conf/httpd.conf
    sed -i 's/^#ServerName www.example.com:80/ServerName 0.0.0.0:80/' ${apache_location}/conf/httpd.conf
    sed -i 's/^ServerAdmin you@example.com/ServerAdmin admin@localhost/' ${apache_location}/conf/httpd.conf
    sed -i 's@^#Include conf/extra/httpd-info.conf@Include conf/extra/httpd-info.conf@' ${apache_location}/conf/httpd.conf
    sed -i 's@DirectoryIndex index.html@DirectoryIndex index.html index.php@' ${apache_location}/conf/httpd.conf
    sed -i "s@^DocumentRoot.*@DocumentRoot \"${web_root_dir}\"@" ${apache_location}/conf/httpd.conf
    sed -i "s@^<Directory \"${apache_location}/htdocs\">@<Directory \"${web_root_dir}\">@" ${apache_location}/conf/httpd.conf
    echo "ServerTokens ProductOnly" >> ${apache_location}/conf/httpd.conf
    echo "ProtocolsHonorOrder On" >> ${apache_location}/conf/httpd.conf
    echo "Protocols h2 http/1.1" >> ${apache_location}/conf/httpd.conf
    cat > /etc/logrotate.d/httpd <<EOF
${apache_location}/logs/*log {
    daily
    rotate 14
    missingok
    notifempty
    compress
    sharedscripts
    postrotate
        [ ! -f ${apache_location}/logs/httpd.pid ] || kill -USR1 \`cat ${apache_location}/logs/httpd.pid\`
    endscript
}
EOF
    cat > ${apache_location}/conf/extra/httpd-vhosts.conf <<EOF
Include ${apache_location}/conf/vhost/*.conf
EOF
    cat > ${apache_location}/conf/vhost/default.conf <<EOF
<VirtualHost _default_:80>
ServerName localhost
DocumentRoot ${web_root_dir}
<Directory ${web_root_dir}>
    SetOutputFilter DEFLATE
    Options FollowSymLinks
    AllowOverride All
    Order Deny,Allow
    Allow from All
    DirectoryIndex index.php index.html index.htm
</Directory>
</VirtualHost>
EOF

# httpd modules array
httpd_mod_list=(
mod_actions.so
mod_auth_digest.so
mod_auth_form.so
mod_authn_anon.so
mod_authn_dbd.so
mod_authn_dbm.so
mod_authn_socache.so
mod_authnz_fcgi.so
mod_authz_dbd.so
mod_authz_dbm.so
mod_authz_owner.so
mod_buffer.so
mod_cache.so
mod_cache_socache.so
mod_case_filter.so
mod_case_filter_in.so
mod_charset_lite.so
mod_data.so
mod_dav.so
mod_dav_fs.so
mod_dav_lock.so
mod_deflate.so
mod_echo.so
mod_expires.so
mod_ext_filter.so
mod_http2.so
mod_include.so
mod_info.so
mod_proxy.so
mod_proxy_connect.so
mod_proxy_fcgi.so
mod_proxy_ftp.so
mod_proxy_html.so
mod_proxy_http.so
mod_proxy_http2.so
mod_proxy_scgi.so
mod_ratelimit.so
mod_reflector.so
mod_request.so
mod_rewrite.so
mod_sed.so
mod_session.so
mod_session_cookie.so
mod_socache_dbm.so
mod_socache_memcache.so
mod_socache_shmcb.so
mod_speling.so
mod_ssl.so
mod_substitute.so
mod_suexec.so
mod_unique_id.so
mod_userdir.so
mod_vhost_alias.so
mod_xml2enc.so
)
    # enable some modules by default
    for mod in ${httpd_mod_list[@]}; do
        if [ -s "${apache_location}/modules/${mod}" ]; then
            sed -i -r "s/^#(.*${mod})/\1/" ${apache_location}/conf/httpd.conf
        fi
    done
    # add mod_md to httpd.conf
    if [[ $(grep -Ec "^\s*LoadModule md_module modules/mod_md.so" ${apache_location}/conf/httpd.conf) -eq 0 ]] && \
       [[ -s "${apache_location}/modules/mod_md.so" ]]; then
        lnum=$(sed -n '/LoadModule/=' ${apache_location}/conf/httpd.conf | tail -1)
        sed -i "${lnum}aLoadModule md_module modules/mod_md.so" ${apache_location}/conf/httpd.conf
    fi

    [ -d "${openssl_location}" ] && sed -i "s@^export LD_LIBRARY_PATH.*@export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${openssl_location}/lib@" ${apache_location}/bin/envvars
    sed -i 's/Allow from All/Require all granted/' ${apache_location}/conf/extra/httpd-vhosts.conf
    sed -i 's/Require host .example.com/Require host localhost/g' ${apache_location}/conf/extra/httpd-info.conf
    cp -f ${cur_dir}/conf/httpd-ssl.conf ${apache_location}/conf/extra/httpd-ssl.conf
    rm -f /etc/init.d/httpd
    cp -f ${cur_dir}/init.d/httpd-init /etc/init.d/httpd
    sed -i "s#^apache_location=.*#apache_location=${apache_location}#" /etc/init.d/httpd
    chmod +x /etc/init.d/httpd
    rm -fr /var/log/httpd /usr/sbin/httpd
    ln -s ${apache_location}/bin/httpd /usr/sbin/httpd
    ln -s ${apache_location}/logs /var/log/httpd
    cp -f ${cur_dir}/conf/index.html ${web_root_dir}
    cp -f ${cur_dir}/conf/index_cn.html ${web_root_dir}
    cp -f ${cur_dir}/conf/lamp.png ${web_root_dir}
    cp -f ${cur_dir}/conf/favicon.ico ${web_root_dir}
    chown -R apache.apache ${web_root_dir}
    boot_start httpd

}

install_apache_modules(){
    if_in_array "${mod_wsgi_filename}" "${apache_modules_install}" && install_mod_wsgi
    if_in_array "${mod_security_filename}" "${apache_modules_install}" && install_mod_security
    if_in_array "${mod_jk_filename}" "${apache_modules_install}" && install_mod_jk
}

install_pcre(){
    cd ${cur_dir}/software/
    _info "Installing ${pcre_filename}..."
    download_file "${pcre_filename}.tar.gz" "${pcre_filename_url}"
    tar zxf ${pcre_filename}.tar.gz
    cd ${pcre_filename}

    error_detect "./configure --prefix=${depends_prefix}/pcre"
    error_detect "parallel_make"
    error_detect "make install"
    add_to_env "${depends_prefix}/pcre"
    create_lib64_dir "${depends_prefix}/pcre"
    _info "Install ${pcre_filename} completed..."
}

install_nghttp2(){
    cd ${cur_dir}/software/
    _info "Installing ${nghttp2_filename}..."
    download_file "${nghttp2_filename}.tar.gz" "${nghttp2_filename_url}"
    tar zxf ${nghttp2_filename}.tar.gz
    cd ${nghttp2_filename}

    if [ -d "${openssl_location}" ]; then
        export OPENSSL_CFLAGS="-I${openssl_location}/include"
        export OPENSSL_LIBS="-L${openssl_location}/lib -lssl -lcrypto"
    fi
    error_detect "./configure --prefix=/usr --enable-lib-only"
    error_detect "parallel_make"
    error_detect "make install"
    unset OPENSSL_CFLAGS OPENSSL_LIBS
    _info "Install ${nghttp2_filename} completed..."
}

install_openssl(){
    local openssl_version=$(openssl version -v)
    local major_version=$(echo ${openssl_version} | awk '{print $2}' | grep -oE "[0-9.]+")

    if version_lt ${major_version} 1.1.1; then
        cd ${cur_dir}/software/
        _info "Installing ${openssl_filename}..."
        download_file "${openssl_filename}.tar.gz" "${openssl_filename_url}"
        tar zxf ${openssl_filename}.tar.gz
        cd ${openssl_filename}

        error_detect "./config --prefix=${openssl_location} -fPIC shared zlib"
        error_detect "make"
        error_detect "make install"

        if ! grep -qE "^${openssl_location}/lib" /etc/ld.so.conf.d/*.conf; then
            echo "${openssl_location}/lib" > /etc/ld.so.conf.d/openssl.conf
        fi
        ldconfig
        _info "Install ${openssl_filename} completed..."
    else
        _info "OpenSSL version is greater than or equal to 1.1.1, installation skipped."
    fi
}

install_mod_wsgi(){
    cd ${cur_dir}/software/
    _info "Installing ${mod_wsgi_filename}..."
    download_file "${mod_wsgi_filename}.tar.gz" "${mod_wsgi_filename_url}"
    tar zxf ${mod_wsgi_filename}.tar.gz
    cd ${mod_wsgi_filename}

    [ -e "/usr/libexec/platform-python" ] && mod_wsgi_configure="--with-python=/usr/libexec/platform-python" || mod_wsgi_configure=""
    error_detect "./configure --with-apxs=${apache_location}/bin/apxs ${mod_wsgi_configure}"
    error_detect "make"
    error_detect "make install"
    # add mod_wsgi to httpd.conf
    if [[ $(grep -Ec "^\s*LoadModule wsgi_module modules/mod_wsgi.so" ${apache_location}/conf/httpd.conf) -eq 0 ]]; then
        lnum=$(sed -n '/LoadModule/=' ${apache_location}/conf/httpd.conf | tail -1)
        sed -i "${lnum}aLoadModule wsgi_module modules/mod_wsgi.so" ${apache_location}/conf/httpd.conf
    fi
    _info "Install ${mod_wsgi_filename} completed..."
}

install_mod_jk(){
    cd ${cur_dir}/software/
    _info "Installing ${mod_jk_filename}..."
    download_file "${mod_jk_filename}.tar.gz" "${mod_jk_filename_url}"
    tar zxf ${mod_jk_filename}.tar.gz
    cd ${mod_jk_filename}/native

    error_detect "./configure --with-apxs=${apache_location}/bin/apxs --enable-api-compatibility"
    error_detect "make"
    error_detect "make install"
    # add mod_jk to httpd.conf
    if [[ $(grep -Ec "^\s*LoadModule jk_module modules/mod_jk.so" ${apache_location}/conf/httpd.conf) -eq 0 ]]; then
        lnum=$(sed -n '/LoadModule/=' ${apache_location}/conf/httpd.conf | tail -1)
        sed -i "${lnum}aLoadModule jk_module modules/mod_jk.so" ${apache_location}/conf/httpd.conf
    fi
    _info "Install ${mod_jk_filename} completed..."
}

install_mod_security(){
    cd ${cur_dir}/software/
    _info "Installing ${mod_security_filename}..."
    download_file "${mod_security_filename}.tar.gz" "${mod_security_filename_url}"
    tar zxf ${mod_security_filename}.tar.gz
    cd ${mod_security_filename}

    error_detect "./configure --prefix=${depends_prefix} --with-apxs=${apache_location}/bin/apxs --with-apr=${apache_location}/bin/apr-1-config --with-apu=${apache_location}/bin/apu-1-config"
    error_detect "make"
    error_detect "make install"
    chmod 755 ${apache_location}/modules/mod_security2.so
    # add mod_security2 to httpd.conf
    if [[ $(grep -Ec "^\s*LoadModule security2_module modules/mod_security2.so" ${apache_location}/conf/httpd.conf) -eq 0 ]]; then
        lnum=$(sed -n '/LoadModule/=' ${apache_location}/conf/httpd.conf | tail -1)
        sed -i "${lnum}aLoadModule security2_module modules/mod_security2.so" ${apache_location}/conf/httpd.conf
    fi
    _info "Install ${mod_security_filename} completed..."
}
