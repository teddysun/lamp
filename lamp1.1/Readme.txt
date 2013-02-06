本脚本适用环境：
系统支持：CentOS-5 (32bit/64bit)或CentOS-6 (32bit/64bit)
内存要求：≥256M
日期：2013年1月31日

将会安装:
1、Apache 2.4.3
2、MySQL 5.5.29
3、PHP 5.3.20 + ZendGuardLoader
4、phpMyAdmin 3.5.6
5、xcache 1.3.2 (建议安装)
6、OCI8 + oracle-instantclient  (可选安装，支持PHP连接Oracle数据库)

如何安装：
第一步，终端中输入以下命令：
cd /root
wget http://teddysun.googlecode.com/files/lamp1.1.tar.gz
tar -zxvf lamp1.1.tar.gz
cd /root/lamp1.1
chmod +x *.sh

第二步，禁止SELINUX
终端中输入以下命令：
cd /root/lamp1.1
./disable.sh

第三步，安装LAMP
终端中输入以下命令：
cd /root/lamp1.1
./lamp.sh 2>&1 | tee lamp.log

安装其它：
1、（建议安装）执行脚本xcache.sh安装xcache 1.3.2。(命令：./xcache.sh)
2、执行脚本php5.3_oci8_oracle11g.sh安装OCI8扩展以及oracle-instantclient11.2（命令：./php5.3_oci8_oracle11g.sh）
3、执行脚本php5.3_oci8_oracle10g.sh安装OCI8扩展以及oracle-instantclient10.2（命令：./php5.3_oci8_oracle10g.sh）

备注：2、3两者选其一执行即可（可选）。该脚本是为了使PHP可以连接Oracle数据库。若连接的数据库版本为10.2，则执行3，否则执行2。


使用提示：
lamp uninstall：一键删除LAMP（删除之前注意备份好数据！）。

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
默认web根目录： /data/www/default


最后，祝你使用愉快！
