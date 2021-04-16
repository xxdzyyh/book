# HTML



[TOC]

## 标签

### span

<span> 标签被用来组合文档中的行内元素。

span 没有固定的格式表现。当对它应用样式时，它才会产生视觉上的变化。

```
<p class="tip"><span>提示：</span>... ... ...</p>

p.tip span {
	font-weight:bold;
	color:#ff9955;
}
```

### i

<i> 标签显示斜体文本效果。



### template

html中的`template`标签中的内容在页面中不会显示。但是在后台查看页面DOM结构存在`template`标签。这是因为template标签天生不可见，它设置了`display:none;`属性。

```
<!--当前页面只显示"我是自定义表现abc"这个内容，不显示"我是template",这是因为template标签天生不可见-->
<template><div>我是template</div></template>
<abc>我是自定义表现abc</abc>
```



vue 中的 template

1. template标签在vue实例绑定的元素内部

   它是可以显示template标签中的内容，但是查看后台的dom结构不存在template标签。如果template标签不放在vue实例绑定的元素内部默认里面的内容不能显示在页面上，但是查看后台dom结构存在template标签。

   ```
   <div id="app">
       <!--此处的template标签中的内容显示并且在dom中不存在template标签-->
       <template>
           <div>我是template</div>
           <div>我是template</div>
       </template>
   </div>
   <!--此处的template标签中的内容在页面中不显示，但是在dom结构存在该标签及内部结构-->
   <template id="tem">
       <div id="div1">我是template</div>
       <div>我是template</div>
   </template>
   <script src="node_modules/vue/dist/vue.js"></script>
   <script>
       let vm = new Vue({
           el: "#app",
       });
   </script>
   ```

   vue实例绑定的元素内部的template标签不支持v-show指令，即v-show="false"对template标签来说不起作用。但是此时的template标签支持v-if、v-else-if、v-else、v-for这些指令。

2. vue实例中的template属性
   将实例中template属性值进行编译，并将编译后的dom替换掉vue实例绑定的元素，如果该vue实例绑定的元素中存在内容，这些内容会直接被覆盖。
   特点：

   * 如果vue实例中有template属性，会将该属性值进行编译，将编译后的虚拟dom直接替换掉vue实例绑定的元素（即el绑定的那个元素）；

   * template属性中的dom结构只能有一个根元素，如果有多个根元素需要使用v-if、v-else、v-else-if设置成只显示其中一个根元素；

   * 在该属性对应的属性值中可以使用vue实例data、methods中定义的数据。

     ```
     <!--此处页面显示hello-->
     <div id="app"></div>
     <!--此处template标签必须在vue绑定的元素外面定义，并且在页面中不显示下面的template标签中的内容-->
     <template id="first">
         <div v-if="flag">{{msg}}<div>
         <div v-else>111<div>
     </template>
     <script src="./node_modules/vue/dist/vue.js"></script>
     <script>
         let vm = new Vue({
             el:"#app",
             data:{
                 msg:"hello",
                 flag:true
             },
             template:"#first"//通过该属性可以将自定义的template属性中的内容全部替换app的内容，并且会覆盖里面原有的内容，并且在查看dom结构时没有template标签
         });
     </script>
     ```

     