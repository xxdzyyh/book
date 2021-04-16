# Sync & Async

dispatch_sync(queue, task);

dispatch_sync 不会开启新的线程，所以dispatch_sync中的 task 会在 queue 当前所在线程执行。

而 dispatch_sync()  本身会在当前线程执行，并且会阻塞当前线程，等待 task 完成。

所以如果 dispatch_sync() 当前所在的线程 和 task 要执行的线程是同一个线程，就会死循环。



主队列不是不可以执行 dispatch_sync, 而是不能在主线程执行 dispatch_sync

```
dispatch_async(dispatch_get_global_queue(0, 0), ^{
  dispatch_sync(dispatch_get_main_queue(), ^{
    NSLog(@"%@",[NSThread currentThread]);
    NSLog(@"%@",@"主队列同步执行");
  });
  NSLog(@"111");
});
```

