# Hadoop 설치

## 0. 계획
* hdfs, yarn, mapred 계정으로 hadoop 실행
* hadoop HA 구성

|구분|Host|비고|
|:--|:--|:--|
|NodeManager|peter-kafka001,peter-kafka002,peter-kafka003||
|ResourceManager|peter-kafka001,peter-kafka002|Active|
|Namenode|peter-kafka001,peter-kafka002|NamenodeActive|
|Datanode|peter-kafka001,peter-kafka002,peter-kafka003||
|journalnode|peter-kafka001,peter-kafka002,peter-kafka003|/wZookeeper|
|JobHistoryServer|peter-kafka001||

## 1. 계정 추가
```
# groupadd -g 1004 hadoop

# useradd hadoop -u 1004 -g hadoop
# useradd hdfs -u 8020 -g hadoop
# useradd yarn -u 8032 -g hadoop
# useradd mapred -u 19888 -g hadoop
```
> NOTE. hadoop 유저 계정은 사용하지 않음.

```
# su - hdfs
$ ssh-keygen -t rsa
$ exit
# passwd hdfs
(input password: ****)
$ su - hdfs
$ ssh-copy-id -i ~/.ssh/id_rsa.pub hdfs@peter-kafka001
$ ssh-copy-id -i ~/.ssh/id_rsa.pub hdfs@peter-kafka002
$ ssh-copy-id -i ~/.ssh/id_rsa.pub hdfs@peter-kafka003
```

```
# su - yarn
$ ssh-keygen -t rsa
$ exit
# passwd yarn
(input password: ****)
$ su - yarn
$ ssh-copy-id -i ~/.ssh/id_rsa.pub yarn@peter-kafka001
$ ssh-copy-id -i ~/.ssh/id_rsa.pub yarn@peter-kafka002
$ ssh-copy-id -i ~/.ssh/id_rsa.pub yarn@peter-kafka003
```

```
# su - mapred
$ ssh-keygen -t rsa
$ exit
# passwd mapred
(input password: ******)
$ su - mapred
$ ssh-copy-id -i ~/.ssh/id_rsa.pub mapred@peter-kafka001
$ ssh-copy-id -i ~/.ssh/id_rsa.pub mapred@peter-kafka002
$ ssh-copy-id -i ~/.ssh/id_rsa.pub mapred@peter-kafka003
```

## 2. 설치
```
# cd ~/work
# wget https://downloads.apache.org/hadoop/common/hadoop-2.10.1/hadoop-2.10.1.tar.gz
# cd /opt
# tar zxvf ~/work/hadoop-2.10.1.tar.gz
# ln -s hadoop-2.10.1 hadoop
(in Linux)
# find /opt/hadoop/ -name "*.cmd" -delete -print
```

## 3. 설정
* slaves, include_server
```
# cd /opt/hadoop/etc/hadoop/
# cp -p slaves slaves.orig
# vi slaves
peter-kafka001
peter-kafka002
peter-kafka003
# cat slaves > include_server
```

* core-site.xml
```
# cd /opt/hadoop/etc/hadoop/
# cp -p core-site.xml core-site.xml.orig
# vi core-site.xml
```
> [core-site.xml](core-site.xml)

* hdfs-site.xml
```
# cd /opt/hadoop/etc/hadoop/
# cp -p hdfs-site.xml hdfs-site.xml.orig
# vi hdfs-site.xml
```
> [hdfs-site.xml](hdfs-site.xml)

* yarn-site.xml
```
# cd /opt/hadoop/etc/hadoop/
# cp -p yarn-site.xml yarn-site.xml.orig
# vi yarn-site.xml
```
> [yarn-site.xml](yarn-site.xml)

## 4. spark-2.3.4-yarn-shuffle.jar 복사
```
# cd ~/work
# wget https://archive.apache.org/dist/spark/spark-2.3.4/spark-2.3.4-bin-hadoop2.7.tgz
# tar zxvf spark-2.3.4-bin-hadoop2.7.tgz
# cp -p /root/work/spark-2.3.4-bin-hadoop2.7/yarn/spark-2.3.4-yarn-shuffle.jar /opt/hadoop/share/hadoop/yarn/lib/.
# chown hadoop:hadoop /opt/hadoop/share/hadoop/yarn/lib/spark-2.3.4-yarn-shuffle.jar
```
> NOTE. hadoop-2.10.0.tar.gz 설치시 필요했음.

(in peter-kafka002, peter-kafka003)
```
# scp -p root@peter-kafka001:/opt/hadoop/share/hadoop/yarn/lib/spark-2.3.4-yarn-shuffle.jar /opt/hadoop/share/hadoop/yarn/lib/.
# chown hadoop:hadoop /opt/hadoop/share/hadoop/yarn/lib/spark-2.3.4-yarn-shuffle.jar
```

## 5. 저장소 설정
```
# mkdir /dfs/
# mkdir /dfs/nn/ /dfs/dn/ /dfs/jn/ /dfs/jn/tmp/ /LOG/

# chown -R hdfs:hadoop /dfs/nn/
# chown -R hdfs:hadoop /dfs/dn/
# chown -R hdfs:hadoop /dfs/jn/
# chown -R hdfs:hadoop /dfs/jn/tmp/
# chown -R yarn:hadoop /LOG/

# chmod 775 /dfs/
# chmod 775 /dfs/nn/
# chmod 770 /dfs/dn/
# chmod 775 /dfs/jn/
# chmod 775 /dfs/jn/tmp/
```

## 6. 권한 설정
```
# chown -R hadoop:hadoop /opt/hadoop-2.10.1/
# chown -R hadoop:hadoop /opt/hadoop
# chmod -R g+w /opt/hadoop-2.10.1/

# mkdir /opt/hadoop/logs/
# chown hadoop:hadoop
# chmod 775 /opt/hadoop/logs/
```

## 7. 전체 노드에 설정 복사
(in pater-kafka001)
```
# cd  /opt/hadoop/etc/hadoop/
# scp -p slaves include_server core-site.xml hdfs-site.xml yarn-site.xml root@peter-kafka002:/opt/hadoop/etc/hadoop/.
# scp -p slaves include_server core-site.xml hdfs-site.xml yarn-site.xml root@peter-kafka003:/opt/hadoop/etc/hadoop/.
```

## 8. 실행
### JournalNode
1. Zookeeper file system 포맷  
(in peter-kafka001)
```
# su - hdfs
$ /opt/hadoop/bin/hdfs zkfc -formatZK
```

