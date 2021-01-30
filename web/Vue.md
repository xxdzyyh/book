

# Vue.js

[TOC]

Vue.js 使用了基于 HTML 的模版语法，允许开发者声明式地将 DOM 绑定至底层 Vue 实例的数据。

Vue.js 的核心是一个允许你采用简洁的模板语法来声明式的将数据渲染进 DOM 的系统。

结合响应系统，在应用状态改变时， Vue 能够智能地计算出重新渲染组件的最小代价并应用到 DOM 操作上。

## 集成

```
<!-- 开发环境版本，包含了有帮助的命令行警告 -->
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>

<!-- 生产环境版本，优化了尺寸和速度 -->
<script src="https://cdn.jsdelivr.net/npm/vue"></script>
```

## 指令

### v-html 

使用 v-html 指令用于输出 html 代码。不使用v-html，对应的字符串会当做普通字符串处理，而不是像html那样加入DOM。

```
<div id="app">
    <div v-html="message"></div>
</div>
<script>
new Vue({
  el: '#app',
  data: {
    message: '<h1>菜鸟教程</h1>'
  }
})
</script>
```

### v-bind 

关联HTML 属性中的值应使用 v-bind 指令。没使用 v-bind 的时候，对应的属性只接受字符串，不接受表达式，使用 v-bind 后，变成了表达式或者函数，可以动态赋值。

`v-bind` 的缩写为 `:` ，所以看起来有些HTML属性是以`:`开头的，但其实只是`v-bind`的缩写

```
<el-tooltip placement="right" content="url" popper-class="tips">
<el-tooltip placement="right" v-bind:content="scope.row.url" popper-class="tips">
<el-tooltip placement="right" :content="scope.row.url" popper-class="tips">
```



`v-bind` 对 class/style做了特殊的处理

// TODO 做了哪些特殊处理



以下实例判断 use 的值，如果为 true 使用 class1 类的样式，否则不使用该类

```
<div id="app">
  <label for="r1">修改颜色</label><input type="checkbox" v-model="use" id="r1">
  <br><br>
  <div v-bind:class="{'class1': use}">
    v-bind:class 指令
  </div>
</div>
    
<script>
new Vue({
  el: '#app',
  data:{
      use: false
  }
});
</script>
```

```
<!-- 完整语法 -->
<a v-bind:href="url"></a>
<!-- 缩写 -->
<a :href="url"></a>
```

> V-bind:class

可以用来动态设置样式

```
<div class="static"
     v-bind:class="{ 'active' : isActive, 'text-danger' : hasError }">
</div>
```

### v-if

v-if 指令将根据表达式 seen 的值(true 或 false )来决定是否插入 p 元素。

```
<div id="app">
    <p v-if="seen">现在你看到我了</p>
</div>
    
<script>
new Vue({
  el: '#app',
  data: {
    seen: true
  }
})
</script>
```

v-else: 指令可以和v-if配合使用

v-else-if:  

### v-on

v-on用于监听 DOM 事件

```
<a v-on:click="doSomething">
```

```
<!-- 完整语法 -->
<a v-on:click="doSomething"></a>
<!-- 缩写 -->
<a @click="doSomething"></a>
```

除了直接绑定到一个方法，也可以用内联 JavaScript 语句：

```
<div id="app">
  <button v-on:click="say('hi')">Say hi</button>
  <button v-on:click="say('what')">Say what</button>
</div>
 
<script>
new Vue({
  el: '#app',
  methods: {
    say: function (message) {
      alert(message)
    }
  }
})
</script>
```

Vue.js 为 v-on 提供了事件修饰符来处理 DOM 事件细节，如：event.preventDefault() 或 event.stopPropagation()。

Vue.js 通过由点 **.** 表示的指令后缀来调用修饰符。

