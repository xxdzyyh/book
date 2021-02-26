项目在更换后台环境后需要重新编译整个项目，没有办法利用 xcode 编译缓存，导致每次切换环境后编译时间特别长。

分析项目配置后，发现定义后台环境的变量的文件 URLMacro.h 被间接包含在项目的pch文件中，导致这个文件被所有文件包含，一旦改动URLMacro.h，所有的文件都需要重新编译。因此需要将 URLMacro.h 从 pch 文件中移除。

头文件导入关系如下：

```
-- pch  
	-- AppMacro.h
	  -- URLMacro.h
	  -- ThirdPartKeyMacro.h
	  	 -- URLMacro.h
```

在 URLMacro.h 和 ThirdPartKeyMacro.h 中定义了不少的宏，将这两个文件移出pch后，用到这两个文件中的宏的文件需要自行导入相应的头文件。要确保所有用到这些宏的文件导入了对应的头文件，可以通过xcode一个一个检索哪些文件使用这些宏，这样会比较麻烦，我们可以用shell脚本来做这个事情。

### 用到的 shell 命令

> grep

针对给定的内容，对文件进行逐行搜索

> awk

对文本文件进行按列处理

> uniq

对相邻的重复行进行去重

> sort

对文件进行按行排序

### check_macro.sh

```
path=$1
rm ~/Desktop/result.txt
rm ~/Desktop/result1.txt

workspace='/Users/xiaoniu/Workspace/XNOnline/XNOnline/XNOnline'
	
for i in `grep ^#define $path | awk '{print $2}' | uniq`; do
	echo $i
	
	for j in `grep -r "$i" "$workspace" | awk -F ':' '{print $1}'`; do
		echo $j >> ~/Desktop/result.txt
	done
done
	
sort ~/Desktop/result.txt | uniq > ~/Desktop/result1.txt 
```

调用 

```
sh check_marco.sh /Users/xiaoniu/Workspace/XNOnline/XNOnline/XNOnline/Macro/ThirdPartKeyMacro.h 

cat result1.txt 
/Users/xiaoniu/Workspace/XNOnline/XNOnline/XNOnline/AppDelegate/XNOAppDelegate.m
/Users/xiaoniu/Workspace/XNOnline/XNOnline/XNOnline/General/Classes/APNSManager/XNOAPNSManager.m
/Users/xiaoniu/Workspace/XNOnline/XNOnline/XNOnline/General/Classes/CustomerServiceIM/XNOCustomerServiceIM.m
/Users/xiaoniu/Workspace/XNOnline/XNOnline/XNOnline/General/Classes/TYStatisticUtils/Core/XNOTYStatisticHelper.m
/Users/xiaoniu/Workspace/XNOnline/XNOnline/XNOnline/LoanModule/IdentityAuthentication/VC/XNOBindBankCardVC.m
/Users/xiaoniu/Workspace/XNOnline/XNOnline/XNOnline/LoanModule/IdentityAuthentication/VC/XNORealNameVerifiedVC.m
/Users/xiaoniu/Workspace/XNOnline/XNOnline/XNOnline/Macro/ThirdPartKeyMacro.h
/Users/xiaoniu/Workspace/XNOnline/XNOnline/XNOnline/Vendors/STCardLib/STAPIAccountInfo.h
/Users/xiaoniu/Workspace/XNOnline/XNOnline/XNOnline/main.m
```

也就是这9个文件包含了 ThirdPartKeyMacro.h 中定义的宏，ThirdPartKeyMacro.h 本身是不用导入的，所以可以剔除。
依次导入头文件后，可以使用下面的语句进行检查

```
for path in `awk '{print $1}' result1.txt`; do
  grep -q '#import "ThirdPartKeyMacro.h"' $path
  if [[ $? == 0 ]]; then
  	echo "$path has import ThirdPartKeyMacro.h"
  else
  	echo "!!! $path has not import ThirdPartKeyMacro.h !!!"
  fi
done;

```

对于 URLMarco.h 执行同样的操作即可。






