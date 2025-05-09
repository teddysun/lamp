<div align="center">
    <a href="https://lamp.sh/" target="_blank">
        <img alt="LAMP" src="https://github.com/teddysun/lamp/blob/master/conf/lamp.png">
    </a>
</div>

## Description

LAMP (Linux + Apache + MariaDB + PHP) is a powerful bash script for the installation of Apache + MariaDB + PHP and so on.

You can install Apache + MariaDB + PHP in a smaller memory VPS by `dnf` command, Just need to input numbers to choose what you want to install before installation.

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

- Enterprise Linux 8 (CentOS Stream 8, RHEL 8, Rocky Linux 8, AlmaLinux 8, Oracle Linux 8)
- Enterprise Linux 9 (CentOS Stream 9, RHEL 9, Rocky Linux 9, AlmaLinux 9, Oracle Linux 9)

## System requirements

- Hard disk space: 5 GiB
- RAM: 512 MiB
- Internet connection is required
- Correct repository
- User: root

## Supported Software

- Apache 2.4  ※ Apache packages provided by [Teddysun Repository](https://dl.lamp.sh/linux/)
- MariaDB 10.11, 11.4  ※ MariaDB packages provided by [MariaDB Repository](https://downloads.mariadb.com/MariaDB/)
- PHP 7.4, 8.0, 8.1, 8.2, 8.3, 8.4  ※ PHP packages provided by [Remi Repository](https://rpms.remirepo.net/)

## Supported Architecture

- x86_64 (amd64)
- aarch64 (arm64)

## Installation

```bash
dnf -y install wget git
git clone -b rpm https://github.com/teddysun/lamp.git
cd lamp
chmod 755 *.sh
./lamp.sh 2>&1 | tee lamp.log
```

## Upgrade

```bash
dnf update -y httpd
dnf update -y MariaDB-*
dnf update -y php-*
```

## Uninstall

```bash
dnf remove -y httpd
dnf remove -y MariaDB-*
dnf remove -y php-*
```

## Default Location

| Apache Location            | Path                                        |
|----------------------------|---------------------------------------------|
| Web root location          | /data/www/default                           |
| Main Configuration File    | /etc/httpd/conf/httpd.conf                  |
| Sites Configuration Folder | /etc/httpd/conf.d/vhost                     |

| MariaDB Location           | Path                                        |
|----------------------------|---------------------------------------------|
| Data Location              | /var/lib/mysql                              |
| my.cnf File                | /etc/my.cnf                                 |

| PHP Location               | Path                                        |
|----------------------------|---------------------------------------------|
| php-fpm File               | /etc/php-fpm.d/www.conf                     |
| php.ini File               | /etc/php.ini                                |

## Process Management

| Process     | Command                                                    |
|-------------|------------------------------------------------------------|
| Apache      | systemctl [start\|stop\|status\|restart] httpd             |
| MariaDB     | systemctl [start\|stop\|status\|restart] mariadb           |
| PHP         | systemctl [start\|stop\|status\|restart] php-fpm           |

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
