---
type : iOS
---

作为开发人员，和脚本打交道是不可避免的。

很多时候，你在界面上点点点，实际上最终转为执行了几条脚本命令。比如说Xcode 编译某个项目就相当于

```
xcodebuild -workspace LearnSwift.xcworkspace -scheme LearnSwift
```

很多图形界面工具都会提供相应的命令来供命令行使用，如Xcode/jenkins，在使用这些工具的时候，实际上就已经在和 Shell 打交道了。

使用 Shell 我们也可以摆脱对图形界面工具的依赖，比如 SourceTree/Versions，有些工具还是收费的，我们完全可以不用这些工具。

借助 Shell 我们将一些繁琐的东西自动化，比如自动打包，或者半自动化如后台接口文档生成模型代码。

### Shell 简介

Linux 的 Shell 种类众多，常见的有：

- Bourne Shell（/usr/bin/sh或/bin/sh）
- Bourne Again Shell（/bin/bash）
- C Shell（/usr/bin/csh）
- K Shell（/usr/bin/ksh）
- Shell for Root（/sbin/sh）
- ……

由于易用和免费，Bash 在日常工作中被广泛使用。同时，Bash 也是大多数Linux 系统默认的 Shell。

在一般情况下，人们并不区分 Bourne Shell 和 Bourne Again Shell,我们这里讨论的是Bash。

创建一个文件test.sh，输入以下内容，最简单的脚本就完成了。 

```
#!/bin/bash
echo "Hello World !"
```

```#!```  告诉系统其后路径所指定的程序即是解释此脚本文件的 Shell 程序。

```
chmod +x ./test.sh #使脚本具有执行权限
./test.sh  #执行脚本
```

或者直接

```
sh test.sh
```

想要了解特定的命令，可以通过 man 来查看文档

```
$ man echo
```

shell 作为一种入口，不管用那种语言写的脚本，都可以用这个入口进行调用,同时，优秀的脚本程序层出不穷，所以，shell 脚本能做的事情非常多，非常有效率。

### 文本处理命令

在日常工作中，我们常用 shell 来处理各种文本，因此，重点介绍一下文本处理相关的命令 

* grep 按行处理  查找特定内容

  * -r 递归搜索
  * -v 输出未匹配的行
  * -i 忽略大小写
  * -c 输出匹配到数量，统计个数时常用到

  ```
  $ cd /Users/xiaoniu/Workspace/XNOnline
  $ grep -r 4006- .
  
  ./XNOnline/XNOnline/Resources/Files/info.json:    "mmnWithdrawDelayTip": "由于网络异常，您的提现结果尚未确认，请稍后在我的网贷-月月牛中查询。如有疑问请拨打客户热线4006-0755-70。",
  ./XNOnline/XNOnline/Resources/Files/info.json:    "mmnInvestDelayTip": "由于网络异常，您的投资结果尚未确认，请稍后在我的网贷-月月牛中查询。如有疑问请拨打客户热线4006-0755-70。",
  ./XNOnline/XNOnline/Resources/Files/info.json:    "flexInvestDelayTipTail": "中查询。如有疑问请拨打客户热线4006-0755-70。",
  ./XNOnline/XNOnline/Resources/Files/info.json:    "flexWithdrawDelayTipTail": "中查询。如有疑问请拨打客户热线4006-0755-70。",
  ./XNOnline/XNOnline/Resources/Files/info.json:    "serviceCall": "4006-0755-70",
  ./XNOnline/XNOnline/Resources/Files/info.json:    "currentWithdrawDelayTip2": "由于网络异常，您的提取结果尚未确认，请稍后在我的网贷-天天牛中的资金详情里查询提取记录。如有疑问拨打客服热线4006-0755-70。",
  ./XNOnline/XNOnline/Resources/Files/info.json:    "investDelayTip2": "由于网络异常，您的投资结果尚未确认，请稍后在我的网贷-天天牛中查询。如有疑问请拨打客户热线4006-0755-70。",
  ```

* awk  按列处理  先按列划分，然后依据表达式进行逐行处理

  * $0 当前行
  * `$1`,` $2`,…,`NF` 第一列，第二列，最后一列
  
  * NR，当前行
  
  账号迁移之后，原账号下添加的设备id得移过来。暂时没有发现可以导出的地方，只能复制网页内容。复制后的内容如下
  
```
	Ganyisou    cccccb6e4854bccccc0f8775f9c6e86e44eccccc
Lineshine   ccccc7c3800bdccccc1af740346213b83b3ccccc
  iPhone      cccccf732dba1d57afccccc87ba30e41fb4ccccc
```

  苹果给的批量添加设备id的格式如下

```
	Device ID   Device Name
A123456789012345678901234567890123456789    NAME1
  B123456789012345678901234567890123456789    NAME2
```


