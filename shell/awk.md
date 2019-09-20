---
type : other 
---

[TOC]

很多时候，我们需要对文本进行按列处理，比如调换两列的位置又或者求几列之和，这个时候，我们可以使用awk命令。

### 基础用法

- $0 当前行
- `x$1`,` $2`,…,,`$NF` 第一列，第二列，最后一列
- NR，当前行

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

### awk 数组

```
awk 'BEGIN{	
  huluwa[1]="大娃";
  huluwa[2]="二娃";
  huluwa[3]="三娃";
  huluwa[4]="四娃";
  for(i=1;i<=4;i++) {
    print i,huluwa[i]
  }
}'
1 大娃
2 二娃
3 三娃
4 四娃

awk 'BEGIN{
  huluwa["yiwa"]="大娃";
  huluwa["erwa"]="二娃";
  huluwa["sanwa"]="三娃";
  huluwa["siwa"]="四娃";
  for(i in huluwa) { 
    print i,huluwa[i]
  } 
}'
siwa 四娃
yiwa 大娃
erwa 二娃
sanwa 三娃
```

### 匹配

### awk 与 shell 相互传值

> awk 使用 shell 定义的变量

```
path=$1
awk '{
	# 注意加入结束条件，不然死循环
	if (NR == 1) {
		print "我是变量" >> "'$path'" 
	}
}' $1
```

> shell 使用 awk 定义的变量

awk 的值本来是没有办法传递给外界的，但是还是有一些套路的，借助套路可以实现。

看一下下面的语句

```
eval $(echo "var=qqqq")
echo $var  
qqqq
```

在awk中，我们可以使print或者prinf输出类似 var=xxx 的语句，然后，用 eval 拦截输出，后面就可以直接使用var了

```
path=$1

var=$(awk 'BEGIN {
	localVar="哈哈";
	print "outvar="'localVar'"";
}' $1)

eval $var
echo $outvar
```

```
$ sh AwkShellCommunication.sh 22.txt

哈哈
```

### awk 调用 shell 命令

> system()

```
# awk程序中我们可以使用system() 函数去调用shell命令
$ awk 'BEGIN{system("echo abc")}' file
$ awk 'BEGIN{v1="echo";v2="abc";system(v1" "v2)}'
abc
```

> print 

```
awk 'BEGIN{print "echo","abc"| "/bin/bash"}'
```

如果命令是自定义函数

```
#!/bin/bash
a(){
	echo "hello admin";
}
# 创建函数后只需要设置成全局函数就可以直接使用awk的两种方式调用了
export -f a
awk 'BEGIN{"a"|getline test;print test }'
awk 'BEGIN{system("a")}'
```



### 内置函数


