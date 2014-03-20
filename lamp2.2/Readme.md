## 简介
* 1.  `LAMP` 指的是 `Linux` + `Apache` + `MySQL` + `PHP` 运行环境
* 2.  `LAMP` 一键安装是用 `Linux Shell` 语言编写的，用于在 `Linux` 系统(`Redhat`/`CentOS`/`Fedora`)上一键安装 `LAMP`环境的工具脚本。

## 本脚本的系统需求
* 需要`2GB`及以上磁盘剩余空间
* 需要`256M`及以上内存空间
* 服务器必须配置好软件源和可连接外网
* 必须具有系统`Root`权限
* 建议使用干净系统全新安装
* 日期：2014年03月20日

## 关于本脚本
* 支持`PHP`自带所有组件；
* 第三方组件支持`Zend`和`XCache`(可选安装)；
* 支持ZendGuardLoader(可选安装)；
* 支持`MySQL`和`SQLite`数据库;
* 支持OCI8组件（可让`PHP`连接`Oracle`数据库）；
* 命令行新增虚拟主机，操作简便；
* 自助升级`PHP`和`phpMyAdmin`版本；
* 支持创建`FTP`用户；
* 卸载简便。

## 将会安装
* 1、`Apache 2.4.9`
* 2、`MySQL 5.6.16`
* 3、`PHP 5.4.26`
* 4、`phpMyAdmin 4.1.9`
* 5、`xcache 3.1.0` (推荐安装)
* 6、`OCI8 + oracle-instantclient`（可选安装，支持`PHP`连接`Oracle`数据库）
* 7、`pure-ftpd-1.0.36`（可选安装）
* 8、`ZendGuardLoader`（可选安装）

## 如何安装
### 第一步，终端中输入以下命令：

    cd /root
    wget --no-check-certificate https://github.com/teddysun/lamp/archive/master.zip -O lamp.zip
    unzip lamp.zip
    cd /root/lamp-master/lamp2.2
    chmod +x *.sh

### 第二步，安装LAMP
终端中输入以下命令：

    cd /root/lamp-master/lamp2.2
    ./lamp.sh | tee lamp.log

### 安装其它：

* 1、（推荐安装）执行脚本`xcache_3.1.0.sh`安装`xcache 3.1.0`。(命令：`./xcache_3.1.0.sh`)
* 2、执行脚本`php5.4_oci8_oracle11g.sh`安装OCI8扩展以及`oracle-instantclient11.2`（命令：`./php5.4_oci8_oracle11g.sh`）
* 3、（可选安装）执行脚本`pureftpd.sh`安装`pure-ftpd-1.0.36`。(命令：`./pureftpd.sh`)
* 4、（可选安装）执行脚本`ZendGuardLoader.sh`安装`ZendGuardLoader`。(命令：`./ZendGuardLoader.sh`)

**备注**：脚本`php5.4_oci8_oracle11g.sh`是为了使`PHP`可以连接`Oracle`数据库。


**关于update.sh**

新增`update.sh`脚本，目的是为了自动检测和升级`PHP、phpMyAdmin`。这两种软件版本更新比较频繁，因此才会有此脚本，一劳永逸。

安装完`lamp.sh`一段时间后，如果你发现`PHP`或`phpMyAdmin`官网已更新，那即可运行此脚本更新到最新版。

因PHP5.5.x系列Release没多久，很多软件还不兼容该版本，因此本脚本升级的PHP版本为5.4.x系列的最新版。
###使用方法：

    ./update.sh | tee update.log

**FAQ**

1、执行脚本时出现下面的错误提示时该怎么办？

    -bash: ./lamp.sh: /bin/bash^M: bad interpreter: No such file or directory

是因为`Windows`下和`Linux`下的文件编码不同所致。
解决办法是执行：

    vi lamp.sh
输入命令

    :set ff=unix 

回车后，输入ZZ（两个大写字母Z），即可保存退出。

2、连接外部`Oracle`服务器出现`ORA-24408:could not generate unique server group name`这样的错误怎么办？
解决办法是在`hosts`中将主机名添加即可：

    vi /etc/hosts

    127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4 test
    ::1 localhost localhost.localdomain localhost6 localhost6.localdomain6 test

上面的示例中，最后的那个`test`即为主机名。更改完毕后，输入ZZ（两个大写字母Z），即可保存退出。
然后重启网络服务即可。

    service network restart

##使用提示：

* lamp add(del,list)：创建（删除，列出）虚拟主机。
* lamp ftp(add|del|list)：创建（删除，列出）ftp用户。
* lamp uninstall：一键删除lamp（删除之前注意备份好数据！）

##程序目录：

* `mysql`安装目录: `/usr/local/mysql`
* `mysql data`目录：`/usr/local/mysql/data`（默认，安装时可更改路径）
* `php`安装目录: `/usr/local/php`
* `apache`安装目录： `/usr/local/apache`

##命令一览：
* mysql命令: /etc/init.d/mysqld(start|stop|restart|reload|status)

      或：service mysqld(start|stop|restart|reload|status)
* apache命令: /etc/init.d/httpd(start|stop|restart|reload|status)

       或：service httpd(start|stop|restart|reload|status)      

##网站根目录：

安装完后默认的web根目录： `/data/www/default`

如果你在安装后使用遇到问题，请访问[http://teddysun.com/lamp](http://teddysun.com/lamp)，提交评论，我会及时回复。

最后，祝你使用愉快！
