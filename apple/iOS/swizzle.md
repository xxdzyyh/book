## swizzle

swizzle看似简单，但是在实践中可能会遇到一些坑。



### 方法选择

在 OC 中，如果两个方法只是最后的参数不同，那一般短的方法会调用长的方法。

所以如果要 hook 下面的方法，只用 hook 下面的方法，调用上面的方法，上面的方法会在内部调用下面的方法。

```
// NSURLSession
+ (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration;
+ (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(nullable id <NSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue;
```



### 问题

