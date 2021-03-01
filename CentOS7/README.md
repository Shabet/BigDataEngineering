# CentOS7 OS 설정

## 0. 계획
* 방화벽 관련 설정은 모두 중지
* Java는 OpenJDK8 설치
* [설치요약](<docs/01. 설치/설치편 01-CentOS 7 설치.pptx>)

## 1. 방화벽 관련 설정 : 중지
* 방화벽 중지
```
# systemctl status firewalld
# systemctl stop firewalld
# systemctl disable firewalld
```

* SELinux 기능 제거
```
# setenforce 0
# vi /etc/selinux/config
SELINUX=disabled
```

## 2. Java 설치 : OpenJDK8
```
# rpm -qa |grep openjdk
# rpm -e java-1.7.0-openjdk-1.7.0.261-2.6.22.2.el7_8.x86_64
# rpm -e java-1.7.0-openjdk-headless-1.7.0.261-2.6.22.2.el7_8.x86_64
# yum -y install java-1.8.0-openjdk-devel
# rpm -qa|grep openjdk
# javac -version
javac 1.8.0_282
# java -version
openjdk version "1.8.0_282"
OpenJDK Runtime Environment (build 1.8.0_282-b08)
OpenJDK 64-Bit Server VM (build 25.282-b08, mixed mode)
```

## 3. hosts 파일 설정
```
# vi /etc/hosts

##### Kafka(VM 테스트) #####
192.168.126.71	peter-kafka001	peter-zk001
192.168.126.72	peter-kafka002	peter-zk002
192.168.126.73	peter-kafka003	peter-zk003
192.168.126.79	peter-client
```
> NOTE. 호스트3대를 이용하여 zookeeper와 kafka를 설치

## 4. IPv4 설정
```
# vi /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 1

# sysctl -p
```
> ref) https://stackoverflow.com/questions/11850655/how-can-i-disable-ipv6-stack-use-for-ipv4-ips-on-jre

___
.END OF CENTOS7