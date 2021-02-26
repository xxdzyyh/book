## 150行代码搞定Jenkins自动打包

打包是一个没有技术含量但却非常重要的事情，测试人员的工作直接依赖打包结果，如果没有处理好，可能会占用开发人员大量的时间。怎么才能够做好打包这个事情呢？答案就是使用jenkins自动打包。

Jenkins 功能非常强大，也非常灵活，同一个需求往往可以使用不同的方式去实现,有的简单,有的可能相对复杂,这里给大家分享快速解决方案。

### 目标

1. 自动拉取**指定分支**的**最新代码**
2. 可以设置打包的环境Debug/Release、以及域名
3. 导出 ipa
4. 上传 ipa 到svn
5. 发送邮件给指定的人员

### Step 1 更新代码

>获取分支

在打包的时候，可以选择特定分支来打包。

1. 参数化构建过程

2. Extended Choice Parameter -> name = version

3. Base Parameter Types -> Single Select

4. Groovy Srcipt

5. 使用命令动态获取项目分支信息

   ```
   # cut -b 56- 这个56是依据项目实际情况来的
   def command = [ 'bash', '-c', 'git ls-remote 项目git地址 | grep refs/heads/BF | cut -b 56- | sort -r']
   command.execute().text.tokenize('\n')
   ```

后续步骤可以使用 $version 来获取选择的分支