可以看到复制的内容要交换两列的位置才能符合要求。

  ```
  # 交换id.txt的第一列和第二列
  
  $ awk -F " " '{print $2, $1 > "id.txt"}' id.txt
  ```

  ```
  Beth	4.00	0
  Dan	  3.75	0
  kathy	4.00	10
  Mark	5.00	20
  Mary	5.50	22
  Susie	4.25	18
  
  $ awk '$3 >0 { print $1, $2 * $3 }' emp.data
  
  Kathy 40
  Mark 100
  Mary 121
  Susie 76.5
  ```



* sed   按行处理  增删改查。Mac sed 和 Linux sed 有点不一样，网上的教程一般是Linux的需要注意一下，可以改成Linux 风格的 [Mac使用gnu sed](https://blog.csdn.net/sun_wangdong/article/details/71078083)。

  ```
  # 删除第一行

  // d 删除
  // a 追加，新内容在下一行 
  // i 插入，新内容在上一行
  // p 打印，通常 p 会与参数 sed -n 一起运行
// s 替换
  // n 读取下一行到模式空间
// N 追加下一行到模式空间
  
  sed 1d test.txt

  #匹配 删除以//开头的行，也就是删除某些注释
  sed '/^\/\//d' test.txt

  #指定行号 删除1-5行
  sed 1,5d test.txt

  # sed 匹配的时候可以使用正则
$ echo q_00040 | sed 's/0\+//' 
  
  q_40
  
  # 对匹配的内容进行操作，增加@2x
  echo q_00040.png | sed 's/0\+[0-9]*/\0@2x/'
  
  q_00040@2x.png
  
  # 将两行合为一行，输出结果
  sed -n "N;s/\n//;p" test.txt
  ```

### 其他命令

* diff

```
# 比较1.txt和2.txt改动的地方，-a 单做文本文件处理 -b 忽略空格数量引起的变化 -u 格式化输出，git diff
$ diff -abu 1.txt 2.txt
```

* say 使用系统的语音去读文本   

```
$ say 我爱中国
$ say 下班了，去打卡
```

### Xcode Run Script Phase

* env 查看Xcode 设置的环境变量

* Build Number 自增
		
		```
    if [ $CONFIGURATION == Release ]; then
       echo "Bumping build number..."
       plist=${PROJECT_DIR}/${INFOPLIST_FILE}

       #increment the build number (ie 115 to 116)
       buildnum=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${plist}")

       if [[ "${buildnum}" == "" ]]; then
           echo "No build number in $plist"
           exit 2
       fi

       buildnum=$(expr $buildnum + 1)

       /usr/libexec/Plistbuddy -c "Set CFBundleVersion $buildnum" "${plist}"

       echo "Bumped build number to $buildnum"
     else
       echo $CONFIGURATION " build - Not bumping build number."
     fi
	```
	
* Bugly 自动上传dSYMs

* 打包上传时移除第三方库中无用的部分

	```
	# Without further ado, here’s the script. Add a Run Script step to your build steps, put it after your step to embed frameworks, set it to use /bin/sh and enter the following script:

  APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

  # This script loops through the frameworks embedded in the application and
  # removes unused architectures.
  find "$APP_PATH" -name '*.framework' -type d | while read -r FRAMEWORK
  do
  FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable)
  FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"
  echo "Executable is $FRAMEWORK_EXECUTABLE_PATH"

  EXTRACTED_ARCHS=()

  for ARCH in $ARCHS
  do
  echo "Extracting $ARCH from $FRAMEWORK_EXECUTABLE_NAME"
  lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
  EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
  done

  echo "Merging extracted architectures: ${ARCHS}"
  lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}"
  rm "${EXTRACTED_ARCHS[@]}"

  echo "Replacing original executable with thinned version"
  rm "$FRAMEWORK_EXECUTABLE_PATH"
  mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$FRAMEWORK_EXECUTABLE_PATH"

  done
	```

* iOS 修改类的前缀

  ```
echo 'sh file.sh -o 旧的前缀 -n 新的前缀 需要替换的目录'
	while getopts "o:n:" opt; do
    case $opt in
      o)
        oldPrefix=$OPTARG 
        ;;
      n)
        newPrefix=$OPTARG 
        ;;
      \?)
        echo "Invalid option: -$OPTARG" 
        ;;
    esac
  done
  src=${@: -1}
  echo $oldPrefix
  echo $newPrefix
  echo $src
  for file in `find $src -name "${oldPrefix}*"`; do
      # 文件名，包含后缀
      fileName=${file##*/}
      if [[ ! -d $file ]]; then
          # 文件所在目录
          dir=${file%/*}
          # 新的文件名，包含后缀
          nFilePath=${newPrefix}${fileName#${oldPrefix}}
          # 新文件的完整地址
          nPath=${dir}/${nFilePath}
          # 原文件名，不含后缀
          oFileName=${fileName%.*}
          # 新文件名，不含后缀
          nFileName=${newPrefix}${oFileName#${oldPrefix}}
          # 文本替换
          LC_ALL=C sed -i "" "s/$oFileName/$nFileName/g" `grep $oFileName -rl $src`
          # 重命名文件
          mv -v $file $nPath
      fi
  done
  ```
