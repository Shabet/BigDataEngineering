# Hive 설치

## 0. 계획
* metastore server, thrift server 를 별도로 실행
* hive 계정으로 실행

## 1. 계정 추가
(in peter-kafka001, peter-kafka002)
```
# groupadd -g 9083 hive
# useradd hive -u 9083 -g hive
```

## 2. 설치
(in peter-kafka001, peter-kafka002)
```
# cd ~/work
# wget https://downloads.apache.org/hive/hive-2.3.8/apache-hive-2.3.8-bin.tar.gz
# cd /opt
# tar zxvf ~/work/apache-hive-2.3.8-bin.tar.gz 
# ln -s apache-hive-2.3.8-bin hive
```

## 3. 설정(for metastore 서비스)
(in peter-kafka001, peter-kafka002)
```
# cd /opt/hive/conf/
# mkdir hive-metastoreserver
# cd hive-metastoreserver
# cp -p ../hive-log4j2.properties.template hive-log4j2.properties
# cp -p ../hive-env.sh.template hive-env.sh
```

* hive-log4j2.properties
```
# vi /opt/hive/conf/hive-metastoreserver/hive-log4j2.properties

<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
...
property.hive.log.dir = /var/log/hive                     # <- 로그 디렉토리 경로 변경
property.hive.log.file = hive-metastoreserver.log         # <- 로그 파일명 변경
...
# >>>> Delete log files older than x days
appender.DRFA.strategy.action.type = Delete
appender.DRFA.strategy.action.basepath = ${sys:hive.log.dir}
appender.DRFA.strategy.action.maxDepth = 1
appender.DRFA.strategy.action.condition.type = IfFileName
appender.DRFA.strategy.action.condition.glob = ${sys:hive.log.file}.*
appender.DRFA.strategy.action.IfAny.type = IfAny
appender.DRFA.strategy.action.IfAny.IfLastModified.type = IfLastModified
appender.DRFA.strategy.action.IfAny.IfLastModified.age = 7d
# <<<<
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
```

* hive-env.sh
```
# vi /opt/hive/conf/hive-metastoreserver/hive-env.sh

<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
...
    export HIVE_AUX_JARS_PATH=${HIVE_HOME}/auxjars
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
```

* hive-site.xml
```
# vi /opt/hive/conf/hive-metastoreserver/hive-site.xml
```
> [hive-site.xml](metastore/hive-site.xml)

> 아래의 항목은 환경설정에 맞게 수정할것!
- javax.jdo.option.ConnectionUserName  
- javax.jdo.option.ConnectionPassword

* MariaDB JDBC Connector 설치
```
# cd ~/work
# wget https://downloads.mariadb.com/Connectors/java/connector-java-2.3.0/mariadb-java-client-2.3.0.jar
# /opt/hive
# mkdir auxjars
# cd auxjars
# cp -p ~/work/mariadb-java-client-2.3.0.jar .
# ln -s mariadb-java-client-2.3.0.jar mariadb-java-client.jar
```
> NOTE. mariadb-java-client-2.7.2.jar은 나중에 서비스 시작시에 Self-test query [select "DB_ID" from "DBS"] failed; direct SQL is disabled 에러 발생.

* 기타 디렉토리 생성
```
# mkdir /var/log/hive
```

## 4. 실행 계정 설정
(in peter-kafka001, peter-kafka002)
```
# chown -R hive:hive /opt/apache-hive-2.3.8-bin/
# chown -R hive:hive /opt/hive
```

## 5. Metastore DB 생성
1. 생성
(in peter-kafka001)
```
# vi /opt/hive/conf/hive-site.xml
```
> NOTE. schema 생성을 위해서 임시로 hive-site.xml 생성

```
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
  <!-- Metastore DB -->
  <property>
    <name>javax.jdo.option.ConnectionURL</name>
    <value>jdbc:mariadb://peter-kafka001:3306,peter-kafka002:3306/metastore</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionDriverName</name>
    <value>org.mariadb.jdbc.Driver</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionUserName</name>
    <value>hive</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionPassword</name>
    <value>hive</value>
  </property>
</configuration>
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
```

