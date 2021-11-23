# git



[Toc]

### git cherry-pick  commitid

将本地存在的某次提交合并到当前分支,会产生一个新的commitid，后续如果merge这个提交所在的分支到当前分支，就会出现两个提交内容一样，commit message一样，但是commitid不同的情况，这个时候可以适当考虑

```git merge --squash ```将多个commit合成同一个，就只会看到第一个commit了。

```
git cherry-pick 1d976a3c0d26a7b853a5a0122a3c218f9986465f
```



### git merge --squash 

多个commit合并成一个commit。有时候分开的东西发现实际应该一起提交，就可以使用。



### 从特定分支获取文件

在其他分支上改了一些东西，可以通过 `git cherry-pick` 同步过来，但是如果一次提交中的部分文件，可以使用下面的语句使用其他分支的文件替换本分支的文件。



```
git checkout 分支名称 文件路径 
// 
git checkout feature_serversiderender BugInsight/SessionReplay/UTGestureDetector.m 
```



### git add --force



## stash

### git stash [save 'stash 说明']

### git stash pop [stash@{n}]

### git stash list

### git stash drop [stash@{n}]

### git stash clear

### git show stash@{n}





## 分支



### 获取当前分支名称

```
git rev-parse --abbrev-ref HEAD
```



### 分支描述



* 添加描述

  ```
  git config branch.${分支名称}.description "分支描述"
  ```

  

* 查看描述

  ```
  git config branch.${分支名称}.description
  ```

  

## log



* 设置 git log 日志显示格式

  ```
  git config --global log.date iso8601
  
  设置之后日期显示为 
  
  Date:  2021-10-09 11:08:51 +0800
  ```

  



## 忽略文件

### .gitignore

修改 .gitignore 使之生效后，项目所有人都会有影响。



### 本地忽略文件

假设有个文件存放某个经常修改的变量，比如服务器地址，提交的时候，这个文件变更又不需要提交。可以编辑 .git/info/exclude 文件，将文件加进去，使忽略仅本地有效。

```
window._sjt_dict = {
  	origin: location.origin,
	  base_url: 'http://192.168.28.85:8082/api',
};
```



```
vi .git/info/exclude 

# git ls-files --others --exclude-from=.git/info/exclude
# Lines that start with '#' are comments.
# For a project mostly in C, the following would be a good set of
# exclude patterns (uncomment them if you want to use them):
# *.[oa]
# *~
serverconfig.js
```

添加之后，改动文件，git status 不会显示有变更。
