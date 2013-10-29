本脚本适用环境：
系统支持：CentOS-5 (32bit/64bit)或CentOS-6 (32bit/64bit)
内存要求：≥256M

将会安装:
1、Apache 2.2.22或Apache 2.4.3
2、MySQL 5.5.29
3、PHP 5.2.17或PHP 5.3.20
4、phpMyAdmin 3.5.5
5、ZendOptimizer 3.3.9 (可选，只适合PHP 5.2.17)
6、xcache 1.3.2 (可选)
7、pure-ftpd-1.0.36（可选）

如何安装：
第一步，禁止SELINUX,运行
vi /etc/selinux/config
查看SELINUX=disabled的话，则无需运行./disable.sh，否则需要先运行./disable.sh，再重启。

第二步，终端中输入以下命令：
cd /root
wget http://teddysun.googlecode.com/files/lamp.tar.gz
tar -zxvf lamp.tar.gz
cd /root/lamp
chmod +x *.sh
./lamp.sh 2>&1 | tee lamp.log

安装其它：
1、（可选）执行脚本pureftpd.sh安装pure-ftpd-1.0.36。(命令：./pureftpd.sh)
2、（可选）执行脚本zend.sh安装ZendOptimizer 3.3.9。(命令：./zend.sh) 注意：不适用于PHP 5.3.20
3、（建议）执行脚本xcache.sh安装xcache 1.3.2。(命令：./xcache.sh)
4、执行脚本php5.3_oci8_oracle11g.sh安装OCI8扩展以及oracle-instantclient11.2（命令：./php5.3_oci8_oracle11g.sh）
5、执行脚本php5.3_oci8_oracle10g.sh安装OCI8扩展以及oracle-instantclient10.2（命令：./php5.3_oci8_oracle10g.sh）

备注：4、5两者选其一执行即可（可选）。该脚本是为了使PHP可以连接Oracle数据库。若连接的数据库版本为10.2，则执行5，否则执行4。


使用提示：
lamp add(del,list)：创建（删除，列出）虚拟主机。
lamp ftp(add|del|list)：创建（删除，列出）ftp用户。
lamp uninstall：一键删除lamp（删除之前注意备份好数据！）。

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

网站目录：
默认web目录： /data/www/default

使用注意：
mysql root密码存放在/root/my.cnf文件中，添加虚拟主机的时候需要调用。如果修改了root密码，请手动更新my.cnf文件。


最后，祝你使用愉快！
