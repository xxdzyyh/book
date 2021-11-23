# grep 使用

[TOC]



```
// 输出匹配行及其后5行
grep -A 5 foo 1.txgrep -A 5 foo 1.txt

// 输出匹配行及其前5行
grep -B 5 foo 1.txgrep -A 5 foo 1.txt

// 输出匹配行及其前后5行
grep -C 5 foo 1.txgrep -A 5 foo 1.txt
```


## 在文件中查找指定内容

```
grep "receiver replay " info_collector.log
```