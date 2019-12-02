





## MVP

视图中的控件会把接收到的用户的输入直接转给Presenter，由其进行事件处理。视图监听模型的变化以更新自己的状态（Observer模式）。

### Supervising Controller

视图中的控件会把接收到的用户的输入直接转给Presenter，由其进行事件处理。视图和模型间的数据同步通过binding机制来处理。Binding机制和observer模式类型，模型对象发生变动时会通知监听者，即presenter,presenter会继而通知视图控件从模型对象中读取数据，更新视图。



presenter和iOS MVVM中的VM在bind这一块是一致的。

### Passive View

Model：专注于领域逻辑，完全不知道控制器和视图的存在

View：视图会监视模型的变更，也会显示模型的数据

Controller：根据视图的输入来操作模型                                                                                                                

## MVC

Model：专注于领域逻辑，完全不知道控制器和视图的存在

View：(1)视图会监视模型的变更，(2)也会显示模型的数据

Controller：根据视图的输入来操作模型

Controller会直接引用View和Model，View会直接引用Model，Model非常简单，谁都不引用。

