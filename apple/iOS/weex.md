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

