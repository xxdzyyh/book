# iOS 更新日志



## dev



v1.3.2

* 更新

  * 设置为动态库，使用 xcframework 进行分发

  * 时间线添加应用进入前台、后台、becomeactive、resignactive

  * 视频回放数据采集可以设置为界面刷新后获取一帧数据，默认每秒获取一次数据

  * 会话在 App 进入后台时不会立即结束，默认在后台持续时间达到 30s 结束

    

* Bug 修复
  * 应用在任务管理器里闪烁
  * \+ (NSURLSession *)sessionWithConfiguration:delegate:delegateQueue: 网络数据没有采集到



## release



