# weex



### 创建一个 App

请确保你已经安装了 [Node.js](https://nodejs.org/)，然后全局安装 `weex-cli`。

```bash
npm install weex-toolkit -g
```

目前 `weex-cli` 只支持创建 Vue.js 的项目。

```
weex create awesome-app
```

### 编译和运行

默认情况下 `weex create` 命令并不初始化 iOS 和 Android 项目，你可以通过执行 `weex platform add` 来添加特定平台的项目。

```bash
weex platform add ios
weex platform add android
```

```bash
weex run ios
weex run android
weex run web
```

```
weex run ios

$ Compile JSBundle done
$ Start hotreload server done
$ Set native config done
$ Copy JS source done
$ Watch JS source done
```

首先编译 Vue.js 项目，然后将编译好的文件 copy 到 bundlejs 文件夹下。

原生项目里



### 开发

```bash
cd awesome-app
npm install
npm start
```

然后工具会启动一个本地的 web 服务，监听 `8081` 端口。你可以打开 `http://localhost:8081` 查看页面在 Web 下的渲染效果。 源代码在 `src/` 目录中，你可以像一个普通的 Vue.js 项目一样来开发.



### 注意

说是可以像一个普通的 Vue.js 项目一样来开发，但是如果你信了，你就太天真了。



开发还是要使用 weex 内置的各种组件

https://weex.apache.org/zh/docs/components/recycle-list.html



`<text>` 是 Weex 内置的组件，用来将文本按照指定的样式渲染出来.

- 不要在 `<div>` 中直接添加文本，而要使用 `<text>` 组件。
- 不可以在`<a>`标签内部直接添加文本，需要使用`<text>`标签来显示文本。



<template>下面只能有一个root节点。

```
<template>
  <div>
    <text>3.1415926</text>
    <button>1415926</button>
    <text class="message">Now, let's use Vue.js to build your Weex app.</text>
  </div>
</template>
```







