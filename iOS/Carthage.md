## Carthage
Cocoapods 的功能非常强大，设计到 iOS 第三方依赖的方方面面。

Carthage 相对比较简单，只是负责下载framework代码，然后使用xcodebuild命令编译出framework。


### Carthage 安装

$ brew install carthage

### 使用

Cocoapods要创建 Podfile, Carthage 也需要创建 Cartfile,Cartfile 和 Podfile 作用类型，描述依赖的第三方,之后 update

1. 创建Cartfile

	```
	vi Cartfile
	
	github 'xxdzyyh/XFSweetAlert' // 默认取最近一个 tag 的代码，没有tag会失败
	```

2. carthage update 

	```
	$ carthage update
	
	*** Fetching XFSweetAlert
	*** Checking out XFSweetAlert at "0.0.5"
	*** xcodebuild output can be found in /var/folders/tm/894_j49d0ds4b6k1vntmjxnh0000gn/T/carthage-xcodebuild.hu055I.log
	*** Building scheme "SweetAlert" in XFSweetAlert.xcodeproj
	
	$ ls
	
	Cartfile
	// 下载的文件存放在 Carthage 文件夹下面
	Carthage   
	Cartfile.resolved
	
	```
3. 将 framework 拖到项目中
4. 在target中 New Run Script Phase,添加一个 /bin/sh  脚本
	```
	/usr/local/bin/carthage copy-frameworks
	```

	Add the paths to the frameworks you want to use under “Input Files". For example:

	```
	$(SRCROOT)/Carthage/Build/iOS/Result.framework
	$(SRCROOT)/Carthage/Build/iOS/ReactiveSwift.framework
	$(SRCROOT)/Carthage/Build/iOS/ReactiveCocoa.framework
	```
	
	Add the paths to the copied frameworks to the “Output Files”. For example:

	```
	$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/Result.framework
	$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/ReactiveSwift.framework
	$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/ReactiveCocoa.framework
	```
	
	因为要提交App Store,framework不能是 universal binaries，framework的 dSYMs 也需要被关联，所以添加这个脚本.
	
### 使用 Carthage 添加自己的framework

使用Cocoapods时，我们需要在项目下面添加一个 xxx.podspec，这样Cocoapods 通过解析 xxx.podspec 来获取相应的代码和资源。

使用 Carthage 时，我们不需要添加一个这样的文件，但是需要保证项目中有一个 shared framework shecme，也就是项目有一个framework target，如果项目最初的 target 不是 framework 类型，可以新建一个 framework。


	
