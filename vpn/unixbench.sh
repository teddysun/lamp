#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   Description:  Unixbench for Test
#===============================================================================================

# Create new soft download dir
mkdir -p /opt/unixbench;
cd /opt/unixbench;

# Download unixbench
wget http://teddysun.googlecode.com/files/unixbench-5.1.2.tar.gz;
tar -xzf unixbench-5.1.2.tar.gz;
cd unixbench-5.1.2;

yum -y install gcc gcc-c autoconf gcc-c++ time

#Run unixbench
sed -i "s/GRAPHIC_TESTS = defined/#GRAPHIC_TESTS = defined/g" ./Makefile
make;
./Run;

echo '';
echo '';
echo '';
echo "======= Script description and score comparison: ======= ";
echo '';
echo '';
echo '';




