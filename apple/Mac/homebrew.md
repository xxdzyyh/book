# homebrew



### 安装

```
brew install apache-flink
```



### 查看

可以看到安装路径

```
$ brew info apache-flink  

apache-flink: stable 1.13.1 (bottled), HEAD
Scalable batch and stream data processing
https://flink.apache.org/
/usr/local/Cellar/apache-flink/1.13.1 (160 files, 325.4MB) *
  Poured from bottle on 2021-09-13 at 19:32:35
From: https://mirrors.ustc.edu.cn/homebrew-core.git/Formula/apache-flink.rb
License: Apache-2.0
==> Dependencies
Required: openjdk@11 ✔
==> Options
--HEAD
	Install HEAD version
==> Analytics
install: 431 (30 days), 1,419 (90 days), 7,458 (365 days)
install-on-request: 429 (30 days), 1,415 (90 days), 7,450 (365 days)
build-error: 0 (30 days)
```



### 查询可更新的包

```text
brew outdated
```



### 更新

```
// 更新所有
brew upgrade

// 更新指定包
brew upgrade [包名]
```



### 清理

```text
//清理所有包的旧版本
brew cleanup
```
