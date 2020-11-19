## iOS 多行字符串常量

现在有一个写好的JS文件，iOS 端需要在webView加载的某个时机去调用它。

我们可以直接使用下面的代码从文件中读取

```
NSString *jsPath = [[NSBundle mainBundle] pathForResource:@"webview_inject" ofType:@"js"];
NSData *data = [NSData dataWithContentsOfFile:jsPath];
NSString *jsString =  [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
NSLog(@"%@",jsString);
```

但是如果你是在静态framework中使用这个文件，就会有问题，因为上面的方法无法获取到这个文件的位置。

文件在framework下面，但是在framework里使用NSBundle自带的方法`bundleForClass`得到的依旧是mainBundle。

可以考虑将文件中的内容转化为字符串

目前遇到的问题：

1. `\` 必须转义
2. `"` 必须转义

可以将js文件放到主工程，执行上面的代码，鼠标放在jsString上面，显示的内容就是转义后的字符串，但是复制只能复制一部分，打印转义又没了，后续跟进这个问题。

可以先替换js文件中的`\`,再替换`"`