> 실행예
```
[hdfs@peter-kafka001 ~]$ /opt/hadoop/bin/hdfs zkfc -formatZK
21/02/21 12:51:13 INFO tools.DFSZKFailoverController: STARTUP_MSG: 
/************************************************************
STARTUP_MSG: Starting DFSZKFailoverController
STARTUP_MSG:   host = peter-kafka001/192.168.126.71
STARTUP_MSG:   args = [-formatZK]
STARTUP_MSG:   version = 2.10.1
STARTUP_MSG:   classpath = /opt/hadoop-2.10.1/etc/hadoop:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-collections-3.2.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/servlet-api-2.5.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jetty-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jetty-util-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jetty-sslengine-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jsp-api-2.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jersey-core-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jersey-json-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jettison-1.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jaxb-impl-2.2.3-1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jaxb-api-2.2.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/stax-api-1.0-2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/activation-1.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jackson-core-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jackson-mapper-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jackson-jaxrs-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jackson-xc-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jersey-server-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/asm-3.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/log4j-1.2.17.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jets3t-0.9.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/java-xmlbuilder-0.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-lang-2.6.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-configuration-1.6.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-digester-1.8.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-beanutils-1.9.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-lang3-3.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/slf4j-api-1.7.25.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/slf4j-log4j12-1.7.25.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/avro-1.7.7.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/paranamer-2.3.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/snappy-java-1.0.5.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-compress-1.19.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/protobuf-java-2.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/gson-2.2.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/hadoop-auth-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/nimbus-jose-jwt-7.9.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jcip-annotations-1.0-1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/json-smart-1.3.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/apacheds-kerberos-codec-2.0.0-M15.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/apacheds-i18n-2.0.0-M15.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/api-asn1-api-1.0.0-M20.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/api-util-1.0.0-M20.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/zookeeper-3.4.14.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/spotbugs-annotations-3.1.9.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/audience-annotations-0.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/netty-3.10.6.Final.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/curator-framework-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/curator-client-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jsch-0.1.55.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/curator-recipes-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/htrace-core4-4.1.0-incubating.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/stax2-api-3.1.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/woodstox-core-5.0.3.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/junit-4.11.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/hamcrest-core-1.3.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/mockito-all-1.8.5.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/hadoop-annotations-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/guava-11.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jsr305-3.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-cli-1.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-math3-3.1.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/xmlenc-0.52.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/httpclient-4.5.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/httpcore-4.4.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-logging-1.1.3.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-codec-1.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-io-2.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-net-3.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/hadoop-common-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/hadoop-common-2.10.1-tests.jar:/opt/hadoop-2.10.1/share/hadoop/common/hadoop-nfs-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-codec-1.4.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/log4j-1.2.17.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-logging-1.1.3.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jsr305-3.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/netty-3.10.6.Final.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/guava-11.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-cli-1.2.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/xmlenc-0.52.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-io-2.4.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/servlet-api-2.5.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jetty-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jetty-util-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jersey-core-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jackson-core-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jackson-mapper-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jersey-server-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/asm-3.2.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-lang-2.6.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/protobuf-java-2.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/htrace-core4-4.1.0-incubating.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/hadoop-hdfs-client-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/okhttp-2.7.5.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/okio-1.6.0.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-daemon-1.0.13.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/netty-all-4.1.50.Final.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/xercesImpl-2.12.0.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/xml-apis-1.4.01.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/leveldbjni-all-1.8.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jackson-databind-2.9.10.6.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jackson-annotations-2.9.10.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jackson-core-2.9.10.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-2.10.1-tests.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-client-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-client-2.10.1-tests.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-native-client-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-native-client-2.10.1-tests.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-rbf-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-rbf-2.10.1-tests.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-nfs-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-cli-1.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/log4j-1.2.17.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-compress-1.19.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/servlet-api-2.5.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-codec-1.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jetty-util-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jersey-core-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jersey-client-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jackson-core-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jackson-mapper-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jackson-jaxrs-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jackson-xc-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/guice-servlet-3.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/guice-3.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/javax.inject-1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/aopalliance-1.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-io-2.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jersey-server-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/asm-3.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jersey-json-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jettison-1.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jaxb-impl-2.2.3-1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jersey-guice-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-math3-3.1.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/xmlenc-0.52.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/httpclient-4.5.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/httpcore-4.4.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-net-3.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-collections-3.2.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jetty-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jetty-sslengine-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jsp-api-2.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jets3t-0.9.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/java-xmlbuilder-0.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-configuration-1.6.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-digester-1.8.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-beanutils-1.9.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-lang3-3.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/avro-1.7.7.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/paranamer-2.3.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/snappy-java-1.0.5.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/gson-2.2.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/nimbus-jose-jwt-7.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jcip-annotations-1.0-1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/json-smart-1.3.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/apacheds-kerberos-codec-2.0.0-M15.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/apacheds-i18n-2.0.0-M15.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/api-asn1-api-1.0.0-M20.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/api-util-1.0.0-M20.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/zookeeper-3.4.14.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/spotbugs-annotations-3.1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/audience-annotations-0.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/netty-3.10.6.Final.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/curator-framework-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/curator-client-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jsch-0.1.55.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/curator-recipes-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/htrace-core4-4.1.0-incubating.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/stax2-api-3.1.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/woodstox-core-5.0.3.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/leveldbjni-all-1.8.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/geronimo-jcache_1.0_spec-1.0-alpha-1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/ehcache-3.3.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/HikariCP-java7-2.4.12.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/mssql-jdbc-6.2.1.jre7.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/metrics-core-3.0.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/fst-2.50.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/java-util-1.9.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/json-io-2.5.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-lang-2.6.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/guava-11.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jsr305-3.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-logging-1.1.3.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jaxb-api-2.2.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/stax-api-1.0-2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/activation-1.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/protobuf-java-2.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-api-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-common-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-registry-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-common-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-nodemanager-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-web-proxy-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-applicationhistoryservice-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-resourcemanager-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-tests-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-client-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-sharedcachemanager-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-timeline-pluginstorage-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-router-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-applications-distributedshell-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-applications-unmanaged-am-launcher-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/protobuf-java-2.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/avro-1.7.7.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/jackson-core-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/jackson-mapper-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/paranamer-2.3.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/snappy-java-1.0.5.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/commons-compress-1.19.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/hadoop-annotations-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/commons-io-2.4.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/jersey-core-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/jersey-server-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/asm-3.2.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/log4j-1.2.17.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/netty-3.10.6.Final.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/leveldbjni-all-1.8.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/guice-3.0.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/javax.inject-1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/aopalliance-1.0.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/jersey-guice-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/guice-servlet-3.0.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/junit-4.11.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/hamcrest-core-1.3.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-core-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-common-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-shuffle-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-app-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-hs-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-hs-plugins-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.10.1-tests.jar:/contrib/capacity-scheduler/*.jar
STARTUP_MSG:   build = https://github.com/apache/hadoop -r 1827467c9a56f133025f28557bfc2c562d78e816; compiled by 'centos' on 2020-09-14T13:17Z
STARTUP_MSG:   java = 1.8.0_282
************************************************************/
21/02/21 12:51:13 INFO tools.DFSZKFailoverController: registered UNIX signal handlers for [TERM, HUP, INT]
21/02/21 12:51:13 INFO tools.DFSZKFailoverController: Failover controller configured for NameNode NameNode at peter-kafka001/192.168.126.71:8020
21/02/21 12:51:13 INFO zookeeper.ZooKeeper: Client environment:zookeeper.version=3.4.14-4c25d480e66aadd371de8bd2fd8da255ac140bcf, built on 03/06/2019 16:18 GMT
21/02/21 12:51:13 INFO zookeeper.ZooKeeper: Client environment:host.name=peter-kafka001
21/02/21 12:51:13 INFO zookeeper.ZooKeeper: Client environment:java.version=1.8.0_282
21/02/21 12:51:13 INFO zookeeper.ZooKeeper: Client environment:java.vendor=Red Hat, Inc.
21/02/21 12:51:13 INFO zookeeper.ZooKeeper: Client environment:java.home=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.282.b08-1.el7_9.x86_64/jre
21/02/21 12:51:13 INFO zookeeper.ZooKeeper: Client environment:java.class.path=/opt/hadoop-2.10.1/etc/hadoop:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-collections-3.2.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/servlet-api-2.5.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jetty-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jetty-util-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jetty-sslengine-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jsp-api-2.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jersey-core-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jersey-json-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jettison-1.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jaxb-impl-2.2.3-1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jaxb-api-2.2.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/stax-api-1.0-2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/activation-1.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jackson-core-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jackson-mapper-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jackson-jaxrs-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jackson-xc-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jersey-server-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/asm-3.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/log4j-1.2.17.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jets3t-0.9.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/java-xmlbuilder-0.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-lang-2.6.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-configuration-1.6.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-digester-1.8.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-beanutils-1.9.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-lang3-3.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/slf4j-api-1.7.25.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/slf4j-log4j12-1.7.25.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/avro-1.7.7.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/paranamer-2.3.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/snappy-java-1.0.5.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-compress-1.19.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/protobuf-java-2.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/gson-2.2.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/hadoop-auth-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/nimbus-jose-jwt-7.9.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jcip-annotations-1.0-1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/json-smart-1.3.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/apacheds-kerberos-codec-2.0.0-M15.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/apacheds-i18n-2.0.0-M15.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/api-asn1-api-1.0.0-M20.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/api-util-1.0.0-M20.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/zookeeper-3.4.14.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/spotbugs-annotations-3.1.9.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/audience-annotations-0.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/netty-3.10.6.Final.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/curator-framework-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/curator-client-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jsch-0.1.55.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/curator-recipes-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/htrace-core4-4.1.0-incubating.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/stax2-api-3.1.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/woodstox-core-5.0.3.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/junit-4.11.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/hamcrest-core-1.3.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/mockito-all-1.8.5.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/hadoop-annotations-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/guava-11.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jsr305-3.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-cli-1.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-math3-3.1.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/xmlenc-0.52.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/httpclient-4.5.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/httpcore-4.4.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-logging-1.1.3.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-codec-1.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-io-2.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-net-3.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/hadoop-common-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/hadoop-common-2.10.1-tests.jar:/opt/hadoop-2.10.1/share/hadoop/common/hadoop-nfs-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-codec-1.4.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/log4j-1.2.17.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-logging-1.1.3.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jsr305-3.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/netty-3.10.6.Final.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/guava-11.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-cli-1.2.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/xmlenc-0.52.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-io-2.4.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/servlet-api-2.5.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jetty-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jetty-util-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jersey-core-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jackson-core-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jackson-mapper-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jersey-server-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/asm-3.2.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-lang-2.6.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/protobuf-java-2.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/htrace-core4-4.1.0-incubating.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/hadoop-hdfs-client-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/okhttp-2.7.5.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/okio-1.6.0.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-daemon-1.0.13.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/netty-all-4.1.50.Final.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/xercesImpl-2.12.0.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/xml-apis-1.4.01.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/leveldbjni-all-1.8.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jackson-databind-2.9.10.6.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jackson-annotations-2.9.10.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jackson-core-2.9.10.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-2.10.1-tests.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-client-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-client-2.10.1-tests.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-native-client-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-native-client-2.10.1-tests.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-rbf-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-rbf-2.10.1-tests.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-nfs-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-cli-1.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/log4j-1.2.17.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-compress-1.19.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/servlet-api-2.5.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-codec-1.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jetty-util-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jersey-core-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jersey-client-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jackson-core-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jackson-mapper-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jackson-jaxrs-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jackson-xc-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/guice-servlet-3.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/guice-3.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/javax.inject-1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/aopalliance-1.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-io-2.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jersey-server-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/asm-3.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jersey-json-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jettison-1.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jaxb-impl-2.2.3-1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jersey-guice-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-math3-3.1.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/xmlenc-0.52.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/httpclient-4.5.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/httpcore-4.4.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-net-3.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-collections-3.2.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jetty-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jetty-sslengine-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jsp-api-2.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jets3t-0.9.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/java-xmlbuilder-0.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-configuration-1.6.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-digester-1.8.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-beanutils-1.9.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-lang3-3.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/avro-1.7.7.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/paranamer-2.3.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/snappy-java-1.0.5.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/gson-2.2.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/nimbus-jose-jwt-7.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jcip-annotations-1.0-1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/json-smart-1.3.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/apacheds-kerberos-codec-2.0.0-M15.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/apacheds-i18n-2.0.0-M15.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/api-asn1-api-1.0.0-M20.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/api-util-1.0.0-M20.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/zookeeper-3.4.14.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/spotbugs-annotations-3.1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/audience-annotations-0.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/netty-3.10.6.Final.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/curator-framework-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/curator-client-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jsch-0.1.55.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/curator-recipes-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/htrace-core4-4.1.0-incubating.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/stax2-api-3.1.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/woodstox-core-5.0.3.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/leveldbjni-all-1.8.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/geronimo-jcache_1.0_spec-1.0-alpha-1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/ehcache-3.3.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/HikariCP-java7-2.4.12.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/mssql-jdbc-6.2.1.jre7.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/metrics-core-3.0.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/fst-2.50.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/java-util-1.9.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/json-io-2.5.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-lang-2.6.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/guava-11.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jsr305-3.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-logging-1.1.3.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jaxb-api-2.2.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/stax-api-1.0-2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/activation-1.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/protobuf-java-2.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-api-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-common-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-registry-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-common-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-nodemanager-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-web-proxy-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-applicationhistoryservice-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-resourcemanager-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-tests-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-client-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-sharedcachemanager-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-timeline-pluginstorage-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-router-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-applications-distributedshell-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-applications-unmanaged-am-launcher-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/protobuf-java-2.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/avro-1.7.7.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/jackson-core-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/jackson-mapper-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/paranamer-2.3.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/snappy-java-1.0.5.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/commons-compress-1.19.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/hadoop-annotations-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/commons-io-2.4.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/jersey-core-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/jersey-server-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/asm-3.2.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/log4j-1.2.17.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/netty-3.10.6.Final.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/leveldbjni-all-1.8.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/guice-3.0.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/javax.inject-1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/aopalliance-1.0.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/jersey-guice-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/guice-servlet-3.0.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/junit-4.11.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/hamcrest-core-1.3.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-core-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-common-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-shuffle-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-app-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-hs-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-hs-plugins-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.10.1-tests.jar:/contrib/capacity-scheduler/*.jar
21/02/21 12:51:13 INFO zookeeper.ZooKeeper: Client environment:java.library.path=/opt/hadoop-2.10.1/lib/native
21/02/21 12:51:13 INFO zookeeper.ZooKeeper: Client environment:java.io.tmpdir=/tmp
21/02/21 12:51:13 INFO zookeeper.ZooKeeper: Client environment:java.compiler=<NA>
21/02/21 12:51:13 INFO zookeeper.ZooKeeper: Client environment:os.name=Linux
21/02/21 12:51:13 INFO zookeeper.ZooKeeper: Client environment:os.arch=amd64
21/02/21 12:51:13 INFO zookeeper.ZooKeeper: Client environment:os.version=3.10.0-1160.el7.x86_64
21/02/21 12:51:13 INFO zookeeper.ZooKeeper: Client environment:user.name=hdfs
21/02/21 12:51:13 INFO zookeeper.ZooKeeper: Client environment:user.home=/home/hdfs
21/02/21 12:51:13 INFO zookeeper.ZooKeeper: Client environment:user.dir=/home/hdfs
21/02/21 12:51:13 INFO zookeeper.ZooKeeper: Initiating client connection, connectString=peter-zk001:2181,peter-zk002:2181,peter-zk003:2181 sessionTimeout=300000 watcher=org.apache.hadoop.ha.ActiveStandbyElector$WatcherWithClientRef@7c729a55
21/02/21 12:51:13 INFO zookeeper.ClientCnxn: Opening socket connection to server peter-zk001/192.168.126.71:2181. Will not attempt to authenticate using SASL (unknown error)
21/02/21 12:51:13 INFO zookeeper.ClientCnxn: Socket connection established to peter-zk001/192.168.126.71:2181, initiating session
21/02/21 12:51:13 INFO zookeeper.ClientCnxn: Session establishment complete on server peter-zk001/192.168.126.71:2181, sessionid = 0x100000027490002, negotiated timeout = 40000
21/02/21 12:51:13 INFO ha.ActiveStandbyElector: Session connected.
21/02/21 12:51:13 INFO ha.ActiveStandbyElector: Successfully created /hadoop-ha/peter-cluster in ZK.
21/02/21 12:51:13 INFO zookeeper.ZooKeeper: Session: 0x100000027490002 closed
21/02/21 12:51:13 INFO zookeeper.ClientCnxn: EventThread shut down for session: 0x100000027490002
21/02/21 12:51:13 INFO tools.DFSZKFailoverController: SHUTDOWN_MSG: 
/************************************************************
SHUTDOWN_MSG: Shutting down DFSZKFailoverController at peter-kafka001/192.168.126.71
************************************************************/
[hdfs@peter-kafka001 ~]$
```

