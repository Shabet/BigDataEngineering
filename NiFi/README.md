# NiFi 설치

## 0. 계획
* nifi 계정으로 nifi 실행
* zookeeper를 이용한 cluster 구성
* [설치요약](<docs/01. 설치/설치편 04-Zookeeper Kafka Nifi 설치.pptx>)

## 1. 계정 추가
```
# groupadd -g 8080 nifi
# useradd  nifi -u 8080 -g nifi
```

## 2. 설치
```
# cd ~/work
# wget https://archive.apache.org/dist/nifi/1.11.4/nifi-1.11.4-bin.tar.gz
# wget https://archive.apache.org/dist/nifi/1.11.4/nifi-toolkit-1.11.4-bin.tar.gz
# wget https://archive.apache.org/dist/nifi/1.11.4/nifi-1.11.4-source-release.zip
# cd /opt
# tar zxvf ~/work/nifi-1.11.4-bin.tar.gz
# ln -s nifi-1.11.4 nifi
```

## 3. 설정
* nifi.properties
```
# cd /opt/nifi/conf
# cp -p nifi.properties nifi.properties.orig
# vi nifi.properties
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
...
nifi.web.http.host=peter-kafka00[1|2|3]
nifi.web.http.port=8080
#nifi.web.http.port=8081 # <- zookeeper에서 8080포트를 사용함으로 변경!

nifi.cluster.is.node=true
nifi.cluster.node.address=peter-kafka00[1|2|3]
nifi.cluster.node.protocol.port=8082

#nifi.zookeeper.connect.string=192.168.126.71:2181,192.168.126.72:2181,192.168.126.73:2181
nifi.zookeeper.connect.string=peter-kafka001:2181,peter-kafka002:2181,peter-kafka003:2181
#nifi.zookeeper.connect.string=peter-zk001:2181,peter-zk002:2181,peter-zk003:2181   # <- 이건 이상하게 동작함. 클라스터 멤버가 3이 아닌 6으로 인식하는 문제 발생. 끊임없는 leader선출...
...
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
```

* bootstrap.conf
```
# cd /opt/nifi/conf
# cp -p bootstrap.conf bootstrap.conf.orig
# vi bootstrap.conf
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
...
run.as=nifi

# JVM memory settings
java.arg.2=-Xms1024m  # <- default set to 512m
java.arg.3=-Xmx1024m  # <- default set to 512m
...
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
```

* state-management.xml
```
# cd /opt/nifi/conf
# cp -p state-management.xml state-management.xml.orig
# vi state-management.xml
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
...
<cluster-provider>
        <id>zk-provider</id>
        <class>org.apache.nifi.controller.state.providers.zookeeper.ZooKeeperStateProvider</class>
        <property name="Connect String">peter-kafka001:2181,peter-kafka002:2181,peter-kafka003:2181</property> # <- 여기 값 추가
        <property name="Root Node">/nifi</property>
        <property name="Session Timeout">10 seconds</property>
        <property name="Access Control">Open</property>
    </cluster-provider>
...
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
```
> ref) https://stackoverflow.com/questions/59826510/a-hostprovider-may-not-be-empty-after-upgrading-to-nifi-1-10

> NOTE. ListSFTP 와 같은 processor에서 위의 zookeeper 설정값을 사용함!(설정을 하지 않을시 HostProvider may not empty 에러 발생)

* nifi-env.sh 파일 설정
```
# cd /opt/nifi/bin
# cp -p nifi-env.sh nifi-env.sh.orig
# vi nifi-env.sh
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
...
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk/
...
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
```

## 4. 불필요한 파일 삭제(in Linux)
```
# cd /opt/nifi
# /bin/rm -f bin/*.bat
```

## 5. 기타 설정
```
# vi /etc/profile.d/java.sh
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk/
```

## 6. 실행 계정 설정
```
# chown -R nifi:nifi /opt/nifi-1.11.4/
# chown -R nifi:nifi /opt/nifi
```

## 7. 자동 실행 등록(systemd)
```
# /opt/nifi/bin/nifi.sh install nifi
# source /etc/profile.d/java.sh
# systemctl daemon-reload
# systemctl start nifi.service
# systemctl status nifi.service
```

## 8. 확인
```
# jps
# ps -ef|grep nifi
# netstat -ntlp | grep 8080
# /opt/zookeeper/bin/zkCli.sh
ls /nifi
```

## 9. 웹 접속
웹URL:
> http://peter-kafka001:8080/nifi/  
> http://peter-kafka002:8080/nifi/  
> http://peter-kafka003:8080/nifi/  

___
.END OF KAFKA