```
<!-- 阻止单击事件冒泡 -->
<a v-on:click.stop="doThis"></a>
<!-- 提交事件不再重载页面 -->
<form v-on:submit.prevent="onSubmit"></form>
<!-- 修饰符可以串联  -->
<a v-on:click.stop.prevent="doThat"></a>
<!-- 只有修饰符 -->
<form v-on:submit.prevent></form>
<!-- 添加事件侦听器时使用事件捕获模式 -->
<div v-on:click.capture="doThis">...</div>
<!-- 只当事件在该元素本身（而不是子元素）触发时触发回调 -->
<div v-on:click.self="doThat">...</div>
<!-- click 事件只能点击一次，2.1.4版本新增 -->
<a v-on:click.once="doThis"></a>
```

Vue 允许为 v-on 在监听键盘事件时添加按键修饰符：

```
<!-- 只有在 keyCode 是 13 时调用 vm.submit() -->
<input v-on:keyup.13="submit">
```

记住所有的 keyCode 比较困难，所以 Vue 为最常用的按键提供了别名：

```
<!-- 同上 -->
<input v-on:keyup.enter="submit">
<!-- 缩写语法 -->
<input @keyup.enter="submit">
```

全部的按键别名：

- `.enter`
- `.tab`
- `.delete` (捕获 "删除" 和 "退格" 键)
- `.esc`
- `.space`
- `.up`
- `.down`
- `.left`
- `.right`
- `.ctrl`
- `.alt`
- `.shift`
- `.meta`

### v-show

```
<h1 v-show="ok">Hello!</h1>
```

`v-show` 和 `v-if`的区别，`v-show`只是简单的隐藏和显示，`v-if`决定要不要创建、销毁

### v-for

其实就是swift的 for ... in

```
<div id="app">
  <ul>
    <li v-for="n in 10">
     {{ n }}
    </li>
  </ul>
</div>
```

```
<div id="app">
  <ol>
    <li v-for="site in sites">
      {{ site.name }}
    </li>
  </ol>
</div>
 
<script>
new Vue({
  el: '#app',
  data: {
    sites: [
      { name: 'Runoob' },
      { name: 'Google' },
      { name: 'Taobao' }
    ]
  }
})
</script>

<ul>
  <template v-for="site in sites">
    <li>{{ site.name }}</li>
    <li>--------------</li>
  </template>
</ul>
```

v-for 可以通过一个对象的属性来迭代数据

```
<div id="app">
  <ul>
    <li v-for="value in object">
    {{ value }}
    </li>
  </ul>
</div>
 
<script>
new Vue({
  el: '#app',
  data: {
    object: {
      name: '菜鸟教程',
      url: 'http://www.runoob.com',
      slogan: '学的不仅是技术，更是梦想！'
    }
  }
})
</script>
```

<p style="background-color:#000fff"></p>

### v-model

指令用来在 input、select、textarea、checkbox、radio 等表单控件元素上创建双向数据绑定，根据表单上的值，自动更新绑定的元素的值。

```
<div id="app">
    <p>{{ message }}</p>
    <input v-model="message">
</div>
    
<script>
new Vue({
  el: '#app',
  data: {
    message: 'Runoob!'
  }
})
</script>
```

## Vue实例

### data

值可以是 object 或者 function，但是在组件中，只能是 function。组件是可以复用的，所以组件中的data如果返回同一个对象，那一处修改，其他地方都会改变。

Vue 将会递归将data的属性转换为 getter/setter,从而让data的属性能够响应数据变化。

```
const Vue = {
	_appname: '',
	get appname() {
		return this._appname;
	}
	set appname(value) {
		this.appname = value
	}
}
```

实例创建之后，可以通过 `vm.$data`访问原始数据对象。Vue实例也代理了data对象上所有的属性，因此，访问

`vm.a` 等价于访问 `vm.$data.a`。以 `_`或者'$'开头的属性不会被Vue实例代理，因为可能和内置的属性、API方法冲突，你可以使用例如`vm.$data._property`的方式访问这些属性。

```
new Vue({
	el: "#app",
	data: {
		"key1" : value1
	}
})
```

```
export default {
  name: 'app-new',
  data: function () {
    return {
      platform: '1',
      appname: ''
    }
  },
  methods: {
  	onSubmit() {
      alert(this.appname + '---' + this.platform)
    }
  }
})
```

