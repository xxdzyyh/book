---
type: iOS
---

iOS中以NS开头实现锁的有NSCondition、NSConditionLock、NSLock、NSRecursiveLock，其中NSCondition最为特别。

* NSCondition的condition可以被忽略，那就和一般的锁没有区别.
* NSConditionLock和NSCondition都可以实现条件锁，区别在于NSConditionLock自身持有一个条件，而NSCondition的条件依赖于外部变量
* NSCondition展示了更多的细节

### NSCondition

lock & checkpoint，即充当锁又充当检查点。

```
__block int flag = 0;

NSCondition *condition = [NSCondition new];

dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [condition lock];
    while (flag != 1) {
   		  // 阻塞当前线程，现在只能等待其他线程唤醒condition了
        [condition wait];
    }
    
    // 需要加锁保护的代码
    
    [condition unlock];
});

dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    flag = 1;
    
    // 随机唤醒1个在等待 condition 的线程，可以多次调用，唤醒多个线程
    [cond signal];
    
    // 唤醒所有在等待 condition 的线程
    [cond broadcast];
});
```

可以看到，NSCondition可以主动进行wait/signal/broadcast。

在一个线程里加锁要考虑的问题：

1、加锁失败怎么处理？
	
* lock 阻塞当前线程
* tryLock 不阻塞当线程

2、被阻塞的线程怎么恢复

signal:唤醒一个被condition阻塞的线程
broadcast:唤醒全部被condition阻塞的线程

wait/sigal这一套其实和信号量是一样的。

### NSLock

The NSLock class uses POSIX threads to implement its locking behavior. When sending an unlock message to an NSLock object, you must be sure that message is sent from the same thread that sent the initial lock message. Unlocking a lock from a different thread can result in undefined behavior.

加锁和解锁必须在同一个线程，否则会导致未知结果，只在NSLock的文档里有这个警告。

```
NSLock *lock = [[NSLock alloc] init];

dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
	[lock lock];
	
	// 需要加锁保护的代码 
	
	[lock unlock];
});

```

NSLock的lock和tryLock的区别

```
// bool success = [condition lock];
// while (!success) {
//     [condition wait];
// }
[lock lock];
    
// bool success = [condition lock];
// while (!success) {
//     do nothing   
// }
bool success = [lock tryLock];
```

NSLock的unlock

```
// [condition unlock];
// [condition broadcast];
[lock unlock];
```

### NSConditionLock

满足条件时才能获取锁。在获得锁执行保护区域代码后，可以释放锁并重新设置条件。

> 条件不满足，阻塞当前线程

```
__block int flag = 0;

NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:1];

dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // flag = 0 ; lock.condition = 1; 
    // flag != condition 无法获得锁，当前线程进入休眠,等待唤醒
    
    // [condition lock];
    // while (flag != condition) {
    //    [condition wait]
    // }
    [lock lockWhenCondition:flag];

    // 需要加锁保护的代码
    // lock.condition = 2;
    // [conditon unlock];
    // [condition broadcast];
    [lock unlockWithCondition:2];
});

```

> 条件不满足，阻塞，后添加满足，获得锁

```
__block int flag = 0;

NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:1];

dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [lock lockWhenCondition:flag];

    // 需要加锁保护的代码
    
    [condition unlockWithCondition:2];
});

dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		
	 // [condition unlock];
	 // [condition broadcast];	
    [lock unlockWithCondition:1];
});

```

### 信号量

```
// 设定一个信号，当前可用为0
dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSLog(@"semaphore = 0 无法执行");
    // 如果 semaphore > 0 ,wait 会使 semaphore - 1，否则会阻塞当前线程，所以不要主线程 wait
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    NSLog(@"Run Task 1 Start");
    sleep(1);
    NSLog(@"Run Task 1 End");
    dispatch_semaphore_signal(semaphore);
});
    
NSLog(@"semaphore 即将+1");
// semaphore + 1
dispatch_semaphore_signal(semaphore);
    
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSLog(@"semaphore = 0 无法执行");
    // 如果 semaphore > 0 ,wait 会使 semaphore - 1，否则会阻塞当前线程，所以不要主线程 wait
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    NSLog(@"Run Task 2 Start");
    sleep(1);
    NSLog(@"Run Task 2 End");
    dispatch_semaphore_signal(semaphore);
});
```

上面一点代码和下面的代码执行结果没有区别

```
__block NSUInteger flag = 0;
NSCondition *condition = [[NSCondition alloc] init];
    
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSLog(@"semaphore = 0 无法执行");
    // 如果 semaphore > 0 ,wait 会使 semaphore - 1，否则会阻塞当前线程，所以不要主线程 wait
    while (flag == 0) {
        [condition wait];
    }
    flag--;
    NSLog(@"Run Task 1 Start");
    sleep(1);
    NSLog(@"Run Task 1 End");
    
    flag++;
    [condition signal];
});
    
NSLog(@"semaphore 即将+1");
// semaphore + 1
flag++;
[condition broadcast];
    
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSLog(@"semaphore = 0 无法执行");
    // 如果 semaphore > 0 ,wait 会使 semaphore - 1，否则会阻塞当前线程，所以不要主线程 wait
    while (flag == 0) {
        [condition wait];
    }
    flag--;
    
    NSLog(@"Run Task 2 Start");
    sleep(1);
    NSLog(@"Run Task 2 End");
    
    flag++;
    [condition signal];
});

```
### POSIX

Portable Operating System Interface of UNIX,一套通用的操作系统接口。

### NSLocking

- lock
- unlock

NSCondition、NSConditionLock、NSLock、NSRecursiveLock都实现了这个协议