```
# chown hive:hive /opt/hive/conf/hive-site.xml
```

```
# cd /opt/hive/conf/
# cp -p hive-metastoreserver/hive-env.sh .
# chown hive:hive /opt/hive/conf/hive-env.sh
```
> NOTE. hive-env.sh 파일도 역시 임시로 생성

```
# su - hive
$ hive --service schemaTool -dbType mysql -initSchema
```

> 실행 예)
```
[hive@peter-kafka001 ~]$ hive --service schemaTool -dbType mysql -initSchema
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/opt/apache-hive-2.3.8-bin/lib/log4j-slf4j-impl-2.6.2.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/opt/hadoop-2.10.1/share/hadoop/common/lib/slf4j-log4j12-1.7.25.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
SLF4J: Actual binding is of type [org.apache.logging.slf4j.Log4jLoggerFactory]
Metastore connection URL:        jdbc:mariadb://peter-kafka001:3306,peter-kafka002:3306/metastore
Metastore Connection Driver :    org.mariadb.jdbc.Driver
Metastore connection User:       hive
Starting metastore schema initialization to 2.3.0
Initialization script hive-schema-2.3.0.mysql.sql
Initialization script completed
schemaTool completed
```
> 위의 명령을 위해서 앞에서 설정파일을 임시로 생성한 것임.

```
$ exit
# rm -f /opt/hive/conf/hive-site.xml
# rm -f /opt/hive/conf/hive-env.sh
```

2. 확인
(in peter-kafka001 or peter-kafka002)
```
# mysql -u root -p
Enter password: (암호입력)
MariaDB [(none)]> use metastore;
MariaDB [(none)]> show tables;

MariaDB [(none)]> exit
```
> NOTE. 동기화 되는지 확인

3. mariadb 한글 깨짐 해결
> ref) https://heum-story.tistory.com/34  
       https://www.lesstif.com/dbms/mysql-rhel-centos-ubuntu-20775198.html

* table coulmn character-set 변경
(in peter-kafka001)
```
# mysql -u root -p
Enter password: (암호입력)

alter table COLUMNS_V2 modify COMMENT varchar(256) character set utf8 collate utf8_general_ci;
alter table TABLE_PARAMS modify PARAM_VALUE mediumtext character set utf8 collate utf8_general_ci;
alter table SERDE_PARAMS modify PARAM_VALUE mediumtext character set utf8 collate utf8_general_ci;
alter table SD_PARAMS modify PARAM_VALUE mediumtext character set utf8 collate utf8_general_ci;
alter table PARTITION_PARAMS modify PARAM_VALUE varchar(4000) character set utf8 collate utf8_general_ci;
alter table PARTITION_KEYS modify PKEY_COMMENT varchar(4000) character set utf8 collate utf8_general_ci;
alter table INDEX_PARAMS modify PARAM_VALUE varchar(4000) character set utf8 collate utf8_general_ci;
alter table DATABASE_PARAMS modify PARAM_VALUE varchar(4000) character set utf8 collate utf8_general_ci;
alter table DBS modify `DESC` varchar(4000) character set utf8 collate utf8_general_ci;
```

* table 확인
```
show full columns from COLUMNS_V2;
show full columns from TABLE_PARAMS;
show full columns from SERDE_PARAMS;
show full columns from SD_PARAMS;
show full columns from PARTITION_PARAMS;
show full columns from PARTITION_KEYS;
show full columns from INDEX_PARAMS;
show full columns from DATABASE_PARAMS;
show full columns from DBS;
```