除了数据属性，Vue 实例还提供了一些有用的实例属性与方法。它们都有前缀 $，以便与用户定义的属性区分开来。



### props

Prop 是你可以在组件上注册的一些自定义 attribute。当一个值传递给一个 prop attribute 的时候，它就变成了那个组件实例的一个 property。为了给博文组件传递一个标题，我们可以用一个 `props`选项将其包含在该组件可接受的 prop 列表中：

```
Vue.component('blog-post', {
  props: ['title'],
  template: '<h3>{{ title }}</h3>'
})

// use
<blog-post title="My journey with Vue"></blog-post>
```



```
new Vue({
  el: '#blog-post-demo',
  data: {
    posts: [
      { id: 1, title: 'My journey with Vue' },
      { id: 2, title: 'Blogging with Vue' },
      { id: 3, title: 'Why Vue is so fun' }
    ]
  }
})
```



```
<blog-post
  v-for="post in posts"
  v-bind:key="post.id"
  v-bind:title="post.title"
></blog-post>

// 直接传入一个post对象
Vue.component('blog-post', {
  props: ['post'],
  template: `
    <div class="blog-post">
      <h3>{{ post.title }}</h3>
      <div v-html="post.content"></div>
    </div>
  `
})
```



```
Vue.component('my-component', {
  props: {
  	propA: Number,
  	propB: [String, Number],
  	propC: {
      type: String,
      required: true
    },
     // 带有默认值的数字
    propD: {
      type: Number,
      default: 100
    },
    // 带有默认值的对象
    propE: {
      type: Object,
      // 对象或数组默认值必须从一个工厂函数获取
      default: function () {
        return { message: 'hello' }
      }
    },
    // 自定义验证函数
    propF: {
      validator: function (value) {
        // 这个值必须匹配下列字符串中的一个
        return ['success', 'warning', 'danger'].indexOf(value) !== -1
      }
    }
  }  
}
```



### filters

Vue.js 允许你自定义过滤器，被用作一些常见的文本格式化。由"管道符"指示, 格式如下：

```
<!-- 在两个大括号中 -->
{{ message | capitalize }}

<!-- 在 v-bind 指令中 -->
<div v-bind:id="rawId | formatId"></div>
```

过滤器函数接受表达式的值作为第一个参数。

以下实例对输入的字符串第一个字母转为大写：

```
<div id="app">
  {{ message | capitalize }}
</div>
    
<script>
new Vue({
  el: '#app',
  data: {
    message: 'runoob'
  },
  filters: {
    capitalize: function (value) {
      if (!value) return ''
      value = value.toString()
      return value.charAt(0).toUpperCase() + value.slice(1)
    }
  }
})
</script>
```

```
// 过滤器可以串联：
{{ message | filterA | filterB }}
// 过滤器可以串联：
{{ message | filterA('arg1', arg2) }}

// message 是第一个参数，字符串 'arg1' 将传给过滤器作为第二个参数， arg2 表达式的值将被求值然后传给过滤器作为第三个参数
```



### computed

```
<div id="app">
  {{ message.split('').reverse().join('') }}
</div>
```
computed 是基于它的依赖缓存，只有相关依赖发生改变时才会重新取值。

```
<div id="app">
  <p>原始字符串: {{ message }}</p>
  <p>计算后反转字符串: {{ reversedMessage }}</p>
</div>
 
<script>
var vm = new Vue({
  el: '#app',
  data: {
    message: 'Runoob!'
  },
  computed: {
    // 计算属性的 getter
    reversedMessage: function () {
      // `this` 指向 vm 实例
      return this.message.split('').reverse().join('')
    }
  }
})
</script>
```

使用 methods ，在重新渲染的时候，函数总会重新调用执行
```
methods: {
  reversedMessage2: function () {
    return this.message.split('').reverse().join('')
  }
}
```

computed 属性默认只有 getter ，不过在需要时你也可以提供一个 setter 

