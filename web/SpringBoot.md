# SpringBoot



[TOC]

## kafka

1. 安装 zookeeper

   `brew install zookeeper`

   默认安装位置

   启动文件： /usr/local/Cellar/zookeeper/3.4.10/bin/

   配置文件： /usr/local/etc/zookeeper/     

2. 启动zookeeper

   `nohup zookeeper-server-start /usr/local/etc/kafka/zookeeper.properties &`

3. 安装kafka

   `brew install kafka`

4. 修改Kafka服务配置文件

   修改配置文件 /usr/local/etc/kafka/server.properties

   解除注释: listeners=PLAINTEXT://localhost:9092
   
5. 启动kafka

   `nohup kafka-server-start /usr/local/etc/kafka/server.properties &`



```
kafka-server-stop
zookeeper-server-stop

nohup zookeeper-server-start /usr/local/etc/kafka/zookeeper.properties &
nohup kafka-server-start /usr/local/etc/kafka/server.properties &
```





## 常见问题



### Q: Tomcat启动后很快又自动关闭

A: 查看controller的@RequestMapping中是否有重复的url，可能因为重复导致项目启动不了



### 端口占用

Zookeeper 默认是 2181 端口

使用 `lsof -i tcp:2181`

```
$ nohup zookeeper-server-start /usr/local/etc/kafka/zookeeper.properties &
$ lsof -i tcp:2181
COMMAND  PID USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
java    2772  mac  117u  IPv6 0x392e470d533b79b1      0t0  TCP *:eforward (LISTEN)

// 启动 Springboot 项目后
$ lsof -i tcp:2181
COMMAND  PID USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
java    2772  mac  117u  IPv6 0x392e470d533b79b1      0t0  TCP *:eforward (LISTEN)
java    2772  mac  122u  IPv6 0x392e470d533ba491      0t0  TCP localhost:eforward->localhost:50099 (ESTABLISHED)
java    3113  mac  114u  IPv6 0x392e470d533b9231      0t0  TCP localhost:50099->localhost:eforward (ESTABLISHED)
```