> 실행예)
```
MariaDB [metastore]>     show full columns from COLUMNS_V2;
+-------------+--------------+-------------------+------+-----+---------+-------+---------------------------------+---------+
| Field       | Type         | Collation         | Null | Key | Default | Extra | Privileges                      | Comment |
+-------------+--------------+-------------------+------+-----+---------+-------+---------------------------------+---------+
| CD_ID       | bigint(20)   | NULL              | NO   | PRI | NULL    |       | select,insert,update,references |         |
| COMMENT     | varchar(256) | latin1_bin        | YES  |     | NULL    |       | select,insert,update,references |         |
| COLUMN_NAME | varchar(767) | latin1_bin        | NO   | PRI | NULL    |       | select,insert,update,references |         |
| TYPE_NAME   | mediumtext   | latin1_swedish_ci | YES  |     | NULL    |       | select,insert,update,references |         |
| INTEGER_IDX | int(11)      | NULL              | NO   |     | NULL    |       | select,insert,update,references |         |
+-------------+--------------+-------------------+------+-----+---------+-------+---------------------------------+---------+
5 rows in set (0.001 sec)

MariaDB [metastore]>     show full columns from TABLE_PARAMS;
+-------------+--------------+------------+------+-----+---------+-------+---------------------------------+---------+
| Field       | Type         | Collation  | Null | Key | Default | Extra | Privileges                      | Comment |
+-------------+--------------+------------+------+-----+---------+-------+---------------------------------+---------+
| TBL_ID      | bigint(20)   | NULL       | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_KEY   | varchar(256) | latin1_bin | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_VALUE | mediumtext   | latin1_bin | YES  |     | NULL    |       | select,insert,update,references |         |
+-------------+--------------+------------+------+-----+---------+-------+---------------------------------+---------+
3 rows in set (0.001 sec)

MariaDB [metastore]>     show full columns from SERDE_PARAMS;
+-------------+--------------+------------+------+-----+---------+-------+---------------------------------+---------+
| Field       | Type         | Collation  | Null | Key | Default | Extra | Privileges                      | Comment |
+-------------+--------------+------------+------+-----+---------+-------+---------------------------------+---------+
| SERDE_ID    | bigint(20)   | NULL       | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_KEY   | varchar(256) | latin1_bin | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_VALUE | mediumtext   | latin1_bin | YES  |     | NULL    |       | select,insert,update,references |         |
+-------------+--------------+------------+------+-----+---------+-------+---------------------------------+---------+
3 rows in set (0.001 sec)

MariaDB [metastore]>     show full columns from SD_PARAMS;
+-------------+--------------+------------+------+-----+---------+-------+---------------------------------+---------+
| Field       | Type         | Collation  | Null | Key | Default | Extra | Privileges                      | Comment |
+-------------+--------------+------------+------+-----+---------+-------+---------------------------------+---------+
| SD_ID       | bigint(20)   | NULL       | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_KEY   | varchar(256) | latin1_bin | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_VALUE | mediumtext   | latin1_bin | YES  |     | NULL    |       | select,insert,update,references |         |
+-------------+--------------+------------+------+-----+---------+-------+---------------------------------+---------+
3 rows in set (0.001 sec)

MariaDB [metastore]>     show full columns from PARTITION_PARAMS;
+-------------+---------------+------------+------+-----+---------+-------+---------------------------------+---------+
| Field       | Type          | Collation  | Null | Key | Default | Extra | Privileges                      | Comment |
+-------------+---------------+------------+------+-----+---------+-------+---------------------------------+---------+
| PART_ID     | bigint(20)    | NULL       | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_KEY   | varchar(256)  | latin1_bin | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_VALUE | varchar(4000) | latin1_bin | YES  |     | NULL    |       | select,insert,update,references |         |
+-------------+---------------+------------+------+-----+---------+-------+---------------------------------+---------+
3 rows in set (0.001 sec)

MariaDB [metastore]>     show full columns from PARTITION_KEYS;
+--------------+---------------+------------+------+-----+---------+-------+---------------------------------+---------+
| Field        | Type          | Collation  | Null | Key | Default | Extra | Privileges                      | Comment |
+--------------+---------------+------------+------+-----+---------+-------+---------------------------------+---------+
| TBL_ID       | bigint(20)    | NULL       | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PKEY_COMMENT | varchar(4000) | latin1_bin | YES  |     | NULL    |       | select,insert,update,references |         |
| PKEY_NAME    | varchar(128)  | latin1_bin | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PKEY_TYPE    | varchar(767)  | latin1_bin | NO   |     | NULL    |       | select,insert,update,references |         |
| INTEGER_IDX  | int(11)       | NULL       | NO   |     | NULL    |       | select,insert,update,references |         |
+--------------+---------------+------------+------+-----+---------+-------+---------------------------------+---------+
5 rows in set (0.001 sec)

MariaDB [metastore]>     show full columns from INDEX_PARAMS;
+-------------+---------------+------------+------+-----+---------+-------+---------------------------------+---------+
| Field       | Type          | Collation  | Null | Key | Default | Extra | Privileges                      | Comment |
+-------------+---------------+------------+------+-----+---------+-------+---------------------------------+---------+
| INDEX_ID    | bigint(20)    | NULL       | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_KEY   | varchar(256)  | latin1_bin | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_VALUE | varchar(4000) | latin1_bin | YES  |     | NULL    |       | select,insert,update,references |         |
+-------------+---------------+------------+------+-----+---------+-------+---------------------------------+---------+
3 rows in set (0.001 sec)

MariaDB [metastore]>     show full columns from DATABASE_PARAMS;
+-------------+---------------+------------+------+-----+---------+-------+---------------------------------+---------+
| Field       | Type          | Collation  | Null | Key | Default | Extra | Privileges                      | Comment |
+-------------+---------------+------------+------+-----+---------+-------+---------------------------------+---------+
| DB_ID       | bigint(20)    | NULL       | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_KEY   | varchar(180)  | latin1_bin | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_VALUE | varchar(4000) | latin1_bin | YES  |     | NULL    |       | select,insert,update,references |         |
+-------------+---------------+------------+------+-----+---------+-------+---------------------------------+---------+
3 rows in set (0.001 sec)

MariaDB [metastore]>     show full columns from DBS;
+-----------------+---------------+------------+------+-----+---------+-------+---------------------------------+---------+
| Field           | Type          | Collation  | Null | Key | Default | Extra | Privileges                      | Comment |
+-----------------+---------------+------------+------+-----+---------+-------+---------------------------------+---------+
| DB_ID           | bigint(20)    | NULL       | NO   | PRI | NULL    |       | select,insert,update,references |         |
| DESC            | varchar(4000) | latin1_bin | YES  |     | NULL    |       | select,insert,update,references |         |
| DB_LOCATION_URI | varchar(4000) | latin1_bin | NO   |     | NULL    |       | select,insert,update,references |         |
| NAME            | varchar(128)  | latin1_bin | YES  | UNI | NULL    |       | select,insert,update,references |         |
| OWNER_NAME      | varchar(128)  | latin1_bin | YES  |     | NULL    |       | select,insert,update,references |         |
| OWNER_TYPE      | varchar(10)   | latin1_bin | YES  |     | NULL    |       | select,insert,update,references |         |
+-----------------+---------------+------------+------+-----+---------+-------+---------------------------------+---------+
6 rows in set (0.001 sec)

MariaDB [metastore]> alter table COLUMNS_V2 modify COMMENT varchar(256) character set utf8 collate utf8_general_ci;
    alter table TABLE_PARAMS modify PARAM_VALUE mediumtext character set utf8 collate utf8_general_ci;
Query OK, 0 rows affected (0.021 sec)              
Records: 0  Duplicates: 0  Warnings: 0

MariaDB [metastore]>     alter table TABLE_PARAMS modify PARAM_VALUE mediumtext character set utf8 collate utf8_general_ci;
    alter table SERDE_PARAMS modify PARAM_VALUE mediumtext character set utf8 collate utf8_general_ci;
    alter table SD_PARAMS modify PARAM_VALUE mediumtext character set utf8 collate utf8_general_ci;
Query OK, 0 rows affected (0.016 sec)              
Records: 0  Duplicates: 0  Warnings: 0

MariaDB [metastore]>     alter table SERDE_PARAMS modify PARAM_VALUE mediumtext character set utf8 collate utf8_general_ci;
Query OK, 0 rows affected (0.015 sec)              
Records: 0  Duplicates: 0  Warnings: 0

MariaDB [metastore]>     alter table SD_PARAMS modify PARAM_VALUE mediumtext character set utf8 collate utf8_general_ci;
    alter table PARTITION_PARAMS modify PARAM_VALUE varchar(4000) character set utf8 collate utf8_general_ci;
    alter table PARTITION_KEYS modify PKEY_COMMENT varchar(4000) character set utf8 collate utf8_general_ci;
Query OK, 0 rows affected (0.014 sec)              
Records: 0  Duplicates: 0  Warnings: 0

MariaDB [metastore]>     alter table PARTITION_PARAMS modify PARAM_VALUE varchar(4000) character set utf8 collate utf8_general_ci;
    alter table INDEX_PARAMS modify PARAM_VALUE varchar(4000) character set utf8 collate utf8_general_ci;
Query OK, 0 rows affected (0.015 sec)              
Records: 0  Duplicates: 0  Warnings: 0

MariaDB [metastore]>     alter table PARTITION_KEYS modify PKEY_COMMENT varchar(4000) character set utf8 collate utf8_general_ci;
    alter table DATABASE_PARAMS modify PARAM_VALUE varchar(4000) character set utf8 collate utf8_general_ci;
Query OK, 0 rows affected (0.016 sec)              
Records: 0  Duplicates: 0  Warnings: 0

MariaDB [metastore]>     alter table INDEX_PARAMS modify PARAM_VALUE varchar(4000) character set utf8 collate utf8_general_ci;
Query OK, 0 rows affected (0.015 sec)              racter set utf8 collate utf8_general_ci;Stage: 2 of 2 'Enabling keys'      0% of stage done
Records: 0  Duplicates: 0  Warnings: 0

MariaDB [metastore]>     alter table DATABASE_PARAMS modify PARAM_VALUE varchar(4000) character set utf8 collate utf8_general_ci;
Query OK, 0 rows affected (0.016 sec)              
Records: 0  Duplicates: 0  Warnings: 0

MariaDB [metastore]>     alter table DBS modify `DESC` varchar(4000) character set utf8 collate utf8_general_ci;
Query OK, 0 rows affected (0.010 sec)              
Records: 0  Duplicates: 0  Warnings: 0

MariaDB [metastore]> show full columns from COLUMNS_V2;
+-------------+--------------+-------------------+------+-----+---------+-------+---------------------------------+---------+
| Field       | Type         | Collation         | Null | Key | Default | Extra | Privileges                      | Comment |
+-------------+--------------+-------------------+------+-----+---------+-------+---------------------------------+---------+
| CD_ID       | bigint(20)   | NULL              | NO   | PRI | NULL    |       | select,insert,update,references |         |
| COMMENT     | varchar(256) | utf8_general_ci   | YES  |     | NULL    |       | select,insert,update,references |         |
| COLUMN_NAME | varchar(767) | latin1_bin        | NO   | PRI | NULL    |       | select,insert,update,references |         |
| TYPE_NAME   | mediumtext   | latin1_swedish_ci | YES  |     | NULL    |       | select,insert,update,references |         |
| INTEGER_IDX | int(11)      | NULL              | NO   |     | NULL    |       | select,insert,update,references |         |
+-------------+--------------+-------------------+------+-----+---------+-------+---------------------------------+---------+
5 rows in set (0.001 sec)

MariaDB [metastore]>     show full columns from TABLE_PARAMS;
    show full columns from SERDE_PARAMS;
+-------------+--------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
| Field       | Type         | Collation       | Null | Key | Default | Extra | Privileges                      | Comment |
+-------------+--------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
| TBL_ID      | bigint(20)   | NULL            | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_KEY   | varchar(256) | latin1_bin      | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_VALUE | mediumtext   | utf8_general_ci | YES  |     | NULL    |       | select,insert,update,references |         |
+-------------+--------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
3 rows in set (0.011 sec)

MariaDB [metastore]>     show full columns from SERDE_PARAMS;
+-------------+--------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
| Field       | Type         | Collation       | Null | Key | Default | Extra | Privileges                      | Comment |
+-------------+--------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
| SERDE_ID    | bigint(20)   | NULL            | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_KEY   | varchar(256) | latin1_bin      | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_VALUE | mediumtext   | utf8_general_ci | YES  |     | NULL    |       | select,insert,update,references |         |
+-------------+--------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
3 rows in set (0.001 sec)

MariaDB [metastore]>     show full columns from SD_PARAMS;
+-------------+--------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
| Field       | Type         | Collation       | Null | Key | Default | Extra | Privileges                      | Comment |
+-------------+--------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
| SD_ID       | bigint(20)   | NULL            | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_KEY   | varchar(256) | latin1_bin      | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_VALUE | mediumtext   | utf8_general_ci | YES  |     | NULL    |       | select,insert,update,references |         |
+-------------+--------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
3 rows in set (0.001 sec)

MariaDB [metastore]>     show full columns from PARTITION_PARAMS;
+-------------+---------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
| Field       | Type          | Collation       | Null | Key | Default | Extra | Privileges                      | Comment |
+-------------+---------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
| PART_ID     | bigint(20)    | NULL            | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_KEY   | varchar(256)  | latin1_bin      | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_VALUE | varchar(4000) | utf8_general_ci | YES  |     | NULL    |       | select,insert,update,references |         |
+-------------+---------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
3 rows in set (0.001 sec)

MariaDB [metastore]>     show full columns from PARTITION_KEYS;
+--------------+---------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
| Field        | Type          | Collation       | Null | Key | Default | Extra | Privileges                      | Comment |
+--------------+---------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
| TBL_ID       | bigint(20)    | NULL            | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PKEY_COMMENT | varchar(4000) | utf8_general_ci | YES  |     | NULL    |       | select,insert,update,references |         |
| PKEY_NAME    | varchar(128)  | latin1_bin      | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PKEY_TYPE    | varchar(767)  | latin1_bin      | NO   |     | NULL    |       | select,insert,update,references |         |
| INTEGER_IDX  | int(11)       | NULL            | NO   |     | NULL    |       | select,insert,update,references |         |
+--------------+---------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
5 rows in set (0.001 sec)

MariaDB [metastore]>     show full columns from INDEX_PARAMS;
+-------------+---------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
| Field       | Type          | Collation       | Null | Key | Default | Extra | Privileges                      | Comment |
+-------------+---------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
| INDEX_ID    | bigint(20)    | NULL            | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_KEY   | varchar(256)  | latin1_bin      | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_VALUE | varchar(4000) | utf8_general_ci | YES  |     | NULL    |       | select,insert,update,references |         |
+-------------+---------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
3 rows in set (0.001 sec)

MariaDB [metastore]>     show full columns from DATABASE_PARAMS;
+-------------+---------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
| Field       | Type          | Collation       | Null | Key | Default | Extra | Privileges                      | Comment |
+-------------+---------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
| DB_ID       | bigint(20)    | NULL            | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_KEY   | varchar(180)  | latin1_bin      | NO   | PRI | NULL    |       | select,insert,update,references |         |
| PARAM_VALUE | varchar(4000) | utf8_general_ci | YES  |     | NULL    |       | select,insert,update,references |         |
+-------------+---------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
3 rows in set (0.001 sec)

MariaDB [metastore]>     show full columns from DBS;
+-----------------+---------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
| Field           | Type          | Collation       | Null | Key | Default | Extra | Privileges                      | Comment |
+-----------------+---------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
| DB_ID           | bigint(20)    | NULL            | NO   | PRI | NULL    |       | select,insert,update,references |         |
| DESC            | varchar(4000) | utf8_general_ci | YES  |     | NULL    |       | select,insert,update,references |         |
| DB_LOCATION_URI | varchar(4000) | latin1_bin      | NO   |     | NULL    |       | select,insert,update,references |         |
| NAME            | varchar(128)  | latin1_bin      | YES  | UNI | NULL    |       | select,insert,update,references |         |
| OWNER_NAME      | varchar(128)  | latin1_bin      | YES  |     | NULL    |       | select,insert,update,references |         |
| OWNER_TYPE      | varchar(10)   | latin1_bin      | YES  |     | NULL    |       | select,insert,update,references |         |
+-----------------+---------------+-----------------+------+-----+---------+-------+---------------------------------+---------+
6 rows in set (0.002 sec)

MariaDB [metastore]> 
```

