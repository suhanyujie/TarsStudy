#!/bin/bash

MachineIp=192.168.255.161
SoftwarePath=/root/tarsInstall
SoftwarePathRelease=$SoftwarePath/softwareRelease

# 软件包变量声明
CmakePackageName="cmake-2.8.8.tar.gz"
ResinPackageName="resin-4.0.49.tar.gz"
MysqlPackageName="mysql-5.6.25.tar.gz"
TarsMasterName="tars-master.zip"
MavenPackageName="apache-maven-3.3.9-bin.tar.gz"
JavaPackageName="jdk-8u171-linux-x64.tar.gz"

# 普通用户声明
NormalUserName="cloud-user"

# 开始执行命令
setenforce 0   
yum install -y gcc* bison flex glibc-devel perl perl-Module-Install.noarch git zlib-devel ncurses-devel curl-devel autoconf unzip
# 解压tars-master文件夹
cd $SoftwarePath
unzip $CmakePackageName -d $SoftwarePathRelease/tars-master

# cmake编译安装
cd $SoftwarePath
tar zxvf $CmakePackageName -C $SoftwarePathRelease/cmake
cd $SoftwarePathRelease/cmake
./bootstrap
make && make install
# 安装resin
cd /usr/local/
mkdir -p /usr/local/resin
tar zxvf $SoftwarePath/$CmakePackageName -C /usr/local/resin
# 安装mysql
cd /usr/local
mkdir mysql-5.6.26
chown mysql:mysql ./mysql-5.6.26
ln -s /usr/local/mysql-5.6.26 /usr/local/mysql
cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql-5.6.26 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DMYSQL_USER=mysql -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci
make && make install
yum install perl
cd /usr/local/mysql
useradd mysql
rm -rf /usr/local/mysql/data
mkdir -p /data/mysql-data
ln -s /data/mysql-data /usr/local/mysql/data
chown -R mysql:mysql /data/mysql-data /usr/local/mysql/data
cp support-files/mysql.server /etc/init.d/mysql
yum install -y perl-Module-Install.noarch
perl scripts/mysql_install_db --user=mysql
echo `
[mysqld]

# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
innodb_buffer_pool_size = 128M

# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
log_bin

# These are commonly set, remove the # and set as required.
basedir = /usr/local/mysql
datadir = /usr/local/mysql/data
# port = .....
# server_id = .....
socket = /tmp/mysql.sock

bind-address=${MachineIp}

# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
join_buffer_size = 128M
sort_buffer_size = 2M
read_rnd_buffer_size = 2M

sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
` > /usr/local/mysql/my.cnf
service mysql start
chkconfig mysql on
echo "PATH=\$PATH:/usr/local/mysql/bin" >> /etc/profile
echo "export PATH" >> /etc/profile
source /etc/profile

cd /usr/local/mysql/
./bin/mysqladmin -u root password 'root@appinside'
./bin/mysqladmin -u root -h ${MachineIp} password 'root@appinside'
cd -
echo "/usr/local/mysql/lib/" >> /etc/ld.so.conf
ldconfig

# 安装jdk
cd $SoftwarePath
tar zxvf ${JavaPackageName} -C $SoftwarePathRelease/java1.8
echo "export JAVA_HOME=$SoftwarePathRelease/java1.8" >> /etc/profile
echo "CLASSPATH=\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" >> /etc/profile
echo "PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile
echo "export PATH JAVA_HOME CLASSPATH" >> /etc/profile
source /etc/profile
java -version

# 安装maven
cd $SoftwarePath
tar zxvf ${MavenPackageName} -C $SoftwarePathRelease/maven
echo "export MAVEN_HOME=${SoftwarePathRelease}/maven" >> /etc/profile
echo "export PATH=\$PATH:\$MAVEN_HOME/bin" >> /etc/profile
source /etc/profile

# 安装java语言框架
cd $SoftwarePathRelease/tars-master/java/
mvn clean install 
mvn clean install -f core/client.pom.xml 
mvn clean install -f core/server.pom.xml
cd -

# C++开发环境安装
cd $SoftwarePathRelease/tars-master/cpp/build
chmod u+x build.sh
./build.sh all
./build.sh install
cd /usr/local
mkdir tars
chown ${NormalUserName}:${NormalUserName} ./tars/

# tars数据环境初始化
mysql -uroot -proot@appinside -e "grant all on *.* to 'tars'@'%' identified by 'root@appinside' with grant option;"
mysql -uroot -proot@appinside -e "grant all on *.* to 'tars'@'localhost' identified by 'root@appinside' with grant option;"
mysql -uroot -proot@appinside -e "grant all on *.* to 'tars'@'${MachineIp}' identified by 'root@appinside' with grant option;"
mysql -uroot -proot@appinside -e "flush privileges;"

# 创建数据库
cd $SoftwarePathRelease/tars-master/cpp/framework/sql
sed -i "s/192.168.2.131/${MachineIp}/g" `grep 192.168.2.131 -rl ./*`;
sed -i "s/db.tars.com/${MachineIp}/g" `grep db.tars.com -rl ./*`;
chmod u+x exec-sql.sh
./exec-sql.sh

# 基础服务打包
make framework-tar
make tarsstat-tar
make tarsnotify-tar
make tarsproperty-tar
make tarslog-tar
make tarsquerystat-tar
make tarsqueryproperty-tar

