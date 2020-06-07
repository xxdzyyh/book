## Cocoapods

### pod update  & pod install

update 和 install 的区别关键在于处理Podfile.lock的方式。Podfile.lock记载了通过cocoapods添加的依赖的版本信息，包括版本号和哈希值。

* pod install 

  依据Podfile.lock记载的信息去添加依赖，如果没有Podfile.lock，就读取Podfile相关的信息，下载依赖然后依据下载的版本创建Podfile.lock。

* pod update 

  直接忽略Podfile.lock记载的信息，依据Podfile的描述下载最新的,然后更新Podfile.lock。



### pod outdated

pod outdated 用来查看哪些库可以更新,并不会直接更新项目，需要更新的话可以配合 `pod update PODNAME`来使用。 

```
$ pod outdated                

...
The following pod updates are available:
- AliAuthSDK 2.0.0.1 -> 2.0.0.1 (latest version 2.0.0.3)
- AlibcTradeSDK 4.0.0.0 -> 4.0.0.0 (latest version 4.0.0.9-wk)
- AliLinkPartnerSDK 2.0.0.0 -> 2.0.0.0 (latest version 4.0.0.24)
- BCUserTrack 5.2.0.1-appkeys -> 5.2.0.1-appkeys (latest version 5.2.0.11-appkeys)
- IGListKit 2.1.0 -> 2.1.0 (latest version 4.0.0)
- IQKeyboardManager 6.2.1 -> 6.2.1 (latest version 6.5.4)
- JXCategoryView 1.5.0 -> 1.5.2 (latest version 1.5.2)
- MJRefresh 3.2.0 -> 3.3.1 (latest version 3.3.1)
- ReactiveObjC 3.1.0 -> 3.1.0 (latest version 3.1.1)
- SDCycleScrollView 1.65 -> 1.65 (latest version 1.80)
- SDWebImage 3.7.3 -> 3.7.3 (latest version 5.4.0)
- securityGuard 5.4.172 -> 5.4.172 (latest version 5.4.173)
- TZImagePickerController 3.2.2 -> 3.2.8 (latest version 3.2.8)
```

