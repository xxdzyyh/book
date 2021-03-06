
* 平台：Mac OS
* 工具：脚本编辑器
* [AppleScript 帮助](https://help.apple.com/applescript/mac/10.9/)
* [Introduction to AppleScript Language Guide](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/introduction/ASLR_intro.html)

### 常用语句

> hello world

```shell
say "hello world"
beep 2
```

> 变量

```shell
set a to {1, 2}
# 此处报错，a不能转成字符串
say a
```

> dialog

```shell
set message to "Dialog Message"
set temp to display dialog message buttons {"OK", "Cancel"}
set selectedTitle to button returned of temp
display dialog "You pressed the following button " & selectedTitle
```
![dialog_1](https://upload-images.jianshu.io/upload_images/1324053-2fc7aba2f03bfddf.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/620)

![dialog_2](https://upload-images.jianshu.io/upload_images/1324053-3982521bc6898b98.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/620)

>清空废纸篓

```shell
tell application "Finder"
	empty trash
end tell
```

>列表选择器

```shell
choose from list {"dawei", "libai", "lilei"} with title "名字选择器" with prompt "请选择名称" default items {"lilei"} with empty selection allowed and multiple selections allowed
```

![自定义内容选择.png](https://upload-images.jianshu.io/upload_images/1324053-1bb7ded49fc47087.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/620)

文件选择器

```shell
# choose folder 选择文件夹
choose file of type ("txt") with prompt "选取文件"
```
![文件选择器](https://upload-images.jianshu.io/upload_images/1324053-91bd6fb9bb04fe30.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


## AppleScript 和 shell 交互

### 相互调用

> AppleScript 调用shell

```sh
do shell script "cd ~;ls"
```

> shell 调用 AppleScript

```shell
# osascript -e "语句"
finder=`osascript -e "set dir to POSIX path of (choose folder with prompt \"选择一个文件夹\")"`
# 输出结果/Users/xiaoniu/Documents/XXXX/
echo $finder

/** 
	osascript <<EOF
	语句
	EOF
 */

echo "shell 调用 AppleScript start"

path=`pwd`
osascript <<EOF
set a to  POSIX file "$path"
tell application "Finder"
	open folder a
end tell
EOF

# 这里注意一下传值问题，path是shell里面的变量，作为参数传个osascript语句，加了"".

echo "
```

### 传值

>AppleScript -> shell

如果是字符串，可以直接使用 & 进行拼接。

```shell
set hostname to "www.baidu.com"

do shell script "ping -c1 " & hostname
```

更通用的是 quoted form of

```shell
# quoted form of
set hostname to "www.baidu.com"

do shell script "ping -c1 " & quoted form of hostname
```

> shell -> AppleScript

```shell
path=`pwd`
osascript <<EOF
set a to  POSIX file "$path"
```
![shell 调用 AppleScript](https://upload-images.jianshu.io/upload_images/1324053-a8805b7af6659e25.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/620)

很多时候，shell 需要获取Apple Script的执行结果，获取方式如下

```shell
finder=`osascript -e "set dir to POSIX path of (choose folder with prompt \"选择一个文件夹\")"`
# 输出结果/Users/xiaoniu/Documents/XXXX/
echo $finder
```

> 路径转换

```shell
set p to "/usr/local/bin/" 
set a to POSIX file p 
   -- file "Macintosh HD:usr:local:bin:"

To translate an AppleScript path (file or directory, valid or not) into a POSIX path use POSIX path of.

set a to "Macintosh HD:usr:local:bin:" 
set p to POSIX path of a 
   -- "/usr/local/bin/"
```


