---
type : Android
---



## Activity 生命周期

### onCreate

在 activity 被创建时调用，完成初始化操作。通过 setContentView 加载界面，设置控件引用等等，相当于iOS 

Init ——— ViewDidLoad 这段时间要处理的事情。

### onStart

此时Activity已经准备好了，只是还没有在前台显示，因此无法与用户进行交互。相当于iOS viewWillAppear。

### onResume

Activity 已经显示了，用户可以与之交互。相当于iOS viewDidAppear。

### onPause

Activity即将停止，一般会立即调用onStop,但是有些场合比如用户将Activity退到后台又立即切到前台,可能会立即调用onResume,相当于iOS viewWillDisappear。

### onStop

此时Activity已不可见，仅在后台运行，相当于iOS viewDidDisappear。

### onRestart

一般是用户打开了一个新的Activity时，当前的Activity就会被暂停（onPause和onStop被执行了），接着又回到当前Activity页面时，onRestart方法就会被回调。 iOS 没有对应的状态



![生命周期](https://github.com/xxdzyyh/static/blob/8647a4129ac0a666923d98fff029acafa703a992/android/20160717151833576.png?raw=true)





