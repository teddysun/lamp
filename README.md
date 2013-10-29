## 简介
1.  `LAMP` 指的是 `Linux` + `Apache` + `MySQL` + `PHP` 运行环境。
2.	`LAMP` 一键安装是用 `Linux Shell` 语言编写的，用于在 `Linux` 系统(`Redhat`/`CentOS`/`Fedora`)上一键安装 `LAMP`环境的工具脚本。

## 本脚本的系统需求
* 需要`2GB`以上磁盘剩余空间
* 需要`256M`及以上内存空间
* 服务器必须配置好软件源和可连接外网
* 必须具有系统`Root`权限
* 建议使用干净系统全新安装
* Release日期：2013年10月23日

## 将会安装
* 1、`Apache 2.4.6`
* 2、`MySQL 5.6.14`
* 3、`PHP 5.4.21`
* 4、`phpMyAdmin 4.0.8`
* 5、`OCI8 + oracle-instantclient`  (可选安装，支持`PHP`连接`Oracle`数据库)
* 6、`xcache 2.0.1` (可选安装)
* 7、`xcache 3.0.3` (推荐安装)
* 8、`pure-ftpd-1.0.36`（可选安装）

**注意**：6、7二者只能选其一安装

## 如何安装
### 第一步，终端中输入以下命令：

    cd /root
    wget http://teddysun.googlecode.com/files/lamp2.2.tar.gz
    tar -zxvf lamp2.2.tar.gz
    cd /root/lamp2.2
    chmod +x *.sh

### 第二步，安装LAMP
终端中输入以下命令：

    cd /root/lamp2.2
    ./lamp.sh | tee lamp.log

### 安装其它：

* 1、（可选安装）执行脚本`xcache_2.0.1.sh`安装`xcache 2.0.1`。(命令：`./xcache_2.0.1.sh`)
*   （推荐安装）执行脚本`xcache_3.0.3.sh`安装`xcache 3.0.3`。(命令：`./xcache_3.0.3.sh`)
* 2、执行脚本`php5.4_oci8_oracle11g.sh`安装OCI8扩展以及`oracle-instantclient11.2`（命令：`./php5.4_oci8_oracle11g.sh`）
* 3、执行脚本`php5.4_oci8_oracle10g.sh`安装OCI8扩展以及`oracle-instantclient10.2`（命令：`./php5.4_oci8_oracle10g.sh`）
* 4、（可选安装）执行脚本`pureftpd.sh`安装`pure-ftpd-1.0.36`。(命令：`./pureftpd.sh`)

**备注**：2、3两者选其一执行即可（可选）。该脚本是为了使`PHP`可以连接`Oracle`数据库。若连接的数据库版本为10.2，则执行3，否则执行2。


**关于升级脚本**

新增`update.sh`脚本，目的是为了自动检测和升级`PHP、phpMyAdmin`。这两种软件版本更新比较频繁，因此才会有此脚本，一劳永逸。

安装完`lamp.sh`一段时间后，如果你发现`PHP`或`phpMyAdmin`官网已更新，那即可运行此脚本更新到最新版。

2013/08/23修改：PHP5.5.x系列Release没多久，待测试其兼容性后再做升级，因此该脚本升级PHP的版本为5.4.x系列的最新版。
###使用方法：

    ./update.sh | tee update.log

**注意:**

1、执行脚本时出现下面的错误提示时。

    -bash: ./lamp.sh: /bin/bash^M: bad interpreter: No such file or directory

是因为`Windows`下和`Linux`下的文件编码不同所致。
解决办法是执行：

    vi lamp.sh
输入命令

    :set ff=unix 

回车后，输入ZZ（即Shift+zz），即可保存退出。

2、Oracle数据库连接错误排查
一般连接外部oracle服务器那一步骤时，可能会出现`ORA-24408:could not generate unique server group name`这样的错误，解决办法是在`hosts`中将主机名添加即可：

    vi /etc/hosts

    127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4 test
    ::1 localhost localhost.localdomain localhost6 localhost6.localdomain6 test

上面的代码中，`test`即为主机名。然后重启网络服务即可。

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
