### MVC

视图 <------>控制器

模型 <------  控制器 

模型 <------  视图



* 模型专注于领域逻辑，完全不知道视图和控制器的存在。

* 控制器用来响应视图接收到的用户输入，相应的改变模型，并通知视图进行更新。

```
class Controller {
	model
	view
	
	view.tapBlock = ^{
		model.tapCount++
		updateView()	
	}
	
	updateView(model) {
		view.update(model)
	}
}

class View {
	label
	update(model) {
		label.text = model.tapCount
	}
}

class Model {
	tapCount
}
```



### MVP

视图会将接收的用户输入直接传递给Presenter,视图只负责渲染。