转：[http://www.cnblogs.com/chengmo/archive/2010/10/08/1845913.html](http://www.cnblogs.com/chengmo/archive/2010/10/08/1845913.html)

 

这节详细介绍awk内置函数，主要分以下3种类似：算数函数、字符串函数、其它一般函数、时间函数

 

**一、算术函数****:**

以下算术函数执行与 C 语言中名称相同的子例程相同的操作：

| **函数名**      | **说明**                                                     |
| --------------- | ------------------------------------------------------------ |
| atan2( y, x )   | 返回 y/x 的反正切。                                          |
| cos( x )        | 返回 x 的余弦；x 是弧度。                                    |
| sin( x )        | 返回 x 的正弦；x 是弧度。                                    |
| exp( x )        | 返回 x 幂函数。                                              |
| log( x )        | 返回 x 的自然对数。                                          |
| sqrt( x )       | 返回 x 平方根。                                              |
| int( x )        | 返回 x 的截断至整数的值。                                    |
| rand( )         | 返回任意数字 n，其中 0 <= n < 1。                            |
| srand( [Expr] ) | 将 rand 函数的种子值设置为 Expr 参数的值，或如果省略 Expr 参数则使用某天的时间。返回先前的种子值。 |

 

**举例说明：**

```
$ awk 'BEGIN{OFMT="%.3f";fs=sin(1);fe=exp(10);fl=log(10);fi=int(3.1415);print fs,fe,fl,fi;}'
0.841 22026.466 2.303 3
```





 

OFMT 设置输出数据格式是保留3位小数

**获得随机数：**

[chengmo@centos5 ~]$ awk 'BEGIN{srand();fr=int(100*rand());print fr;}'
78
[chengmo@centos5 ~]$ awk 'BEGIN{srand();fr=int(100*rand());print fr;}'
31
[chengmo@centos5 ~]$ awk 'BEGIN{srand();fr=int(100*rand());print fr;}'

41

 

二、字符串函数是：

| **函数**                                              | **说明**                                                     |
| ----------------------------------------------------- | ------------------------------------------------------------ |
| gsub( Ere, Repl, [ In ] )                             | 全局替换，除了正则表达式所有具体值被替代这点，它和sub 函数完全一样地执行，。 |
| sub( Ere, Repl, [ In ] )gensub(Ere, Repl, h, [In])    | sub:第一次出现的替换，用 Repl 参数指定的字符串替换 In 参数指定的字符串中的由 Ere 参数指定的扩展正则表达式的第一个具体值。sub 函数返回替换的字符数量。出现在 Repl参数指定的字符串中的 &（和符号）由 In 参数指定的与Ere 参数的指定的扩展正则表达式匹配的字符串替换。如果未指定 In 参数，缺省值是整个记录（$0 记录变量）。gensub:类似于sub，但是h参数可以控制替换的位置,g/G全局替换，h为数字表示替换第几次出现的位置，具体查看man awk |
| index( String1, String2 )                             | 在由 String1 参数指定的字符串（其中有出现 String2 指定的参数）中，返回位置，从 1 开始编号。如果 String2参数不在 String1 参数中出现，则返回 0（零）。 |
| length [(String)]                                     | 返回 String 参数指定的字符串的长度（字符形式）。如果未给出 String 参数，则返回整个记录的长度（$0 记录变量）。 |
| blength [(String)]                                    | 返回 String 参数指定的字符串的长度（以字节为单位）。如果未给出 String 参数，则返回整个记录的长度（$0 记录变量）。 |
| substr( String, M, [ N ] )                            | 返回具有 N 参数指定的字符数量子串。子串从 String 参数指定的字符串取得，其字符以 M 参数指定的位置开始。M参数指定为将 String 参数中的第一个字符作为编号 1。如果未指定 N 参数，则子串的长度将是 M 参数指定的位置到String 参数的末尾 的长度。 |
| match( String, Ere )**可以使用'~'****$0 ~ /partern/** | 在 String 参数指定的字符串（Ere 参数指定的扩展正则表达式出现在其中）中返回位置（字符形式），从 1 开始编号，或如果 Ere 参数不出现，则返回 0（零）。RSTART特殊变量设置为返回值。RLENGTH 特殊变量设置为匹配的字符串的长度，或如果未找到任何匹配，则设置为 -1（负一）。 |
| split( String, A, [Ere] )                             | 将 String 参数指定的参数分割为数组元素 A[1], A[2], . . ., A[n]，并返回 n 变量的值。此分隔可以通过 Ere 参数指定的扩展正则表达式进行，或用当前字段分隔符（FS 特殊变量）来进行（如果没有给出 Ere 参数）。除非上下文指明特定的元素还应具有一个数字值，否则 A 数组中的元素用字符串值来创建。 |
| tolower( String)                                      | 返回 String 参数指定的字符串，字符串中每个大写字符将更改为小写。大写和小写的映射由当前语言环境的LC_CTYPE 范畴定义。 |
| toupper( String )                                     | 返回 String 参数指定的字符串，字符串中每个小写字符将更改为大写。大写和小写的映射由当前语言环境的LC_CTYPE 范畴定义。 |
| sprintf(Format, Expr, Expr, . . . )                   | 根据 Format 参数指定的 printf 子例程格式字符串来格式化 Expr 参数指定的表达式并返回最后生成的字符串。 |

> sub

```
sub("需要匹配的内容，可以是正则表达式","匹配到的内容替换成什么","目标字符串")

$ echo "  top," | awk -F "," '{sub("^ *","");print $1}' 
top
$ echo "  top," | awk -F "," '{sub("^ *","",$1);print $1}'
top
$ echo "  top," | awk -F "," '{sub("^ *","lalal",$1);print $1}'
lalaltop
```

### 附录

```
# grep @property $1 | awk -f declearToFileAwk.txt
eval `grep @property $1 | awk -f declearToFileAwk.txt`

echo $getterString >> 33.txt
echo ---------------
echo $constraintsString >> 33.txt
echo $subviewsString >> 33.txt
```

```
BEGIN {
	getter="";
	constraints="";
	subviews="";
} {
	propertyname=substr($5,2,length($5)-2);
	property="_"propertyname;
	
	if ($3!~/assign/) {
		getter=getter"- ("$4" *)" propertyname "{\n	if (!"property") {\n		"property" = [["$4" alloc] init];\n	}\n	return "property";\n}\n\n";
		subviews=subviews"[self addSubview:self."propertyname"];\n";
		constraints=constraints"[self."propertyname" mas_makeConstraints:^(MASConstraintMaker *make) {\
		\
		}];\n\n";
	} 
} END {
	printf("getterString='%s';constraintsString='%s';subviewsString='%s'",getter,constraints,subviews);

	print getterString;
	
	#print "- (void)setupSubviews {\n    "subviews"\n}";
	#print "- (void)setupContraints {\n    "constraints"\n}";
}
```