2. 설정 확인
```
$ /opt/zookeeper/bin/zkCli.sh
[zk: localhost:2181(CONNECTED) 0] ls /
[hadoop-ha, kafka, zookeeper]
[zk: localhost:2181(CONNECTED) 1] ls /hadoop-ha
[peter-cluster]
[zk: localhost:2181(CONNECTED) 2] 
```

3. 실행
```
# vi /etc/profile.d/hadoop.sh 설정
export HADOOP_HOME=/opt/hadoop
export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop

export PATH=$PATH:$HADOOP_HOME/bin/:$HADOOP_HOME/sbin
```

```
# su - yarn
$ cd /opt/hadoop
$ sbin/hadoop-daemon.sh start journalnode
$ jps
```

> 실행예
```
[yarn@peter-kafka001 ~]$ cd /opt/hadoop
[yarn@peter-kafka001 hadoop]$ sbin/hadoop-daemon.sh start journalnode
starting journalnode, logging to /opt/hadoop-2.10.1/logs/hadoop-yarn-journalnode-peter-kafka001.out
[yarn@peter-kafka001 hadoop]$ jps
5292 JournalNode            # <--- 실행후 추가됨.
5358 Jps

[yarn@peter-kafka002 ~]$ cd /opt/hadoop
[yarn@peter-kafka002 hadoop]$ sbin/hadoop-daemon.sh start journalnode
starting journalnode, logging to /opt/hadoop-2.10.1/logs/hadoop-yarn-journalnode-peter-kafka002.out
[yarn@peter-kafka002 hadoop]$ jps
53824 Jps
53768 JournalNode            # <--- 실행후 추가됨.

[yarn@peter-kafka003 ~]$ cd /opt/hadoop
[yarn@peter-kafka003 hadoop]$ sbin/hadoop-daemon.sh start journalnode
starting journalnode, logging to /opt/hadoop-2.10.1/logs/hadoop-yarn-journalnode-peter-kafka003.out
[yarn@peter-kafka003 hadoop]$ jps
55857 Jps
55801 JournalNode            # <--- 실행후 추가됨.
```

4. JournalNode 중지
```
# su - yarn
$ cd /opt/hadoop
$ sbin/hadoop-daemon.sh stop journalnode
% ssh yarn@peter-kafka002 "/opt/hadoop/sbin/hadoop-daemon.sh stop journalnode"
% ssh yarn@peter-kafka003 "/opt/hadoop/sbin/hadoop-daemon.sh stop journalnode"
```
> 참고. Namenode format을 위해서는 중지 하면 안됨

### NameNode
1. NameNode 포맷
(in peter-kafka001)
```
# su - hdfs
$ cd /opt/hadoop
$ bin/hdfs namenode -format
```
> journalnode 가 실행된 상태에서 실행해야함

