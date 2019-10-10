不想偷懒的程序员不是好程序员，而使用shell脚本就是一种非常正确的偷懒方式。

shell脚本编写还是比较简单的，很多看似复杂的功能使用几条简单的命令就可以搞定。

很多有规律的一些列的操作都可以使用一个脚本来替代，比如自动打包、检查打卡情况等等。

也可以使用shell来制作一些工具，比如直接将接口返回的json转成model代码。

这个功能使用一条awk命令就可以实现，非常实用。

```
awk -F '"' '{
	if ($2 > 0) {
	 	 if ($4 > 0) {
			print "@property (nonatomic, copy) NSString *"$2";";
		 } else {
		 	print "@property (nonatomic, strong) NSNumber *"$2";";
		 }
	}
}' $1
```

