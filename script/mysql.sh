#!/bin/bash
  mysqlbase=/usr/local/mysql       #mysql 安装程序路径
  mysqldata=/data/mysql            #mysql 数据库目录
  mysqlpasswd=3g_dba               #mysql 初始密码;


  yum clean all

 #yum makecache 2&>1 /dev/null ; [ $? -ne 0 ] && echo "yum error" && exit;
 
  yum -y install make gcc-c++ cmake bison-devel  ncurses-devel

  id mysql
  if [ $? -ne 0 ];then
	 groupadd -g 27 mysql
	 useradd -g 27  -u 27 -s /sbin/nologin  mysql
  fi

  if [ ! -d  ${mysqlbase} ];then
        mkdir -p ${mysqlbase}
  else
        rm -rf ${mysqlbase}/*
  fi
 
 
 if [ ! -d  ${mysqldata} ];then
	mkdir -p  ${mysqldata}
 else
	rm -rf ${mysqldata}/*
 fi
 
  chown  -R  mysql:mysql  ${mysqlbase}
  chown  -R  mysql:mysql  ${mysqldata}

  cd /root
  tar zxvf mysql-5.6.24.tar.gz 
  cd mysql-5.6.24


cmake \
-DCMAKE_INSTALL_PREFIX=${mysqlbase} \
-DMYSQL_DATADIR=${mysqldata} \
-DSYSCONFDIR=/etc \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DMYSQL_UNIX_ADDR=${mysqldata}/mysql.sock\
-DENABLED_LOCAL_INFILE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci

 make 
 make install 


  #cp -f /root/my.cnf /etc/my.cnf 
  ln -s ${mysqlbase}/bin/* /usr/local/bin/
  cp ${mysqlbase}/support-files/my-default.cnf   /etc/my.cnf
  cp ${mysqlbase}/support-files/mysql.server  /etc/init.d/mysqld

  cd ${mysqlbase}/scripts/
 ./mysql_install_db --basedir=${mysqlbase} --defaults-file=/etc/my.cnf --datadir=${mysqldata} --user=mysql
  
  service mysqld start
  /usr/local/mysql/bin/mysql_secure_installation
     
  #mysqladmin -u root -S /tmp/mysql.sock password ${mysqlpasswd}
  #mysqladmin -u root -h 127.0.0.1 -P 3306 password ${mysqlpasswd}
  #mysql -u root -p${mysqlpasswd} -S /tmp/mysql.sock -e "create database hxbjc default charset utf8;grant all on hxbjc.* to hxbjc@'192.168.%' identified by 'Huix_hxbjc';flush privileges;"
  chkconfig mysqld on