> 실행예
```
[hdfs@peter-kafka001 hadoop]$ bin/hdfs namenode -format
21/02/21 13:35:52 INFO namenode.NameNode: STARTUP_MSG: 
/************************************************************
STARTUP_MSG: Starting NameNode
STARTUP_MSG:   host = peter-kafka001/192.168.126.71
STARTUP_MSG:   args = [-format]
STARTUP_MSG:   version = 2.10.1
STARTUP_MSG:   classpath = /opt/hadoop/etc/hadoop:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-collections-3.2.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/servlet-api-2.5.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jetty-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jetty-util-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jetty-sslengine-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jsp-api-2.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jersey-core-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jersey-json-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jettison-1.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jaxb-impl-2.2.3-1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jaxb-api-2.2.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/stax-api-1.0-2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/activation-1.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jackson-core-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jackson-mapper-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jackson-jaxrs-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jackson-xc-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jersey-server-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/asm-3.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/log4j-1.2.17.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jets3t-0.9.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/java-xmlbuilder-0.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-lang-2.6.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-configuration-1.6.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-digester-1.8.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-beanutils-1.9.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-lang3-3.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/slf4j-api-1.7.25.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/slf4j-log4j12-1.7.25.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/avro-1.7.7.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/paranamer-2.3.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/snappy-java-1.0.5.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-compress-1.19.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/protobuf-java-2.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/gson-2.2.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/hadoop-auth-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/nimbus-jose-jwt-7.9.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jcip-annotations-1.0-1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/json-smart-1.3.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/apacheds-kerberos-codec-2.0.0-M15.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/apacheds-i18n-2.0.0-M15.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/api-asn1-api-1.0.0-M20.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/api-util-1.0.0-M20.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/zookeeper-3.4.14.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/spotbugs-annotations-3.1.9.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/audience-annotations-0.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/netty-3.10.6.Final.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/curator-framework-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/curator-client-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jsch-0.1.55.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/curator-recipes-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/htrace-core4-4.1.0-incubating.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/stax2-api-3.1.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/woodstox-core-5.0.3.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/junit-4.11.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/hamcrest-core-1.3.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/mockito-all-1.8.5.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/hadoop-annotations-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/guava-11.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jsr305-3.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-cli-1.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-math3-3.1.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/xmlenc-0.52.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/httpclient-4.5.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/httpcore-4.4.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-logging-1.1.3.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-codec-1.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-io-2.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-net-3.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/hadoop-common-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/hadoop-common-2.10.1-tests.jar:/opt/hadoop-2.10.1/share/hadoop/common/hadoop-nfs-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-codec-1.4.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/log4j-1.2.17.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-logging-1.1.3.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jsr305-3.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/netty-3.10.6.Final.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/guava-11.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-cli-1.2.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/xmlenc-0.52.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-io-2.4.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/servlet-api-2.5.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jetty-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jetty-util-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jersey-core-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jackson-core-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jackson-mapper-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jersey-server-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/asm-3.2.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-lang-2.6.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/protobuf-java-2.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/htrace-core4-4.1.0-incubating.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/hadoop-hdfs-client-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/okhttp-2.7.5.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/okio-1.6.0.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-daemon-1.0.13.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/netty-all-4.1.50.Final.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/xercesImpl-2.12.0.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/xml-apis-1.4.01.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/leveldbjni-all-1.8.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jackson-databind-2.9.10.6.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jackson-annotations-2.9.10.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jackson-core-2.9.10.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-2.10.1-tests.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-client-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-client-2.10.1-tests.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-native-client-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-native-client-2.10.1-tests.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-rbf-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-rbf-2.10.1-tests.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-nfs-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-cli-1.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/log4j-1.2.17.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-compress-1.19.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/servlet-api-2.5.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-codec-1.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jetty-util-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jersey-core-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jersey-client-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jackson-core-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jackson-mapper-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jackson-jaxrs-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jackson-xc-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/guice-servlet-3.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/guice-3.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/javax.inject-1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/aopalliance-1.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-io-2.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jersey-server-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/asm-3.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jersey-json-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jettison-1.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jaxb-impl-2.2.3-1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jersey-guice-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-math3-3.1.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/xmlenc-0.52.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/httpclient-4.5.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/httpcore-4.4.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-net-3.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-collections-3.2.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jetty-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jetty-sslengine-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jsp-api-2.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jets3t-0.9.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/java-xmlbuilder-0.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-configuration-1.6.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-digester-1.8.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-beanutils-1.9.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-lang3-3.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/avro-1.7.7.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/paranamer-2.3.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/snappy-java-1.0.5.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/gson-2.2.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/nimbus-jose-jwt-7.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jcip-annotations-1.0-1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/json-smart-1.3.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/apacheds-kerberos-codec-2.0.0-M15.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/apacheds-i18n-2.0.0-M15.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/api-asn1-api-1.0.0-M20.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/api-util-1.0.0-M20.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/zookeeper-3.4.14.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/spotbugs-annotations-3.1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/audience-annotations-0.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/netty-3.10.6.Final.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/curator-framework-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/curator-client-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jsch-0.1.55.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/curator-recipes-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/htrace-core4-4.1.0-incubating.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/stax2-api-3.1.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/woodstox-core-5.0.3.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/leveldbjni-all-1.8.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/geronimo-jcache_1.0_spec-1.0-alpha-1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/ehcache-3.3.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/HikariCP-java7-2.4.12.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/mssql-jdbc-6.2.1.jre7.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/metrics-core-3.0.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/fst-2.50.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/java-util-1.9.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/json-io-2.5.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-lang-2.6.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/guava-11.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jsr305-3.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-logging-1.1.3.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jaxb-api-2.2.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/stax-api-1.0-2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/activation-1.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/protobuf-java-2.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/spark-2.3.4-yarn-shuffle.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-api-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-common-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-registry-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-common-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-nodemanager-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-web-proxy-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-applicationhistoryservice-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-resourcemanager-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-tests-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-client-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-sharedcachemanager-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-timeline-pluginstorage-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-router-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-applications-distributedshell-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-applications-unmanaged-am-launcher-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/protobuf-java-2.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/avro-1.7.7.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/jackson-core-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/jackson-mapper-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/paranamer-2.3.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/snappy-java-1.0.5.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/commons-compress-1.19.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/hadoop-annotations-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/commons-io-2.4.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/jersey-core-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/jersey-server-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/asm-3.2.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/log4j-1.2.17.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/netty-3.10.6.Final.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/leveldbjni-all-1.8.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/guice-3.0.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/javax.inject-1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/aopalliance-1.0.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/jersey-guice-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/guice-servlet-3.0.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/junit-4.11.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/hamcrest-core-1.3.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-core-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-common-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-shuffle-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-app-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-hs-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-hs-plugins-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.10.1-tests.jar:/opt/hadoop/contrib/capacity-scheduler/*.jar
STARTUP_MSG:   build = https://github.com/apache/hadoop -r 1827467c9a56f133025f28557bfc2c562d78e816; compiled by 'centos' on 2020-09-14T13:17Z
STARTUP_MSG:   java = 1.8.0_282
************************************************************/
21/02/21 13:35:52 INFO namenode.NameNode: registered UNIX signal handlers for [TERM, HUP, INT]
21/02/21 13:35:52 INFO namenode.NameNode: createNameNode [-format]
21/02/21 13:35:53 INFO common.Util: Assuming 'file' scheme for path /dfs/nn in configuration.
21/02/21 13:35:53 INFO common.Util: Assuming 'file' scheme for path /dfs/nn in configuration.
Formatting using clusterid: CID-a94e54b2-0de8-45d7-b88f-7009b166327a
21/02/21 13:35:53 INFO namenode.FSEditLog: Edit logging is async:true
21/02/21 13:35:53 INFO namenode.FSNamesystem: KeyProvider: null
21/02/21 13:35:53 INFO namenode.FSNamesystem: fsLock is fair: true
21/02/21 13:35:53 INFO namenode.FSNamesystem: Detailed lock hold time metrics enabled: false
21/02/21 13:35:53 INFO namenode.FSNamesystem: fsOwner             = hdfs (auth:SIMPLE)
21/02/21 13:35:53 INFO namenode.FSNamesystem: supergroup          = supergroup
21/02/21 13:35:53 INFO namenode.FSNamesystem: isPermissionEnabled = true
21/02/21 13:35:53 INFO namenode.FSNamesystem: Determined nameservice ID: peter-cluster
21/02/21 13:35:53 INFO namenode.FSNamesystem: HA Enabled: true
21/02/21 13:35:53 INFO common.Util: dfs.datanode.fileio.profiling.sampling.percentage set to 0. Disabling file IO profiling
21/02/21 13:35:53 INFO util.HostsFileReader: Adding a node "peter-kafka001" to the list of included hosts from /opt/hadoop/etc/hadoop/include_server
21/02/21 13:35:53 INFO util.HostsFileReader: Adding a node "peter-kafka002" to the list of included hosts from /opt/hadoop/etc/hadoop/include_server
21/02/21 13:35:53 INFO util.HostsFileReader: Adding a node "peter-kafka003" to the list of included hosts from /opt/hadoop/etc/hadoop/include_server
21/02/21 13:35:53 INFO blockmanagement.DatanodeManager: dfs.block.invalidate.limit: configured=1000, counted=60, effected=1000
21/02/21 13:35:53 INFO blockmanagement.DatanodeManager: dfs.namenode.datanode.registration.ip-hostname-check=true
21/02/21 13:35:53 INFO blockmanagement.BlockManager: dfs.namenode.startup.delay.block.deletion.sec is set to 000:00:00:00.000
21/02/21 13:35:53 INFO blockmanagement.BlockManager: The block deletion will start around 2021 2월 21 13:35:53
21/02/21 13:35:53 INFO util.GSet: Computing capacity for map BlocksMap
21/02/21 13:35:53 INFO util.GSet: VM type       = 64-bit
21/02/21 13:35:53 INFO util.GSet: 2.0% max memory 889 MB = 17.8 MB
21/02/21 13:35:53 INFO util.GSet: capacity      = 2^21 = 2097152 entries
21/02/21 13:35:53 INFO blockmanagement.BlockManager: dfs.block.access.token.enable=false
21/02/21 13:35:53 WARN conf.Configuration: No unit for dfs.heartbeat.interval(3) assuming SECONDS
21/02/21 13:35:53 WARN conf.Configuration: No unit for dfs.namenode.safemode.extension(30000) assuming MILLISECONDS
21/02/21 13:35:53 INFO blockmanagement.BlockManagerSafeMode: dfs.namenode.safemode.threshold-pct = 0.9990000128746033
21/02/21 13:35:53 INFO blockmanagement.BlockManagerSafeMode: dfs.namenode.safemode.min.datanodes = 0
21/02/21 13:35:53 INFO blockmanagement.BlockManagerSafeMode: dfs.namenode.safemode.extension = 30000
21/02/21 13:35:53 INFO blockmanagement.BlockManager: defaultReplication         = 2
21/02/21 13:35:53 INFO blockmanagement.BlockManager: maxReplication             = 512
21/02/21 13:35:53 INFO blockmanagement.BlockManager: minReplication             = 1
21/02/21 13:35:53 INFO blockmanagement.BlockManager: maxReplicationStreams      = 2
21/02/21 13:35:53 INFO blockmanagement.BlockManager: replicationRecheckInterval = 3000
21/02/21 13:35:53 INFO blockmanagement.BlockManager: encryptDataTransfer        = false
21/02/21 13:35:53 INFO blockmanagement.BlockManager: maxNumBlocksToLog          = 1000
21/02/21 13:35:53 INFO namenode.FSNamesystem: Append Enabled: true
21/02/21 13:35:53 INFO namenode.FSDirectory: GLOBAL serial map: bits=24 maxEntries=16777215
21/02/21 13:35:53 INFO util.GSet: Computing capacity for map INodeMap
21/02/21 13:35:53 INFO util.GSet: VM type       = 64-bit
21/02/21 13:35:53 INFO util.GSet: 1.0% max memory 889 MB = 8.9 MB
21/02/21 13:35:53 INFO util.GSet: capacity      = 2^20 = 1048576 entries
21/02/21 13:35:53 INFO namenode.FSDirectory: ACLs enabled? false
21/02/21 13:35:53 INFO namenode.FSDirectory: XAttrs enabled? true
21/02/21 13:35:53 INFO namenode.NameNode: Caching file names occurring more than 10 times
21/02/21 13:35:53 INFO snapshot.SnapshotManager: Loaded config captureOpenFiles: falseskipCaptureAccessTimeOnlyChange: false
21/02/21 13:35:53 INFO util.GSet: Computing capacity for map cachedBlocks
21/02/21 13:35:53 INFO util.GSet: VM type       = 64-bit
21/02/21 13:35:53 INFO util.GSet: 0.25% max memory 889 MB = 2.2 MB
21/02/21 13:35:53 INFO util.GSet: capacity      = 2^18 = 262144 entries
21/02/21 13:35:53 INFO metrics.TopMetrics: NNTop conf: dfs.namenode.top.window.num.buckets = 10
21/02/21 13:35:53 INFO metrics.TopMetrics: NNTop conf: dfs.namenode.top.num.users = 10
21/02/21 13:35:53 INFO metrics.TopMetrics: NNTop conf: dfs.namenode.top.windows.minutes = 1,5,25
21/02/21 13:35:53 INFO namenode.FSNamesystem: Retry cache on namenode is enabled
21/02/21 13:35:53 INFO namenode.FSNamesystem: Retry cache will use 0.03 of total heap and retry cache entry expiry time is 600000 millis
21/02/21 13:35:53 INFO util.GSet: Computing capacity for map NameNodeRetryCache
21/02/21 13:35:53 INFO util.GSet: VM type       = 64-bit
21/02/21 13:35:53 INFO util.GSet: 0.029999999329447746% max memory 889 MB = 273.1 KB
21/02/21 13:35:53 INFO util.GSet: capacity      = 2^15 = 32768 entries
21/02/21 13:35:54 INFO namenode.FSImage: Allocated new BlockPoolId: BP-1796558398-192.168.126.71-1613882154343
21/02/21 13:35:54 INFO common.Storage: Storage directory /dfs/nn has been successfully formatted.
21/02/21 13:35:54 INFO namenode.FSImageFormatProtobuf: Saving image file /dfs/nn/current/fsimage.ckpt_0000000000000000000 using no compression
21/02/21 13:35:54 INFO namenode.FSImageFormatProtobuf: Image file /dfs/nn/current/fsimage.ckpt_0000000000000000000 of size 322 bytes saved in 0 seconds .
21/02/21 13:35:54 INFO namenode.NNStorageRetentionManager: Going to retain 1 images with txid >= 0
21/02/21 13:35:54 INFO namenode.FSImage: FSImageSaver clean checkpoint: txid = 0 when meet shutdown.
21/02/21 13:35:54 INFO namenode.NameNode: SHUTDOWN_MSG: 
/************************************************************
SHUTDOWN_MSG: Shutting down NameNode at peter-kafka001/192.168.126.71
************************************************************/
[hdfs@peter-kafka001 hadoop]$ 
[hdfs@peter-kafka001 hadoop]$ ll /dfs/nn/current/
합계 16
-rw-r--r-- 1 hdfs hadoop 218  2월 21 13:35 VERSION
-rw-r--r-- 1 hdfs hadoop 322  2월 21 13:35 fsimage_0000000000000000000
-rw-r--r-- 1 hdfs hadoop  62  2월 21 13:35 fsimage_0000000000000000000.md5
-rw-r--r-- 1 hdfs hadoop   2  2월 21 13:35 seen_txid
[hdfs@peter-kafka001 hadoop]$ 
```

2. Secondary Namenode data 동기화를 위해 namenode 실행
(in peter-kafka001)
```
# su - hdfs
$ cd /opt/hadoop
$ sbin/hadoop-daemon.sh start namenode
```

