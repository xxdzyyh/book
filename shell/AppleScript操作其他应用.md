
```
tell application "System Events"
	tell process "QQ音乐" 
		entire contents -- 获取所有 UI 元素
	end tell
end tell
```
运行结果非常的长，将 "", "替换为 "", \n"，便于阅读，查找"下一首"。

```
...
menu "播放控制" of menu bar item "播放控制" of menu bar 1 of application process "QQMusic" of application "System Events", 
menu item "暂停" of menu "播放控制" of menu bar item "播放控制" of menu bar 1 of application process "QQMusic" of application "System Events", 
menu item "上一首" of menu "播放控制" of menu bar item "播放控制" of menu bar 1 of application process "QQMusic" of application "System Events", 
menu item "下一首" of menu "播放控制" of menu bar item "播放控制" of menu bar 1 of application process "QQMusic" of application "System Events", 
menu item "音量加" of menu "播放控制" of menu bar item "播放控制" of menu bar 1 of application process "QQMusic" of application "System Events", 
menu item "音量减" of menu "播放控制" of menu bar item "播放控制" of menu bar 1 of application process "QQMusic" of application "System Events", 
menu item "喜欢歌曲" of menu "播放控制" of menu bar item "播放控制" of menu bar 1 of application process "QQMusic" of application "System Events", 
menu item "播放模式" of menu "播放控制" of menu bar item "播放控制" of menu bar 1 of application process "QQMusic" of application "System Events", 
...
```
找到"下一首"的位置，这个下一首就是点击 QQ音乐 -> 系统导航栏左边会显示QQ的菜单中的“下一首”。

```
tell application "System Events"
	tell process "QQ音乐" 
		click menu item "下一首" of menu "播放控制" of menu bar item "播放控制" of menu bar 1 of application process "QQMusic" of application "System Events"
	end tell
end tell
```

"of application process "QQMusic" of application "System Events" 可以省略，因为上下文已经提供了相关的信息。

这样，通过脚本完成了QQ音乐切换到下一首歌的功能。

设置输入框的文本

```
tell application "System Events"
	tell process "QQ音乐"
		
		set value of text field "搜索" of menu item 1 of menu "帮助" of menu bar item "帮助" of menu bar 1 to "cd"
		
	end tell
end tell

```
检测

```
tell application "Safari" to activate --打开 Safari
tell application "System Events"
	tell process "Safari"
		repeat until window 1 exists
			-- 直到 Safari 应用的一个窗口存在之前，不停循环这段空语句
		
		end repeat
		-- 第一个窗口出现之后，继续要做的事……
	end tell
end tell
```