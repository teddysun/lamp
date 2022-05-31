<div align="center">
    <a href="https://lamp.sh/" target="_blank">
        <img alt="LAMP" src="https://github.com/teddysun/lamp/blob/master/conf/lamp.png">
    </a>
</div>

## Description

[LAMP](https://lamp.sh/) is a powerful bash script for the installation of Apache + PHP + MySQL/MariaDB and so on. You can install Apache + PHP + MySQL/MariaDB in an very easy way, just need to choose what you want to install before installation. And all things will be done in few minutes.

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

- Amazon Linux 2
- AlmaLinux 8
- AlmaLinux 9
- CentOS 7
- CentOS Stream 8
- CentOS Stream 9
- Rocky Linux 8 (recommend)
- Debian 9
- Debian 10
- Debian 11 (recommend)
- Ubuntu 18.04
- Ubuntu 20.04 (recommend)
- Ubuntu 22.04

## Supported Software

- Apache-2.4 (Include HTTP/2 module: [nghttp2](https://github.com/nghttp2/nghttp2), [mod_http2](https://httpd.apache.org/docs/2.4/mod/mod_http2.html))
- Apache Additional Modules: [mod_wsgi](https://github.com/GrahamDumpleton/mod_wsgi), [mod_security](https://github.com/SpiderLabs/ModSecurity), [mod_jk](https://tomcat.apache.org/download-connectors.cgi)
- MySQL-5.7, MySQL-8.0, MariaDB-10.2, MariaDB-10.3, MariaDB-10.4, MariaDB-10.5, MariaDB-10.6, MariaDB-10.7
- PHP-7.4, PHP-8.0, PHP-8.1
- PHP Additional extensions: [Zend OPcache](https://www.php.net/manual/en/book.opcache.php), [ionCube Loader](https://www.ioncube.com/loaders.php), [PDFlib](https://www.pdflib.com/), [APCu](https://pecl.php.net/package/APCu), [imagick](https://pecl.php.net/package/imagick), [libsodium](https://github.com/jedisct1/libsodium-php), [memcached](https://github.com/php-memcached-dev/php-memcached), [redis](https://github.com/phpredis/phpredis), [mongodb](https://pecl.php.net/package/mongodb), [swoole](https://github.com/swoole/swoole-src), [yaf](https://github.com/laruence/yaf), [yar](https://github.com/laruence/yar), [msgpack](https://pecl.php.net/package/msgpack), [psr](https://github.com/jbboehr/php-psr), [phalcon](https://github.com/phalcon/cphalcon), [grpc](https://github.com/grpc/grpc), [xdebug](https://github.com/xdebug/xdebug)
- Other Software: [OpenSSL](https://github.com/openssl/openssl), [ImageMagick](https://github.com/ImageMagick/ImageMagick), [Memcached](https://github.com/memcached/memcached), [phpMyAdmin](https://github.com/phpmyadmin/phpmyadmin), [Adminer](https://github.com/vrana/adminer), [Redis](https://github.com/redis/redis), [re2c](https://github.com/skvadrik/re2c), [KodExplorer](https://github.com/kalcaddle/KodExplorer)

## Software Version

| Apache & Additional Modules   | Version                                                   |
|-------------------------------|-----------------------------------------------------------|
| httpd                         | 2.4.53                                                    |
| apr                           | 1.7.0                                                     |
| apr-util                      | 1.6.1                                                     |
| nghttp2                       | 1.47.0                                                    |
| openssl                       | 1.1.1o                                                    |
| mod_wsgi                      | 4.9.2                                                     |
| mod_security2                 | 2.9.5                                                     |
| mod_jk                        | 1.2.48                                                    |

| Database                      | Version                                                   |
|-------------------------------|-----------------------------------------------------------|
| MySQL                         | 5.7.38, 8.0.29                                            |
| MariaDB                       | 10.2.44, 10.3.35, 10.4.25, 10.5.16, 10.6.8, 10.7.4        |

| PHP & Additional extensions   | Version                                                   |
|-------------------------------|-----------------------------------------------------------|
| PHP                           | 7.4.29, 8.0.19, 8.1.6                                     |
| ionCube Loader                | 11.0.1                                                    |
| PDFlib                        | 10.0.0                                                    |
| APCu extension                | 5.1.21                                                    |
| gRPC extension                | 1.45.0                                                    |
| ImageMagick                   | 7.1.0-35                                                  |
| imagick extension             | 3.7.0                                                     |
| libsodium                     | 1.0.18                                                    |
| libsodium extension           | 2.0.23                                                    |
| memcached                     | 1.6.6                                                     |
| libmemcached                  | 1.0.18                                                    |
| memcached extension           | 3.1.5                                                     |
| re2c                          | 3.0                                                       |
| redis                         | 5.0.14                                                    |
| redis extension               | 5.3.7                                                     |
| mongodb extension             | 1.12.0                                                    |
| swoole extension              | 4.8.9                                                     |
| yaf extension                 | 3.3.5                                                     |
| yar extension                 | 2.3.2                                                     |
| msgpack extension             | 2.1.2                                                     |
| psr extension                 | 1.2.0                                                     |
| phalcon extension             | 4.1.2                                                     |
| xdebug extension              | 3.1.3                                                     |

| Database Management Tools     | Version                                                   |
|-------------------------------|-----------------------------------------------------------|
| phpMyAdmin                    | 5.2.0                                                     |
| Adminer                       | 4.8.1                                                     |

| File Managerment Tool         | Version                                                   |
|-------------------------------|-----------------------------------------------------------|
| KodExplorer                   | 4.48                                                      |

## Installation

- If your server system: Amazon Linux 2/CentOS/Rocky Linux
```bash
yum -y install wget git
git clone https://github.com/teddysun/lamp.git
cd lamp
chmod 755 *.sh
./lamp.sh
```

- If your server system: Debian/Ubuntu
```bash
apt-get -y install wget git
git clone https://github.com/teddysun/lamp.git
cd lamp
chmod 755 *.sh
./lamp.sh
```

- [Automation install mode](https://lamp.sh/autoinstall.html)
```bash
./lamp.sh -h
```

- Automation install mode example
```bash
./lamp.sh --apache_option 1 --apache_modules mod_wsgi,mod_security --db_option 1 --db_root_pwd teddysun.com --php_option 1 --php_extensions apcu,ioncube,imagick,redis,mongodb,libsodium,swoole --db_manage_modules phpmyadmin,adminer --kodexplorer_option 1
```

## Upgrade

```bash
cd ~/lamp
git reset --hard         // Resets the index and working tree
git pull                 // Get latest version first
chmod 755 *.sh

./upgrade.sh             // Select one to upgrade
./upgrade.sh apache      // Upgrade Apache
./upgrade.sh db          // Upgrade MySQL or MariaDB
./upgrade.sh php         // Upgrade PHP
./upgrade.sh phpmyadmin  // Upgrade phpMyAdmin
./upgrade.sh adminer     // Upgrade Adminer
```

## Backup

- You must modify the config before run it
- Backup MySQL or MariaDB datebases, files and directories
- Backup file is encrypted with AES256-cbc with SHA1 message-digest (Depends on `openssl` command) (option)
- Auto transfer backup file to Google Drive (Depends on [`rclone`](https://teddysun.com/469.html) command) (option)
- Auto transfer backup file to FTP server (Depends on `ftp` command) (option)
- Auto delete remote file from Google Drive or FTP server (option)

```bash
./backup.sh
```

## Uninstall

```bash
./uninstall.sh
```

## Default Installation Location

| Apache Location            | Path                                                |
|----------------------------|-----------------------------------------------------|
| Install prefix             | /usr/local/apache                                   |
| Web root location          | /data/www/default                                   |
| Main configuration File    | /usr/local/apache/conf/httpd.conf                   |
| Default virtual host conf  | /usr/local/apache/conf/vhost/default.conf           |
| Virtual host conf          | /usr/local/apache/conf/vhost/your_virtual_host.conf |
| Virtual host SSL location  | /usr/local/apache/conf/ssl/your_virtual_host        |
| Virtual host location      | /data/www/your_virtual_host_names                   |
| Virtual host log location  | /data/wwwlog/your_virtual_host_names                |

| phpMyAdmin Location        | Path                                                |
|----------------------------|-----------------------------------------------------|
| Installation location      | /data/www/default/phpmyadmin                        |

| Adminer Location           | Path                                                |
|----------------------------|-----------------------------------------------------|
| Installation location      | /data/www/default/adminer.php                       |

| KodExplorer Location       | Path                                                |
|----------------------------|-----------------------------------------------------|
| Installation location      | /data/www/default/kod                               |

| PHP Location               | Path                                                |
|----------------------------|-----------------------------------------------------|
| Install prefix             | /usr/local/php                                      |
| Configuration file         | /usr/local/php/etc/php.ini                          |
| ini additional location    | /usr/local/php/php.d                                |

| MySQL Location             | Path                                                |
|----------------------------|-----------------------------------------------------|
| Install prefix             | /usr/local/mysql                                    |
| Default data location      | /usr/local/mysql/data                               |
| my.cnf configuration File  | /etc/my.cnf                                         |

| MariaDB Location           | Path                                                |
|----------------------------|-----------------------------------------------------|
| Install prefix             | /usr/local/mariadb                                  |
| Default data location      | /usr/local/mariadb/data                             |
| my.cnf configuration file  | /etc/my.cnf                                         |

## Process Management

| Process       | Command                                                 |
|---------------|---------------------------------------------------------|
| Apache        | /etc/init.d/httpd  (start\|stop\|status\|restart)       |
| MySQL/MariaDB | /etc/init.d/mysqld (start\|stop\|status\|restart)       |
| Memcached     | /etc/init.d/memcached (start\|stop\|restart)            |
| Redis-Server  | /etc/init.d/redis-server (start\|stop\|restart)         |

## lamp Command

| Command       | Description                       |
|---------------|-----------------------------------|
| lamp add      | Create a new Apache virtual host  |
| lamp del      | Delete a Apache virtual host      |
| lamp list     | List all of Apache virtual hosts  |
| lamp version  | Print version and exit            |

## Bugs & Issues

Please feel free to report any bugs or issues to us, email to: i@teddysun.com or [open issues](https://github.com/teddysun/lamp/issues) on Github.

Support(Chinese only): https://lamp.sh/support.html

## License

Copyright (C) 2013 - 2022 [Teddysun](https://teddysun.com/)

Licensed under the [GPLv3](LICENSE) License.
