# MariaDB 설치

## 0. 계획
* 이중화 설치
* mysql 계정으로 실행

> ref)  
    https://downloads.mariadb.org/mariadb/repositories/#mirror=yongbok  
    https://bamdule.tistory.com/66

## 1. 계정 추가
```
# groupadd -g 3306 mysql
# useradd mysql -u 3306 -g mysql
```

## 2. 설치
(in peter-kafka001, peter-kafka002)
```
# vi /etc/yum.repos.d/MariaDB.repo
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# MariaDB 10.5 CentOS repository list - created 2021-02-27 05:30 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.5/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
```

```
# yum install galera-4
# yum install MariaDB-server MariaDB-client
```

## 3. 설정
```
# vi /etc/my.cnf
```
> [my.cnf](my.cnf)

## 4. DB 초기화 작업
(in peter-kafka001)
```
# systemctl start mariadb
# systemctl status mariadb
# systemctl enable mariadb
```

> 실행예
```
[root@peter-kafka001 etc]# systemctl enable mariadb
Created symlink from /etc/systemd/system/multi-user.target.wants/mariadb.service to /usr/lib/systemd/system/mariadb.service.
```

```
# /usr/bin/mysql_secure_installation
```    

> 실행예
```
[root@peter-kafka001 my.cnf.d]# /usr/bin/mysql_secure_installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user. If you've just installed MariaDB, and
haven't set the root password yet, you should just press enter here.

Enter current password for root (enter for none): 
OK, successfully used password, moving on...

Setting the root password or using the unix_socket ensures that nobody
can log into the MariaDB root user without the proper authorisation.

You already have your root account protected, so you can safely answer 'n'.

Switch to unix_socket authentication [Y/n] n
 ... skipping.

You already have your root account protected, so you can safely answer 'n'.

Change the root password? [Y/n] y
New password: 
Re-enter new password: 
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] 
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] n
 ... skipping.

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] 
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] 
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
[root@peter-kafka001 my.cnf.d]# 
```

## 5. galera 설정
```
# vi /etc/my.cnf.d/server.cnf
```
> [server.cnf](server.cnf)

> NOTE. 서버별로 설정값이 다름.(wsrep_node_address)

## 6. cluster 작업
(in peter-kafka001)
```
# galera_new_cluster
```

(in peter-kafka002)
```
# systemctl start mariadb
# systemctl status mariadb
# systemctl enable mariadb
```

## 7. 확인
(in peter-kafka001 or peter-kafka002)
```
# mysql -u root -p
Enter password: root
MariaDB [(none)]> show status like 'wsrep%';
MariaDB [(none)]> show global status like 'wsrep_cluster_size';

MariaDB [(none)]> show databases;
MariaDB [(none)]> create database metastore DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
MariaDB [(none)]> show databases;

MariaDB [(none)]> select host,user,password from mysql.user;
MariaDB [(none)]> grant all privileges on metastore.* to 'hive'@'%' identified by 'hive';
MariaDB [(none)]> select host,user,password from mysql.user;

MariaDB [(none)]> flush privileges;

MariaDB [(none)]> exit
```

> NOTE. Hive를 위한 DB및 계정 생성

> NOTE. 동기화 되는지 확인

___
.END OF MARIADB    