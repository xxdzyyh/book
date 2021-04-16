# maven



## 打包



新建一个 java command line application，添加 maven 支持。



新项目 pom.xml 非常简单。

```
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>groupId</groupId>
    <artifactId>TingyunUpdate</artifactId>
    <version>1.0-SNAPSHOT</version>
    
    
    
</project>
```



添加依赖

````
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>groupId</groupId>
    <artifactId>TingyunUpdate</artifactId>
    <version>1.0-SNAPSHOT</version>

    <dependencies>

        <dependency>
            <groupId>com.google.code.gson</groupId>
            <artifactId>gson</artifactId>
            <version>2.8.6</version>
        </dependency>
        
		</dependencies>
</project>
````



进行开发，这个时候如果直接 `mvn clean install `, jar 可以打包成功，但是非常小，使用 JD-GUI 看这个jar,发现依赖没有打包进去。



mvn 打包方式也有几种，需要在 pom 中指定。

### maven-jar-plugin

配置很简单，但是 jar 的依赖没有包含,jar 依赖的文件放在外部，如果多个jar 依赖同一个jar,没有必要每个jar 都包含一份。

```
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-jar-plugin</artifactId>
    <version>3.0.2</version>
    <configuration>
        <archive>
            <manifest>
                <addClasspath>true</addClasspath>
                <mainClass>com.leishu.Application</mainClass> <!-- 此处为主入口-->
                <classpathPrefix>lib/</classpathPrefix> // 指定外部jar所在的路径，添加的classpath为 【路径】/jar文件名，Maven自动解析文件名，使用本项目生成的jar包时，当前目录下有lib文件夹，lib文件夹中有本项目使用的外部jar文件即可
            </manifest>
        </archive>
    </configuration>
</plugin>
```



### maven-assembly-plugin

maven-assembly-plugin 插件主要是为了允许用户输出项目及其依赖关系、模块、网站文档和其他文件到一个单独的可发布的文档中。

```
mvn clean compile assembly:single
```

```
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-assembly-plugin</artifactId>
            <configuration>
                <archive>
                    <manifest>
                        <addClasspath>true</addClasspath>
                        <mainClass>com.tingyun.Main</mainClass> //这里是你的包含mian方法的类
                    </manifest>
                </archive>
                <descriptorRefs>
                    <descriptorRef>jar-with-dependencies</descriptorRef>
                </descriptorRefs>
            </configuration>
            <executions>
                <execution>
                    <id>make-assembly</id>
                    <phase>package</phase>
                    <goals>
                        <goal>single</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

