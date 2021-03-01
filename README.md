# Hadoop Install Guide

Hadoop ecosystem manual installation guide

## 설치OS
CentOS 7.9.2009

## 설치방법
VMWare를 이용하여 3대의 Linux 서버를 구성

## 서버별 설치 S/W
|host|IP|MariaDB|Hive|Zookeeper|Kafka|NiFi|Hadoop|Spark|
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
|peter-kafka001|192.168.126.71|O|O|O|O|O|O|O|
|peter-kafka002|192.168.126.72|O|O|O|O|O|O||
|peter-kafka003|192.168.126.73|||O|O||O||

## 설치 S/W
* Zookeeper: 3.5.9 버전 설치 (3.5.x branch 중 최신 버전)
* Kafka: 2.13-2.7.0 버전 설치(scala-kafka 버전, * 2021-02-15 현재 가장 최신 버전)
* Hadoop: 2.10.1 버전 설치
> Kafka, NiFi는 Hadoop과는 별개로 설치가 가능

## 설치 상세
* [OS 설치](CentOS7/README.md)
* [Zookeeper 설치](Zookeeper/README.md)
* [Kafka 설치](Kafka/README.md)
* [NiFi 설치](NiFi/README.md)
* [Hadoop 설치](Hadoop/README.md)
* [MariaDB 설치](MariaDB/README.md)
* [Hive 설치](Hive/README.md)

___
.END OF README