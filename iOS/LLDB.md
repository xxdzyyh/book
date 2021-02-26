## LLDB



https://github.com/DerekSelander/lldb



### methods

列出一个类所有的类方法、属性和实例方法，私有的方法也可以显示出来。

```
methods ViewController
```

等价于

```
exp -lobjc -O -- [ViewController _shortMethodDescription]
```



```none
image lookup -rn ViewController
```



 