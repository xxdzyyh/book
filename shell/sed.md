sed命令以行为单位对文本文件进行处理。

Mac OS自带的sed和gnu-sed有一些区别，gnu-sed更好用一些，因此下面sed指的都是gnu-sed.

```
$ brew install gnu-sed
$ where sed

/usr/local/opt/gnu-sed/libexec/gnubin/sed
/usr/bin/sed

$ /usr/local/opt/gnu-sed/libexec/gnubin/sed -i 1d test.txt

$ gsed -i 1d test.txt
```

可以针对特定的行进行处理，直接指定行号，如1，也可以通过正则匹配对匹配成功的行进行处理

> 直接指定行号

```
# 删除第一行
sed 1d test.txt

# 最后一行后面添加一行，内容为a,建议加个\作为分隔符
sed '$aa' test.txt
sed '$a\a' test.txt
```

> 匹配内容

所有匹配到的行都会执行操作

```
# 匹配删除包含er的行
sed /er/d test.txt	
```

> 指定区间

指定区间使用','隔开起始位置和结束位置

```
# 指定行号 删除1-5行
sed 1,5d test.txt

# 匹配 删除起始位置以<<<<开头的行 ，结束位置以'===='开头的行
sed '/^<<<</,/^====/'d test.txt

# 指定行号和匹配行是同等地位，可以混用
# 删除第2行到以'===='开头的行
sed  '2,/^====/'d test.txt
```

### Command

sed 命令循环读入行数据到模式空间，然后执行操作命令，然后清空模式空间，重复。。。

- a ：新增， a 的后面可以接字串，而这些字串会在新的一行出现(目前的下一 行)

  ```
  # 可以在a后面加个\作为分隔，这样看起来会好些，加不加效果是一样的
  echo eee | sed 1a\www
  eee
  www
  ```

- c ：取代， c 的后面可以接字串，这些字串可以取代指定的行

  ```
  echo eee | sed 1c\www
  www
  ```

- d ：删除，因为是删除啊，所以 d 后面通常不接任何内容

  ```
  echo "eee\nwww" | sed 1d
  www
  ```

- e : 可以指定多个命令

  ```
  $ cat 11.txt
  
  123456
  qwerty
  
  # 对每一行按顺序执行每个命令
  $ sed -e 's/1/q/' -e 's/q/1/' 11.txt 
  
  123456
  1werty
  
  ```

- f ：从文件中读取sed命令，比 -e 更适合复杂场景

  ```
  $ cat 11.txt
  
  123456
  qwerty
  
  $ cat commands.txt
  
  s/1/q/; #这里分号可以省略，单独行就是一天命令
  s/q/1/;
  
  $ sed -f commands.txt 11.txt
  
  123456
  1werty
  ```

  > 定义标签

  

- i  ：插入， i 的后面可以接字串，而这些字串会在新的一行出现(目前的上一行)；

  ```
  echo "eee" | sed 1i\www
  www
  eee
  ```

- p ：打印，亦即将某个选择的数据印出。通常 p 会与参数 sed -n 一起运行～

  ```
  # sed默认在清空模式空间的时候会将内容输出，-n 可以控制不输出
  echo "eee" | sed -n 1p
  eee
  ```

- s ：替换，可以直接进行取代的工作哩！通常这个 s 的动作可以搭配正则表达式

  > g

  ```
  // sed s默认匹配到一个就结束了，加上g,可以匹配所有
  echo q_00040 | sed 's/0\+//g'  
  q_4
  ```

  > \0  \1

  ```
  // 有时候想要对匹配到的内容进行处理，可以参考下面的命令 \0 对应整个匹配到内容
  echo q_00040.png | sed 's/0\+[0-9]*/\0@2x/'
  q_00040@2x.png
  
  // 可以使用\()进行标记，后续使用 \1,\2 进行提取
  echo 'TextStyle(fontSize: 14)' | sed "s/fontSize: \([0-9]\+\)/fontSize: XNScale.fontSize(\1)/"
  TextStyle(fontSize: XNScale.fontSize(14))
  ```

- n : 立即清空当前模式空间并读入下一行

  ```
  // test.txt 9行，内容为1-9
  
  // 先读入一行执行p,然后执行n,这个时候清空掉模式空间，读入下一行，本次循环结束，模式空间数据被清空
  // 所以输出是奇数行
  sed -n 'p;n' test.txt
  1
  3
  5
  7
  9
  
  // 先读入一行执行n,这个时候清空掉模式空间，读入下一行，执行p,本次循环结束，模式空间数据被清空
  // 所以输出是偶数行
  sed -n 'n;p' test.txt
  2
  4
  6
  8
  ```

- N : 不清空当前模式空间，读入下一行，用 \n 分隔两行.这里有个问题，9 不见了，append 下一行结果没有成功，模式空间看起来被清空了

  ```
  sed -n "N;s/\n//;p" test.txt
  12
  34
  56
  78
  ```



### sed应用

现在要去掉所有的0
有一批图片，命名如下

```
qiqiu_00005.png ... qiqiu_00045.png
```

现在要去掉数字前面的0

```
#!bin/bash
for file in `ls $1` 
do
	if test -f $1"/"$file  
	then
		if echo $file | grep -q '.png$'
		then
			newname=$(echo "$file" | sed 's/0\+//')
			echo $newname
			mv $1"/"$file $1"/"${newname}
		fi
	fi
done
```

主要还是

```
echo "$file" | sed 's/0\+//'
```

sed是可以使用正则表达式的，这里用了+出现一次或者多次，因为出现的位置特殊，需要转义，否则+不具备特殊含义。

sed默认只处理了第一个匹配到的数据，否则qiqiu_00040.png应该变成qiqiu_4.png而不是qiqiu_40.png，但是可以添加参数来匹配所有的

```
echo q_00040 | sed 's/0\+//' 
q_40

echo q_00040 | sed 's/0\+//g'     
q_4
```

注意上面的写法有个问题，如果是qiqiu_00000会变成qiqiu_而不是qiqiu_0。