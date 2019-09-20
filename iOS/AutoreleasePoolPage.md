---
type: iOS
---

```
magic_t magic;
id *next;
AutoreleasePoolPage *child;
AutoreleasePoolPage *parent;
pthread *thread;
int depth;
int hiwat;
```
AutoreleasePool实际就是 AutoreleasePoolPage 构成的双向链表，相关的方法都是在 AutoreleasePoolPage 中实现的。

### _objc\_autoreleasePoolPrint()

可以使用私有函数 _objc\_autoreleasePoolPrint() 进行调试，对应 OC 的方法是 [NSAutoreleasePool showPools]。

需要注意的地方是 AutoreleasePool 清空的速度是非常的快，所以进行调试时需要提前下断点，然后单步调试。

```
+ (MemoryObj *)memoryObj {
    MemoryObj *memory = [[MemoryObj alloc] init];
    
    return memory;
}

// 想要验证 obj 是否被注册到 AutoreleasePool，需要在return memory下断点，而不是在下面这句出下断点 
MemoryObj *obj = [MemoryObj memoryObj];

```

```
po _objc_autoreleasePoolPrint()

po [NSAutoreleasePool showPools]

objc[86279]: ##############
objc[86279]: AUTORELEASE POOLS for thread 0x70000c98f000
objc[86279]: 1 releases pending.
objc[86279]: [0x7fc54d847000]  ................  PAGE  (hot) (cold)
objc[86279]: [0x7fc54d847038]    0x600001a1eb50  MemoryObj
objc[86279]: ##############

```

### Runloop

在 main.m 中， @autoreleasepool 前添加一个断点，po [NSRunloop currentLoop]。

```
observers = (null),
```

在程序启动后，暂停，po [NSRunloop currentLoop]


```
observers = (
    "<CFRunLoopObserver 0x6000017bc460 [0x10b0ceb68]>{valid = Yes, activities = 0x1, repeats = Yes, order = -2147483647, callout = _wrapRunLoopWithAutoreleasePoolHandler (0x114a771b1), context = <CFArray 0x6000028fa040 [0x10b0ceb68]>{type = mutable-small, count = 1, values = (\n\t0 : <0x7f8a01801058>\n)}}",
    "<CFRunLoopObserver 0x6000017b8a00 [0x10b0ceb68]>{valid = Yes, activities = 0x20, repeats = Yes, order = 0, callout = _UIGestureRecognizerUpdateObserver (0x114649473), context = <CFRunLoopObserver context 0x600000dba3e0>}",
    "<CFRunLoopObserver 0x6000017bc320 [0x10b0ceb68]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 1999000, callout = _beforeCACommitHandler (0x114aa6dfc), context = <CFRunLoopObserver context 0x7f8a01502590>}",
    "<CFRunLoopObserver 0x6000017bc5a0 [0x10b0ceb68]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 2000000, callout = _ZN2CA11Transaction17observer_callbackEP19__CFRunLoopObservermPv (0x10c7b26ae), context = <CFRunLoopObserver context 0x0>}",
    "<CFRunLoopObserver 0x6000017bc140 [0x10b0ceb68]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 2001000, callout = _afterCACommitHandler (0x114aa6e75), context = <CFRunLoopObserver context 0x7f8a01502590>}",
    "<CFRunLoopObserver 0x6000017bc3c0 [0x10b0ceb68]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 2147483647, callout = _wrapRunLoopWithAutoreleasePoolHandler (0x114a771b1), context = <CFArray 0x6000028fa040 [0x10b0ceb68]>{type = mutable-small, count = 1, values = (\n\t0 : <0x7f8a01801058>\n)}}"
),
```

可以看到有两个 observer 是和 AutoreleasePool 相关的，回调都是 _wrapRunLoopWithAutoreleasePoolHandler 。

可以创建一个符号断点来观察 _wrapRunLoopWithAutoreleasePoolHandler 。

第一个 Observer 监视的事件是 kCFRunLoopEntry，其回调内会调用 _objc_autoreleasePoolPush() 创建自动释放池。其 order 是-2147483647，优先级最高，保证创建释放池发生在其他所有回调之前。

第二个 Observer 监视了两个事件： kCFRunLoopBeforeWaiting 时调用_objc_autoreleasePoolPop() 和 _objc\_autoreleasePoolPush() 释放旧的池并创建新池；kCFRunLoopExit 时调用 \_objc\_autoreleasePoolPop() 来释放自动释放池。这个 Observer 的 order 是 2147483647，优先级最低，保证其释放池子发生在其他所有回调之后。

### __autoreleasing

ARC 生效时，对象必须要附加所有权修饰符。

* __strong
* __weak
* __unsafe\_unretained
* __autoreleasing

>__strong 

id和对象类型默认修饰符是 __strong，

```
id obj = [[NSObject alloc] init];
id __strong obj = [[NSObject alloc] init];


id array = [NSArray array];
// 注意这里不是__autoreleasing,注册到 autoreleasePool 发生在 + (NSArray *)array; 
id __strong obj = [NSArray array];

```

>__autoreleasing

1. 非 alloc/new/copy/mutableCopy 开头的方法返回的对象会注册到自动释放池
2. 附有 __weak 修饰符的变量必须注册到 autoreleasepool, 延长引用对象的生命周期
3. 没有显示附加修饰符，会自动附加 __autoreleasing
	
	```
	-(BOOL)performOperationWithError:(NSError **)error;
	
	-(BOOL)performOperationWithError:(NSError * __autoreleasing *)error;
	```

### 线程问题

子线程默认是没有开启 runloop 的，那子线程的 __autoreleasing 变量怎么释放呢？
通过测试可以看到子线程也有 autoReleasePool ，那子线程的 autoReleasePool 什么时候清空呢？

```
// 在main线程打印
po _objc_autoreleasePoolPrint()
objc[87148]: ##############
objc[87148]: AUTORELEASE POOLS for thread 0x700005c3d000
objc[87148]: 0 releases pending.
objc[87148]: [0x7ff7fb884000]  ................  PAGE  (hot) (cold)
objc[87148]: ##############

- (void)test4 {
    NSMutableArray __autoreleasing*array = [NSMutableArray array];
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(asyncTask) object:nil];
    
    [thread start];
}

- (void)asyncTask {
    NSLog(@"%@",[NSThread currentThread]);
    id __weak obj = [MemoryObj memoryObj];
    
    NSLog(@"%@",[NSThread currentThread]);
}

// 在子线程打印
po _objc_autoreleasePoolPrint()
objc[87148]: ##############
objc[87148]: AUTORELEASE POOLS for thread 0x700005b37000
objc[87148]: 1 releases pending.
objc[87148]: [0x7ff7fa056000]  ................  PAGE  (hot) (cold)
objc[87148]: [0x7ff7fa056038]    0x600000b2f2e0  MemoryObj
objc[87148]: ##############

```
```id __weak obj = [MemoryObj memoryObj];``` 执行后 ```po _objc_autoreleasePoolPrint()```,自动释放池已经是空的。
这个时机的确不好说，需要进一步查找资料。
