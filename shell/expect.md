# expect



ssh 登录过程中需要输入登录密码，不能用简单的命令实现登录，可以通过 expect 实现。



安装

```
brew install expect
```



通过脚本登录 ssh。

```
#!/usr/bin/expect
 
set port 22
set user root
set host 139.9.216.236
set password UTesotr_!2021
spawn ssh -p $port $user@$host
expect "password:"
 
send "$password\r"
expect "*Last login*" interact
```



```
chmod +x sshToDev.sh
```



因为不是 bash , 不能用` sh sshToDev.sh`执行，直接 `./sshToDev.sh` 或者 `expect sshToDev.sh   `



## 命令解释

* spawn	新建一个进程，这个进程的交互由
* expect    控制 expect  等待接受进程返回的字符串，直到超时时间，根据规则决定下一步操作 
* send      发送字符串给expect控制的进程 
* set     设定变量为某个值 
* exp_continue    重新执行expect命令分支 
* lindex $argv 0 ...99     这些是接受参数