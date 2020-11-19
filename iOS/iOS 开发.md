## iOS 开发

 

* [苹果全部开源代码](https://opensource.apple.com/tarballs/)

* [objc4源码在线查看](https://opensource.apple.com/source/objc4/)
* [objc4源码下载地址](https://opensource.apple.com/tarballs/objc4/)
* [CFFoundation](https://opensource.apple.com/tarballs/CF/CF-855.17.tar.gz)

### http

项目中用到http方法

> post 参数在请求体重，没有长度限制

> get 参数明文传输，

> put 上传

> head 只是返回head,不返回其他数据，可以用来判断资源是否存在、判断资源是否更新过等，节约流量

### TCP

Q:为什么断开连接要四次？

A:因为收到断开连接请求的时候，可能还有数据要传给对方，必须等数据传完才能断开，所以需要先发ACK，再发FIN

建立连接

1. 主动方发送SYN
2. 被动方收到SYN，发送SYN-ACK请求
3. 主动方收到SYN-ACK，发送ACK

释放连接

1. 主动方发送Fin
2. 被动方收到Fin，发送ACK
3. 被动方发送Fin
4. 主动方收到Fin，发送ACK

### 断点续传

http/1.1 提供的功能。一般服务器告诉你content-Length,客户端可以指定下载的range。

在 iOS 中，可以通过 NSURLSession 来实现断点续传。
resume data 其实就是一个plist文件，包含了下载需要的相关信息。

```
<plist version="1.0">
	<dict>
		<key>NSURLSessionDownloadURL</key>
		<string>http://wwww.xxxx.file</string>
		<key> NSURLSessionResumeBytesReceived</key>
		<integer>12505822</integer>
		<key>NSURLSessionResumeCurrentRequest</key>
		<data>YnBsaXsdjfafkafklasfadlfakdfsf</data>
		...
	</dict>
</plist>


```

```
// NSURLSession.m

/* Creates a download task with the resume data.  If the download cannot be successfully resumed, URLSession:task:didCompleteWithError: will be called. */
- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData;
```

```
// AFURLSessionManager.m

/**
 Creates an `NSURLSessionDownloadTask` with the specified resume data.

 @param resumeData The data used to resume downloading.
 @param progress A progress object monitoring the current download progress.
 @param destination A block object to be executed in order to determine the destination of the downloaded file. This block takes two arguments, the target path & the server response, and returns the desired file URL of the resulting download. The temporary file used during the download will be automatically deleted after being moved to the returned URL.
 @param completionHandler A block to be executed when a task finishes. This block has no return value and takes three arguments: the server response, the path of the downloaded file, and the error describing the network or parsing error that occurred, if any.
 */
- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                                progress:(NSProgress * __nullable __autoreleasing * __nullable)progress
                                             destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                       completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * __nullable filePath, NSError * __nullable error))completionHandler;


```

### 构架

### MVVM 如何实现绑定

kvc & kvo

### 进程 & 线程

一个应用程序一般只有一个进程，一个进程可以有多个线程。

进程：需要分配独立进程号、地址空间等，开销大
线程：一个进行可以有多个线程，切换需要使用硬件资源
协程：一个线程可以有多个协程，切换由软件层面实现，不需要使用硬件资源

>进程通信方式？

1. 共享存储
	相互通讯的进程有共享存储区.进程间可以通过直接读写共享存储区的变量来交互数据，同步与互斥在并发程序设计时安排进入程序。操作系统提供这样的共享存储区及同步互斥工具。

2. 消息传递


3. 管道通信
