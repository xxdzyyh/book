## JavaScript

JavaScript  用来指明网页的行为。

JavaScript 是 Web 的编程语言。

所有现代的 HTML 页面都使用 JavaScript。

[TOC]

### 使用javaScript

* 内嵌

  ```
  <!DOCTYPE html>
  <html>
  <head>
  <meta charset="utf-8">
  <title>菜鸟教程(runoob.com)</title>
  </head>
  <body>
  <h1 onclick="this.innerHTML='Ooops!'">点击文本!</h1>
  </body>
  </html>
  ```

  

* 直接写在 `<script></script>`中间，脚本可被放置在 HTML 页面的 <body> 和 <head> 部分中。

  ```
  <!DOCTYPE html>
  <html>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <head>
  	<title>点击按钮弹出alert</title>
  </head>
  <body>
  <h3>点击弹出</h3>
  <button type="button" onclick="myButtonClicked()"> 点我 </button>
  <script type="text/javascript">	
  function myButtonClicked() {
  	alert("点我干什么？？？")
  }
  </script>
  </body>
  </html>
  ```

* 外部 js 文件

  ```
  // alert.html
  <!DOCTYPE html>
  <html>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <head>
    <title>点击按钮弹出alert</title>
  </head>
  <body>
  <h3>点击弹出</h3>
  <button type="button" onclick="myButtonClicked()"> 点我 </button>
  <script type="text/javascript" src="alert.js"></script>
  </body>
  </html>
  
  // alert.js
  function myButtonClicked() {
  	alert("点我干什么？？？")
  }
  
  ```

JavaScript 没有任何打印或者输出的函数。

### JavaScript 显示数据

JavaScript 可以通过不同的方式来输出数据：

- 使用 **window.alert()** 弹出警告框。
- 使用 **document.write()** 方法将内容写到 HTML 文档中。
- 使用 **innerHTML** 写入到 HTML 元素。
- 使用 **console.log()** 写入到浏览器的控制台。

> 请使用 document.write() 仅仅向文档输出写内容。 如果在文档已完成加载后执行 document.write，整个 HTML 页面将被覆盖。


```
<!DOCTYPE html>
<html>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<body>
<h1>我的第一个 Web 页面</h1>
<p id="demo">我的第一个段落</p>
<script>
document.getElementById("demo").innerHTML = "段落已修改。";
</script>
</body>
</html>
```

### JavaScript 对象

```
var person = {firstName:"John",lastName:"Doe",id:5566}
// 重新定义变量，变量的值不会丢失
var person
console.log(person)
// {firstName:"John",lastName:"Doe",id:5566}

// 声明变量类型
var name = new String;
```

### Undefined 和 Null

Undefined 这个值表示变量不含有值。

可以通过将变量的值设置为 null 来清空变量。

```
var person = null;           // 值为 null(空), 但类型为对象
var person = undefined;      // 值为 undefined, 类型为 undefined
```

判断是不是 undefined

```
let params = this.$route.params.params
if (typeof(params) == "undefined") {
    params = localStorage.getItem("netdetail")
}
```

判断 null

```
var exp = null; 
if (!exp && typeof(exp)!=”undefined” && exp!=0) { 
	alert(“is null”); 
}　
```

### const let var

`let`完全可以取代`var`，因为两者语义相同，而且`let`没有副作用。

`var`命令存在变量提升效用，`let`命令没有这个问题。

```
'use strict';

if (true) {
  console.log(x); // ReferenceError
  let x = 'hello';
}
```

上面代码如果使用`var`替代`let`，`console.log`那一行就不会报错，而是会输出`undefined`，因为变量声明提升到代码块的头部。这违反了变量先声明后使用的原则。

在`let`和`const`之间，建议优先使用`const`，尤其是在全局环境，不应该设置变量，只应设置常量。

`const`优于`let`有几个原因。一个是`const`可以提醒阅读程序的人，这个变量不应该改变；另一个是`const`比较符合函数式编程思想，运算不改变值，只是新建值，而且这样也有利于将来的分布式运算；最后一个原因是 JavaScript 编译器会对`const`进行优化，所以多使用`const`，有利于提高程序的运行效率，也就是说`let`和`const`的本质区别，其实是编译器内部的处理不同。

