
### 键盘设置

有时候command在空格两边，有时候alt在空格两边，可以在系统偏好设置 - 键盘 - 右下角修饰键 自己换一下 command 和 Option 就行了 .


### 隐藏文件

```
// 始终显示隐藏文件
defaults write com.apple.finder AppleShowAllFiles -boolean true; killall Finder
// 不显示隐藏文件
defaults write com.apple.finder AppleShowAllFiles -boolean false ; killall Finder
```


