#!/bin/bash

MysqlPassword="root@appinside"
MachineIp="192.168.2.161"

mysql -uroot -p${MysqlPassword} -e "grant all on *.* to 'tars'@'%' identified by '${MysqlPassword}' with grant option;"
mysql -uroot -p{MysqlPassword} -e "grant all on *.* to 'tars'@'${MachineIp}' identified by '${MysqlPassword}' with grant option;"
