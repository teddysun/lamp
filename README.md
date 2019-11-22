<div align="center">
    <a href="https://lamp.sh/" target="_blank">
        <img alt="LAMP" src="https://github.com/teddysun/lamp/blob/master/conf/lamp.png">
    </a>
</div>

## Description

[LAMP](https://lamp.sh/) is a powerful bash script for the installation of Apache + PHP + MySQL/MariaDB/Percona Server and so on. You can install Apache + PHP + MySQL/MariaDB/Percona Server in an very easy way, just need to choose what you want to install before installation. And all things will be done in few minutes.

- [Supported System](#supported-system)
- [Supported Software](#supported-software)
- [Software Version](#software-version)
- [Installation](#installation)
- [Upgrade](#upgrade)
- [Backup](#backup)
- [Uninstall](#uninstall)
- [Default Installation Location](#default-installation-location)
- [Process Management](#process-management)
- [lamp command](#lamp-command)
- [Bugs & Issues](#bugs--issues)
- [License](#license)

## Supported System

- Amazon Linux 2018.03
- CentOS-6.x
- CentOS-7.x (recommend)
- Fedora-29
- Debian-8.x
- Debian-9.x (recommend)
- Ubuntu-16.x
- Ubuntu-18.x (recommend)

## Supported Software

- Apache-2.4 (Include HTTP/2 module: [nghttp2](https://github.com/nghttp2/nghttp2), [mod_http2](https://httpd.apache.org/docs/2.4/mod/mod_http2.html))
- Apache Additional Modules: [mod_wsgi](https://github.com/GrahamDumpleton/mod_wsgi), [mod_security](https://github.com/SpiderLabs/ModSecurity), [mod_jk](https://tomcat.apache.org/download-connectors.cgi)
- MySQL-5.5, MySQL-5.6, MySQL-5.7, MySQL-8.0, MariaDB-5.5, MariaDB-10.0, MariaDB-10.1, MariaDB-10.2, MariaDB-10.3, MariaDB-10.4, Percona-Server-5.5, Percona-Server-5.6, Percona-Server-5.7, Percona-Server-8.0
- PHP-5.6, PHP-7.0, PHP-7.1, PHP-7.2, PHP-7.3
- PHP Additional extensions: Zend OPcache, [ionCube Loader](https://www.ioncube.com/loaders.php), [XCache](https://xcache.lighttpd.net/), [imagick](https://pecl.php.net/package/imagick), [gmagick](https://pecl.php.net/package/gmagick), [libsodium](https://github.com/jedisct1/libsodium-php), [memcached](https://github.com/php-memcached-dev/php-memcached), [redis](https://github.com/phpredis/phpredis), [mongodb](https://pecl.php.net/package/mongodb), [swoole](https://github.com/swoole/swoole-src), [yaf](https://github.com/laruence/yaf), [xdebug](https://github.com/xdebug/xdebug)
- Other Software: [OpenSSL](https://github.com/openssl/openssl), [ImageMagick](https://github.com/ImageMagick/ImageMagick), [GraphicsMagick](http://www.graphicsmagick.org/), [Memcached](https://github.com/memcached/memcached), [phpMyAdmin](https://github.com/phpmyadmin/phpmyadmin), [Redis](https://github.com/antirez/redis), [re2c](https://github.com/skvadrik/re2c), [KodExplorer](https://github.com/kalcaddle/KodExplorer)

## Software Version

| Apache & Additional Modules | Version                                            |
|-----------------------------|----------------------------------------------------|
| httpd                       | 2.4.41                                             |
| apr                         | 1.7.0                                              |
| apr-util                    | 1.6.1                                              |
| nghttp2                     | 1.40.0                                             |
| openssl                     | 1.1.1d                                             |
| mod_wsgi                    | 4.6.5                                              |
| mod_security2               | 2.9.3                                              |
| mod_jk                      | 1.2.46                                             |

| Database                    | Version                                            |
|-----------------------------|----------------------------------------------------|
| MySQL                       | 5.5.62, 5.6.46, 5.7.28, 8.0.18                     |
| MariaDB                     | 5.5.66, 10.0.38, 10.1.43, 10.2.29, 10.3.20, 10.4.10|
| Percona-Server              | 5.5.62-38.14, 5.6.46-86.2, 5.7.28-31, 8.0.16-7     |

| PHP & Additional extensions | Version                                            |
|-----------------------------|----------------------------------------------------|
| PHP                         | 5.6.40, 7.0.33, 7.1.33, 7.2.25, 7.3.12             |
| ionCube Loader              | 10.3.9                                             |
| XCache(PHP 5.6 only)        | 3.2.0                                              |
| ImageMagick                 | 7.0.8-68                                           |
| imagick extension           | 3.4.4                                              |
| GraphicsMagick              | 1.3.33                                             |
| gmagick extension(PHP 5.6)  | 1.1.7RC3                                           |
| gmagick extension(PHP 7)    | 2.0.5RC1                                           |
| libsodium                   | 1.0.18                                             |
| libsodium extension         | 2.0.22                                             |
| memcached                   | 1.5.19                                             |
| libmemcached                | 1.0.18                                             |
| memcached extension(PHP 5.6)| 2.2.0                                              |
| memcached extension(PHP 7)  | 3.1.3                                              |
| redis                       | 5.0.6                                              |
| redis extension(PHP 5.6)    | 4.3.0                                              |
| redis extension(PHP 7)      | 5.0.2                                              |
| mongodb extension           | 1.6.0                                              |
| swoole extension(PHP 7 only)| 4.4.8                                              |
| yaf extension(PHP 7 only)   | 3.0.8                                              |
| xdebug extension(PHP 5.6)   | 2.5.5                                              |
| xdebug extension(PHP 7)     | 2.7.2                                              |
| phpMyAdmin                  | 4.9.1                                              |
| KodExplorer                 | 4.35                                               |

## Installation

- If your server system: Amazon Linux/CentOS/Fedora
```bash
yum -y install wget screen git
git clone https://github.com/teddysun/lamp.git
cd lamp
chmod 755 *.sh
screen -S lamp
./lamp.sh
```

- If your server system: Debian/Ubuntu
```bash
apt-get -y install wget screen git
git clone https://github.com/teddysun/lamp.git
cd lamp
chmod 755 *.sh
screen -S lamp
./lamp.sh
```

- [Automation install mode](https://lamp.sh/autoinstall.html)
```bash
~/lamp/lamp.sh -h
```

- Automation install mode example
```bash
~/lamp/lamp.sh --apache_option 1 --apache_modules mod_wsgi,mod_security --db_option 3 --db_root_pwd teddysun.com --php_option 4 --php_extensions ioncube,imagick,redis,mongodb,libsodium,swoole --phpmyadmin_option 1 --kodexplorer_option 1
```

## Upgrade

```bash
cd ~/lamp
git reset --hard         // Resets the index and working tree
git pull                 // Get latest version first
chmod 755 *.sh

./upgrade.sh             // Select one to upgrade
./upgrade.sh apache      // Upgrade Apache
./upgrade.sh db          // Upgrade MySQL/MariaDB/Percona
./upgrade.sh php         // Upgrade PHP
./upgrade.sh phpmyadmin  // Upgrade phpMyAdmin
```

## Backup

- You must modify the config before run it
- Backup MySQL/MariaDB/Percona datebases, files and directories
- Backup file is encrypted with AES256-cbc with SHA1 message-digest (option)
- Auto transfer backup file to Google Drive (need install [gdrive](https://teddysun.com/469.html) command) (option)
- Auto transfer backup file to FTP server (option)
- Auto delete Google Drive's or FTP server's remote file (option)

```bash
./backup.sh
```

## Uninstall

```bash
./uninstall.sh
```

## Default Installation Location

| Apache Location            | Path                                           |
|----------------------------|------------------------------------------------|
| Install Prefix             | /usr/local/apache                              |
| Web root location          | /data/www/default                              |
| Main Configuration File    | /usr/local/apache/conf/httpd.conf              |
| Default Virtual Host conf  | /usr/local/apache/conf/extra/httpd-vhosts.conf |
| Virtual Host location      | /data/www/virtual_host_names                   |
| Virtual Host log location  | /data/wwwlog/virtual_host_names                |
| Virtual Host conf          | /usr/local/apache/conf/vhost/virtual_host.conf |

| phpMyAdmin Location        | Path                                           |
|----------------------------|------------------------------------------------|
| Installation location      | /data/www/default/phpmyadmin                   |

| KodExplorer Location       | Path                                           |
|----------------------------|------------------------------------------------|
| Installation location      | /data/www/default/kod                          |

| PHP Location               | Path                                           |
|----------------------------|------------------------------------------------|
| Install Prefix             | /usr/local/php                                 |
| Configuration File         | /usr/local/php/etc/php.ini                     |
| ini additional location    | /usr/local/php/php.d                           |

| MySQL Location             | Path                                           |
|----------------------------|------------------------------------------------|
| Install Prefix             | /usr/local/mysql                               |
| Data Location              | /usr/local/mysql/data                          |
| my.cnf Configuration File  | /etc/my.cnf                                    |

| MariaDB Location           | Path                                           |
|----------------------------|------------------------------------------------|
| Install Prefix             | /usr/local/mariadb                             |
| Data Location              | /usr/local/mariadb/data                        |
| my.cnf Configuration File  | /etc/my.cnf                                    |

| Percona Location           | Path                                           |
|----------------------------|------------------------------------------------|
| Install Prefix             | /usr/local/percona                             |
| Data Location              | /usr/local/percona/data                        |
| my.cnf Configuration File  | /etc/my.cnf                                    |

## Process Management

| Process     | Command                                                 |
|-------------|---------------------------------------------------------|
| Apache      | /etc/init.d/httpd  (start\|stop\|status\|restart)       |
| MySQL       | /etc/init.d/mysqld (start\|stop\|status\|restart)       |
| MariaDB     | /etc/init.d/mysqld (start\|stop\|status\|restart)       |
| Percona     | /etc/init.d/mysqld (start\|stop\|status\|restart)       |
| Memcached   | /etc/init.d/memcached (start\|stop\|restart)            |
| Redis-Server| /etc/init.d/redis-server (start\|stop\|restart)         |

## lamp Command

| Command    | Description                     |
|------------|---------------------------------|
| lamp add   | create a virtual host           |
| lamp list  | list all virtual host           |
| lamp del   | remove a virtual host           |

## Bugs & Issues

Please feel free to report any bugs or issues to us, email to: i@teddysun.com or [open issues](https://github.com/teddysun/lamp/issues) on Github.

Support(Chinese only): https://lamp.sh/support.html

## License

Copyright (C) 2013 - 2019 [Teddysun](https://teddysun.com/)

Licensed under the [GPLv3](LICENSE) License.
