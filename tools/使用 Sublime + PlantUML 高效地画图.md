# 使用 Sublime + PlantUML 高效地画图



* 安装 Sublime

* 安装 graphviz。

   brew install graphviz

* 安装sublime_diagram_plugin插件
  - command+shift+p：打开Command Palette
  - 输入 add repository 找到 Package Control:Add Repository
  - 输入框中输入 https://github.com/jvantuyl/sublime_diagram_plugin.git 然后回车
  - 重启sublime



```
@startuml

class Parent {
	
}

class Children {
	
}

Parent <|-- Children

@enduml
```

command + m