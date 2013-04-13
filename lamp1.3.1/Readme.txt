本脚本适用环境：
系统支持：CentOS-5 (32bit/64bit)或CentOS-6 (32bit/64bit)
内存要求：≥256M
日期：2013年04月13日

将会安装:
1、Apache 2.4.4
2、MySQL 5.6.10
3、PHP 5.4.14
4、phpMyAdmin 3.5.8
5、OCI8 + oracle-instantclient  (可选安装，支持PHP连接Oracle数据库)
6、xcache 2.0.1 (可选安装)
7、xcache 3.0.1 (推荐安装)
8、pure-ftpd-1.0.36（可选安装）

注意：6、7二者只能选其一安装。

如何安装：
第一步，终端中输入以下命令：
cd /root
wget http://teddysun.googlecode.com/files/lamp1.3.1.tar.gz
tar -zxvf lamp1.3.1.tar.gz
cd /root/lamp1.3.1
chmod +x *.sh

第二步，禁止SELINUX
终端中输入以下命令：
cd /root/lamp1.3.1
./disable.sh

第三步，安装LAMP
终端中输入以下命令：
cd /root/lamp1.3.1
./lamp.sh | tee lamp.log

安装其它：
1、（可选安装）执行脚本xcache_2.0.1.sh安装xcache 2.0.1。(命令：./xcache_2.0.1.sh)
   （推荐安装）执行脚本xcache_3.0.1.sh安装xcache 3.0.1。(命令：./xcache_3.0.1.sh)
2、执行脚本php5.4_oci8_oracle11g.sh安装OCI8扩展以及oracle-instantclient11.2（命令：./php5.4_oci8_oracle11g.sh）
3、执行脚本php5.4_oci8_oracle10g.sh安装OCI8扩展以及oracle-instantclient10.2（命令：./php5.4_oci8_oracle10g.sh）
4、（可选安装）执行脚本pureftpd.sh安装pure-ftpd-1.0.36。(命令：./pureftpd.sh)

备注：2、3两者选其一执行即可（可选）。该脚本是为了使PHP可以连接Oracle数据库。若连接的数据库版本为10.2，则执行3，否则执行2。

注意1:执行脚本时出现下面的错误提示时。
-bash: ./lamp.sh: /bin/bash^M: bad interpreter: No such file or directory

是因为Windows下和Linux下的文件编码不同所致。
解决办法是：
执行
vi lamp.sh
输入命令
:set ff=unix 
#注意，包括冒号
回车后，输入ZZ（即Shift+zz），即可。

注意2：Oracle数据库连接错误排查
一般连接外部oracle服务器那一步骤时，可能会出现ORA-24408:could not generate unique server group name这样的错误，解决办法是在hosts中将主机名添加即可：
vi /etc/hosts
127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4 test
::1 localhost localhost.localdomain localhost6 localhost6.localdomain6 test

上面的代码中，test即为主机名。然后重启网络服务即可。service network restart

使用提示：
lamp add(del,list)：创建（删除，列出）虚拟主机。
lamp ftp(add|del|list)：创建（删除，列出）ftp用户。
lamp uninstall：一键删除lamp（删除之前注意备份好数据！）

程序目录：
mysql安装目录: /usr/local/mysql
mysql data目录：/usr/local/mysql/data（默认，安装时可更改路径）
php安装目录: /usr/local/php
apache安装目录： /usr/local/apache

命令一览：
mysql命令: /etc/init.d/mysqld(start|stop|restart|reload|status)
       或：service mysqld(start|stop|restart|reload|status)
apache命令: /etc/init.d/httpd(start|stop|restart|reload|status)
       或：service httpd(start|stop|restart|reload|status)      

网站根目录：
安装完后默认的web根目录： /data/www/default

最后，祝你使用愉快！
