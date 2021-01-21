# iOS

Xcode和Mac系统最好一起升级，否则可能会出各种奇怪的Bug。



### 源码地址

* [苹果开源代码](https://opensource.apple.com/tarballs/)]
* [objc4](https://opensource.apple.com/tarballs/objc4/)
* [CFFoundation](https://opensource.apple.com/tarballs/CF/CF-855.17.tar.gz)
* [libdispatch](https://opensource.apple.com/tarballs/libdispatch/)
* [dyld](https://opensource.apple.com/tarballs/dyld/)

### 工具

* [LLDB commands collection Chisel](https://github.com/facebook/chisel)

* [FLEX](https://github.com/Flipboard/FLEX)

* [Reveal](https://revealapp.com)

* [iOS App Signer]()

* [Charles]()

  

### 深度阅读

[Swizzling in iOS 11 with UIDebuggingInformationOverlay](https://www.raywenderlich.com/295-swizzling-in-ios-11-with-uidebugginginformationoverlay)

[神经病院objc runtime入院考试](https://blog.sunnyxx.com/2014/11/06/runtime-nuts/)

[视音频技术笔记](https://blog.csdn.net/leixiaohua1020)

[美团技术团队](https://tech.meituan.com/archives)

[swift tips](https://swifter.tips)

[戴铭的博客](https://ming1016.github.io)

[sunnyxx的博客](https://blog.sunnyxx.com)

[开源框架源代码解读](https://github.com/draveness/analyze)

### 术语

* 超级签名：个人账号或者公司账号可以安装设备的限制是100个，不管有多少个不同的App。如果用户想要安装某个App,获取用户设备id后，查询一下这个设备是否已经添加到了某个开发者账号，如果已经加了，就可以用这个账号打一个包给他安装，如果不属于任何账号，添加这个设备到某个账号下再打包让他安装，后续如果这个用户要安装其他的App,就可以使用已有的账号给他安装。假设有10个账号就可以支持1000台设备，但能支持多少App就要看设备安装的App有没有重合的部分。像蒲公英这种分发平台，可以让不同客户的App用同一个账号安装给一个设备，这样维护每个账号的成本就会很低。

  