### 向未声明的 JavaScript 变量分配值

如果您把值赋给尚未声明的变量，该变量将被自动作为 window 的一个属性。



### 原型

* 对象 ： js 一切皆对象, 每一个 js 对象(null除外)在创建的时候就会有一个与之关联的对象，就是我们所说的原型。

* 函数 ：函数也是对象，每个函数都有一个 prototype 



对象

* `__proto__`
* `constructor`



函数

* `prototype`

* `__proto__`
* `constructor`



```
function Foo() {

}
let f1 = new Foo()

f1.__proto__ // Foo.prototype
f1.constructor // Foo() 
Foo().constructor // Function()
Foo.prototype // Function.prototype
Foo.prototype.__proto__ // Object.prototype
Function.prototype.constructor // Function()
Object.prototype.__proto__ // null
```





## HTML DOM



```
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>菜鸟教程(runoob.com)</title>
</head>
<body>

<div onmouseover="mOver(this)" onmouseout="mOut(this)" style="background-color:#D94A38;width:120px;height:20px;padding:40px;">Mouse Over Me</div>
<script>
function mOver(obj){
	obj.innerHTML="Thank You"
}
function mOut(obj){
	obj.innerHTML="Mouse Over Me"
}
</script>
</body>
</html>
```



### DOM vs BOM

* DOM

  DOM 全称是 Document Object Model，也就是文档对象模型。是针对XML的基于树的API。描述了处理网页内容的方法和接口，是HTML和XML的API，DOM把整个页面规划成由节点层级构成的文档。

  这个DOM定义了一个HTMLDocument和HTMLElement做为这种实现的基础,就是说为了能以编程的方法操作这个 HTML 的内容（比如添加某些元素、修改元素的内容、删除某些元素），我们把这个 HTML 看做一个对象树（DOM树），它本身和里面的所有东西比如 <div></div> 这些标签都看做一个对象，每个对象都叫做一个节点（node），节点可以理解为 DOM 中所有 Object 的父类。

* BOM

  BOM 是 Browser Object Model，浏览器对象模型。

  刚才说过 DOM 是为了操作文档出现的接口，那 BOM 顾名思义其实就是为了控制浏览器的行为而出现的接口。
  浏览器可以做什么呢？比如跳转到另一个页面、前进、后退等等，程序还可能需要获取屏幕的大小之类的参数。
  所以 BOM 就是为了解决这些事情出现的接口。比如我们要让浏览器跳转到另一个页面，只需要

  location.href = "http://www.xxxx.com";这个 location 就是 BOM 里的一个对象。

   

  由于BOM的window包含了document，因此可以直接使用window对象的document属性，通过document属性就可以访问、检索、修改XHTML文档内容与结构。因为document对象又是DOM（Document Object Model）模型的根节点。

  可以说，BOM包含了DOM(对象)，浏览器提供出来给予访问的是BOM对象，从BOM对象再访问到



## 第三方管理

* package.json 项目第三方依赖管理（类似于swift package.swift）

| 工具                  | 配置文件      | 锁定文件          |
| --------------------- | ------------- | ----------------- |
| npm                   | package.json  | package-lock.json |
| cocoapods             | Podfile       | Podfile.lock      |
| Swift Package Manager | package.swift |                   |



| 操作         | npm      | Cocoapods | Swift Package Manager |
| ------------ | -------- | --------- | --------------------- |
| 创建配置文件 | npm init | pod init  |                       |
| 小版本升级   | ^        | ~=        |                       |
|              |          |           |                       |
|              |          |           |                       |

### package.json

* scripts 

  定义脚本的缩写

  ```
  {
    "dev": "webpack-dev-server --inline --progress --config build/webpack.dev.conf.js",
    "start": "npm run dev",
    "unit": "jest --config test/unit/jest.conf.js --coverage",
    "test": "npm run unit",
    "lint": "eslint --ext .js,.vue src test/unit",
    "build": "node build/build.js"
  }
  ```

