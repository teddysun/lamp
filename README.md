<div align="center">
    <a href="https://lamp.sh/" target="_blank">
        <img alt="LAMP" src="https://github.com/teddysun/lamp/blob/master/conf/lamp.png">
    </a>
</div>

## Description

LAMP (Linux + Apache + MariaDB + PHP) is a powerful bash script for the installation of Apache + MariaDB + PHP and so on.

You can install Apache + MariaDB + PHP in a smaller memory VPS by `apt-get` command, Just need to input numbers to choose what you want to install before installation.

And all things will be done in a few minutes.

- [Supported System](#supported-system)
- [System requirements](#system-requirements)
- [Supported Software](#supported-software)
- [Supported Architecture](#supported-architecture)
- [Installation](#installation)
- [Upgrade](#upgrade)
- [Uninstall](#uninstall)
- [Default Location](#default-location)
- [Process Management](#process-management)
- [lamp command](#lamp-command)
- [Bugs & Issues](#bugs--issues)
- [License](#license)

## Supported System

- Debian 11
- Debian 12
- Debian 13
- Ubuntu 20.04
- Ubuntu 22.04
- Ubuntu 24.04

## System requirements

- Hard disk space: 5 GiB
- RAM: 512 MiB
- Internet connection is required
- Correct repository
- User: root

## Supported Software

- Apache 2.4  ※ Apache packages provided by Official Repository
- MariaDB 10.11, 11.4, 11.8  ※ MariaDB packages provided by [MariaDB Repository](https://dlm.mariadb.com/browse/mariadb_server/)
- PHP 7.4, 8.0, 8.1, 8.2, 8.3, 8.4, 8.5  ※ PHP packages provided by [deb.sury.org](https://deb.sury.org/)

## Supported Architecture

- x86_64 (amd64)
- aarch64 (arm64)

## Installation

```bash
apt-get -y install wget git
git clone -b deb https://github.com/teddysun/lamp.git
cd lamp
chmod 755 *.sh
./lamp.sh 2>&1 | tee lamp.log
```

## Upgrade

```bash
apt-get install --only-upgrade -y apache2
apt-get install --only-upgrade -y mariadb-*
# for example: php_ver=[7.4|8.0|8.1|8.2|8.3|8.4|8.5]
php_ver="8.4"
apt-get install --only-upgrade -y php${php_ver}-*
```

## Uninstall

```bash
apt-get remove -y apache2
apt-get remove -y mariadb-*
# for example: php_ver=[7.4|8.0|8.1|8.2|8.3|8.4|8.5]
php_ver="8.4"
apt-get remove -y php${php_ver}-*
```

## Default Location

| Apache Location            | Path                                        |
|----------------------------|---------------------------------------------|
| Web root location          | /data/www/default                           |
| Main Configuration File    | /etc/apache2/apache2.conf                   |
| Sites Configuration Folder | /etc/apache2/sites-enabled                  |

| MariaDB Location           | Path                                        |
|----------------------------|---------------------------------------------|
| Data Location              | /var/lib/mysql                              |
| my.cnf File                | /etc/mysql/my.cnf                           |

| PHP Location               | Path                                        |
|----------------------------|---------------------------------------------|
| php-fpm File               | /etc/php/${php_ver}/fpm/pool.d/www.conf     |
| php.ini File               | /etc/php/${php_ver}/fpm/php.ini             |

## Process Management

| Process     | Command                                                    |
|-------------|------------------------------------------------------------|
| Apache      | systemctl [start\|stop\|status\|restart] apache2           |
| MariaDB     | systemctl [start\|stop\|status\|restart] mariadb           |
| PHP         | systemctl [start\|stop\|status\|restart] php${php_ver}-fpm |

## lamp Command

| Command          | Description                                           |
|------------------|-------------------------------------------------------|
| lamp start       | Start all of LAMP services                            |
| lamp stop        | Stop all of LAMP services                             |
| lamp restart     | Restart all of LAMP services                          |
| lamp status      | Check all of LAMP services status                     |
| lamp version     | Print all of LAMP software version                    |
| lamp vhost add   | Create a new Apache virtual host                      |
| lamp vhost list  | List all of Apache virtual hosts                      |
| lamp vhost del   | Delete a Apache virtual host                          |
| lamp db add      | Create a MariaDB database and a user with same name   |
| lamp db list     | List all of MariaDB databases                         |
| lamp db del      | Delete a MariaDB database and a user with same name   |
| lamp db edit     | Update a MariaDB database username's password         |

## Bugs & Issues

Please feel free to report any bugs or issues to us, email to: i@teddysun.com or [open issues](https://github.com/teddysun/lamp/issues) on Github.


## License

Copyright (C) 2013 - 2025 [Teddysun](https://teddysun.com/)

Licensed under the [GPLv3](LICENSE) License.
