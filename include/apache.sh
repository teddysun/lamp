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
    if [ "$apache" != "do_not_install" ]; then
        apache_configure_args="--prefix=${apache_location} \
        --with-pcre=${depends_prefix}/pcre \
        --with-mpm=event \
        --with-included-apr \
        --with-ssl \
        --with-nghttp2 \
        --enable-modules=reallyall \
        --enable-mods-shared=reallyall"
    fi
    log "Info" "Starting to install dependencies packages for Apache..."
    local apt_list=(zlib1g-dev openssl libssl-dev libxml2-dev lynx lua-expat-dev libjansson-dev)
    local yum_list=(zlib-devel openssl-devel libxml2-devel lynx expat-devel lua-devel lua jansson-devel)
    if check_sys packageManager apt; then
        for depend in ${apt_list[@]}; do
            error_detect_depends "apt-get -y install ${depend}"
        done
    elif check_sys packageManager yum; then
        for depend in ${yum_list[@]}; do
            error_detect_depends "yum -y install ${depend}"
        done
    fi
    log "Info" "Install dependencies packages for Apache completed..."

    if ! grep -qE "^/usr/local/lib" /etc/ld.so.conf.d/*.conf; then
        echo "/usr/local/lib" > /etc/ld.so.conf.d/locallib.conf
    fi

    check_installed "install_pcre" "${depends_prefix}/pcre"
    check_installed "install_openssl" "${openssl_location}"
    install_nghttp2

    cd ${cur_dir}/software/
    download_file "${apr_filename}.tar.gz"
    tar zxf ${apr_filename}.tar.gz
    download_file "${apr_util_filename}.tar.gz"
    tar zxf ${apr_util_filename}.tar.gz
    download_file "${apache2_4_filename}.tar.gz"
    tar zxf ${apache2_4_filename}.tar.gz
    cd ${apache2_4_filename}
    mv ${cur_dir}/software/${apr_filename} srclib/apr
    mv ${cur_dir}/software/${apr_util_filename} srclib/apr-util

    LDFLAGS=-ldl
    if [ -d ${openssl_location} ]; then
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

    [ ! -d ${web_root_dir} ] && mkdir -p ${web_root_dir} && chmod -R 755 ${web_root_dir}
    local version=$1

    if [ -f ${apache_location}/conf/httpd.conf ]; then
        cp -f ${apache_location}/conf/httpd.conf ${apache_location}/conf/httpd.conf.bak
    fi

    grep -qE "^\s*#\s*Include conf/extra/httpd-vhosts.conf" ${apache_location}/conf/httpd.conf && \
    sed -i 's#^\s*\#\s*Include conf/extra/httpd-vhosts.conf#Include conf/extra/httpd-vhosts.conf#' ${apache_location}/conf/httpd.conf || \
    sed -i '$aInclude conf/extra/httpd-vhosts.conf' ${apache_location}/conf/httpd.conf

    mv ${apache_location}/conf/extra/httpd-vhosts.conf ${apache_location}/conf/extra/httpd-vhosts.conf.bak
    mkdir -p ${apache_location}/conf/vhost/

    cat > /etc/logrotate.d/httpd <<EOF
${apache_location}/logs/access_log ${apache_location}/logs/error_log {
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

    sed -i 's/^User.*/User apache/i' ${apache_location}/conf/httpd.conf
    sed -i 's/^Group.*/Group apache/i' ${apache_location}/conf/httpd.conf
    sed -i 's/^#ServerName www.example.com:80/ServerName 0.0.0.0:80/' ${apache_location}/conf/httpd.conf
    sed -i 's/^ServerAdmin you@example.com/ServerAdmin admin@localhost/' ${apache_location}/conf/httpd.conf
    sed -i 's@^#Include conf/extra/httpd-info.conf@Include conf/extra/httpd-info.conf@' ${apache_location}/conf/httpd.conf
    sed -i 's@DirectoryIndex index.html@DirectoryIndex index.html index.php@' ${apache_location}/conf/httpd.conf
    sed -i "s@^DocumentRoot.*@DocumentRoot \"${web_root_dir}\"@" ${apache_location}/conf/httpd.conf
    sed -i "s@^<Directory \"${apache_location}/htdocs\">@<Directory \"${web_root_dir}\">@" ${apache_location}/conf/httpd.conf
    echo "ServerTokens ProductOnly" >> ${apache_location}/conf/httpd.conf

    sed -i -r 's/^#(.*mod_cache.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_cache_socache.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_socache_shmcb.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_socache_dbm.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_socache_memcache.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_proxy.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_proxy_connect.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_proxy_ftp.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_proxy_http.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_suexec.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_vhost_alias.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_rewrite.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_deflate.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_expires.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_ssl.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_http2.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_authn_dbm.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_authn_anon.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_authn_dbd.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_authn_socache.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_authz_dbm.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_authz_owner.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_authz_dbd.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_authnz_fcgi.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_auth_form.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_auth_digest.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_proxy_http2.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_proxy_html.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_proxy_fcgi.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_proxy_scgi.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_echo.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_case_filter.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_case_filter_in.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_buffer.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_data.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_ratelimit.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_ext_filter.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_request.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_include.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_reflector.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_substitute.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_sed.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_charset_lite.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_xml2enc.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_session.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_session_cookie.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_dav.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_dav_fs.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_dav_lock.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_info.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_actions.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_speling.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_userdir.so)/\1/' ${apache_location}/conf/httpd.conf
    sed -i -r 's/^#(.*mod_unique_id.so)/\1/' ${apache_location}/conf/httpd.conf
    # add mod_md to httpd.conf
    if [[ `grep -E -c "^\s*LoadModule md_module modules/mod_md.so" ${apache_location}/conf/httpd.conf` -eq 0 ]]; then
        if [ -f ${apache_location}/modules/mod_md.so ]; then
            lnum=$(sed -n '/LoadModule/=' ${apache_location}/conf/httpd.conf | tail -1)
            sed -i "${lnum}aLoadModule md_module modules/mod_md.so" ${apache_location}/conf/httpd.conf
        fi
    fi

    echo "ProtocolsHonorOrder On" >> ${apache_location}/conf/httpd.conf
    echo "Protocols h2 http/1.1" >> ${apache_location}/conf/httpd.conf

    [ -d ${openssl_location} ] && sed -i "s@^export LD_LIBRARY_PATH.*@export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${openssl_location}/lib@" ${apache_location}/bin/envvars

    sed -i 's/Allow from All/Require all granted/' ${apache_location}/conf/extra/httpd-vhosts.conf
    sed -i 's/Require host .example.com/Require host localhost/g' ${apache_location}/conf/extra/httpd-info.conf
    cp -f ${cur_dir}/conf/httpd24-ssl.conf ${apache_location}/conf/extra/httpd-ssl.conf

    rm -f /etc/init.d/httpd
    if centosversion 6; then
        cp -f ${cur_dir}/conf/httpd-init-centos6 /etc/init.d/httpd
    else
        cp -f ${cur_dir}/conf/httpd-init /etc/init.d/httpd
    fi
    sed -i "s#^apache_location=.*#apache_location=$apache_location#" /etc/init.d/httpd
    chmod +x /etc/init.d/httpd

    rm -fr /var/log/httpd /usr/sbin/httpd
    ln -s ${apache_location}/bin/httpd /usr/sbin/httpd
    ln -s ${apache_location}/logs /var/log/httpd

    cp -f ${cur_dir}/conf/index.html ${web_root_dir}
    cp -f ${cur_dir}/conf/index_cn.html ${web_root_dir}
    cp -f ${cur_dir}/conf/lamp.png ${web_root_dir}
    cp -f ${cur_dir}/conf/jquery.js ${web_root_dir}
    cp -f ${cur_dir}/conf/p.php ${web_root_dir}
    cp -f ${cur_dir}/conf/p_cn.php ${web_root_dir}
    cp -f ${cur_dir}/conf/phpinfo.php ${web_root_dir}
    cp -f ${cur_dir}/conf/favicon.ico ${web_root_dir}

    chown -R apache.apache ${web_root_dir}

    boot_start httpd

}

