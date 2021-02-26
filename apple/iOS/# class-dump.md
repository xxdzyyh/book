# class-dump



问题：**class-dump** Error:**Cannot** **find** **offset** **for** **address** **0x**d80000000101534a in stringAtAddress:

我的**class-dump**是官网下载的，在使用**class-dump** -H报错Error:**Cannot** **find** **offset** **for** **address** **0x**d80000000101534a in stringAtAddress:由于我项目使用了Swift和Oc混编，猜测可能是官网的**class-dump**不支持dump swift files导致。

##### 解决办法：

从链接[https://github.com/AloneMonkey/MonkeyDev/blob/master/bin/**class-dump**](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2FAloneMonkey%2FMonkeyDev%2Fblob%2Fmaster%2Fbin%2Fclass-dump)中重新下载**class-dump**拖入到路径：**/usr/local/bin**

若执行**class-dump**命令报错`/usr/local/bin/**class-dump**: Permission denied`，在终端运行`sudo chmod 777 /usr/local/bin/**class-dump**`命令赋予所有用户可读可写可执行**class-dump**文件权限

最后运行**class-dump**即可。