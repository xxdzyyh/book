## CSS

HTML 标签被设计为用于定义文档内容，如下实例：

```
<h1>这是一个标题</h1>
<p>这是一个段落。</p>
```

样式表定义如何显示 HTML 元素，就像 HTML 中的字体标签和颜色属性所起的作用那样。样式通常保存在外部的 .css 文件中。我们只需要编辑一个简单的 CSS 文档就可以改变所有页面的布局和外观。

![img](https://www.runoob.com/wp-content/uploads/2013/07/632877C9-2462-41D6-BD0E-F7317E4C42AC.jpg)

```
<!DOCTYPE html>
<html>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<head>
	<title>点击按钮弹出alert</title>
</head>
<body>
<h3>点击弹出</h3>
<button type="button" onclick="myButtonClicked()"> 点我改变body背景颜色 </button>
<script type="text/javascript">	
function myButtonClicked() {
	document.body.style.backgroundColor = "yellow"
}
</script>
<style type="text/css">
body {
	background:#d0e4fe;
}
h3 {
	text-align:center;
}
button {
	background-color:#fff000;
	color: #000fff;
}
</style>
</body>
</html>
```



*不要在属性值与单位之间留有空格（如："margin-left: 20 px" ），正确的写法是 "margin-left: 20px" 。*

## 选择器

默认的HTML标签，h1

```
<p id="myid">123</p>
<h1 class="center">标题居中</h1>
<p class="center">段落居中。</p> 

<style>
h3 {
	text-align: center;
}

/*ID属性不要以数字开头*/
#myid {
	color: red;
}

.center {
	text-align:center;
}

p.center {
	text-align: center;
}
<style>
```

### 外部样式表

```
<head>
<link rel="stylesheet" type="text/css" href="mystyle.css">
</head>
```

### 内部样式表

当单个文档需要特殊的样式时，就应该使用内部样式表。你可以使用 <style> 标签在文档头部定义内部样式表，就像这样:

### 内联样式

由于要将表现和内容混杂在一起，内联样式会损失掉样式表的许多优势。请慎用这种方法，例如当样式仅需要在一个元素上应用一次时。

要使用内联样式，你需要在相关的标签内使用样式（style）属性。Style 属性可以包含任何 CSS 属性。本例展示如何改变段落的颜色和左外边距：

```
<p style="color:sienna;margin-left:20px">这是一个段落。</p>
```

一般情况下，优先级如下：

**内联样式）Inline style > （内部样式）Internal style sheet >（外部样式）External style sheet > 浏览器默认样式**

**注意：***如果外部样式放在内部样式的后面，则外部样式将覆盖内部样式。*




```
<head>
<style>
hr {color:sienna;}
p {margin-left:20px;}
body {background-image:url("images/back40.gif");}
</style>
</head>

```

### 颜色定义

CSS中，颜色值通常以以下方式定义:

- 十六进制 - 如："#ff0000"
- RGB - 如："rgb(255,0,0)"
- 颜色名称 - 如："red"



## flex

flex 属性是 flex-grow、flex-shrink 和 flex-basis 属性的简写属性。

```
.app-list-wrapper
    display: flex
    flex-direction: column
    //flex: 1
```

### flex-basis

flex-basis 属性用于设置或检索弹性盒伸缩基准值。。

**注意：**如果元素不是弹性盒对象的元素，则 flex-basis 属性不起作用。

| 值       | 描述                                                         |
| :------- | :----------------------------------------------------------- |
| *number* | 一个长度单位或者一个百分比，规定灵活项目的初始长度。         |
| auto     | 默认值。长度等于灵活项目的长度。如果该项目未指定长度，则长度将根据内容决定。 |
| initial  | 设置该属性为它的默认值。请参阅 [*initial*](https://www.runoob.com/cssref/css-initial.html)。 |
| inherit  | 从父元素继承该属性。请参阅 [*inherit*](https://www.runoob.com/cssref/css-inherit.html)。 |