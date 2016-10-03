![LAMP](https://github.com/teddysun/lamp/raw/master/conf/lamp.gif)
Description
===========
LAMP is a powerful bash script for the installation of Apache + PHP + MySQL/MariaDB/Percona and so on.You can install Apache + PHP + MySQL/MariaDB/Percona in an very easy way, Just need to input numbers to choose what you want to install before installation. And all things will be done in a few minutes.

- [Supported System](#supported-system)
- [Supported Software](#supported-software)
- [Installation](#installation)
- [Upgrade](#upgrade)
- [Backup](#backup)
- [Uninstall](#uninstall)
- [Default Location](#default-location)
- [Process Management](#process-management)
- [lamp command](#lamp-command)
- [Bugs & Issues](#bugs--issues)
- [License](#license)

Supported System
===============
- CentOS-5.x
- CentOS-6.x
- CentOS-7.x
- Ubuntu-12.x
- Ubuntu-13.x
- Ubuntu-14.x
- Ubuntu-15.x
- Ubuntu-16.x
- Debian-7.x
- Debian-8.x

Supported Software
==================
- Apache-2.2 Apache-2.4
- MySQL-5.5 MySQL-5.6 MySQL-5.7 MariaDB-5.5 MariaDB-10.0 MariaDB-10.1 Percona-Server-5.5 Percona-Server-5.6 Percona-Server-5.7
- PHP-5.3 PHP-5.4 PHP-5.5 PHP-5.6 PHP-7.0
- PHP Module: OPcache ZendGuardLoader ionCube_Loader XCache Imagemagick GraphicsMagick Memcache Memcached Redis Mongo Swoole
- Other Software: Memcached phpMyAdmin Redis-Server

Installation
============
If your server system: CentOS
```bash
yum -y install wget screen unzip
wget --no-check-certificate -O lamp.zip https://github.com/teddysun/lamp/archive/master.zip
unzip lamp.zip
cd lamp-master
chmod +x *.sh
screen -S lamp
./lamp.sh
```
If your server system: Debian/Ubuntu
```bash
apt-get -y install wget screen unzip
wget --no-check-certificate -O lamp.zip https://github.com/teddysun/lamp/archive/master.zip
unzip lamp.zip
cd lamp-master
chmod +x *.sh
screen -S lamp
./lamp.sh
```

Upgrade
=======
```bash
./upgrade.sh             // Select one to upgrade
./upgrade.sh apache      // Upgrade Apache
./upgrade.sh db          // Upgrade MySQL/MariaDB/Percona
./upgrade.sh php         // Upgrade PHP
./upgrade.sh phpmyadmin  // Upgrade phpMyAdmin
```

Backup
======
- You need to modify the config at first
- Backup MySQL/MariaDB/Percona datebases, files and directories
- Backup file is encrypted with AES256-cbc with SHA1 message-digest
- Auto transfer backup file to Google Drive (need install `gdrive` command)
- Auto delete Google Drive's remote file (option)

```bash
./backup.sh
```

Uninstall
=========
```bash
./uninstall.sh
```

Default Location
================
| Apache Location            |                                                |
|----------------------------|------------------------------------------------|
| Install Prefix             | /usr/local/apache                              |
| Web root location          | /data/www/default                              |
| Main Configuration File    | /usr/local/apache/conf/httpd.conf              |
| Default Virtual Host conf  | /usr/local/apache/conf/extra/httpd-vhosts.conf |
| Virtual Host location      | /usr/local/apache/conf/vhost/                  |

| PHP Location               |                                                |
|----------------------------|------------------------------------------------|
| Install Prefix             | /usr/local/php                                 |
| Configuration File         | /usr/local/php/etc/php.ini                     |
| ini additional location    | /usr/local/php/php.d                           |

| MySQL Location             |                                                |
|----------------------------|------------------------------------------------|
| Install Prefix             | /usr/local/mysql                               |
| Data Location              | /usr/local/mysql/data                          |
| my.cnf Configuration File  | /etc/my.cnf                                    |

| MariaDB Location           |                                                |
|----------------------------|------------------------------------------------|
| Install Prefix             | /usr/local/mariadb                             |
| Data Location              | /usr/local/mariadb/data                        |
| my.cnf Configuration File  | /etc/my.cnf                                    |

| Percona Location           |                                                |
|----------------------------|------------------------------------------------|
| Install Prefix             | /usr/local/percona                             |
| Data Location              | /usr/local/percona/data                        |
| my.cnf Configuration File  | /etc/my.cnf                                    |

Process Management
==================
| Process     | Command                                                 |
|-------------|---------------------------------------------------------|
| Apache      | /etc/init.d/httpd  (start\|stop\|status\|restart)       |
| MySQL       | /etc/init.d/mysqld (start\|stop\|status\|restart)       |
| MariaDB     | /etc/init.d/mysqld (start\|stop\|status\|restart)       |
| Percona     | /etc/init.d/mysqld (start\|stop\|status\|restart)       |
| Memcached   | /etc/init.d/memcached (start\|stop\|restart)            |
| Redis-Server| /etc/init.d/redis-server (start\|stop\|restart)         |

lamp Command
============
| Command    | Description                     |
|------------|---------------------------------|
| lamp add   | create a virtual host           |
| lamp list  | list all virtual host           |
| lamp del   | remove a virtual host           |

Bugs & Issues
=============
Please feel free to report any bugs or issues to us, email: i@teddysun.com

Support(中文):https://lamp.sh/support.html

License
=======
Copyright (C) 2013 - 2016 Teddysun

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