* dependencies

  release 环境需要的依赖

  ```
  "dependencies": {
    "blueimp-md5": "^2.11.0",
    "default-passive-events": "^1.0.10",
    "echarts": "^4.2.1",
    "element-ui": "^2.9.1",
    "node-sass": "^4.14.1",
    "videojs-vjsdownload": "^1.0.4",
    "vue": "^2.5.2",
    "vue-clipboard2": "^0.3.0",
    "vue-resource": "^1.5.1",
    "vue-router": "^3.0.1",
    "vue-video-player": "^5.0.2"
  }
  ```

  

* devDependencies

  develop 环境需要的依赖

* engines

  ```
  "engines": {
    "node": ">= 6.0.0",
    "npm": ">= 3.0.0"
  }
  ```

* browserslist

  ```
  "browserslist": [
    "> 1%",
    "last 2 versions",
    "not ie <= 8"
  ]
  ```

  



## ES6



## Babel转码器

[Babel](https://babeljs.io/)是一个广泛使用的ES6转码器，可以将ES6代码转为ES5代码，从而在现有环境执行。这意味着，你可以用ES6的方式编写程序，又不用担心现有环境是否支持。下面是一个例子。

```javascript
// 转码前
input.map(item => item + 1);

// 转码后
input.map(function (item) {
  return item + 1;
});
```

上面的原始代码用了箭头函数，这个特性还没有得到广泛支持，Babel将其转为普通函数，就能在现有的JavaScript环境执行了。



### 使用

```
<script type="text/ecmascript-6">

</script>
```



### class



js 有一个原型的概念，其实就类似于 OC 的 meta class.

不使用 class 关键字生成类。

```
function Point(x, y) {
  this.x = x;
  this.y = y;
}

Point.prototype.toString = function () {
  return '(' + this.x + ', ' + this.y + ')';
};

var p = new Point(1, 2);
```

上面这种写法跟传统的面向对象语言（比如C++和Java）差异很大，很容易让新学习这门语言的程序员感到困惑。

ES6提供了更接近传统语言的写法，引入了Class（类）这个概念，作为对象的模板。通过`class`关键字，可以定义类。基本上，ES6的`class`可以看作只是一个语法糖，它的绝大部分功能，ES5都可以做到，新的`class`写法只是让对象原型的写法更加清晰、更像面向对象编程的语法而已。上面的代码用ES6的“类”改写，就是下面这样。



* 声明

  ```
  class Point {
  	constructor(x, y) {
      this.x = x;
      this.y = y;
    }
    
    // 类方法，Point.value() // 'hello'
    static value() {
    	return "hello"
    }
    
    toString() {
      return '(' + this.x + ', ' + this.y + ')';
    }
  }
  
  ```

* 创建实例

  ```
  var point = new Point(2,3)
  point.toString() // (2, 3)
  
  typeof Point // "function"
  Point === Point.prototype.constructor // true
  
  point.hasOwnProperty('x') // true
  point.hasOwnProperty('y') // true
  point.hasOwnProperty('toString') // false
  point.__proto__.hasOwnProperty('toString') // true
  
  var p1 = new Point(2,3);
  var p2 = new Point(3,2);
  
  p1.__proto__ === p2.__proto__ //true
  ```

* 继承

  ```
  class ColorPoint extends Point {
  	constructor(x, y, color) {
      super(x, y); // 调用父类的constructor(x, y)
      this.color = color;
    }
    
    static value() {
    	return super.classMethod + ', too';
    }
  
    toString() {
      return this.color + ' ' + super.toString(); // 调用父类的toString()
    }
  }
  ```

  



## 数组



### map

```
let sessionIds = this.sessions.map(item => {
  return item.sessionId
}).join(',');
```



### 删除元素

**splice()操作方法** 

在JavaScript的Array对象中提供了一个splice()方法用于对数组进行特定的操作。splice()恐怕要算最强大的数组方法了，他的用法有很多种，在此只介绍删除数组元素的方法。在删除数组元素的时候，它可以删除任意数量的项，只需要指定2个参数：要删除的第一项的位置和要删除的项数。

```
var colors = ["red", "blue", "grey"];
var color = colors.splice(0, 1);

console.log(color); // "red"
console.log(colors); // ["blue", "grey"]
```



> splice vs slice

splice 会修改原数组，而 slice 不会。两者都可以用来获取子数组



#### 获取最后一个元素

```
array.slice(-1)[0]
```





## 数组高阶函数



### forEach(遍历)



forEach() 方法用于调用数组的每个元素，并将元素传递给回调函数。(没有返回值，将数组遍历)

注意: forEach() 对于空数组是不会执行回调函数的。

回调函数参数：currentValue  必需。当前元素； index  可选。当前元素的索引值； arr  可选。当前元素所属的数组对象。



```
[].forEach(function(value,index,array) {
	// code something
})
```



```
var array = ['a','b','c']
array.forEach(function(element) {
	console.log(element)
})
```



### filter 过滤 

filter() 方法创建一个新的数组，新数组中的元素是通过检查指定数组中符合条件的所有元素。

返回值：返回新数组

注意： filter() 不会对空数组进行检测。

注意： filter() 不会改变原始数组。



```
var ages = [32,33,16,40]
let res = ages.filter(function(item) {
	return item > 18
})

// res [32,33,40]
```



### map 映射 

map() 方法返回一个新数组，数组中的元素为原始数组元素调用函数处理后的值。

map() 方法按照原始数组元素顺序依次处理元素。

返回值：返回新数组

注意： map() 不会对空数组进行检测。

注意： map() 不会改变原始数组。

回调函数参数：currentValue  必需。当前元素； index  可选。当前元素的索引值； arr  可选。当前元素所属的数组对象。



```
var numbers = [65, 44, 12, 4];
console.log(numbers.map(function(item){
	return item * 10;
}))
//输出[650,440,120,40]
```



### some 判断是否含有符合条件的元素



some() 方法用于检测数组中的元素是否满足指定条件（函数提供）。

some() 方法会依次执行数组的每个元素：

如果有一个元素满足条件，则表达式返回true , 剩余的元素不会再执行检测。
如果没有满足条件的元素，则返回false。
注意： some() 不会对空数组进行检测。

注意： some() 不会改变原始数组。

回调函数参数：currentValue  必需。当前元素； index  可选。当前元素的索引值； arr  可选。当前元素所属的数组对象。



### every 

every() 方法用于检测数组所有元素是否都符合指定条件（通过函数提供）。

every() 方法使用指定函数检测数组中的所有元素：

如果数组中检测到有一个元素不满足，则整个表达式返回 false ，且剩余的元素不会再进行检测。
如果所有元素都满足条件，则返回 true。

注意： every() 不会对空数组进行检测。

注意： every() 不会改变原始数组。



### reduce 累计



```
var arr = [{price:30,count:2},{price:40,count:3}]

var sum = arr.reduce(function(x,y) {
	return x.price*x.count + y.price*y.count
})
```





### sort

无论使用冒泡排序还是快速排序，排序的核心是比较两个元素的大小。如果是数字，我们可以直接比较，但如果是字符串或者两个对象呢？直接比较数学上的大小是没有意义的，因此，比较的过程必须通过函数抽象出来。通常规定，对于两个元素`x`和`y`，如果认为`x < y`，则返回`-1`，如果认为`x == y`，则返回`0`，如果认为`x > y`，则返回`1`，这样，排序算法就不用关心具体的比较过程，而是根据比较结果直接排序。



注：sort() 方法会直接对 array  进行修改，它返回的结果仍是当前 Array



```
var arr = [10,20,1,2]
arr.sort(function(x,y) {
	if (x < y) {
		return -1
	} else if (x > y) {
		return 1
	} else {
		return 0
	}
})

console.log(arr) // [1,2,10,20]
```



### find



`find()`方法用于查找符合条件的第一个元素，如果找到了，返回这个元素，否则，返回`undefined`：

```
var arr = ['Apple','pear','orange']

console.log(arr.find(function (s) {
	return s.toLowCase() === s
}))
```



### findIndex



`findIndex()`和`find()`类似，也是查找符合条件的第一个元素，不同之处在于`findIndex()`会返回这个元素的索引，如果没有找到，返回`-1`：



```
var arr = ['Apple','pear','orange']

console.log(arr.findIndex(function (s) {
	return s.toLowCase() === s
})) // 1, 因为 'pear' 的索引是 1
```