```
var vm = new Vue({
  el: '#app',
  data: {
    name: 'Google',
    url: 'http://www.google.com'
  },
  computed: {
    site: {
      // getter
      get: function () {
        return this.name + ' ' + this.url
      },
      // setter
      set: function (newValue) {
        var names = newValue.split(' ')
        this.name = names[0]
        this.url = names[names.length - 1]
      }
    }
  }
})
// 调用 setter， vm.name 和 vm.url 也会被对应更新
vm.site = '菜鸟教程 http://www.runoob.com';
document.write('name: ' + vm.name);
document.write('<br>');
document.write('url: ' + vm.url);
```

### watch

类似于OC kvo,观察某个

```
<div id = "app">
    <p style = "font-size:25px;">计数器: {{ counter }}</p>
    <button @click = "counter++" style = "font-size:25px;">点我</button>
</div>
<script type = "text/javascript">
var vm = new Vue({
    el: '#app',
    data: {
        counter: 1
    }
});
vm.$watch('counter', function(nval, oval) {
    alert('计数器值的变化 :' + oval + ' 变为 ' + nval + '!');
});
</script>
```



### v-model

在表单控件元素上创建双向数据绑定

![img](https://www.runoob.com/wp-content/uploads/2017/01/20151109171527_549.png)

```
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Vue 测试实例 - 菜鸟教程(runoob.com)</title>
<script src="https://cdn.staticfile.org/vue/2.2.2/vue.min.js"></script>
</head>
<body>
<div id="app">
  <p>input 元素：</p>
  <input v-model="message" placeholder="编辑我……">
  <p>消息是: {{ message }}</p>
	
  <p>textarea 元素：</p>
  <p style="white-space: pre">{{ message2 }}</p>
  <textarea v-model="message2" placeholder="多行文本输入……"></textarea>
</div>

<script>
new Vue({
  el: '#app',
  data: {
    message: 'Runoob',
		message2: '菜鸟教程\r\nhttp://www.runoob.com'
  }
})
</script>
</body>
</html>
```

```
<div id="app">
  <select v-model="selected" name="fruit">
    <option value="">选择一个网站</option>
    <option value="www.runoob.com">Runoob</option>
    <option value="www.google.com">Google</option>
  </select>
 
  <div id="output">
      选择的网站是: {{selected}}
  </div>
</div>
 
<script>
new Vue({
  el: '#app',
  data: {
    selected: '' 
  }
})
</script>
```

如果想自动将用户的输入值转为 Number 类型（如果原值的转换结果为 NaN 则返回原值），可以添加一个修饰符 number 给 v-model 来处理输入值：

```
<input v-model.number="age" type="number">
```



在默认情况下， v-model 在 input 事件中同步输入框的值与数据，但你可以添加一个修饰符 lazy ，从而转变为在 change 事件中同步：

```
<!-- 在 "change" 而不是 "input" 事件中更新 -->
<input v-model.lazy="msg" >
```



### component

组件（Component）是 Vue.js 最强大的功能之一。组件可以扩展 HTML 元素，封装可重用的代码。

其实就类似于iOS 自定义的view，定义之后，可以到处使用。

```
<p>添加一个段落</p>

<mycomponent></mycomponent>
```



> 全局组件 所有实例都能用

```
<div id="app">
    <runoob></runoob>
</div>
 
<script>
// 注册
Vue.component('runoob', {
  template: '<h1>自定义组件!</h1>'
})
// 创建根实例
new Vue({
  el: '#app'
})
</script>
```

> 局部组件

```
<div id="app">
    <runoob></runoob>
</div>
 
<script>
var Child = {
  template: '<h1>自定义组件!</h1>'
}
 
// 创建根实例
new Vue({
  el: '#app',
  components: {
    // <runoob> 将只在父模板可用
    'runoob': Child
  }
})
</script>
```

### template

```
let app = new Vue({
	el: "#app",
	data: {
	
	},
	template: '<h3>我是模板</3>'
})
```



## 网络请求

vue是基于数据驱动的，不需要直接操作DOM，因此没有必要引入jquery
vue提供了一款轻量的http请求库，vue-resource
vue-resource除了提供http请求外，还提供了inteceptor拦截器功能，在访问前，访问后，做处理。

### vue-resource

```
methods: {
  getPeoples: function () {
    var vm = this;
    vm.$http.get('http://localhost:20000/my_test').then(
      function (data) {
          var newdata = JSON.parse(data.body)
          vm.$set('peoples', newdata.result)
      }).catch(function (response) {
          console.log(response)
      })
  }
}
```



#### interceptors

拦截器是拦截所有的请求，这样错误可以统一处理

也可以统一显示loading,关闭等。

```
Vue.http.interceptors.push(function(request, next){
	//...
	//请求发送前的处理逻辑
	//...
	next(function(response){
		//...
		//请求发送后的处理逻辑
		//...
		//根据请求的状态，response参数会返回给successCallback或errorCallback
		return response
	})
})
```

拦截器使用示例

```
<div id="help">
        <loading v-show="showLoading"></loading>
    </div>
<template id="loading-template">
			<div class="loading-overlay">
				<div class="sk-three-bounce">
					<div class="sk-child sk-bounce1"></div>
					<div class="sk-child sk-bounce2"></div>
					<div class="sk-child sk-bounce3"></div>
				</div>
			</div>
    </template>
<script>
var help = new Vue({
        el: '#help',
        data: {
            showLoading: false
        },
        components: {
            'loading': {
                template: '#loading-template'
            }
        }
    })

    Vue.http.interceptors.push(function(request, next){
        help.showLoading = true
        next(function (response) {
            help.showLoading = false
            return response
        })
    })
</script>
```



## 语言特性

### export vs export default

export 和export default 的区别在于：export 可以导出多个命名模块，例如：

```
//demo1.js
export const str = 'hello world'

export function f(a){
    return a+1
}
```

对应的引入方式：

```
//demo2.js
import { str, f } from 'demo1'
```

export default 只能导出一个默认模块，这个模块可以匿名，例如：

```
//demo1.js
export default {
    a: 'hello',
    b: 'world'      
}
```

对应的引入方式：

```
//demo2.js
import obj from 'demo1'
```

引入的时候可以给这个模块取任意名字，例如 "obj"，且不需要用大括号括起来。

## 路由

### vue-router



### this.$route vs this.$router

router是VueRouter的一个对象，通过Vue.use(VueRouter)和VueRouter构造函数得到一个router的实例对象，这个对象中是一个全局的对象，他包含了所有的路由包含了许多关键的对象和属性。

```
$router.push({path:'home'});本质是向history栈中添加一个路由，在我们看来是 切换路由，但本质是在添加一个history记录
$router.replace({path:'home'});//替换路由，没有历史记录
```

route是一个跳转的路由对象，每一个路由都会有一个route对象，是一个局部的对象，可以获取对应的name,path,params,query等。



>  query 会显示在状态栏,刷新后值还在，而 params 不会显示在状态栏，但是刷新后会变成 undefined

```
// 在query中传递自定义对象，刷新后，对象无法读取,对象变成了 string 类型，内容为 '[object Object]'
this.$router.push({ name:'detail',query:{query:this.getRequestParams,model:model}})

this.$router.push({ name:'detail',params:{query:this.getRequestParams,model:model}})
```

解决方法：使用 localStorage 存储 params

```
created() {
	localStorage.setItem('tempData',JSON.)
}
```





## 实战

```
<template>
  <el-container>
    <el-header>
      <el-button @click="getAppListData">获取数据列表</el-button>
    </el-header>
    <el-main>
      <ul v-if="isDataReady">
        <li v-for="value in this.dataSource">
          {{ value }}
        </li>
      </ul>
    </el-main>
  </el-container>
</template>
<script>

export default {
  name: 'app-tables',
  data() {
    return {
      isDataReady : false,
      dataSource : []
    }
  },
  methods: {
    getAppListData () {
      let uid = localStorage.getItem('USER')
      this.$http.get(window.serverConfig.SERVER + '/app?userId=' + uid).then(res => {
        if (res.body.code === 200) {
          this.dataSource = res.body.data
          this.isDataReady = true
        }
      })
    }
  }
}
</script>
<style scoped>
</style>
```

## 生命周期<img src="https://cn.vuejs.org/images/lifecycle.png" alt="Vue 实例生命周期" style="zoom:33%;" />

了解了生命周期，就可以在合适的地方做合适的事情。

```
beforeCreate?(this: V): void;
created?(): void;
beforeDestroy?(): void;
destroyed?(): void;
beforeMount?(): void;
mounted?(): void;
beforeUpdate?(): void;
updated?(): void;
activated?(): void;
deactivated?(): void;
errorCaptured?(err: Error, vm: Vue, info: string): boolean | void;
serverPrefetch?(this: V): Promise<void>;
```



### nextTick

Vue 实现响应式并**不是数据发生变化之后 DOM 立即变化**，而是按一定的策略进行 DOM 的更新。

简单来说，Vue 在修改数据后，视图不会立刻更新，而是等**同一事件循环**中的所有数据变化完成之后，再统一进行视图更新。同步里执行的方法，每个方法里做的事情组成一个事件循环；接下来再次调用的是另一个事件循环。

this.$nextTick()将回调延迟到下次 DOM 更新循环之后执行。在修改数据之后立即使用它，然后等待 DOM 更新。它跟全局方法 Vue.nextTick 一样，不同的是回调的 this 自动绑定到调用它的实例上。

修改数据后，会触发对象的set方法，会通知watcher，从而触发watcher的update方法，update方法内会将watcher添加进watcher队列，执行nexttick，把清空wacher队列的方法加入到微任务，等待同步事件执行完成后，浏览器就会执行微任务，从而更新dom。

所以何时更新dom就看同步事件何时执行完，定时器是宏任务，每执行完一次定时器都会更新一次DOM

使用JS代码修改DOM后，并不会立即生效，DOM

**需要注意的是，在 created 和 mounted 阶段，如果需要操作渲染后的试图，也要使用 nextTick 方法。**

官方文档说明：mounted 不会承诺所有的子组件也都一起被挂载。如果你希望等到整个视图都渲染完毕，可以用 vm.$nextTick：



setNeedDisplay在receiver标上一个需要被重新绘图的标记，在下一个draw周期自动重绘。



## Vuex

1. 声明

   ```
   const store = new Vuex.Store({
     state: {
       apps: [],
       appVersion:''
     },
     getters: {
       getApps(state) {
         return state.apps
       },
       getAppVersion(state) {
         return state.appVersion
       }
     },
     mutations: {
       updateApps(state,apps) {
         // vue监听不到数组的改变 所以清空重置一下
         state.apps = null;
         state.apps = apps
       },
       updateAppVersion(state,appVersion) {
         state.appVersion = appVersion
       }
     }
   })
   
   // Vuex 提供了一个从根组件向所有子组件，以 store 选项的方式“注入”该 store 的机制
   //  this.$store
   new Vue({
     el: '#app',
     router,
     store: store,
     components: { App },
     template: '<App/>'
   })
   ```



2. 更新

   ```
   // 通过提交 mutation 的方式，而非直接改变 store.state.apps，是因为我们想要更明确地追踪到状态的变化。
   this.$store.commit('updateApps',this.tableData)
   ```

   

3. 获取

   由于 Vuex 的状态存储是响应式的，从 store 实例中读取状态最简单的方法就是在计算属性中返回某个状态.

   每当 `store.state.count` 变化的时候, 都会重新求取计算属性，并且触发更新相关联的 DOM。

   ```
   computed: {
     count () {
       return this.$store.state.count
     }
   }
   
   // 直接watch也没有问题
   watch: {
     '$store.state.apps': function(apps, oldApps){
       this.myApps = apps;
       this.updateUI()
     }
   }
   ```

   

