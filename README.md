## 简介
* 1. LAMP 指的是 Linux + Apache + MySQL + PHP 运行环境
* 2. LAMP 一键安装是用 Linux Shell 语言编写的，用于在 Linux 系统(Redhat/CentOS/Fedora)上一键安装 LAMP 环境的工具脚本。

## 本脚本的系统需求
* 需要 2GB 及以上磁盘剩余空间
* 需要 256M 及以上内存空间
* 服务器必须配置好软件源和可连接外网
* 必须具有系统 Root 权限
* 建议使用干净系统全新安装
* 日期：2014年09月22日

## 关于本脚本
* 支持 PHP 自带所有组件；
* 支持 MySQL ，MariaDB， SQLite 数据库;
* 支持 XCache (可选安装)；
* 支持 Zend Guard Loader (可选安装)；
* 支持 OCI8 （可让 PHP 连接 Oracle 数据库，可选安装）；
* 支持 ionCube PHP Loader (可选安装)；
* 支持 pure-ftpd (可选安装)；
* 支持 ImageMagick （可选安装）；
* 命令行新增虚拟主机，操作简便；
* 自助升级 PHP，phpMyAdmin，MySQL 至最新版本；
* 支持创建 FTP 用户；
* 一键卸载。

## 将会安装
* 1、Apache 2.4.10
* 2、MySQL 5.6.20, MariaDB 5.5.39, MariaDB 10.0.13 （三选一安装）
* 3、PHP 5.4.33
* 4、phpMyAdmin 4.2.9
* 5、xcache 3.1.0 (推荐安装)
* 6、OCI8 2.0.8 （可选安装）
* 7、pure-ftpd 1.0.36 （可选安装）
* 8、Zend Guard Loader 3.3（可选安装）
* 9、ionCube PHP Loader 4.6.1（可选安装）
* 10、ImageMagick 6.8.9-6 （可选安装）

## 如何安装
### 事前准备（安装screen、unzip，创建 screen 会话）：

    yum -y install screen unzip
    screen -S lamp

### 第一步，下载、解压、赋予权限：

    wget --no-check-certificate https://github.com/teddysun/lamp/archive/master.zip -O lamp.zip
    unzip lamp.zip
    cd lamp-master/
    chmod +x *.sh

### 第二步，安装LAMP
终端中输入以下命令：

    ./lamp.sh 2>&1 | tee lamp.log

### 安装其它：

* 1、（推荐安装）执行脚本 xcache.sh 安装 xcache 。(命令：./xcache.sh)
* 2、（可选安装）执行脚本 php5.4_oci8_oracle11g.sh 安装 OCI8 扩展以及 oracle-instantclient11.2（命令：./php5.4_oci8_oracle11g.sh）
* 3、（可选安装）执行脚本 pureftpd.sh 安装 pure-ftpd-1.0.36。(命令：./pureftpd.sh)
* 4、（可选安装）执行脚本 ZendGuardLoader.sh 安装 Zend Guard Loader。(命令：./ZendGuardLoader.sh)
* 5、（可选安装）执行脚本 ioncube.sh 安装 ionCube PHP Loader。(命令：./ioncube.sh)
* 6、（可选安装）执行脚本 ImageMagick.sh 安装 ImageMagick 的 PHP 扩展。（命令：./ImageMagick.sh）
* 7、（升级脚本）执行脚本 update.sh 将会升级 PHP 和 phpMyAdmin 至最新版本。(命令：./update.sh | tee update.log)
* 8、（升级脚本）执行脚本 upgrade_mysql.sh 将会升级 MySQL 至 5.6.x 的最新版本。(命令：./upgrade_mysql.sh | tee upgrade_mysql.log)
* 9、（升级脚本）执行脚本 upgrade_mariadb.sh 将会升级 MariaDB 至已安装版本相对应的最新版本。(命令：./upgrade_mariadb.sh | tee upgrade_mariadb.log)

### 关于 update.sh

新增update.sh脚本，目的是为了自动检测和升级PHP和phpMyAdmin。这两种软件版本更新比较频繁，因此才会有此脚本，一劳永逸。

安装完lamp.sh一段时间后，如果你发现PHP或phpMyAdmin官网已更新，那即可运行此脚本更新到最新版。

因PHP5.5.x系列Release没多久，很多软件还不兼容该版本，因此本脚本升级的PHP版本为5.4.x系列的最新版。

**使用方法：**

    ./update.sh | tee update.log

### 关于 upgrade_mysql.sh

新增upgrade_mysql.sh脚本，目的是为了自动检测和升级 MySQL。升级之前自动备份全部数据库，在升级完成之后再将备份恢复。

**使用方法：**

    ./upgrade_mysql.sh | tee upgrade_mysql.log


### 关于 upgrade_mariadb.sh

新增upgrade_mariadb.sh脚本，目的是为了自动检测和升级 MariaDB。升级之前自动备份全部数据库，在升级完成之后再将备份恢复。

**使用方法：**

    ./upgrade_mariadb.sh | tee upgrade_mariadb.log

### 注意事项

1、执行脚本时出现下面的错误提示时该怎么办？

    -bash: ./lamp.sh: /bin/bash^M: bad interpreter: No such file or directory

是因为Windows下和Linux下的文件编码不同所致。
解决办法是执行：

    vi lamp.sh

输入命令

    :set ff=unix 

回车后，输入ZZ（两个大写字母z），即可保存退出。

2、连接外部Oracle服务器出现ORA-24408:could not generate unique server group name这样的错误怎么办？
解决办法是在hosts中将主机名添加即可：

    vi /etc/hosts

    127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4 test
    ::1 localhost localhost.localdomain localhost6 localhost6.localdomain6 test

上面的示例中，最后的那个test即为主机名。更改完毕后，输入ZZ（两个大写字母Z），即可保存退出。
然后重启网络服务即可。

    service network restart

3、增加 FTP 用户相关

在运行 lamp ftp add 命令之前，先要安装 pure-ftpd ，如果开启了防火墙的话，还需要对端口 21 放行。
执行以下命令安装 pure-ftpd：

    ./pureftpd.sh 2>&1 | tee pureftpd.log
    
##使用提示：

* lamp add(del,list)：创建（删除，列出）虚拟主机。
* lamp ftp(add|del|list)：创建（删除，列出） FTP 用户。
* lamp uninstall：一键删除 LAMP （切记，删除之前注意备份好数据！）

##程序目录：

* MySQL 安装目录: /usr/local/mysql
* MySQL 数据库目录：/usr/local/mysql/data（默认路径，安装时可更改）
* MariaDB 安装目录: /usr/local/mariadb
* MariaDB 数据库目录：/usr/local/mariadb/data（默认路径，安装时可更改）
* PHP 安装目录: /usr/local/php
* Apache 安装目录： /usr/local/apache

##命令一览：
* MySQL 或 MariaDB 命令: 

        /etc/init.d/mysqld(start|stop|restart|status)

* Apache 命令: 

        /etc/init.d/httpd(start|stop|restart|status)

##网站根目录：

安装完后默认的网站根目录： /data/www/default

如果你在安装后使用遇到问题，请访问 [http://teddysun.com/lamp](http://teddysun.com/lamp) 或发邮件至 i@teddysun.com

最后，祝你使用愉快！
