之前都是使用破解的工具，其实挺麻烦的，如果像Git一样使用命令行，就会方便很多。

### svn 服务器项目创建

安装Xcode后，svn工具应该就已经装好了，可以直接使用。

```
#项目名为svntest
svnadmin create ~/Downloads/svndata/svntest

#为了测试方便,将权限打开
$ cd svndata/svntest/conf 
$ vi svnserve.conf
# 添加anon-access = write，允许不登录进行提交，仅仅测试用

# 停止svn
$ killall svnserve

# 启动svn项目
svnserve -d -r ~/Downloads/svndata

# 测试创建结果
svn co svn://localhost/svntest
```

### svn checkout 

svn checkout 可以创建工作副本，svn可以指定目录

```
# checkout 整个目录
$ svn co svn://localhost/svntest

# 指定目录为项目子文件夹2 
$ svn co svn://localhost/svntest/2，不需要把整个项目都checkout下来

# 有时候只是想提交一些东西上去，这个时候checkout特定文件夹当不想包含其中的文件可以如下
svn co --depth=empty svn://localhost/svntest
svn add 1.txt
...
```

### svn add、commit

```
$ vi 1.txt
$ svn add 1.txt
$ svn commit -m "add 1.txt"
```



### svn update

更新

```
svn up fileName
svn update 
```

### svn list AGV

```
$ svn list svn://localhost/svntest

1.txt
2/

# 递归罗列目录下所有的子目录和文件
$ svn list -R svn://localhost/svntest

```