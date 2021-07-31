## LLDB



https://github.com/DerekSelander/lldb



https://zhuanlan.zhihu.com/p/299501575



po



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





### frame v b 



### frame info 显示当前帧信息

```
(lldb) bt
```







### register read

读取寄存器



### register write

写入寄存器

```
register write rax 1
```



## thread

### thread list 列出当前线程列表

列出



### thread select 1

选取线程



### thread return 跳出当前方法的执行

Debug的时候，也许会因为各种原因，我们不想让代码执行某个方法，或者要直接返回一个想要的值。这时候就该thread return上场了。 有返回值的方法里，如：numberOfSectionsInTableView:，直接thread return 20，就可以直接跳过方法执行，返回20.

```text
//跳出方法
(lldb) thread return
//让带有返回int值的方法直接跳出，并返回值20
(lldb) thread return 20
复制代码
```



## image



### image list



### image lookup -a

```
(lldb) image lookup -a 0x0000000100001b8f
			Address: TestWeak[0x0000000100001b8f] (TestWeak.__TEXT.__text + 335)
      Summary: TestWeak`-[Person getInt] + 287 at main.m:31:13
```



### image lookup -name 查找方法来源

```
(lldb) image lookup getInt
```



### image lookup -type 查看成员

```
(lldb) image lookup -type BugInsight

(lldb) image lookup -type MPNetwork
0 match found in /Users/wxf/Library/Developer/Xcode/DerivedData/TingyunDemo-ayfesmgdmmlvvbgphixvtohqaonf/Build/Products/Debug-iphoneos/TingyunDemo.app/Frameworks/BugInsight.framework/BugInsight:
id = {0x7fffffff000a7899}, name = "MPNetwork", byte-size = 48, decl = MPNetwork.h:21, compiler_type = "@interface MPNetwork : NSObject{
    BOOL _shouldManageNetworkActivityIndicator;
    BOOL _useIPAddressForGeoLocation;
    BugInsight * _bugInsight;
    NSURL * _serverURL;
    NSTimeInterval _requestsDisabledUntilTime;
    NSUInteger _consecutiveFailures;
}
@property(nonatomic, readwrite, getter = bugInsight, setter = setBugInsight:) BugInsight *bugInsight;
@property(nonatomic, readwrite, getter = serverURL, setter = setServerURL:) NSURL *serverURL;
@property(nonatomic, assign, readwrite, getter = requestsDisabledUntilTime, setter = setRequestsDisabledUntilTime:) NSTimeInterval requestsDisabledUntilTime;
@property(nonatomic, assign, readwrite, getter = consecutiveFailures, setter = setConsecutiveFailures:) NSUInteger consecutiveFailures;
@property(nonatomic, assign, readwrite, getter = shouldManageNetworkActivityIndicator, setter = setShouldManageNetworkActivityIndicator:) BOOL shouldManageNetworkActivityIndicator;
@property(nonatomic, assign, readwrite, getter = useIPAddressForGeoLocation, setter = setUseIPAddressForGeoLocation:) BOOL useIPAddressForGeoLocation;
@end"
```





