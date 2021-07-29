# SpringBoot



[TOC]

### HelloWorld

首先创建一个Maven Project,将JDK配置好。

在pom.xml中加入依赖

```
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.3.4.RELEASE</version>
    <relativePath/>
</parent>

<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
</dependencies>
```

完整pom.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.3.4.RELEASE</version>
        <relativePath/>
    </parent>

    <groupId>org.feng</groupId>
    <artifactId>study</artifactId>
    <version>1.0-SNAPSHOT</version>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
    </dependencies>

</project>
```

添加请求

```
package com.example.elasticsearchtest.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("log")
public class ELKController {

    @GetMapping("all")
    public String getAllLog() {
        return "123";
    }
}
```

```
curl http://localhost:8888/log/all
123%    
```

#### parent

创建一个parent项目，打包类型为pom，parent项目中不存放任何代码，只是管理多个项目之间公共的依赖。在parent项目的pom文件中定义对common.jar的依赖，三个子项目中只需要定义<parent></parent>，parent标签中写上parent项目的pom坐标就可以引用到common.jar了。简单来讲就是可以继承父项目的pom.xml，这样公共部分有父项目制定

### 使用modules

启动多个SpringBootApplication,

study现在作为容器，只需要pom.xml，其他的文件可以删除，添加两个Module，api/gateway。

```
study
	api
	gateway
	pom.xml
```



因为这api/gateway两个项目目前的依赖都是一样的，所以只需要在study的pom.xml中添加依赖

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <packaging>pom</packaging>
    
    <modules>
        <module>gateway</module>
        <module>api</module>
    </modules>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.3.4.RELEASE</version>
        <relativePath/>
    </parent>

    <groupId>org.feng</groupId>
    <artifactId>study</artifactId>
    <version>1.0-SNAPSHOT</version>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
    </dependencies>

</project>
```

然后在子module的pom.xml中使用parent依赖study

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>study</artifactId>
        <groupId>org.feng</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>api</artifactId>

</project>
```

第一个项目可以正常启动，第二个项目会端口冲突，这个时候添加 application.yml

```
src
	main
		java
		resources
			application.yml
```

application.yml 非常简单

```
server:
  port: 8082
```



### spring cloud gateway

<img src="https://spring.io/images/diagram-microservices-88e01c7d34c688cb49556435c130d352.svg" alt="Microservices diagram" style="zoom: 33%;" />



gateway 网关可以用来做请求预处理操作，比如过滤、转发、鉴权等。

```
study
	api1 # 8080 处理 /hello/**
	api2 # 8082 处理 /simple/**
	gateway # 445 接口转发
	pom.xml
```

application.yml

```
server:
  port: 445
spring:
  cloud:
    gateway:
      routes:
        - id: hello-router
          uri: http://192.168.1.100:8080
          predicates:
            - Path=/hello/**
        - id: simple-router
          uri: http://192.168.1.100:8082
          predicates:
            - Path=/simple/**
```

因为 uri 是完整的地址，所以不需要zookeekper,直接访问就可以。

请求也可以自己处理，添加一个路由规则，如下：

```
- id: gateway-router
  uri: http://127.0.0.1:445
  predicates:
    - Path=/gateway/**
    
或者

- id: gateway-router
  uri: lb:gateway
  predicates:
    - Path=/gateway/**
```

在gateway项目里添加一个controller

```
package com.gateway.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class SimpleController {
    @ResponseBody
    @RequestMapping("/gateway")
    public String hello() {
        return "Gateway Controller,SpringBoot";
    }
}
```

```
$ curl localhost:445/gateway

Gateway Controller,SpringBoot%  
```



#### 路由解析

```
// CompositeRouteDefinitionLocator.java

public Flux<RouteDefinition> getRouteDefinitions() {
        return  this.delegates.flatMapSequential(RouteDefinitionLocator::getRouteDefinitions).flatMap((routeDefinition) -> {
        return routeDefinition.getId() == null ? this.randomId().map((id) -> {
            routeDefinition.setId(id);
            if (log.isDebugEnabled()) {
                log.debug("Id set on route definition: " + routeDefinition);
            }

            return routeDefinition;
        }) : Mono.just(routeDefinition);
    });
}

// this.delegates
// [
//    PropertiesRouteDefinitionLocator,
// 		InMemoryRouteDefinitionRepository
// ]

PropertiesRouteDefinitionLocator.properties

[GatewayProperties@2f677247 routes = list[
RouteDefinition{id='hello-router', predicates=[PredicateDefinition{name='Path', args={_genkey_0=/hello/**}}], filters=[], uri=http://192.168.1.100:8080, order=0, metadata={}}, 

RouteDefinition{id='simple-router', predicates=[PredicateDefinition{name='Path', args={_genkey_0=/simple/**}}], filters=[], uri=http://192.168.1.100:8082, order=0, metadata={}}, 

RouteDefinition{id='gateway-router', predicates=[PredicateDefinition{name='Path', args={_genkey_0=/gateway/**}}], filters=[], uri=lb:gateway, order=0, metadata={}}],

defaultFilters = list[[empty]], 
streamingMediaTypes = list[text/event-stream, application/stream+json], failOnRouteDefinitionError = true]
```

如果在application.yml 中添加 

```
discovery:
  locator:
    enabled: true
    lower-case-service-id: true
```

那delegates 又会多加一条

```
 [DiscoveryLocatorProperties@64c8fcfb enabled = true, routeIdPrefix = [null], includeExpression = 'true', urlExpression = ''lb://'+serviceId', lowerCaseServiceId = true, predicates = list[PredicateDefinition{name='Path', args={pattern='/'+serviceId+'/**'}}], filters = list[FilterDefinition{name='RewritePath', args={regexp='/' + serviceId + '/(?<remaining>.*)', replacement='/${remaining}'}}]]
```



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