install_apache_modules(){
    if_in_array "${mod_wsgi_filename}" "${apache_modules_install}" && install_mod_wsgi
    if_in_array "${mod_security_filename}" "${apache_modules_install}" && install_mod_security
    if_in_array "${mod_jk_filename}" "${apache_modules_install}" && install_mod_jk
}

install_mod_wsgi(){
    cd ${cur_dir}/software/
    log "Info" "${mod_wsgi_filename} install start..."
    download_file "${mod_wsgi_filename}.tar.gz"
    tar zxf ${mod_wsgi_filename}.tar.gz
    cd ${mod_wsgi_filename}

    error_detect "./configure --with-apxs=${apache_location}/bin/apxs"
    error_detect "make"
    error_detect "make install"
    # add mod_wsgi to httpd.conf
    if [[ `grep -E -c "^\s*LoadModule wsgi_module modules/mod_wsgi.so" ${apache_location}/conf/httpd.conf` -eq 0 ]]; then
        lnum=$(sed -n '/LoadModule/=' ${apache_location}/conf/httpd.conf | tail -1)
        sed -i "${lnum}aLoadModule wsgi_module modules/mod_wsgi.so" ${apache_location}/conf/httpd.conf
    fi
    log "Info" "${mod_wsgi_filename} install completed..."
}

install_mod_jk(){
    cd ${cur_dir}/software/
    log "Info" "${mod_jk_filename} install start..."
    download_file "${mod_jk_filename}.tar.gz"
    tar zxf ${mod_jk_filename}.tar.gz
    cd ${mod_jk_filename}/native

    error_detect "./configure --with-apxs=${apache_location}/bin/apxs --enable-api-compatibility"
    error_detect "make"
    error_detect "make install"
    # add mod_jk to httpd.conf
    if [[ `grep -E -c "^\s*LoadModule jk_module modules/mod_jk.so" ${apache_location}/conf/httpd.conf` -eq 0 ]]; then
        lnum=$(sed -n '/LoadModule/=' ${apache_location}/conf/httpd.conf | tail -1)
        sed -i "${lnum}aLoadModule jk_module modules/mod_jk.so" ${apache_location}/conf/httpd.conf
    fi
    log "Info" "${mod_jk_filename} install completed..."
}

install_mod_security(){
    cd ${cur_dir}/software/
    log "Info" "${mod_security_filename} install start..."
    download_file "${mod_security_filename}.tar.gz"
    tar zxf ${mod_security_filename}.tar.gz
    cd ${mod_security_filename}

    error_detect "./configure --prefix=${depends_prefix} --with-apxs=${apache_location}/bin/apxs --with-apr=${apache_location}/bin/apr-1-config --with-apu=${apache_location}/bin/apu-1-config"
    error_detect "make"
    error_detect "make install"
    chmod 755 ${apache_location}/modules/mod_security2.so
    # add mod_security to httpd.conf
    if [[ `grep -E -c "^\s*LoadModule security2_module modules/mod_security2.so" ${apache_location}/conf/httpd.conf` -eq 0 ]]; then
        lnum=$(sed -n '/LoadModule/=' ${apache_location}/conf/httpd.conf | tail -1)
        sed -i "${lnum}aLoadModule security2_module modules/mod_security2.so" ${apache_location}/conf/httpd.conf
    fi
    log "Info" "${mod_security_filename} install completed..."
}
