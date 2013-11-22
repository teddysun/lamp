###版本`2.2`：`Release date:2013/11/22`
更新记录：

* 1、升级`phpMyAdmin`到版本为`4.0.9`；
* 2、升级`PHP`到版本为`5.4.22`；
* 3、优化`lamp.sh`脚本代码逻辑，使其充分利用多核处理器的性能，编译更快；

###版本`2.2`：`Release date:2013/11/04`
更新记录：

* 1、升级`phpMyAdmin`到版本为`4.0.8`；
* 2、升级`PHP`到版本为`5.4.21`；
* 3、升级`MySQL`到版本`5.6.14`；
* 4、优化升级脚本`update.sh`的逻辑，修复因官网改版，判断PHP版本出错的问题;
* 5、新增脚本`xcache_3.1.0.sh`。

###版本`2.1`：`Release date:2013/07/24`
更新记录：

* 1、升级`MySQL`到版本`5.6.12`；
* 2、升级`PHP`到版本为`5.4.17`；
* 3、升级`Apache`到版本`2.4.6`；
* 4、升级`phpMyAdmin`到版本`4.0.4.1`；
* 5、升级`Apache`的依赖包`apr`到版本`1.4.8`；
* 6、升级`Xcache`到版本`3.0.3`，其安装脚本名从`xcache_3.0.1.sh`改为`xcache_3.0.3.sh`。


###版本`2.0`：`Release date:2013/05/13`
更新记录：

* 1、升级`phpMyAdmin`到版本为`4.0.0`；
* 2、升级`PHP`到版本为`5.4.15`；
* 3、优化脚本`update.sh`，修复了安装完新版`PHP`后已安装的`extensions`丢失的`bug`。

**备注：**版本号不作调整，依旧为2.0，替换了原来的下载文件。

###版本`2.0`：`Release date:2013/04/28`
更新记录：

* 1、升级`MySQL`版本为`5.6.11`；
* 2、升级`phpMyAdmin`到版本为`3.5.8.1`；
* 3、增加升级`PHP`和`phpMyAdmin`脚本`update.sh`,可以自动检测最新版`PHP`和`phpMyAdmin`供选择升级;
* 4、合并原来禁止`SELINUX`的脚本`disable.sh`到`lamp.sh`中。

###版本`1.3.1`：`Release date:2013/04/13`
更新记录：

* 1、升级`PHP`到版本`5.4.14`。

###版本`1.3`：`Release date:2013/04/11`
更新记录：

* 1、升级`PHP`到版本`5.4.13`；
* 2、升级`MySQL`版本为`5.6.10`；
* 3、升级`phpMyAdmin`到版本为`3.5.8`；
* 4、升级`Apache`到版本为`2.4.4`；
* 5、升级`apr-util`到版本`1.5.2`；
* 6、优化`oci8_oracle`脚本，配置其`extension为no-debug-non-zts-20100525`；
* 7、优化`xcache`脚本，配置其`extension为no-debug-non-zts-20100525`；
* 8、升级`PHP`探针文件到最新版`v0.4.7`；
* 9、因`ZendGuardLoader`只适用于`PHP5.3.x`系列，故在此版本中去除。

###版本`1.2.1`：`Release date:2013/02/22`
更新记录：

* 1、升级`PHP`版本为`5.3.22`；
* 2、升级`phpMyAdmin`版本为`3.5.7`；
* 3、优化`lamp.sh`，增加创建（删除，列出）虚拟主机、创建（删除，列出）ftp用户命令；
* 4、优化`php.ini`配置文件。


###版本`1.2`：`Release date:2013/02/06`
更新记录：

* 1、升级`MySQL`版本为`5.5.30`；
* 2、升级`PHP`版本为`5.3.21`；
* 3、更新探针`p.php`文件;
* 4、升级`Xcache`版本为`2.0.1`(登录`xcache`管理界面：`http://IP地址或域名/xcache`，用户名：`admin`密码：`123456`)；
* 5、增加`Xcache`版本为`3.0.1`的脚本(强烈推荐安装此版本，加速效果显著，登录管理界面地址同上)；
* 6、优化安装脚本判断逻辑。


###版本`1.1`：`Release date:2013/01/30`
更新记录：

* 1、去除`Apache`和`PHP`低版本的安装脚本选择；
* 2、去除`ZendOptimizer 3.3.9`(脚本`zend.sh`) ，`pure-ftpd-1.0.36`。(脚本`pureftpd.sh`)；
* 3、优化`lamp.sh`脚本，以及相关配置文件；
* 4、修改`Apache`的`httpd-vhosts.conf`配置文件，改为单一安装。
* 5、`phpMyAdmin`升级到`3.5.6`，优化配置文件中的默认语言为简体中文。


###版本`1.0`：`Release date:2013/01/14`

###适用环境：

* 系统支持：`CentOS-5 (32bit/64bit)或CentOS-6 (32bit/64bit)`
* 内存要求：`≥256M`

###将会安装:

* 1、`Apache 2.2.22`或`Apache 2.4.3`
* 2、`MySQL 5.5.29`
* 3、`PHP 5.2.17`或`PHP 5.3.20 + ZendGuardLoader`
* 4、`phpMyAdmin 3.5.5`
* 5、`ZendOptimizer 3.3.9` (可选，只适合`PHP 5.2.17`)
* 6、`xcache 1.3.2` (可选)
* 7、`pure-ftpd-1.0.36`（可选）

###安装其它：

* 1、（可选）执行脚本`pureftpd.sh`安装`pure-ftpd-1.0.36`。(命令：`./pureftpd.sh`)
* 2、（可选）执行脚本`zend.sh`安装`ZendOptimizer 3.3.9`。(命令：`./zend.sh`) 注意：不适用于`PHP 5.3.20`
* 3、（建议）执行脚本`xcache.sh`安装`xcache 1.3.2`。(命令：`./xcache.sh`)
* 4、执行脚本`php5.3_oci8_oracle11g.sh`安装`OCI8`扩展以及`oracle-instantclient11.2`（命令：`./php5.3_oci8_oracle11g.sh`）
* 5、执行脚本`php5.3_oci8_oracle10g.sh`安装`OCI8`扩展以及`oracle-instantclient10.2`（命令：`./php5.3_oci8_oracle10g.sh`）

**备注：**4、5两者选其一执行即可（可选）。该脚本是为了使PHP可以连接Oracle数据库。若连接的数据库版本为10.2，则执行5，否则执行4。

