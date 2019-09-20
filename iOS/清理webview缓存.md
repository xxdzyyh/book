## 清理webview缓存

用户长期使用以后，webView可能会缓存大量的数据，占用用户手机的磁盘空间。因此必须提供一个功能用来清除缓存。

在iOS 8上使用，没有发现应用数据大小随着WKWebView的使用而增加，无需清除缓存，最多清除Cookies。

```
- (void)clearWebCache {
  NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
  NSError *errors;
  [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
}
```

iOS 12 WKWebView缓存存放位置 `沙盒/Library/Caches/WebKit` ,应用数据大小为60.1M，这个文件夹占用56.1，56.1M/60.1M = 93.3%，因此清除缓存的时候，移除这个文件夹就可以了。

视屏等MediaCache会存放在```沙盒/tmp/WebKit```下面,


```
// 针对iOS 9及以上的版本生效
- (void)clearWebCache {
    //allWebsiteDataTypes清除所有缓存
    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        
    }];
}
```



```
// B 转成M NSString *size = [NSString fileSize / 1000.0 / 1000.0
- (unsigned long long)fileSize {

    // 总大小
    unsigned long long size = 0;
    // 文件管理者
    NSFileManager *mgr = [NSFileManager defaultManager];
    // 是否为文件夹
    BOOL isDirectory = NO;

    // 路径是否存在
    BOOL exists = [mgr fileExistsAtPath:self isDirectory:&isDirectory];
    if (!exists) return size;

    if (isDirectory) { // 文件夹
        // 获得文件夹的大小  == 获得文件夹中所有文件的总大小
        NSDirectoryEnumerator *enumerator = [mgr enumeratorAtPath:self];
        for (NSString *subpath in enumerator) {
            // 全路径
            NSString *fullSubpath = [self stringByAppendingPathComponent:subpath];
            // 累加文件大小
            size += [mgr attributesOfItemAtPath:fullSubpath error:nil].fileSize;
        }
    } else { // 文件
        size = [mgr attributesOfItemAtPath:self error:nil].fileSize;
    }
    return size;
}
@end
```