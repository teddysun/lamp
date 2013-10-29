#! /bin/bash
#===============================================================================
#   SYSTEM REQUIRED:  CentOS-5 (32bit/64bit) CentOS-6 (32bit/64bit)
#   DESCRIPTION:  Install LAMP for CentOS
#   AUTHOR: sunzh@bjbsh.com
#===============================================================================

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
#===============================================================================
#DESCRIPTION:disable selinux.
#USAGE:disable_selinux
#===============================================================================
if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
echo "======================You must be reboot system!!!========================"
else
echo "======================Selinux had been disable,Do nothing================="	
fi
