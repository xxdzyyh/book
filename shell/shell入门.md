## shell 入门

[TOC]

### 变量

#### 定义变量 

注意，变量名和等号之间不能有空格

```
your_name="runoob.com"
```

除了显式地直接赋值，还可以用语句给变量赋值

```
for file in `ls /etc`
或
for file in $(ls /etc)
```

#### 使用变量

使用一个定义过的变量，只要在变量名前面加美元符号即可,变量名外面的花括号是可选的，加不加都行，加花括号是为了帮助解释器识别变量的边界

```
your_name="qinjx"
echo $your_name
echo ${your_name}
```

#### 只读变量

```
myUrl="https://www.google.com"
readonly myUrl
```

#### 变量类型

运行shell时，会同时存在三种变量：

- **1) 局部变量** 局部变量在脚本或命令中定义，仅在当前shell实例中有效，其他shell启动的程序不能访问局部变量。
- **2) 环境变量** 所有的程序，包括shell启动的程序，都能访问环境变量，有些程序需要环境变量来保证其正常运行。必要的时候shell脚本也可以定义环境变量。
- **3) shell变量** shell变量是由shell程序设置的特殊变量。shell变量中有一部分是环境变量，有一部分是局部变量，这些变量保证了shell的正常运行

------



### 字符串

单引号字符串的限制：

- 单引号里的任何字符都会原样输出，单引号字符串中的变量是无效的；

- 单引号字串中不能出现单独一个的单引号（对单引号使用转义符后也不行），但可成对出现，作为字符串拼接使用。


双引号的优点：

- 双引号里可以有变量
- 双引号里可以出现转义字符

#### 获取字符串长度

```
string="abcd"
echo ${#string} #输出 4
```

#### 提取子字符串

以下实例从字符串第 **2** 个字符开始截取 **4** 个字符：

```
string="runoob is a great site"
echo ${string:1:4} # 输出 unoo
```

#### 查找子字符串

查找字符 **i** 或 **o** 的位置(哪个字母先出现就计算哪个)：

```
string="runoob is a great site"
echo `expr index "$string" io`  # 输出 4
```

### 数组

#### 定义数组

在 Shell 中，用括号来表示数组，数组元素用"空格"符号分割开。定义数组的一般形式为：

```
数组名=(值1 值2 ... 值n)

或者

array_name[0]=value0
array_name[1]=value1
array_name[2]=value2
```

#### 读取数组

```
// 单个元素
${array_name[index]}

// 获取所有元素
echo "数组的元素为: ${my_array[*]}"
echo "数组的元素为: ${my_array[@]}"
```



### 数组长度

```
echo "数组元素个数为: ${#my_array[*]}"
echo "数组元素个数为: ${#my_array[@]}"
```



### 函数

```
[ function ] funname [()]
{
    action;
    [return int;]
}
```

说明：

- 1、可以带function fun() 定义，也可以直接fun() 定义,不带任何参数。
- 2、参数返回，可以显示加：return 返回，如果不加，将以最后一条命令运行结果，作为返回值。 return后跟数值n(0-255)



#### 获取返回值



### 调用其他脚本

> fork

fork 是最普通的, 就是直接在脚本里面用 path/to/foo.sh 来调用 
foo.sh 这个脚本，比如如果是 foo.sh 在当前目录下，就是 ./foo.sh。运行的时候 terminal 会新开一个子 Shell 执行脚本 foo.sh，子 Shell 执行的时候, 父 Shell 还在。子 Shell 执行完毕后返回父 Shell。 子 Shell 从父 Shell 继承环境变量，但是子 Shell 中的环境变量不会带回父 Shell。

> exec

exec 与 fork 不同，不需要新开一个子 Shell 来执行被调用的脚本. 被调用的脚本与父脚本在同一个 Shell 内执行。但是使用 exec 调用一个新脚本以后, 父脚本中 exec 行之后的内容就不会再执行了。这是 exec 和 source 的区别.

> source

与 fork 的区别是不新开一个子 Shell 来执行被调用的脚本，而是在同一个 Shell 中执行. 所以被调用的脚本中声明的变量和环境变量, 都可以在主脚本中进行获取和使用。

