# Zookeeper 설치

## 0. 계획
* zookeepeer 계정으로 실행
* 시스템 시작시 자동 실행
* [설치요약](<docs/01. 설치/설치편 04-Zookeeper Kafka Nifi 설치.pptx>)

## 1. 계정 추가
```
# groupadd -g 2181 zookeepeer
# useradd zookeeper -u 2181 -g zookeeper
```

## 2. 설치
```
# mkdir ~/work
# cd ~/work
# wget https://downloads.apache.org/zookeeper/zookeeper-3.5.9/apache-zookeeper-3.5.9-bin.tar.gz
# cd /opt
# tar zxvf ~/work/apache-zookeeper-3.5.9-bin.tar.gz
# ln -s apache-zookeeper-3.5.9-bin zookeeper
```

## 3. 저장소 설정
```
# mkdir /zkdata

(in peter-kafka001)
# echo 1 > /zkdata/myid

(in peter-kafka002)
# echo 2 > /zkdata/myid

(in peter-kafka003)
# echo 3 > /zkdata/myid
```

## 4. 설정
```
# cd /opt/zookeeper/conf
# cp -p zoo_sample.cfg zoo.cfg

# vi zoo.cfg
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
...
admin.serverPort=9001
dataDir=/zkdata

server.1=peter-zk001:2888:3888
server.2=peter-zk002:2888:3888
server.3=peter-zk003:2888:3888
...
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
```

## 5. 실행 계정 설정
```
# chown -R zookeeper:zookeeper /zkdata/
# chown -R zookeeper:zookeeper /opt/apache-zookeeper-3.5.9-bin/
# chown -R zookeeper:zookeeper /opt/zookeeper
```

## 6. 자동 실행 등록(systemd)
```
# vi /etc/systemd/system/zookeeper-server.service
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
[Unit]
Description=zookeeper-server
After=network.target

[Service]
Type=forking
User=zookeeper
Group=zookeeper
SyslogIdentifier=zookeeper-server
WorkingDirectory=/opt/zookeeper
Restart=always
RestartSec=0s
ExecStart=/opt/zookeeper/bin/zkServer.sh start
ExecStop=/opt/zookeeper/bin/zkServer.sh stop

[Install]
WantedBy=multi-user.target
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
```

## 7. 시작
```
# systemctl daemon-reload
# systemctl start zookeeper-server.service
# systemctl status zookeeper-server.service
```

## 8. 확인
```
# jps
# ps -ef|grep zookeeper
# netstat -ntlp|grep 2181
tcp        0      0 0.0.0.0:2181            0.0.0.0:*               LISTEN      2715/java
# netstat -ntlp|grep 9001
tcp        0      0 0.0.0.0:9001            0.0.0.0:*               LISTEN      46237/java
# su - zookeeper
$ /opt/zookeeper/bin/zkCli.sh
ls /
```
> NOTE. netstat 결과에서 tcp6이 아닌 tcp6인지 체크할것

## 9. 시스템 재시작시 자동 실행 등록
```
# systemctl enable zookeeper-server.service
```

## 10. 편의를 위한 경로 추가
```
# vi /etc/profile.d/zookeeper.sh
export PATH=$PATH:/opt/zookeeper/bin
```

___
.END OF ZOOKEEPER