> 실혱예
```
[hdfs@peter-kafka001 ~]$ cd /opt/hadoop
[hdfs@peter-kafka001 hadoop]$ jps
5621 Jps
[hdfs@peter-kafka001 hadoop]$ sbin/hadoop-daemon.sh start namenode
starting namenode, logging to /opt/hadoop-2.10.1/logs/hadoop-hdfs-namenode-peter-kafka001.out
[hdfs@peter-kafka001 hadoop]$ jps
5649 NameNode            # <--- 실행후 추가됨.
5802 Jps
[hdfs@peter-kafka001 hadoop]$ 
```

3. Secondary Namenode data 동기화
(in peter-kafka002)
```
# su - hdfs
$ cd /opt/hadoop
$ bin/hdfs namenode -bootstrapStandby
```

> 실행예
```
[hdfs@peter-kafka002 ~]$ cd /opt/hadoop
[hdfs@peter-kafka002 hadoop]$ bin/hdfs namenode -bootstrapStandby
21/02/21 14:02:29 INFO namenode.NameNode: STARTUP_MSG: 
/************************************************************
STARTUP_MSG: Starting NameNode
STARTUP_MSG:   host = peter-kafka002/192.168.126.72
STARTUP_MSG:   args = [-bootstrapStandby]
STARTUP_MSG:   version = 2.10.1
STARTUP_MSG:   classpath = /opt/hadoop/etc/hadoop:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-collections-3.2.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/servlet-api-2.5.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jetty-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jetty-util-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jetty-sslengine-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jsp-api-2.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jersey-core-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jersey-json-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jettison-1.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jaxb-impl-2.2.3-1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jaxb-api-2.2.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/stax-api-1.0-2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/activation-1.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jackson-core-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jackson-mapper-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jackson-jaxrs-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jackson-xc-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jersey-server-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/asm-3.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/log4j-1.2.17.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jets3t-0.9.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/java-xmlbuilder-0.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-lang-2.6.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-configuration-1.6.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-digester-1.8.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-beanutils-1.9.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-lang3-3.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/slf4j-api-1.7.25.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/slf4j-log4j12-1.7.25.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/avro-1.7.7.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/paranamer-2.3.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/snappy-java-1.0.5.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-compress-1.19.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/protobuf-java-2.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/gson-2.2.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/hadoop-auth-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/nimbus-jose-jwt-7.9.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jcip-annotations-1.0-1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/json-smart-1.3.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/apacheds-kerberos-codec-2.0.0-M15.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/apacheds-i18n-2.0.0-M15.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/api-asn1-api-1.0.0-M20.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/api-util-1.0.0-M20.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/zookeeper-3.4.14.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/spotbugs-annotations-3.1.9.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/audience-annotations-0.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/netty-3.10.6.Final.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/curator-framework-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/curator-client-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jsch-0.1.55.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/curator-recipes-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/htrace-core4-4.1.0-incubating.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/stax2-api-3.1.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/woodstox-core-5.0.3.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/junit-4.11.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/hamcrest-core-1.3.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/mockito-all-1.8.5.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/hadoop-annotations-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/guava-11.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/jsr305-3.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-cli-1.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-math3-3.1.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/xmlenc-0.52.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/httpclient-4.5.2.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/httpcore-4.4.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-logging-1.1.3.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-codec-1.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-io-2.4.jar:/opt/hadoop-2.10.1/share/hadoop/common/lib/commons-net-3.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/hadoop-common-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/common/hadoop-common-2.10.1-tests.jar:/opt/hadoop-2.10.1/share/hadoop/common/hadoop-nfs-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-codec-1.4.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/log4j-1.2.17.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-logging-1.1.3.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jsr305-3.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/netty-3.10.6.Final.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/guava-11.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-cli-1.2.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/xmlenc-0.52.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-io-2.4.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/servlet-api-2.5.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jetty-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jetty-util-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jersey-core-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jackson-core-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jackson-mapper-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jersey-server-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/asm-3.2.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-lang-2.6.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/protobuf-java-2.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/htrace-core4-4.1.0-incubating.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/hadoop-hdfs-client-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/okhttp-2.7.5.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/okio-1.6.0.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/commons-daemon-1.0.13.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/netty-all-4.1.50.Final.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/xercesImpl-2.12.0.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/xml-apis-1.4.01.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/leveldbjni-all-1.8.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jackson-databind-2.9.10.6.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jackson-annotations-2.9.10.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/lib/jackson-core-2.9.10.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-2.10.1-tests.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-client-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-client-2.10.1-tests.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-native-client-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-native-client-2.10.1-tests.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-rbf-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-rbf-2.10.1-tests.jar:/opt/hadoop-2.10.1/share/hadoop/hdfs/hadoop-hdfs-nfs-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-cli-1.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/log4j-1.2.17.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-compress-1.19.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/servlet-api-2.5.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-codec-1.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jetty-util-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jersey-core-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jersey-client-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jackson-core-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jackson-mapper-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jackson-jaxrs-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jackson-xc-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/guice-servlet-3.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/guice-3.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/javax.inject-1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/aopalliance-1.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-io-2.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jersey-server-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/asm-3.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jersey-json-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jettison-1.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jaxb-impl-2.2.3-1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jersey-guice-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-math3-3.1.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/xmlenc-0.52.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/httpclient-4.5.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/httpcore-4.4.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-net-3.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-collections-3.2.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jetty-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jetty-sslengine-6.1.26.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jsp-api-2.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jets3t-0.9.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/java-xmlbuilder-0.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-configuration-1.6.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-digester-1.8.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-beanutils-1.9.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-lang3-3.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/avro-1.7.7.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/paranamer-2.3.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/snappy-java-1.0.5.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/gson-2.2.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/nimbus-jose-jwt-7.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jcip-annotations-1.0-1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/json-smart-1.3.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/apacheds-kerberos-codec-2.0.0-M15.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/apacheds-i18n-2.0.0-M15.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/api-asn1-api-1.0.0-M20.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/api-util-1.0.0-M20.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/zookeeper-3.4.14.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/spotbugs-annotations-3.1.9.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/audience-annotations-0.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/netty-3.10.6.Final.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/curator-framework-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/curator-client-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jsch-0.1.55.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/curator-recipes-2.13.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/htrace-core4-4.1.0-incubating.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/stax2-api-3.1.4.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/woodstox-core-5.0.3.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/leveldbjni-all-1.8.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/geronimo-jcache_1.0_spec-1.0-alpha-1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/ehcache-3.3.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/HikariCP-java7-2.4.12.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/mssql-jdbc-6.2.1.jre7.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/metrics-core-3.0.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/fst-2.50.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/java-util-1.9.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/json-io-2.5.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-lang-2.6.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/guava-11.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jsr305-3.0.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/commons-logging-1.1.3.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/jaxb-api-2.2.2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/stax-api-1.0-2.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/activation-1.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/protobuf-java-2.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/lib/spark-2.3.4-yarn-shuffle.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-api-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-common-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-registry-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-common-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-nodemanager-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-web-proxy-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-applicationhistoryservice-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-resourcemanager-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-tests-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-client-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-sharedcachemanager-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-timeline-pluginstorage-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-server-router-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-applications-distributedshell-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/yarn/hadoop-yarn-applications-unmanaged-am-launcher-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/protobuf-java-2.5.0.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/avro-1.7.7.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/jackson-core-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/jackson-mapper-asl-1.9.13.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/paranamer-2.3.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/snappy-java-1.0.5.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/commons-compress-1.19.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/hadoop-annotations-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/commons-io-2.4.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/jersey-core-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/jersey-server-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/asm-3.2.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/log4j-1.2.17.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/netty-3.10.6.Final.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/leveldbjni-all-1.8.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/guice-3.0.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/javax.inject-1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/aopalliance-1.0.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/jersey-guice-1.9.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/guice-servlet-3.0.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/junit-4.11.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/lib/hamcrest-core-1.3.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-core-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-common-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-shuffle-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-app-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-hs-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-hs-plugins-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.10.1.jar:/opt/hadoop-2.10.1/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.10.1-tests.jar:/opt/hadoop/contrib/capacity-scheduler/*.jar
STARTUP_MSG:   build = https://github.com/apache/hadoop -r 1827467c9a56f133025f28557bfc2c562d78e816; compiled by 'centos' on 2020-09-14T13:17Z
STARTUP_MSG:   java = 1.8.0_282
************************************************************/
21/02/21 14:02:29 INFO namenode.NameNode: registered UNIX signal handlers for [TERM, HUP, INT]
21/02/21 14:02:29 INFO namenode.NameNode: createNameNode [-bootstrapStandby]
21/02/21 14:02:29 INFO ha.BootstrapStandby: Found nn: nn1, ipc: peter-kafka001/192.168.126.71:8020
21/02/21 14:02:29 INFO common.Util: Assuming 'file' scheme for path /dfs/nn in configuration.
21/02/21 14:02:29 INFO common.Util: Assuming 'file' scheme for path /dfs/nn in configuration.
=====================================================
About to bootstrap Standby ID nn2 from:
       Nameservice ID: peter-cluster
    Other Namenode ID: nn1
  Other NN's HTTP address: http://peter-kafka001:50070
  Other NN's IPC  address: peter-kafka001/192.168.126.71:8020
         Namespace ID: 190723722
        Block pool ID: BP-1796558398-192.168.126.71-1613882154343
           Cluster ID: CID-a94e54b2-0de8-45d7-b88f-7009b166327a
       Layout version: -63
       isUpgradeFinalized: true
=====================================================
21/02/21 14:02:30 INFO common.Storage: Storage directory /dfs/nn has been successfully formatted.
21/02/21 14:02:30 INFO common.Util: Assuming 'file' scheme for path /dfs/nn in configuration.
21/02/21 14:02:30 INFO common.Util: Assuming 'file' scheme for path /dfs/nn in configuration.
21/02/21 14:02:30 INFO namenode.FSEditLog: Edit logging is async:true
21/02/21 14:02:30 INFO namenode.TransferFsImage: Opening connection to http://peter-kafka001:50070/imagetransfer?getimage=1&txid=0&storageInfo=-63:190723722:1613882154343:CID-a94e54b2-0de8-45d7-b88f-7009b166327a&bootstrapstandby=true
21/02/21 14:02:30 INFO common.Util: Combined time for fsimage download and fsync to all disks took 0.00s. The fsimage download took 0.00s at 0.00 KB/s. Synchronous (fsync) write to disk of /dfs/nn/current/fsimage.ckpt_0000000000000000000 took 0.00s.
21/02/21 14:02:30 INFO namenode.TransferFsImage: Downloaded file fsimage.ckpt_0000000000000000000 size 322 bytes.
21/02/21 14:02:30 INFO namenode.NameNode: SHUTDOWN_MSG: 
/************************************************************
SHUTDOWN_MSG: Shutting down NameNode at peter-kafka002/192.168.126.72
************************************************************/
[hdfs@peter-kafka002 hadoop]$ 
```

