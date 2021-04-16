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

CSS 选择器用于“查找”（或选取）要设置样式的 HTML 元素。

我们可以将 CSS 选择器分为五类：

- 简单选择器（根据名称、id、类来选取元素）
- [组合器选择器](https://www.w3school.com.cn/css/css_combinators.asp)（根据它们之间的特定关系来选取元素）
- [伪类选择器](https://www.w3school.com.cn/css/css_pseudo_classes.asp)（根据特定状态选取元素）
- [伪元素选择器](https://www.w3school.com.cn/css/css_pseudo_elements.asp)（选取元素的一部分并设置其样式）
- [属性选择器](https://www.w3school.com.cn/css/css_attribute_selectors.asp)（根据属性或属性值来选取元素）



* 元素选择器

  ```
  p {
  	text-align: center;
  	color: red;
  }
  
  h1, h2, p {
    text-align: center;
    color: red;
  }
  ```

* CSS id 选择器

  id 选择器使用 HTML 元素的 id 属性来选择特定元素。

  元素的 id 在页面中是唯一的，因此 id 选择器用于选择一个唯一的元素！

  要选择具有特定 id 的元素，请写一个井号（＃），后跟该元素的 id。

  **注意：**id 名称不能以数字开头。

  ```
  #para1 {
    text-align: center;
    color: red;
  }
  ```

  

* CSS 类选择器

  类选择器选择有特定 class 属性的 HTML 元素。

  如需选择拥有特定 class 的元素，请写一个句点（.）字符，后面跟类名。

  ```
  // 所有带有 class="center"
  .myClass {
    text-align: center;
    color: red;
  }
  ```

* 后代选择器（descendant selector）又称为包含选择器。

  ```
  h1 em {color:red;}
  
  <h1>This is a <em>important</em> heading</h1>
  <p>This is a <em>important</em> paragraph.</p>
  ```

  当然，您也可以在 h1 中找到的每个 em 元素上放一个 class 属性，但是显然，后代选择器的效率更高。

  有关后代选择器有一个易被忽视的方面，即两个元素之间的层次间隔可以是无限的。不必是子元素

* 子元素选择器

  ```
  h1 > em {color:red
  
  // 选择p元素，父元素是td td 是table的后代节点 类型 table有一个class='company'
  table.company td > p
  ```

* 相邻兄弟选择器

  ```
  // 选择紧接在 h1 元素后出现的段落，h1 和 p 元素拥有共同的父元素
  h1 + p {margin-top:50px;}
  ```

### 实例

在此例中，所有带有 class="center" 的 HTML 元素将为红色且居中对齐：

```
.center {
  text-align: center;
  color: red;
}
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