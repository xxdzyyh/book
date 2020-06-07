---
layout: post
title: RAC
type: iOS
---

任何的信号转换即是对原有的信号进行订阅从而产生新的信号

### kvo

下面两种写法等价

```
[[self.tableView rac_valuesForKeyPath:@"contentOffset" observer:self] subscribeNext:^(id  _Nullable x) {
    NSLog(@"%@ %@",NSStringFromClass([x class]),x);
}];

```

```
[RACObserve(self.tableView, contentOffset) subscribeNext:^(id  _Nullable x) {
    NSLog(@"%@ %@",NSStringFromClass([x class]),x);
}];

```

1. 为什么不需要移除监听？
2. 为什么后面一种写法输入keypath会有提示？

取消kvo监听(取消订阅)

```
- (void)cancelKVO {
    RACSignal *signal = [self.tableView rac_valuesForKeyPath:@"contentOffset" observer:self];
    
    __block RACDisposable *disposable = [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@ %@",NSStringFromClass([x class]),x);
        
        [disposable dispose];
    }];
}
```

### delegate

通过RAC实现协议方法

```
[[self rac_signalForSelector:@selector(tableView:didSelectRowAtIndexPath:) fromProtocol:@protocol(UITableViewDelegate)] subscribeNext:^(RACTuple * _Nullable x) {
    NSLog(@"xx %@",x);
}];
    
self.tableView.delegate = self;

```

注意在最后设置一下代理，初步看，因该和运行时相关，具体还得仔细分析源码。

在

```
[[self rac_signalForSelector:@selector(tableView:didSelectRowAtIndexPath:) fromProtocol:@protocol(UITableViewDelegate)] subscribeNext:^(RACTuple * _Nullable x) {
    NSLog(@"xx %@",x);
}];
```
执行前后添加断点，输出isa

```
(lldb) po self->isa
DelegateVC

(lldb) po self->isa
DelegateVC_RACSelectorSignal
```
可以看到类已经发生了变化。在这个过程中，新的类实现了代理方法.

### 事件监听

```
[[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
    NSLog(@"button touch up inside");
}];
```

### timer

延迟调用

```
[[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
    NSLog(@"main thread after delay 2");
}];
```

定时触发

```
// takeUntil设置了订阅的条件，否则timer不会停止
[[[RACSignal interval:2 onScheduler:[RACScheduler mainThreadScheduler]] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSDate * _Nullable x) {
    NSLog(@"RAC timer ...");
}];
```

[测试Demo地址] (https://github.com/xxdzyyh/LearnRAC.git)


### 双向绑定

RACKVOChannel

### 冷信号和热信号

* 冷信号：订阅了才开始发送消息，没有订阅时什么也不会发生，只有一个订阅者，不支持一对多。
* 热信号：不管你订不订阅，有变化就会发送，支持一对多。






### 参考文章

* [细说ReactiveCocoa的冷信号与热信号（一）](https://tech.meituan.com/talk-about-reactivecocoas-cold-signal-and-hot-signal-part-1.html)
* [细说ReactiveCocoa的冷信号与热信号（二）：为什么要区分冷热信号](https://tech.meituan.com/talk-about-reactivecocoas-cold-signal-and-hot-signal-part-2.html)
* [细说ReactiveCocoa的冷信号与热信号（三）：怎么处理冷信号与热信号](https://tech.meituan.com/talk-about-reactivecocoas-cold-signal-and-hot-signal-part-3.html)
* [图解ReactiveCocoa基本函数](https://www.jianshu.com/p/38d39923ee81)