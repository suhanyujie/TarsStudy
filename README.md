# TarsStudy
* tars微服务框架学习

## 安装步骤
* 在下方的"软件包下载"中，将软件包下载好，放入linux系统的文件中


## 软件包下载
* 链接地址： `https://pan.baidu.com/s/1AKRnRAF0_pfJULJDUxgQag` 密码:`rlav`
* 放入linux的 `/root/tarsInstall` 下

## 其他

### 关闭防火墙
* 永久关闭firewalld `systemctl disable firewalld:`
* 临时关闭selinux  `setenforce 0`
* 永久关闭selinux：
* `vi /etc/selinux/config`
* 修改为：`SELINUX=disabled`  参考 https://blog.csdn.net/jichl/article/details/20711119

### 重启


## 参考资料
* 参考官方的安装shell https://github.com/Tencent/Tars/blob/phptars/build/install.sh
* 官方的安装指南 https://github.com/Tencent/Tars/blob/phptars/build/install.sh
* 在同事{*俊东+*发军}的指导下进行安装 https://github.com/jackylee92/Blog/blob/master/Tars.md
