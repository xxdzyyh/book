## RACObserver

```
#define RACObserve(TARGET, KEYPATH) \
    [(id)(TARGET) rac_valuesForKeyPath:@keypath(TARGET, KEYPATH) observer:self]
```

RACObserver 是基于KVC实现的（KVC的代码存在于RACKVOTrampoline中），所以KVC需要注意的地方也就是RACObserver需要注意的地方。

### keyPath选取的问题

```
- (instancetype)initWithAnchor:(Anchor *)anchor {
	self = [super init];
	if (self) {
		self.anchor = anchor;
		
		[self bind];
	}
	return self;
}

- (void)bind {
	RAC(self,anchorName) = RACObserve(self.anchor, name);
	RAC(self, anchorUid) = RACObserve(self, anchor.uid);
}
```

RACObserve(self.anchor, name) 监听的是self.anchor这个对象的name属性，如果self.anchor = anchor2，这个时候self.anchorName 依旧不会改变。如果self.anchor = nil,这句话没有效果。

RACObserve(self, anchor.uid) 监听的是anchor.uid,anchor和uid任何一个发生变化，都会改变self.anchorUid。如果执行的时候，anchor 为nil,后续再给self.anchor赋值，self.anchorUid会是正确的值

对比两个keyPath，直接使用后者就行。

### setter

如果重写setter方法，需要注意调用 willChangeValueForKey 和  didChangeValueForKey，直接设置成员变量也一样

```
- (void)setUid:(NSString *)uid {
    [self willChangeValueForKey:@"uid"];
    _uid = uid;
    [self didChangeValueForKey:@"uid"];
}

- (void)updateUid {
    [self willChangeValueForKey:@"uid"];
    _uid = @"002";
    [self didChangeValueForKey:@"uid"];
}
```

### 合理使用

RACObserver使用起来非常方便，但是这个便利是有副作用的。如果监听代码散布在代码的各个角落，维护起来就非常困难。很多时候修改了某个属性就会引起一系列的变化，除了问题很难定位，建议监听的代码集中放置。