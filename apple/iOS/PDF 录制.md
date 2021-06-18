# PDF 录制

[TOC]

### 总结

* 无法获取PDF
  * [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO]
  * [window.layer renderInContext:context];
* 部分系统可以获取( > iOS 13 ???)
  * [self.webView takeSnapshotWithConfiguration:config completionHandler:^(UIImage * _Nullable snapshotImage, NSError * _Nullable error) { }]

### 细节

使用WKWebView PDF 

```
- (void)loadPDF {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"git.pdf" withExtension:nil];
    [self.webView loadFileURL:url allowingReadAccessToURL:url];
}
```



> 无法获取PDF内容

通过下面的方法获取 window 的内容，PDF 内容区域是灰色的，PDF的内容没有获取到。

```
[window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO];
```

OR

```
[window.layer renderInContext:context];
```



> 可以获取PDF内容

```
- (void)takeSnapshotWithConfiguration:(nullable WKSnapshotConfiguration *)snapshotConfiguration completionHandler:(void (^)(UIImage * _Nullable snapshotImage, NSError * _Nullable error))completionHandler API_AVAILABLE(ios(11.0));
```



```
if (@available(iOS 11.0, *)) {
      WKSnapshotConfiguration *config = [[WKSnapshotConfiguration alloc] init];

      // 因为最终的图片会根据 [UIScreen mainScreen].scale 进行缩放。
      // 所以如果希望得到宽为 240，则需要设置为 240/[UIScreen mainScreen].scale
      config.snapshotWidth = @(self.snapshotWidth/[UIScreen mainScreen].scale);
      if (@available(iOS 13.0, *)) {
          config.afterScreenUpdates = NO;
      }

      NSDate *start = [NSDate date];

      // 主要下面的方法回调是异步的。
      // 如果设置 config.snapshotWidth = @(80)，回调大概需要 0.5s
      // 如果设置 config.snapshotWidth = @(240)，回调大概需要 3.75s
      [self.webView takeSnapshotWithConfiguration:config completionHandler:^(UIImage * _Nullable snapshotImage, NSError * _Nullable error) {
          NSLog(@"snapshotImage ----- end");
          NSLog(@"snapshotImage ----- %@",snapshotImage);
          NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - [start timeIntervalSince1970];

          NSString *message = [NSString stringWithFormat:@"%f--%f--%@",self.snapshotWidth,duration,snapshotImage];

          UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];

          [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

          }]];

          [self presentViewController:alertController animated:YES completion:nil];
      }];
  }
```

在 iOS 12.4 的设备上，takeSnapshotWithConfiguration 依旧无法获取 PDF 的内容。

```
[self.webView takeSnapshotWithConfiguration:config completionHandler:^(UIImage * _Nullable snapshotImage, NSError * _Nullable error) {
    NSLog(@"takeSnapshotWithConfiguration -- completionHandler %d",i);
    if (error == nil) {
        [DWAppConfig sharedInstance].lastPDFImage = snapshotImage;
    }
}];

if ([DWAppConfig sharedInstance].lastPDFImage) {
		// 绘制特别耗CPU 100%,70ms,会卡
		[[DWAppConfig sharedInstance].lastPDFImage drawInRect:imageRect];
}
```





