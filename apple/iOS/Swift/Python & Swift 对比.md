



Python3 & Swift



### 字典

> Python

```
// 创建字典，可变的
dict = {}
// 读取并设置默认值
dict.get(key,defaultValue)
// 读取，如果key不存在会报错，建议使用dict.get(key)
var = dict[key]
// 添加或更新key-value
dict[key] = value
```

### Shell交互

> 获取shell 参数

```
python test.py arg1 arg2
```

使用sys 

```
#!/usr/bin/python3
# -*- coding: UTF-8 -*-

import sys

print ('脚本名:',sys.argv[0])
print ('参数个数为:', len(sys.argv), '个参数。')
print ('参数列表:', str(sys.argv))
```

使用getopt模块

