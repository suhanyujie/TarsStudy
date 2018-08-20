#!/bin/bash

# 杀死所有相关进程
ps -ef | grep tars | grep -v grep |awk '{print $2}' | xargs kill -9

# 杀死某一端口进程：
netstat -apn | grep 19385 | awk '{print $7}' | awk -F '/' '{print $1}' | xargs kill -9

service mysql stop
service mysql start
/usr/local/app/tars/tars_install.sh
/usr/local/app/tars/tarspatch/util/init.sh
/usr/local/app/tars/tarsnode/bin/tarsnode --config=/usr/local/app/tars/tarsnode/conf/tarsnode.conf
/usr/local/resin/bin/resin.sh start
echo "完成！"