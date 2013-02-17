#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   SYSTEM REQUIRED:  CentOS-5 (32bit/64bit) or CentOS-6 (32bit/64bit)
#   DESCRIPTION:  Update phpMyAdmin
#   AUTHOR: Teddysun <i@teddysun.com>
#   VISIT:  https://code.google.com/p/teddysun/
#===============================================================================================
cur_dir=`pwd`
cd $cur_dir
#download phpMyAdmin-3.5.7
if [ -s phpMyAdmin-3.5.7-all-languages.tar.gz ]; then
  echo "phpMyAdmin-3.5.7-all-languages.tar.gz [found]"
else
  echo "phpMyAdmin-3.5.7-all-languages.tar.gz not found!!!download now......"
  if ! wget http://teddysun.googlecode.com/files/phpMyAdmin-3.5.7-all-languages.tar.gz;then
    echo "Failed to download phpMyAdmin-3.5.7-all-languages.tar.gz,please download it to $cur_dir directory manually and rerun the install script."
 exit 1
 fi
fi

#install phpMyAdmin-3.5.7
echo "============================phpMyAdmin-3.5.7 install start================================"
rm -rf $cur_dir/untar/
mkdir -p $cur_dir/untar/
tar -xzf phpMyAdmin-3.5.7-all-languages.tar.gz -C $cur_dir/untar/
cp -f /data/www/default/phpmyadmin/config.inc.php $cur_dir/untar/config.inc.php.backup
rm -rf /data/www/default/phpmyadmin
mv $cur_dir/untar/phpMyAdmin-3.5.7-all-languages /data/www/default/phpmyadmin
mv $cur_dir/untar/config.inc.php.backup /data/www/default/phpmyadmin/config.inc.php
rm -rf $cur_dir/untar/
chmod -R 755 /data/www/default/phpmyadmin
mkdir -p /data/www/default/phpmyadmin/upload/
mkdir -p /data/www/default/phpmyadmin/save/
chmod 755 -R /data/www/default/phpmyadmin/upload/
chmod 755 -R /data/www/default/phpmyadmin/save/
chown -R apache:apache /data/www/default/phpmyadmin
service httpd restart
echo "============================phpMyAdmin-3.5.7 install completed============================"
exit
