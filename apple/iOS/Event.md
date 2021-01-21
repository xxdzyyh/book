
### 事件 RACEvent/Event

Event: 一个信号可以产生多个事件，每一次值的变化可以生成一个事件。

Event的类型
	
* next : 信号产生了新的值
* failed: 信号在结束前发生了错误
* completed: 信号已成功结束，不会再有新的值产生

以按钮点击为例，按钮点击可以关联到一个信号，每一次按钮点击，信号就生成一个next类型的event。

### 动作 block/closures

事件发生时需要做什么。一般而言，订阅就是为了执行某个action。ReactiveCocoa 中使用 block 来表示 Action.

ReactiveObjC 中没有暴露订阅者对应的类，所以说某个action订阅了信号也是可以的。

```
[signalA subscribeNext:^(id  _Nullable x) {
        
}];
```

可以说 ```^(id  _Nullable x) { }``` 订阅了 ```signalA next```

以按钮点击为例，


### 信号 RACSigal/Observable

事件像按钮点击等在没有 ReactiveCocoa 的情况下也可以被处理，用信号来处理是与众不同的。

信号可以被订阅，订阅不会有任何副作用。当订阅一个信号时，订阅者只能按照顺序处理信号里的事件，不能随意访问信号里的事件。

### 订阅/观察

信号可以被订阅，订阅和观察是同一个含义。信号有了订阅者，发出的事件才会被处理，否则不需要发送事件。

### 调度器

Schedulers are used to control when and where work is performed.

调度器控制Action在何时在哪个线程被处理。

* where 在那个线程处理

* when  
	* 优先级
	* 时间
	
Scheduler对GCD进行了封装，实际上每个线程都对应一个串行队列来保证相关的action是顺序执行的。
	
### Disposable

Disposable 可以取消订阅，在适当的时候取消订阅是非常有必要的。
 	