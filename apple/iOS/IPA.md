## IPA



### 重签名

使用 `fastlane sigh resign xaLive.ipa --signing_identity "674D18BAF901D5790B1755494AEE34B20BB95706" -p 



### 安装

有时候 ipa 安装不上（常见于重签名的ipa），可以使用`ideviceinstaller -i myApp.ipa` 去安装ipa,可以获取到更多的信息。

```
brew install ideviceinstaller   
ideviceinstaller -i myApp.ipa
```