4. Secondary Namenode 실행
(in peter-kafka002)
```
# su - hdfs
$ cd /opt/hadoop
$ sbin/hadoop-daemon.sh start namenode
```

> 실행예
```
[hdfs@peter-kafka002 opt]$ cd /opt/hadoop
[hdfs@peter-kafka002 hadoop]$ sbin/hadoop-daemon.sh start namenode
starting namenode, logging to /opt/hadoop-2.10.1/logs/hadoop-hdfs-namenode-peter-kafka002.out
[hdfs@peter-kafka002 hadoop]$ jps
54516 NameNode            # <--- 실행후 추가됨.
54670 Jps
[hdfs@peter-kafka002 hadoop]$ 
```

5. 주키퍼 장애 컨트롤러(ZKFC)
(in peter-kafka001, peter-kafka002)
```
# su - hdfs
$ cd /opt/hadoop
$ sbin/hadoop-daemon.sh start zkfc
```

> 실행예
```
[hdfs@peter-kafka001 hadoop]$ cd /opt/hadoop
[hdfs@peter-kafka001 hadoop]$ sbin/hadoop-daemon.sh start zkfc
starting zkfc, logging to /opt/hadoop-2.10.1/logs/hadoop-hdfs-zkfc-peter-kafka001.out
[hdfs@peter-kafka001 hadoop]$ jps
5649 NameNode
7864 DFSZKFailoverController
7935 Jps
[hdfs@peter-kafka001 hadoop]$ 

[hdfs@peter-kafka002 hadoop]$ cd /opt/hadoop
[hdfs@peter-kafka002 hadoop]$ sbin/hadoop-daemon.sh start zkfc
starting zkfc, logging to /opt/hadoop-2.10.1/logs/hadoop-hdfs-zkfc-peter-kafka002.out
[hdfs@peter-kafka002 hadoop]$ jps
54786 Jps
54516 NameNode
54733 DFSZKFailoverController
[hdfs@peter-kafka002 hadoop]$ 
```

### ResourceManger
(in peter-kafka001)
```
# su - yarn
$ cd /opt/hadoop
$ sbin/yarn-daemon.sh start resourcemanager
```
> 실행예
```
[root@peter-kafka001 ~]# su - yarn
[yarn@peter-kafka001 opt]$ cd /opt/hadoop
[yarn@peter-kafka001 hadoop]$ sbin/yarn-daemon.sh start resourcemanager
starting resourcemanager, logging to /opt/hadoop-2.10.1/logs/yarn-yarn-resourcemanager-peter-kafka001.out
[yarn@peter-kafka001 hadoop]$ jps
6249 Jps
6011 ResourceManager            # <--- 실행후 추가됨.
5292 JournalNode
[yarn@peter-kafka001 hadoop]$ 
```

### 여기까지 진행시 프로세스 확인
```
[root@peter-kafka001 ~]# jps
5649 NameNode
6306 Jps
2102 Kafka
1560 -- process information unavailable
1546 QuorumPeerMain
6011 ResourceManager
5292 JournalNode
[root@peter-kafka001 ~]# 

[root@peter-kafka002 ~]# jps
54004 Jps
53768 JournalNode
2842 Kafka
1535 QuorumPeerMain
[root@peter-kafka002 ~]# 

[root@peter-kafka003 ~]# jps
55801 JournalNode
2827 Kafka
55932 Jps
1534 QuorumPeerMain
[root@peter-kafka003 ~]# 
```
> NOTE. 현재 DataNode는 실행하지 않음.  
        hdfs, yarn, mapred 계정으로 실행하므로 root계정에서 jps로 전체프로세스 확인 가능

### JobHistoryServer
(in peter-kafka003)
```
# su - mapred
$ cd /opt/hadoop
$ sbin/mr-jobhistory-daemon.sh start historyserver
```

> 실행예
```
[root@peter-kafka001 ~]# su - mapred
[mapred@peter-kafka001 ~]$ cd /opt/hadoop
[mapred@peter-kafka001 hadoop]$ sbin/mr-jobhistory-daemon.sh start historyserver
starting historyserver, logging to /opt/hadoop-2.10.1/logs/mapred-mapred-historyserver-peter-kafka001.out
[mapred@peter-kafka001 hadoop]$ jps
6530 Jps
6487 JobHistoryServer            # <--- 실행후 추가됨.
[mapred@peter-kafka001 hadoop]$ 
```

### DataNode
(in peter-kafka001, peter-kafka002, peter-kafka003)
```
# su - hdfs
$ cd /opt/hadoop
$ sbin/hadoop-daemon.sh start datanode
```

> 실행예
```
[hdfs@peter-kafka001 ~]$ cd /opt/hadoop
[hdfs@peter-kafka001 hadoop]$ sbin/hadoop-daemon.sh start datanode
starting datanode, logging to /opt/hadoop-2.10.1/logs/hadoop-hdfs-datanode-peter-kafka001.out
[hdfs@peter-kafka001 hadoop]$ jps
5649 NameNode
7170 DataNode            # <--- 실행후 추가됨.
7447 Jps
[hdfs@peter-kafka001 hadoop]$ 

[hdfs@peter-kafka002 ~]$ cd /opt/hadoop
[hdfs@peter-kafka002 hadoop]$ sbin/hadoop-daemon.sh start datanode
starting datanode, logging to /opt/hadoop-2.10.1/logs/hadoop-hdfs-datanode-peter-kafka002.out
[hdfs@peter-kafka002 hadoop]$ jps
54387 Jps
54110 DataNode            # <--- 실행후 추가됨.
[hdfs@peter-kafka002 hadoop]$ 

[hdfs@peter-kafka003 ~]$ cd /opt/hadoop
[hdfs@peter-kafka003 hadoop]$ sbin/hadoop-daemon.sh start datanode
starting datanode, logging to /opt/hadoop-2.10.1/logs/hadoop-hdfs-datanode-peter-kafka003.out
[hdfs@peter-kafka003 hadoop]$ jps
56039 DataNode            # <--- 실행후 추가됨.
56316 Jps
[hdfs@peter-kafka003 hadoop]$ 
```

### Hadoop 중지 후 재시작
> CAUTION. hdfs, yarn, mapred 계정으로 각각 실행하므로 아래의 스크립트를 이용한 실행은 하면 안됨.  
    [~~stop-all.sh~~]  
    [~~start-all.sh~~]

1. 중지
> ref) https://m.blog.naver.com/lionlyloveil/220777609903  
        historyserver, yarn, zkfc, namenode, datanode, journalnode 순으로 종료 후,
        역순으로 기동.  
        zookeeper 프로세스는 내리지 않고 계속 기동상태로 놔뒀다.

(in peter-kafka001)
```
# su - mapred -c "/opt/hadoop/sbin/mr-jobhistory-daemon.sh stop historyserver"
# su - yarn -c "/opt/hadoop/sbin/stop-yarn.sh"
(# su - hdfs -c "sbin/hadoop-daemon.sh stop zkfc")
# su - hdfs -c "/opt/hadoop/sbin/stop-dfs.sh"
# su - yarn -c "/opt/hadoop/sbin/hadoop-daemon.sh stop journalnode"
# su - yarn -c "ssh yarn@peter-kafka002 \"/opt/hadoop/sbin/hadoop-daemon.sh stop journalnode\""
# su - yarn -c "ssh yarn@peter-kafka003 \"/opt/hadoop/sbin/hadoop-daemon.sh stop journalnode\""
```

2. 실행
(in peter-kafka001)
```
# su - yarn -c "/opt/hadoop/sbin/hadoop-daemon.sh start journalnode"
# su - yarn -c "ssh yarn@peter-kafka002 \"/opt/hadoop/sbin/hadoop-daemon.sh start journalnode\""
# su - yarn -c "ssh yarn@peter-kafka003 \"/opt/hadoop/sbin/hadoop-daemon.sh start journalnode\""
# su - hdfs -c "/opt/hadoop/sbin/start-dfs.sh"
(# su - hdfs -c "/opt/hadoop/sbin/hadoop-daemon.sh start zkfc")
# su - yarn -c "/opt/hadoop/sbin/start-yarn.sh"
# su - mapred -c "/opt/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver"
```

<프로세스 확인>
```
[root@peter-kafka001 ~]# jps
12965 NodeManager                 # <--- 
2102 Kafka
12855 ResourceManager             # <--- 
12712 DFSZKFailoverController     # <--- 
1546 QuorumPeerMain
11996 NameNode                    # <--- 
12124 DataNode                    # <--- 
9692 RunNiFi
11757 JournalNode                 # <--- 
9709 NiFi
13582 Jps
[root@peter-kafka001 ~]# 
```

```
[root@peter-kafka002 ~]# jps
57537 DFSZKFailoverController     # <--- 
57636 NodeManager                 # <--- 
56933 JournalNode                 # <--- 
57129 DataNode                    # <--- 
2842 Kafka
57037 NameNode                    # <--- 
55646 RunNiFi
1535 QuorumPeerMain
55663 NiFi
57871 Jps
[root@peter-kafka002 ~]# 
```

```
[root@peter-kafka003 ~]# jps
58866 Jps
58375 DataNode                    # <--- 
2827 Kafka
57131 RunNiFi
57148 NiFi
58269 JournalNode                 # <--- 
1534 QuorumPeerMain
58703 NodeManager                 # <--- 
[root@peter-kafka003 ~]# 
```

### Hadoop 테스트 (wordcount)
1. 디렉토리 구성
```
# su - hdfs
$ hadoop fs -ls /
$ hadoop fs -mkdir /user/
$ hadoop fs -mkdir /user/hdfs/
$ hadoop fs -mkdir /user/hdfs/work/
$ hadoop fs -mkdir /user/hdfs/work/wordcount/
$ hadoop fs -mkdir /user/hdfs/work/wordcount/wc-in/
```

2. 테스트 데이터를 HDFS에 업로드
(in peter-kafka001)
> test용도
```
# su - hdfs
$ mkdir -p ~/work/wordcount/wc-in/
$ cd ~/work/wordcount/wc-in/
$ echo "bla 한글 bla" > a.txt
$ echo "한글 wa bla wa" > b.txt
$ echo "Hello 한글" > c.txt

$ hadoop fs  -put *.txt /user/hdfs/work/wordcount/wc-in/.
```

3. 실행
```
$ hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.10.1.jar wordcount work/wordcount/wc-in/ work/wordcount/wc-out/
```

