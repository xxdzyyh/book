# Flink

[TOC]



## 核心概念



### Event Streams

即事件流，事件流可以是实时的也可以是历史的。Flink 是基于流的，但它不止 能处理流，也能处理批，而流和批的输入都是事件流，差别在于实时与批量。

### State

Flink 擅长处理有状态的计算。通常的复杂业务逻辑都是有状态的，它不仅要处 理单一的事件，而且需要记录一系列历史的信息，然后进行计算或者判断。

### (Event) Time

最主要处理的问题是数据乱序的时候，一致性如何保证。

### Snapshots

实现了数据的快照、故障的恢复，保证数据一致性和作业的升级迁移等。







## 安装



```
$ brew install apache-flink
$ brew info apache-flink

cd /usr/local/Cellar/apache-flink/1.13.1

# 启动
./libexec/bin/start-cluster.sh 

# 停止
./libexec/bin/stop-cluster.sh
```



然后在 http://localhost:8081/#/overview 查看

![截屏2021-09-13 19.47.32](/Users/wxf/WorkSpace/book/apple/Mac/截屏2021-09-13 19.48.02.png)
