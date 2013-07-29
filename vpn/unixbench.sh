#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   Description:  Unixbench for Test
#===============================================================================================

# Create new soft download dir
mkdir -p /opt/unixbench;
cd /opt/unixbench;

# Download UnixBench5.1.3
if [ -s UnixBench5.1.3.tgz ]; then
  echo "UnixBench5.1.3.tgz [found]"
else
 echo "UnixBench5.1.3.tgz not found!!!download now......"
 if ! wget -c http://byte-unixbench.googlecode.com/files/UnixBench5.1.3.tgz;then
	echo "Failed to download UnixBench5.1.3.tgz,please download it to "/opt/unixbench" directory manually and rerun the install script."
	exit 1
 fi
fi
tar -xzf UnixBench5.1.3.tgz;
cd UnixBench;

yum -y install gcc gcc-c autoconf gcc-c++ time perl-Time-HiRes

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




