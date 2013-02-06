本脚本适用环境：
系统支持：CentOS-5 (32bit/64bit)或CentOS-6 (32bit/64bit)
内存要求：≥256M
日期：2013年02月06日

将会安装:
1、Apache 2.4.3
2、MySQL 5.5.30
3、PHP 5.3.21 + ZendGuardLoader
4、phpMyAdmin 3.5.6
5、xcache 2.0.1 (可选)

如何安装：
第一步，禁止SELINUX,运行./disable.sh

第二步，终端中输入以下命令：
cd /root
wget http://teddysun.googlecode.com/files/lamp1.2.tar.gz
tar -zxvf lamp1.2.tar.gz
cd /root/lamp1.2
chmod +x *.sh
./lamp.sh 2>&1 | tee lamp.log

安装其它：
1、（建议）执行脚本xcache.sh安装xcache 2.0.1。(命令：./xcache.sh)
2、执行脚本php5.3_oci8_oracle11g.sh安装OCI8扩展以及oracle-instantclient11.2（命令：./php5.3_oci8_oracle11g.sh）
3、执行脚本php5.3_oci8_oracle10g.sh安装OCI8扩展以及oracle-instantclient10.2（命令：./php5.3_oci8_oracle10g.sh）

备注：2、3两者选其一执行即可（可选）。该脚本是为了使PHP可以连接Oracle数据库。若连接的数据库版本为10.2，则执行3，否则执行2。

注意：Oracle数据库连接错误排查
一般连接外部oracle服务器那一步骤时，可能会出现ORA-24408:could not generate unique server group name这样的错误，解决办法是在hosts中将主机名添加即可：
vi /etc/hosts
127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4 nupctest
::1 localhost localhost.localdomain localhost6 localhost6.localdomain6 nupctest

上面的代码中，nupctest即为主机名。然后重启网络服务即可。service network restart


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
