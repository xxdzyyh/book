## git



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
git checkout 文件路径 分支名称 
// 
git checkout BugInsight/SessionReplay/UTGestureDetector.m feature_serversiderender
```



### git add --force

