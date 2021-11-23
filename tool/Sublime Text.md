# Sublime Text



[TOC]

## Shift + Command + P

通过 Shift + Command + P 可以完成 Sublime Text 大部分功能，安装的插件，也可以通过这种方式调用。



### 查找文件

cmd + p



## PrettyJSON



插件安装后，可以通过 command + shift + p ，搜索插件进行调用



修改快捷键。

Sublime -> Perferences -> Key Bindings ,在右侧的空白添加自己的快捷键就可以了。 



```
[
	{
    	"keys": [
      	  "ctrl+command+j"
    	], 
    	"command": "pretty_json"
	}
]
```



修改成功后， command + shift + p 找到对应的插件，会显示对应的快捷键。


## Hex Viewer

安装之后，通过 Tools -> Package -> HexViewer -> Toggle Hex View 提取二进制中可阅读部分。