## 6. 실행
(in peter-kafka001, peter-kafka002)
```
# vi /etc/profile.d/hive.sh
export HIVE_HOME=/opt/hive
export PATH=$PATH:$HIVE_HOME/bin/:$HIVE_HOME/sbin/
```

```
# cd /opt/hive/
# mkdir sbin
# chown hive:hive sbin/
# cd sbin
# touch hive-metastoreserver.sh
# chown hive:hive hive-metastoreserver.sh
# chmod +x hive-metastoreserver.sh
# vi hive-metastoreserver.sh
```
> [hive-metastoreserver.sh](sbin/hive-metastoreserver.sh)

```
# su - hive
$ hive-metastoreserver.sh start
$ hive-metastoreserver.sh status
($ hive-metastoreserver.sh stop)
```

## 7. 설정(for ThriftServer)
```
# su - hive
$ cd /opt/hive/conf
$ mkdir hive-thriftserver
$ cd hive-thriftserver
$ cp -p ../hive-metastoreserver/hive-env.sh .
$ cp -p ../hive-metastoreserver/hive-log4j2.properties .
```

```
$ vi hive-log4j2.properties
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
...
property.hive.log.file = hive-thriftserver.log
...
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
```

```
$ vi hive-site.xml
```
> [hive-site.xml](thriftserver/hive-site.xml)