> 실행예
```
[hdfs@peter-kafka001 ~]$ hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.10.1.jar wordcount work/wordcount/wc-in/ work/wordcount/wc-out/
21/02/21 15:30:46 INFO Configuration.deprecation: session.id is deprecated. Instead, use dfs.metrics.session-id
21/02/21 15:30:46 INFO jvm.JvmMetrics: Initializing JVM Metrics with processName=JobTracker, sessionId=
21/02/21 15:30:46 INFO input.FileInputFormat: Total input files to process : 3
21/02/21 15:30:46 INFO mapreduce.JobSubmitter: number of splits:3
21/02/21 15:30:46 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_local1133098537_0001
21/02/21 15:30:46 INFO mapreduce.Job: The url to track the job: http://localhost:8080/
21/02/21 15:30:46 INFO mapreduce.Job: Running job: job_local1133098537_0001
21/02/21 15:30:46 INFO mapred.LocalJobRunner: OutputCommitter set in config null
21/02/21 15:30:46 INFO output.FileOutputCommitter: File Output Committer Algorithm version is 1
21/02/21 15:30:46 INFO output.FileOutputCommitter: FileOutputCommitter skip cleanup _temporary folders under output directory:false, ignore cleanup failures: false
21/02/21 15:30:46 INFO mapred.LocalJobRunner: OutputCommitter is org.apache.hadoop.mapreduce.lib.output.FileOutputCommitter
21/02/21 15:30:46 INFO mapred.LocalJobRunner: Waiting for map tasks
21/02/21 15:30:46 INFO mapred.LocalJobRunner: Starting task: attempt_local1133098537_0001_m_000000_0
21/02/21 15:30:46 INFO output.FileOutputCommitter: File Output Committer Algorithm version is 1
21/02/21 15:30:46 INFO output.FileOutputCommitter: FileOutputCommitter skip cleanup _temporary folders under output directory:false, ignore cleanup failures: false
21/02/21 15:30:46 INFO mapred.Task:  Using ResourceCalculatorProcessTree : [ ]
21/02/21 15:30:46 INFO mapred.MapTask: Processing split: hdfs://peter-cluster/user/hdfs/work/wordcount/wc-in/b.txt:0+17
21/02/21 15:30:47 INFO mapred.MapTask: (EQUATOR) 0 kvi 26214396(104857584)
21/02/21 15:30:47 INFO mapred.MapTask: mapreduce.task.io.sort.mb: 100
21/02/21 15:30:47 INFO mapred.MapTask: soft limit at 83886080
21/02/21 15:30:47 INFO mapred.MapTask: bufstart = 0; bufvoid = 104857600
21/02/21 15:30:47 INFO mapred.MapTask: kvstart = 26214396; length = 6553600
21/02/21 15:30:47 INFO mapred.MapTask: Map output collector class = org.apache.hadoop.mapred.MapTask$MapOutputBuffer
21/02/21 15:30:47 INFO mapred.LocalJobRunner: 
21/02/21 15:30:47 INFO mapred.MapTask: Starting flush of map output
21/02/21 15:30:47 INFO mapred.MapTask: Spilling map output
21/02/21 15:30:47 INFO mapred.MapTask: bufstart = 0; bufend = 33; bufvoid = 104857600
21/02/21 15:30:47 INFO mapred.MapTask: kvstart = 26214396(104857584); kvend = 26214384(104857536); length = 13/6553600
21/02/21 15:30:47 INFO mapred.MapTask: Finished spill 0
21/02/21 15:30:47 INFO mapred.Task: Task:attempt_local1133098537_0001_m_000000_0 is done. And is in the process of committing
21/02/21 15:30:47 INFO mapred.LocalJobRunner: map
21/02/21 15:30:47 INFO mapred.Task: Task 'attempt_local1133098537_0001_m_000000_0' done.
21/02/21 15:30:47 INFO mapred.Task: Final Counters for attempt_local1133098537_0001_m_000000_0: Counters: 23
    File System Counters
        FILE: Number of bytes read=303832
        FILE: Number of bytes written=804103
        FILE: Number of read operations=0
        FILE: Number of large read operations=0
        FILE: Number of write operations=0
        HDFS: Number of bytes read=17
        HDFS: Number of bytes written=0
        HDFS: Number of read operations=5
        HDFS: Number of large read operations=0
        HDFS: Number of write operations=1
    Map-Reduce Framework
        Map input records=1
        Map output records=4
        Map output bytes=33
        Map output materialized bytes=38
        Input split bytes=122
        Combine input records=4
        Combine output records=3
        Spilled Records=3
        Failed Shuffles=0
        Merged Map outputs=0
        GC time elapsed (ms)=0
        Total committed heap usage (bytes)=245366784
    File Input Format Counters 
        Bytes Read=17
21/02/21 15:30:47 INFO mapred.LocalJobRunner: Finishing task: attempt_local1133098537_0001_m_000000_0
21/02/21 15:30:47 INFO mapred.LocalJobRunner: Starting task: attempt_local1133098537_0001_m_000001_0
21/02/21 15:30:47 INFO output.FileOutputCommitter: File Output Committer Algorithm version is 1
21/02/21 15:30:47 INFO output.FileOutputCommitter: FileOutputCommitter skip cleanup _temporary folders under output directory:false, ignore cleanup failures: false
21/02/21 15:30:47 INFO mapred.Task:  Using ResourceCalculatorProcessTree : [ ]
21/02/21 15:30:47 INFO mapred.MapTask: Processing split: hdfs://peter-cluster/user/hdfs/work/wordcount/wc-in/a.txt:0+15
21/02/21 15:30:47 INFO mapred.MapTask: (EQUATOR) 0 kvi 26214396(104857584)
21/02/21 15:30:47 INFO mapred.MapTask: mapreduce.task.io.sort.mb: 100
21/02/21 15:30:47 INFO mapred.MapTask: soft limit at 83886080
21/02/21 15:30:47 INFO mapred.MapTask: bufstart = 0; bufvoid = 104857600
21/02/21 15:30:47 INFO mapred.MapTask: kvstart = 26214396; length = 6553600
21/02/21 15:30:47 INFO mapred.MapTask: Map output collector class = org.apache.hadoop.mapred.MapTask$MapOutputBuffer
21/02/21 15:30:47 INFO mapred.LocalJobRunner: 
21/02/21 15:30:47 INFO mapred.MapTask: Starting flush of map output
21/02/21 15:30:47 INFO mapred.MapTask: Spilling map output
21/02/21 15:30:47 INFO mapred.MapTask: bufstart = 0; bufend = 27; bufvoid = 104857600
21/02/21 15:30:47 INFO mapred.MapTask: kvstart = 26214396(104857584); kvend = 26214388(104857552); length = 9/6553600
21/02/21 15:30:47 INFO mapred.MapTask: Finished spill 0
21/02/21 15:30:47 INFO mapred.Task: Task:attempt_local1133098537_0001_m_000001_0 is done. And is in the process of committing
21/02/21 15:30:47 INFO mapred.LocalJobRunner: map
21/02/21 15:30:47 INFO mapred.Task: Task 'attempt_local1133098537_0001_m_000001_0' done.
21/02/21 15:30:47 INFO mapred.Task: Final Counters for attempt_local1133098537_0001_m_000001_0: Counters: 23
    File System Counters
        FILE: Number of bytes read=304217
        FILE: Number of bytes written=804164
        FILE: Number of read operations=0
        FILE: Number of large read operations=0
        FILE: Number of write operations=0
        HDFS: Number of bytes read=32
        HDFS: Number of bytes written=0
        HDFS: Number of read operations=7
        HDFS: Number of large read operations=0
        HDFS: Number of write operations=1
    Map-Reduce Framework
        Map input records=1
        Map output records=3
        Map output bytes=27
        Map output materialized bytes=29
        Input split bytes=122
        Combine input records=3
        Combine output records=2
        Spilled Records=2
        Failed Shuffles=0
        Merged Map outputs=0
        GC time elapsed (ms)=0
        Total committed heap usage (bytes)=350748672
    File Input Format Counters 
        Bytes Read=15
21/02/21 15:30:47 INFO mapred.LocalJobRunner: Finishing task: attempt_local1133098537_0001_m_000001_0
21/02/21 15:30:47 INFO mapred.LocalJobRunner: Starting task: attempt_local1133098537_0001_m_000002_0
21/02/21 15:30:47 INFO output.FileOutputCommitter: File Output Committer Algorithm version is 1
21/02/21 15:30:47 INFO output.FileOutputCommitter: FileOutputCommitter skip cleanup _temporary folders under output directory:false, ignore cleanup failures: false
21/02/21 15:30:47 INFO mapred.Task:  Using ResourceCalculatorProcessTree : [ ]
21/02/21 15:30:47 INFO mapred.MapTask: Processing split: hdfs://peter-cluster/user/hdfs/work/wordcount/wc-in/c.txt:0+13
21/02/21 15:30:47 INFO mapred.MapTask: (EQUATOR) 0 kvi 26214396(104857584)
21/02/21 15:30:47 INFO mapred.MapTask: mapreduce.task.io.sort.mb: 100
21/02/21 15:30:47 INFO mapred.MapTask: soft limit at 83886080
21/02/21 15:30:47 INFO mapred.MapTask: bufstart = 0; bufvoid = 104857600
21/02/21 15:30:47 INFO mapred.MapTask: kvstart = 26214396; length = 6553600
21/02/21 15:30:47 INFO mapred.MapTask: Map output collector class = org.apache.hadoop.mapred.MapTask$MapOutputBuffer
21/02/21 15:30:47 INFO mapred.LocalJobRunner: 
21/02/21 15:30:47 INFO mapred.MapTask: Starting flush of map output
21/02/21 15:30:47 INFO mapred.MapTask: Spilling map output
21/02/21 15:30:47 INFO mapred.MapTask: bufstart = 0; bufend = 21; bufvoid = 104857600
21/02/21 15:30:47 INFO mapred.MapTask: kvstart = 26214396(104857584); kvend = 26214392(104857568); length = 5/6553600
21/02/21 15:30:47 INFO mapred.MapTask: Finished spill 0
21/02/21 15:30:47 INFO mapred.Task: Task:attempt_local1133098537_0001_m_000002_0 is done. And is in the process of committing
21/02/21 15:30:47 INFO mapred.LocalJobRunner: map
21/02/21 15:30:47 INFO mapred.Task: Task 'attempt_local1133098537_0001_m_000002_0' done.
21/02/21 15:30:47 INFO mapred.Task: Final Counters for attempt_local1133098537_0001_m_000002_0: Counters: 23
    File System Counters
        FILE: Number of bytes read=304602
        FILE: Number of bytes written=804227
        FILE: Number of read operations=0
        FILE: Number of large read operations=0
        FILE: Number of write operations=0
        HDFS: Number of bytes read=45
        HDFS: Number of bytes written=0
        HDFS: Number of read operations=9
        HDFS: Number of large read operations=0
        HDFS: Number of write operations=1
    Map-Reduce Framework
        Map input records=1
        Map output records=2
        Map output bytes=21
        Map output materialized bytes=31
        Input split bytes=122
        Combine input records=2
        Combine output records=2
        Spilled Records=2
        Failed Shuffles=0
        Merged Map outputs=0
        GC time elapsed (ms)=0
        Total committed heap usage (bytes)=456130560
    File Input Format Counters 
        Bytes Read=13
21/02/21 15:30:47 INFO mapred.LocalJobRunner: Finishing task: attempt_local1133098537_0001_m_000002_0
21/02/21 15:30:47 INFO mapred.LocalJobRunner: map task executor complete.
21/02/21 15:30:47 INFO mapred.LocalJobRunner: Waiting for reduce tasks
21/02/21 15:30:47 INFO mapred.LocalJobRunner: Starting task: attempt_local1133098537_0001_r_000000_0
21/02/21 15:30:47 INFO output.FileOutputCommitter: File Output Committer Algorithm version is 1
21/02/21 15:30:47 INFO output.FileOutputCommitter: FileOutputCommitter skip cleanup _temporary folders under output directory:false, ignore cleanup failures: false
21/02/21 15:30:47 INFO mapred.Task:  Using ResourceCalculatorProcessTree : [ ]
21/02/21 15:30:47 INFO mapred.ReduceTask: Using ShuffleConsumerPlugin: org.apache.hadoop.mapreduce.task.reduce.Shuffle@3d2dd917
21/02/21 15:30:47 INFO reduce.MergeManagerImpl: MergerManager: memoryLimit=334338464, maxSingleShuffleLimit=83584616, mergeThreshold=220663392, ioSortFactor=10, memToMemMergeOutputsThreshold=10
21/02/21 15:30:47 INFO reduce.EventFetcher: attempt_local1133098537_0001_r_000000_0 Thread started: EventFetcher for fetching Map Completion Events
21/02/21 15:30:47 INFO reduce.LocalFetcher: localfetcher#1 about to shuffle output of map attempt_local1133098537_0001_m_000001_0 decomp: 25 len: 29 to MEMORY
21/02/21 15:30:47 INFO reduce.InMemoryMapOutput: Read 25 bytes from map-output for attempt_local1133098537_0001_m_000001_0
21/02/21 15:30:47 INFO reduce.MergeManagerImpl: closeInMemoryFile -> map-output of size: 25, inMemoryMapOutputs.size() -> 1, commitMemory -> 0, usedMemory ->25
21/02/21 15:30:47 INFO reduce.LocalFetcher: localfetcher#1 about to shuffle output of map attempt_local1133098537_0001_m_000000_0 decomp: 34 len: 38 to MEMORY
21/02/21 15:30:47 INFO reduce.InMemoryMapOutput: Read 34 bytes from map-output for attempt_local1133098537_0001_m_000000_0
21/02/21 15:30:47 INFO reduce.MergeManagerImpl: closeInMemoryFile -> map-output of size: 34, inMemoryMapOutputs.size() -> 2, commitMemory -> 25, usedMemory ->59
21/02/21 15:30:47 INFO reduce.LocalFetcher: localfetcher#1 about to shuffle output of map attempt_local1133098537_0001_m_000002_0 decomp: 27 len: 31 to MEMORY
21/02/21 15:30:47 INFO reduce.InMemoryMapOutput: Read 27 bytes from map-output for attempt_local1133098537_0001_m_000002_0
21/02/21 15:30:47 INFO reduce.MergeManagerImpl: closeInMemoryFile -> map-output of size: 27, inMemoryMapOutputs.size() -> 3, commitMemory -> 59, usedMemory ->86
21/02/21 15:30:47 INFO reduce.EventFetcher: EventFetcher is interrupted.. Returning
21/02/21 15:30:47 WARN io.ReadaheadPool: Failed readahead on ifile
EBADF: Bad file descriptor
    at org.apache.hadoop.io.nativeio.NativeIO$POSIX.posix_fadvise(Native Method)
    at org.apache.hadoop.io.nativeio.NativeIO$POSIX.posixFadviseIfPossible(NativeIO.java:267)
    at org.apache.hadoop.io.nativeio.NativeIO$POSIX$CacheManipulator.posixFadviseIfPossible(NativeIO.java:146)
    at org.apache.hadoop.io.ReadaheadPool$ReadaheadRequestImpl.run(ReadaheadPool.java:208)
    at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)
    at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
    at java.lang.Thread.run(Thread.java:748)
21/02/21 15:30:47 INFO mapred.LocalJobRunner: 3 / 3 copied.
21/02/21 15:30:47 INFO reduce.MergeManagerImpl: finalMerge called with 3 in-memory map-outputs and 0 on-disk map-outputs
21/02/21 15:30:47 INFO mapred.Merger: Merging 3 sorted segments
21/02/21 15:30:47 INFO mapred.Merger: Down to the last merge-pass, with 3 segments left of total size: 66 bytes
21/02/21 15:30:47 INFO reduce.MergeManagerImpl: Merged 3 segments, 86 bytes to disk to satisfy reduce memory limit
21/02/21 15:30:47 INFO reduce.MergeManagerImpl: Merging 1 files, 86 bytes from disk
21/02/21 15:30:47 INFO reduce.MergeManagerImpl: Merging 0 segments, 0 bytes from memory into reduce
21/02/21 15:30:47 INFO mapred.Merger: Merging 1 sorted segments
21/02/21 15:30:47 INFO mapred.Merger: Down to the last merge-pass, with 1 segments left of total size: 74 bytes
21/02/21 15:30:47 INFO mapred.LocalJobRunner: 3 / 3 copied.
21/02/21 15:30:47 INFO Configuration.deprecation: mapred.skip.on is deprecated. Instead, use mapreduce.job.skiprecords
21/02/21 15:30:47 INFO mapreduce.Job: Job job_local1133098537_0001 running in uber mode : false
21/02/21 15:30:47 INFO mapreduce.Job:  map 100% reduce 0%
21/02/21 15:30:48 INFO mapred.Task: Task:attempt_local1133098537_0001_r_000000_0 is done. And is in the process of committing
21/02/21 15:30:48 INFO mapred.LocalJobRunner: 3 / 3 copied.
21/02/21 15:30:48 INFO mapred.Task: Task attempt_local1133098537_0001_r_000000_0 is allowed to commit now
21/02/21 15:30:48 INFO output.FileOutputCommitter: Saved output of task 'attempt_local1133098537_0001_r_000000_0' to hdfs://peter-cluster/user/hdfs/work/wordcount/wc-out/_temporary/0/task_local1133098537_0001_r_000000
21/02/21 15:30:48 INFO mapred.LocalJobRunner: reduce > reduce
21/02/21 15:30:48 INFO mapred.Task: Task 'attempt_local1133098537_0001_r_000000_0' done.
21/02/21 15:30:48 INFO mapred.Task: Final Counters for attempt_local1133098537_0001_r_000000_0: Counters: 29
    File System Counters
        FILE: Number of bytes read=304882
        FILE: Number of bytes written=804313
        FILE: Number of read operations=0
        FILE: Number of large read operations=0
        FILE: Number of write operations=0
        HDFS: Number of bytes read=45
        HDFS: Number of bytes written=28
        HDFS: Number of read operations=12
        HDFS: Number of large read operations=0
        HDFS: Number of write operations=3
    Map-Reduce Framework
        Combine input records=0
        Combine output records=0
        Reduce input groups=4
        Reduce shuffle bytes=98
        Reduce input records=7
        Reduce output records=4
        Spilled Records=7
        Shuffled Maps =3
        Failed Shuffles=0
        Merged Map outputs=3
        GC time elapsed (ms)=8
        Total committed heap usage (bytes)=456130560
    Shuffle Errors
        BAD_ID=0
        CONNECTION=0
        IO_ERROR=0
        WRONG_LENGTH=0
        WRONG_MAP=0
        WRONG_REDUCE=0
    File Output Format Counters 
        Bytes Written=28
21/02/21 15:30:48 INFO mapred.LocalJobRunner: Finishing task: attempt_local1133098537_0001_r_000000_0
21/02/21 15:30:48 INFO mapred.LocalJobRunner: reduce task executor complete.
21/02/21 15:30:48 INFO mapreduce.Job:  map 100% reduce 100%
21/02/21 15:30:48 INFO mapreduce.Job: Job job_local1133098537_0001 completed successfully
21/02/21 15:30:48 INFO mapreduce.Job: Counters: 35
    File System Counters
        FILE: Number of bytes read=1217533
        FILE: Number of bytes written=3216807
        FILE: Number of read operations=0
        FILE: Number of large read operations=0
        FILE: Number of write operations=0
        HDFS: Number of bytes read=139
        HDFS: Number of bytes written=28
        HDFS: Number of read operations=33
        HDFS: Number of large read operations=0
        HDFS: Number of write operations=6
    Map-Reduce Framework
        Map input records=3
        Map output records=9
        Map output bytes=81
        Map output materialized bytes=98
        Input split bytes=366
        Combine input records=9
        Combine output records=7
        Reduce input groups=4
        Reduce shuffle bytes=98
        Reduce input records=7
        Reduce output records=4
        Spilled Records=14
        Shuffled Maps =3
        Failed Shuffles=0
        Merged Map outputs=3
        GC time elapsed (ms)=8
        Total committed heap usage (bytes)=1508376576
    Shuffle Errors
        BAD_ID=0
        CONNECTION=0
        IO_ERROR=0
        WRONG_LENGTH=0
        WRONG_MAP=0
        WRONG_REDUCE=0
    File Input Format Counters 
        Bytes Read=45
    File Output Format Counters 
        Bytes Written=28
[hdfs@peter-kafka001 ~]$ hadoop fs -ls  /user/hdfs/work/wordcount/wc-out/
Found 2 items
-rw-r--r--   2 hdfs supergroup          0 2021-02-21 15:30 /user/hdfs/work/wordcount/wc-out/_SUCCESS
-rw-r--r--   2 hdfs supergroup         28 2021-02-21 15:30 /user/hdfs/work/wordcount/wc-out/part-r-00000
[hdfs@peter-kafka001 ~]$ hadoop fs -cat /user/hdfs/work/wordcount/wc-out/part-r-00000
Hello   1
bla     3
wa      2
한글    3
[hdfs@peter-kafka001 ~]$ 
```

4. 확인
웹URL:
> http://peter-kafka001:50070/ : Namenode info  
> http://peter-kafka001:8088/  : 

___
.END OF HADOOP