![屏幕快照2019-06-10上午9.48.20.png](https://i.loli.net/2019/06/10/5cfdb6f17856586036.png)



> 获取代码

自由风格的项目有一个 Source Code Management，填写一下项目信息就可以。如果不指定workspace，这个会将代码clone到某个位置，用$WORKSPACE可以查看这个地址。相对于直接使用git命令,使用 Source Code Management 有两个主要优点，一个优点是可以在打包后看到git提交信息，让打包人员知道这一个包相对于上一个包改了什么，第二个优点是可以保证workspace是干净的，不会出现因为代码当前的问题导致获取更新失败的情况。因此这里使用  Source Code Management.

![Source Code Management](https://i.loli.net/2019/06/10/5cfdb6283b1c996917.png)



### Step 2 设置环境和域名

添加一个选择参数，让打包人员可以选择环境,后续可以使用 $configuration 来获取打包人员选择的值，默认是Debug。

![屏幕快照2019-06-20上午11.36.06.png](https://i.loli.net/2019/06/20/5d0aff9631d8b46639.png)

添加一个文本参数,可以设置包使用的域名,后续可以使用 $environment 来或者打包人员输入的值,注意给一个默认值,这样如果和默认值一样,打包人员可以不需要输入.

![屏幕快照2019-06-20上午11.36.44.png](https://i.loli.net/2019/06/20/5d0b005b9619c71697.png)



设置 environment 后,我们需要将这个值和代码关联起来.

```
# 将环境变量写入文件
urlfile="$WORKSPACE/BFMoney/BFMoney/Classes/Macro/URLMacro.h"
sed -i '' "s/#define BF_URL_SCHEME\(.*\)/#define BF_URL_SCHEME @\"http:\/\/$environment\/mobile\/\"/" $urlfile
```

这里通过 sed 命令将 environment 的值替换项目中写好的值。



> Jenkins 预置了多种类型的参数，使用与不同的场合，记得为你的参数选取合适的类型。



### Step 3 导出ipa

经过了step1/step2,准备工作已经完成了,这一步导出ipa,也就是打包的结果.

导出ipa主要的两步是

* 生成archive
* archive导出ipa

这里development.plist是每次生成，实际也可以直接读取某个文件。

```
cat >  ~/Desktop/development.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>teamID</key>
	<string>ZWCLX6R5R6</string>
	<key>method</key>
	<string>development</string>
	<key>compileBitcode</key>
	<false/>
	<key>uploadSymbols</key>
	<false/>
	<key>provisioningProfiles</key>
	<dict>
		<key>$bundleid</key>
		<string>com.xiaoniu88.XNOnline_Development</string>
        <key>$bundleid1</key>
		<string>com.xiaoniu88.XNOnline_Development</string>
	</dict>
</dict>
</plist>
EOF

xcodebuild clean -configuration $configuration -alltargets

# 生成 archive 文件
xcodebuild -workspace BFMoney.xcworkspace -scheme BFMoney -archivePath "${archiverpath}" -configuration $configuration archive

# 导出 ipa
xcodebuild -exportArchive -archivePath "${archiverpath}"  -exportPath "${dir}"  -exportOptionsPlist ~/Desktop/development.plist
```

### Step 4 上传到SVN

这一步将上一步的ipa 上传到SVN。

主要的两条命令是 ```svn add file``` 和```svn commit -m "commit message"```.

```
# svn 
cd $svndir

if [[ -d ./$version ]]; then	
	#目录存在
	echo "file"
else
	#目录不存在
	mkdir $version

	# 提交目录
	svn add $version
	svn commit -m "mkdir $version"
fi

cd $version

if [[ -d ./$environment ]]; then	
	#环境目录存在
	echo "file"
else
	mkdir $environment
	svn add $environment
	svn commit -m "mddir $environment"
fi

timestr=`date +%Y%m%d%H%M%S`
mkdir $environment/$timestr
svn add $environment/$timestr
svn commit -m "mddir $timestr"

mv $dir/BFMoney.ipa $svndir/$version/$environment/$timestr/
svn add $environment/$timestr/BFMoney.ipa
svn commit -m "$timestr"

# 移除打包中间产物
rm -rf $dir
```

### Step 5 发送邮件

首先我们通过一个文本参数来获取收件人

![屏幕快照2019-06-20上午11.37.02.png](https://i.loli.net/2019/06/20/5d0b00723eedd69723.png)

后续可以使用 $recipients 来获取这个值，这个值是一个数组，每一行是数组的一个元素，比如输入 ```wangxuefeng2@xiaoniu66.com```,则 \$recipients = (wangxuefeng2@xiaoniu66.com)

前面我们一直使用的bash，发送邮件，为了方便，我们将使用 AppleScript。虽然AppleScript的语法看起来非常的奇怪，但是AppleScript可以充分发挥Mac应用的能力。

```
######################## 发送邮件 ####################################

if [[ -n $recipients ]]; then
	# 填写了邮箱地址
	remoteUrl="http://172.20.21.1/svn/documents/AppDocuments/Zhuanqian/%E5%BC%80%E5%8F%91/IOS/IPA"/$version/$environment/$timestr/BFMoney.ipa
	str=${recipients[*]}

osascript <<EOF

--Variables
set recipientName to "BFMoney"
set theSubject to "BFMoney" & "$version" & "打包结果通知"
set theContent to "本次构建分别产生了以下iOS安装包:\n打包环境：" & "$environment" & "\n 下载地址：" & "$remoteUrl"

set oldDelimiters to AppleScript's text item delimiters --记录开始的去限器
set AppleScript's text item delimiters to " " --设置分隔符
set str4Arr to every text item of "$str" -- 分割
set AppleScript's text item delimiters to oldDelimiters -- 恢复原来的去限器
get str4Arr --获取数组

--Mail Tell Block
tell application "Mail"
	
	--Create the message
	set theMessage to make new outgoing message with properties {subject:theSubject, content:theContent, visible:true}
	
	--Set a recipient
	tell theMessage

		repeat with re in str4Arr
			make new to recipient with properties {name:recipientName, address:re}
		end
		
		--Send the Message
		send
		
	end tell
end tell

EOF

fi
```

如果输入了邮箱，就会给对应的邮箱地址发送邮件，否则不会发送邮寄。

### 结语

经过上面的几个步骤，整个jenkins自动打包就完成，最后的build在包括注释和空行的情况下，还是控制在150行以内。

这里最后说一下几个需要注意的地方：

1. 为每一个步骤编写单独的脚本，可以单独验证这些步骤,这样可以快速测试改动的效果
2. 因为这些命令依赖还是比较多的，所以先确保在不使用jenkins的情况下，这些步骤能够正常运行，然后再集成到jenkins中
3. 建议jenkins每添加一个步骤，就进行一次build,来确保当前步骤没有问题







