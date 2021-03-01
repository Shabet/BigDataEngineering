# Kafka 설치

## 0. 계획
* kafka 계정으로 실행
* [설치요약](<docs/01. 설치/설치편 04-Zookeeper Kafka Nifi 설치.pptx>)

## 1. 계정 추가
```
# groupadd -g 9092 kafka
# useradd kafka -u 9092 -g kafka
```

## 2. 설치
```
# cd ~/work
# wget https://archive.apache.org/dist/kafka/2.7.0/kafka_2.13-2.7.0.tgz
# cd /opt
# tar zxvf ~/work/kafka_2.13-2.7.0.tgz
# ln -s kafka_2.13-2.7.0 kafka
```

## 3. 저장소 설정
```
# mkdir /kfdata1 /kfdata2
```

## 4. 설정
```
# cd /opt/kafka/config
# cp -p server.properties server.properties.orig
# vi server.properties
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
...
broker.id=1 #<- 1 or 2 or 3(각 호스트마다 다르게 설정)
log.dirs=/kfdata1,/kfdata2
zookeeper.connect=peter-zk001:2181,peter-zk002:2181,peter-zk003:2181/peter-kafka
...
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
```

```
# vi jmx
JMX_PORT=9999
```

## 5. 실행 계정 설정
```
# chown -R kafka:kafka /kfdata1/
# chown -R kafka:kafka /kfdata2/
# chown -R kafka:kafka /opt/kafka_2.13-2.7.0/
# chown -R kafka:kafka /opt/kafka
```

## 6. 자동 실행 등록(systemd)
```
# vi /etc/systemd/system/kafka-server.service
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
[Unit]
Description=kafka-server
After=network.target

[Service]
Type=simple
User=kafka
Group=kafka
SyslogIdentifier=kafka-server
WorkingDirectory=/opt/kafka
Restart=no
RestartSec=0s
ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
ExecStop=/opt/kafka/bin/kafka-server-stop.sh
EnvironmentFile=/opt/kafka/config/jmx
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
```

## 7. 시작
```
# systemctl daemon-reload
# systemctl start kafka-server.service
# systemctl status kafka-server.service
```

## 8. 확인
```
# jps
# ps -ef|grep kafka
# netstat -ntlp |grep 9092
tcp        0      0 0.0.0.0:9092            0.0.0.0:*               LISTEN      3751/java       #<- Kafka 기동 확인
# /opt/zookeeper/bin/zkCli.sh #<- 모든 서버에서 확인
[zk: localhost:2181(CONNECTED) 1] ls /peter-kafka/brokers/ids
[1, 2, 3]
```

## 9. 로그 확인
1. Kafka 로그 확인
```
# tail -F /opt/kafka/logs/server.log
```

2. Kafka 로드시 Config 확인
```
# cat /opt/kafka/logs/server.log
{
[2021-01-26 13:37:04,206] INFO KafkaConfig values: 
...
 (kafka.server.KafkaConfig)
} #<- Kafka 로드시 Config 정보 확인할수 있는 로그 블록
```

## 10. 시스템 재시작시 자동 실행 등록
```
# systemctl enable kafka-server.service
```
> NOTE. 테스트 결과 안됨(Kafka는 시스템 시작시 수동으로 실행하자!)

## 11. 편의를 위한 경로 추가
```
# vi /etc/profile.d/kafka.sh
export PATH=$PATH:/opt/kafka/bin
```

## 12. 토픽 생성, 삭제
* 생성
```
# /usr/local/kafka/bin/kafka-topics.sh \
> --zookeeper peter-zk001:2181,peter-zk002:2181,peter-zk003:2181/peter-kafka \
> --replication-factor 1 --partitions 1 --topic peter-topic --create
Created topic peter-topic.
```

* 삭제
```
# /usr/local/kafka/bin/kafka-topics.sh \
> --zookeeper peter-zk001:2181,peter-zk002:2181,peter-zk003:2181/peter-kafka \
> --topic peter-topic --delete
Topic peter-topic is marked for deletion.
Note: This will have no impact if delete.topic.enable is not set to true.
```

## 13. 프로듀서, 컨슈머
* 프로듀서 생성
```
# /usr/local/kafka/bin/kafka-console-producer.sh \
 --broker-list peter-kafka001:9092,peter-kafka002:9092,peter-kafka003:9092 \
 --topic peter-topic
# <- 입력 프롬프트
```

* 컨슈머 생성
```
# /usr/local/kafka/bin/kafka-console-consumer.sh \
 --bootstrap-server peter-kafka001:9092,peter-kafka002:9092,peter-kafka003:9092 \
 --topic peter-topic --from-beginning
```

___
.END OF KAFKA