## 7. 실행(for ThriftServer)
1. 설정
```
# su - hive
$ cd /opt/hive/sbin
$ vi hive-thriftserver.sh
```
> [hive-thriftserver.sh](sbin/hive-thriftserver.sh)

2. 실행
```
$ hive-thriftserver.sh start
$ hive-thriftserver.sh status
($ hive-thriftserver.sh stop)
```

3. 확인
(hdfs상에 hive를 위한 디렉토리 생성)
```
# su - hdfs

$ hadoop fs -mkdir /user/hive
$ hadoop fs -chown hive:hive /user/hive
$ hadoop fs -chmod 1777 /user/hive

$ hadoop fs -mkdir /user/hive/warehouse
$ hadoop fs -chown hive:hive /user/hive/warehouse
$ hadoop fs -chmod 1777 /user/hive/warehouse

$ hadoop fs -mkdir /tmp
$ hadoop fs -chmod 1777 /tmp

$ hadoop fs -mkdir /tmp/hive-staging
$ hadoop fs -chmod 1777 /tmp/hive-staging

$ hadoop fs -mkdir /user/pjy
$ hadoop fs -chown pjy:pjy /user/pjy

# su - hive
$ beeline -u jdbc:hive2://peter-kafka001:10000 -n hive
```
> NOTE. beeline 의 -n 계정명은 HDFS상에 사용할 계정명 입력

4. DBeaver에서 접속 설정
```
General
  JDBC URL => jdbc:hive2://peter-kafka001:10000,peter-kafka002:10000
  Database/Schema: => ()
Authentification (Database Navie)
  Username => pjy (HDFS상에 저장시 사용될 계정)
  Password => ()

NOTE. HDFS상의 계정별 설정시에 필요한 설정은
     hadoop의 core-site.xml에 
        hadoop.proxyuser.hive.groups=*
        hadoop.proxyuser.hive.hosts=*
     hive의 hive-site.xml (thriftserver용)
        hive.server2.enable.doAs=true
    (아직 인증은 어떻게 처리해야할지 고민중...)
```
___
.END OF HIVE