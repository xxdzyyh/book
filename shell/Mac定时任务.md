---
layout: post
type: other
---

### launchctl 命令
 
 
**语法**

launchctl subcommand [arguments ...]

**subcommand**

> submit

```
submit -l label [-p executable] [-o stdout-path] [-e stderr-path] -- command [arg0] [arg1] [...]
              A simple way of submitting a program to run without a configuration file. This mechanism also tells launchd to
              keep the program alive in the event of failure.

              -l label
                       What unique label to assign this job to launchd.

              -p program
                       What program to really execute, regardless of what follows the -- in the submit sub-command.

              -o stdout-path
                       Where to send the stdout of the program.

              -e stderr-path
                       Where to send the stderr of the program.
```

通过submit可以直接运行某个程序，不需要配置文件，但是看起来没有办法设置时间间隔。
下面的命令会无限循环执行

```
# 无限执行/Users/xiaoniu/Documents/MyAppleScript/record.scpt
$ launchctl submit -l com.feng.choose  -o /Users/xiaoniu/Documents/MyAppleScript/out.log -e /Users/xiaoniu/Documents/MyAppleScript/err.log osascript /Users/xiaoniu/Documents/MyAppleScript/record.scpt
```

> list

list [label]

如果不带参数，列出所有的launchd任务。第一行pid,如果在运行，第二行最近一次执行退出状态，第三行任务的label。

如果指定label，输出指定label对应任务相关的信息

```
$ launchctl list com.feng.record

{
	"StandardOutPath" = "/Users/xiaoniu/Documents/MyAppleScript/out.log";
	"LimitLoadToSessionType" = "Aqua";
	"StandardErrorPath" = "/Users/xiaoniu/Documents/MyAppleScript/err.log";
	"Label" = "com.feng.record";
	"TimeOut" = 30;
	"OnDemand" = true;
	"StandardInPath" = "/Users/xiaoniu/Documents/MyAppleScript/in.log";
	"LastExitStatus" = 0;
	"Program" = "osascript";
	"ProgramArguments" = (
		"osascript";
		"/Users/xiaoniu/Documents/MyAppleScript/record.scpt";
	);
};
```

> load

```
load [-wF] [-S sessiontype] [-D searchpath] paths ...	
# 加载指定plist，一个plist对应一个任务
launchctl load -w /Users/xiaoniu/Library/LaunchAgents/18.plist
```

> unload

```
# 移除已加载的plist
launchctl unload /Users/xiaoniu/Library/LaunchAgents/18.plist 
```

> start


```
start [label]

#立即执行一个任务。如果是一个定时任务，通过start可以立即触发，这样可以更方便的测试
launchctl start com.feng.record
```

> stop

```
stop [label]

#停止一个任务，如有有需要，但是系统可能重启这个任务（如果任务有守护，应该stop就会重启)。
launchctl stop com.feng.record
```
> remove 

```
remove [label]

#移除一个任务,通过summit提交的任务，可以通过remove移除
launchctl remove com.feng.choose
```
### 定时任务描述plist

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <!-- 名称，要全局唯一,唯一标志，配合launchctl使用 -->
    <key>Label</key>
    <string>com.feng.updatecode</string>
    <!-- 命令， 第一个为命令，其它为参数，共同组成一条完整的命令 `sh updatecode.sh` -->
    <key>ProgramArguments</key>
    <array>
        <string>sh</string>
        <string>/Users/xiaoniu/Documents/MyAppleScript/updatecode.sh</string>
    </array>
    <!-- 运行时间 -->
    <key>StartCalendarInterval</key>
    <dict>
      <key>Minute</key>
      <integer>0</integer>
      <key>Hour</key>
      <integer>9</integer>
    </dict>
    <key>StandardInPath</key>
    <string>/Users/xiaoniu/Documents/MyAppleScript/in.log</string>
    <key>StandardOutPath</key>
    <string>/Users/xiaoniu/Documents/MyAppleScript/out.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/xiaoniu/Documents/MyAppleScript/err.log</string>
  </dict>
</plist>
```

### 开机自启动
```
FILES
     ~/Library/LaunchAgents         Per-user agents provided by the user.
     /Library/LaunchAgents          Per-user agents provided by the administrator.
     /Library/LaunchDaemons         System wide daemons provided by the administrator.
     /System/Library/LaunchAgents   OS X Per-user agents.
     /System/Library/LaunchDaemons  OS X System wide daemons.
```

创建一个plist文件放到~/Library/Launch Agents/下面，文件里描述你的程序路径和启动参数，那么这个用户登录时就会启动这个程序了，无法stop，被杀了之后会自动重新启动
如果需要把它停止的话，使用 unload 命令

如果放到/Library/Launch Agents/下面的话，就是一开机就启动哦～



