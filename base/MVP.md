## MVP

视图中的控件会把接收到的用户的输入直接转给Presenter，由其进行事件处理。视图监听模型的变化以更新自己的状态（Observer模式）。

### Supervising Controller

视图中的控件会把接收到的用户的输入直接转给Presenter，由其进行事件处理。视图和模型间的数据同步通过binding机制来处理。Binding机制和observer模式类似，模型对象发生变动时会通知监听者，即presenter,presenter会继而通知视图控件从模型对象中读取数据，更新视图。

注意，Presenter会将Model直接传递给View，View是知道Model的。

### Passive View

Model：专注于领域逻辑，完全不知道控制器和视图的存在

View：接收用户输入然后转发给presenter。如果视图需要更新，那presenter会告诉视图具体哪些部分要发生变化。视图完全不知道模型的存在。

Presenter：(1)处理用户输入 (2)修改模型 (3)更新视图                                                                                                           
### MVC

Model：专注于领域逻辑，完全不知道控制器和视图的存在

View：(1)视图会监视模型的变更，(2)也会显示模型的数据

Controller：根据视图的输入来操作模型

Controller会直接引用View和Model，View会直接引用Model，Model非常简单，谁都不引用。



## 如何区分这几种模式

搞清楚这几种角色各自承担的任务以及相互间通信规则就可以区分这几种模式

共同点

* View 接收用户输入，但是不会直接处理而是转发
* Model 领域模型，非常的纯粹
* presenter/controller接收view转发的用户输入并处理
* presenter/controller更新模型
----------------------------------
不同点
* 谁来更新视图
	* 视图监听模型变化，更新自己的状态（Supervising Controller）
	* presenter直接更新视图状态（Passive View）


> 相互通信

* view可以访问model吗？

  

## iOS MVC

官方的图

<img src="https://developer.apple.com/library/archive/documentation/General/Conceptual/DevPedia-CocoaCore/Art/model_view_controller_2x.png" alt="官方文档" style="zoom: 50%;" />


斯坦福公开课

<img src="https://upload-images.jianshu.io/upload_images/8829003-4270fb02a1c1c749.png?imageMogr2/auto-orient/strip|imageView2/2/w/700" alt="img" style="zoom: 67%;" />



* Model不知道Controller和View的存在

* Controller直接持有Model，可以直接修改Model，Controller通过通知、KVO等等方式来监听Model变化
* Controller直接持有View，可以直接修改View
* View通过delegate、target-action将用户的输入传递给Controller,Controller通过dataSource或者直接修改来更新View

* View完全不知道Model的存在，能够感知Controller的存在，但不知道具体是谁

实际上iOS的MVC一般也会写成下面这个样子

* Model 领域模型
* View 视图会监视模型的变更，也会显示模型的数据。View直接访问了Model
* Controller  (1)处理用户输入 (2)更新Model (3)监听Model变化 (4)通知View进行更新

### MVVM

* Model 领域模型
* View 监听ViewModel的变化，显示ViewModel的数据，更新ViewModel(双向绑定)
* ViewModel监视Model变化，更新自身数据，更新View，和Model和View相关的处理才放到ViewModel中，其他的改怎么处理就怎么处理。
* Controller接收View转发的用户输入，监听ViewModel的变化并处理视图逻辑（比如隐藏一个视图，弹出个alert），场景切换
* Controller实际View的一部分

