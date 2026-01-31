<div align="center">
    <a href="https://lamp.sh/" target="_blank">
        <img alt="LAMP" src="https://raw.githubusercontent.com/teddysun/lamp/master/conf/lamp.png" width="600">
    </a>
    <h1>LAMP Stack Installation Scripts</h1>
    <p>
        <a href="https://github.com/teddysun/lamp/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/teddysun/lamp?style=flat-square"></a>
        <img src="https://img.shields.io/badge/Apache%20httpd-2.4-D22128?style=flat-square&logo=apache&logoColor=white" alt="Apache httpd 2.4">
        <img src="https://img.shields.io/badge/MariaDB-10.11|11.4|11.8-003545?style=flat-square&logo=mariadb&logoColor=white" alt="MariaDB">
        <img src="https://img.shields.io/badge/PHP-7.4~8.5-777BB4?style=flat-square&logo=php&logoColor=white" alt="PHP">
        <a href="LICENSE"><img alt="License" src="https://img.shields.io/github/license/teddysun/lamp?style=flat-square&color=blue"></a>
    </p>
    <p>A powerful bash script for automated installation of Apache + MariaDB + PHP</p>
</div>

---

## 📖 Table of Contents

- [Description](#-description)
- [Supported System](#-supported-system)
- [System Requirements](#-system-requirements)
- [Supported Software](#-supported-software)
- [Supported Architecture](#-supported-architecture)
- [Installation](#-installation)
- [Upgrade](#-upgrade)
- [Uninstall](#-uninstall)
- [Default Location](#-default-location)
- [Process Management](#-process-management)
- [lamp Command](#-lamp-command)
- [Bugs & Issues](#-bugs--issues)
- [License](#-license)

---

## 📝 Description

**LAMP** (**L**inux + **A**pache + **M**ariaDB + **P**HP) is a powerful bash script for the installation of Apache + MariaDB + PHP and so on.

You can install Apache + MariaDB + PHP in a smaller memory VPS by package manager command (`dnf` for Enterprise Linux, `apt-get` for Debian/Ubuntu). Just need to input numbers to choose what you want to install before installation.

> ⚡ All things will be done in a few minutes.

---

## 🖥️ Supported System

### Enterprise Linux (RPM)

| Distribution | Versions |
|-------------|----------|
| **Enterprise Linux** | 8 / 9 / 10 (CentOS Stream, RHEL, Rocky Linux, AlmaLinux, Oracle Linux) |
| **Debian** | 11 / 12 / 13 |
| **Ubuntu** | 20.04 / 22.04 / 24.04 |

---

## ⚙️ System Requirements

| Requirement | Minimum |
|-------------|---------|
| Disk Space | 5 GiB |
| RAM | 512 MiB |
| Network | Internet connection required |
| Repository | Correct system repository |
| User | root |

---

## 🛠️ Supported Software

| Software | Versions | Package Source (RPM) | Package Source (DEB) |
|----------|----------|---------------------|---------------------|
| Apache | 2.4 | [Teddysun Repository](https://dl.lamp.sh/linux/) | Official Repository |
| MariaDB | 10.11, 11.4, 11.8 | [MariaDB Repository](https://dlm.mariadb.com/browse/mariadb_server/) | [MariaDB Repository](https://dlm.mariadb.com/browse/mariadb_server/) |
| PHP | 7.4, 8.0, 8.1, 8.2, 8.3, 8.4, 8.5 | [Remi Repository](https://rpms.remirepo.net/) | [deb.sury.org](https://deb.sury.org/) |

---

## 🏗️ Supported Architecture

- `x86_64` (amd64)
- `aarch64` (arm64)

---

## 🚀 Installation

### Enterprise Linux 8 / 9 / 10

```bash
# Install dependencies
dnf -y install wget git

# Clone repository
git clone -b rpm https://github.com/teddysun/lamp.git
cd lamp

# Make scripts executable and run
chmod 755 *.sh
./lamp.sh 2>&1 | tee lamp.log
```

### Debian 11 ~ 13 / Ubuntu 20.04 ~ 24.04

```bash
# Install dependencies
apt-get -y install wget git

# Clone repository
git clone -b deb https://github.com/teddysun/lamp.git
cd lamp

# Make scripts executable and run
chmod 755 *.sh
./lamp.sh 2>&1 | tee lamp.log
```

---

## ⬆️ Upgrade

### Enterprise Linux 8 / 9 / 10

```bash
# Upgrade Apache
dnf update -y httpd

# Upgrade MariaDB
dnf update -y MariaDB-*

# Upgrade PHP
dnf update -y php-*
```

#### Upgrade PHP Major Version (e.g., 8.3 → 8.4)

```bash
dnf module switch-to php:remi-8.4
```

### Debian 11 ~ 13 / Ubuntu 20.04 ~ 24.04

```bash
# Upgrade Apache
apt-get install --only-upgrade -y apache2

# Upgrade MariaDB
apt-get install --only-upgrade -y mariadb-*

# Upgrade PHP (replace 8.4 with your version)
php_ver="8.4"
apt-get install --only-upgrade -y php${php_ver}-*
```

---

## 🗑️ Uninstall

### Enterprise Linux 8 / 9 / 10

```bash
# Remove Apache
dnf remove -y httpd

# Remove MariaDB
dnf remove -y MariaDB-*

# Remove PHP
dnf remove -y php-*
```

### Debian 11 ~ 13 / Ubuntu 20.04 ~ 24.04

```bash
# Remove Apache
apt-get remove -y apache2

# Remove MariaDB
apt-get remove -y mariadb-*

# Remove PHP (replace 8.4 with your version)
php_ver="8.4"
apt-get remove -y php${php_ver}-*
```

---

## 📁 Default Location

### Apache

| Location | Enterprise Linux | Debian/Ubuntu |
|----------|------------------|---------------|
| Web root | `/data/www/default` | `/data/www/default` |
| Main configuration | `/etc/httpd/conf/httpd.conf` | `/etc/apache2/apache2.conf` |
| Sites configuration | `/etc/httpd/conf.d/vhost` | `/etc/apache2/sites-enabled` |

### MariaDB

| Location | Enterprise Linux | Debian/Ubuntu |
|----------|------------------|---------------|
| Data location | `/var/lib/mysql` | `/var/lib/mysql` |
| Configuration | `/etc/my.cnf` | `/etc/mysql/my.cnf` |

### PHP

| Location | Enterprise Linux | Debian/Ubuntu |
|----------|------------------|---------------|
| php-fpm configuration | `/etc/php-fpm.d/www.conf` | `/etc/php/${php_ver}/fpm/pool.d/www.conf` |
| php.ini | `/etc/php.ini` | `/etc/php/${php_ver}/fpm/php.ini` |

> **Note:** For Debian/Ubuntu, replace `${php_ver}` with your PHP version (e.g., `8.4`).

---

## ⚡ Process Management

### Enterprise Linux 8 / 9 / 10

| Process | Command |
|---------|---------|
| Apache | `systemctl [start\|stop\|status\|restart] httpd` |
| MariaDB | `systemctl [start\|stop\|status\|restart] mariadb` |
| PHP-FPM | `systemctl [start\|stop\|status\|restart] php-fpm` |

### Debian 11 ~ 13 / Ubuntu 20.04 ~ 24.04

| Process | Command |
|---------|---------|
| Apache | `systemctl [start\|stop\|status\|restart] apache2` |
| MariaDB | `systemctl [start\|stop\|status\|restart] mariadb` |
| PHP-FPM | `systemctl [start\|stop\|status\|restart] php${php_ver}-fpm` |

> **Note:** For Debian/Ubuntu PHP-FPM, replace `${php_ver}` with your PHP version (e.g., `php8.4-fpm`).

---

## 💻 lamp Command

| Command | Description |
|---------|-------------|
| `lamp start` | Start all LAMP services |
| `lamp stop` | Stop all LAMP services |
| `lamp restart` | Restart all LAMP services |
| `lamp status` | Check all LAMP services status |
| `lamp version` | Print all LAMP software versions |
| `lamp vhost add` | Create a new Apache virtual host |
| `lamp vhost list` | List all Apache virtual hosts |
| `lamp vhost del` | Delete an Apache virtual host |
| `lamp db add` | Create a MariaDB database and user |
| `lamp db list` | List all MariaDB databases |
| `lamp db del` | Delete a MariaDB database and user |
| `lamp db edit` | Update a MariaDB user's password |

---

## 🐛 Bugs & Issues

Please feel free to report any bugs or issues:

- 📧 Email: [i@teddysun.com](mailto:i@teddysun.com)
- 🐙 GitHub: [Open an issue](https://github.com/teddysun/lamp/issues)

---

## 📄 License

Copyright © 2013 - 2026 [Teddysun](https://teddysun.com/)

Licensed under the [GPLv3](LICENSE) License.

