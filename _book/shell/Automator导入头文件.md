---
type : other
---





插件计划功能

1. 选择文本后，分析文本中的类，导入这些类

2. 如果选择文本长度为0，弹出输入框，让用户输入类名，可以输入多个类名

先实现第一步：选择类名，然后导入这个类^-^。

### ### 实现

1. 获取选中文本
2. 将导入语句写入文件

第一步可以很容易，在 Automator 里创建一个“快速操作”，设置工作流程收到当前 “文本” 位于 “xcode”。

第二步就麻烦一些，Automator 没有直接获取选中的文本所在的文件的路径的办法，因此转化一下思维，将目标设定为获取Xcode当前编辑的文件，这个通过AppleScript应该是可以办到的。

获取这个文件路径可以这么做，在快速操作中添加一步 “运行AppleScript”

```
on run {input, parameters}
	(* Your script goes here *)
	set filePath to ""
	tell application "Xcode"
		set CurrentActiveDocument to document 1 whose name starts with (word 1 of (get name of window 1))
		set filePath to path of CurrentActiveDocument
	end tell
	return filePath
end run
```

有了文本和文件地址，后面的工作就容易了。

```
path="$1"
fileName=$(echo $path | awk -F "/" '{print $NF}')
className=$(echo $fileName | awk -F "." '{print $1}')

importString="#import \"$2.h\""

if [[ $fileName =~ .*\.m ]]; then
	if grep -q "@interface $className()" $1 ; then
		#如果有Extension，查到extension前面
		sed -i "/@interface $className()/i$importString" $1
	else 	
		sed -i "/@implementation $className/i$importString" $1
	fi
else
	if grep -q "NS_ASSUME_NONNULL_BEGIN" $1 ; then
		/usr/local/opt/gnu-sed/libexec/gnubin/sed -i "/NS_ASSUME_NONNULL_BEGIN/i$importString" $1
	else
		/usr/local/opt/gnu-sed/libexec/gnubin/sed -i "/@interface $className/i$importString" $1
	fi
fi
```

现实还是会有些问题。如果通过其他方式修改Xcode正在编辑的文件，Xcode会弹一个框，非常头疼，这个还不知道怎么解决，要摸索一下。



