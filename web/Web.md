# Web



[TOC]

* HTML 定义了网页的内容
* CSS    描述了网页的布局
* JavaScript  网页的行为




| Web     | iOS                             | 描述           |      |
| ------- | ------------------------------- | -------------- | ---- |
| npm     | Cocoapods/Swift Package Manager | 第三方依赖管理 |      |
| webpack | Xcode                           | 打包工具       |      |

* `npm install` 安装第三方依赖



### webpack

webpack 是一个打包工具，相当于实现了iOS 代码到 IPA 这一步。 默认将项目代码编译为类浏览器环境里可用。

webpack 也有target的概念，可以为不同的环境（dev,release）创建多个target

webpack 的 source map 就类似于 iOS 的符号表。source map 的配置就类似于符号表的配置。



```
// 注意整个配置中我们使用 Node 内置的 path 模块，并在它前面加上 __dirname这个全局变量。
// 可以防止不同操作系统之间的文件路径问题，并且可以使相对路径按照预期工作。
const path = require('path');
```



* package.json 项目第三方依赖管理（类似于swift package.swift）

| 工具                  | 配置文件      | 锁定文件          |
| --------------------- | ------------- | ----------------- |
| npm                   | package.json  | package-lock.json |
| cocoapods             | Podfile       | Podfile.lock      |
| Swift Package Manager | package.swift |                   |

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

  定义好脚本之后，就可以使用脚本

  ```
  npm run dev
  npm run build 
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




### Express

[Express 中文网](https://www.expressjs.com.cn/)

Express 是一个保持最小规模的灵活的 Node.js Web 应用程序开发框架，为 Web 和移动应用程序提供一组强大的功能。

Express 的功能是非常的强大的，目前我们只用它来作为 web 服务器，也就是和 tomcat 一样的作用。



### 项目打包

```
$ npm run build

// 会生成一个dist文件夹，所有的东西都在dist下面
dist
```



### 项目运行

dist里面包含的网页的数据，而用户是通过 http 进行访问的，你怎么知道有人访问了我们的网页呢？

所以你需要一个 web服务器，监听用户的访问，然后将网页数据返回给用户。

Tomcat 是一个web服务器，Node上最常用的Web服务器也许是[Express](http://expressjs.com/)。



#### 创建 index.js

```
// 引入文件模块
const fs = require('fs');
// 引入处理路径的模块
const path = require('path');
// 引入处理post数据的模块
const bodyParser = require('body-parser');
// 引入Express
const express = require('express');
const app = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));
// app.use(api);
// 访问静态资源文件 这里是访问所有dist目录下的静态资源文件
app.use(express.static(path.resolve(__dirname, './dist')));
// 因为是单页应用 所有请求都走/dist/index.html
app.get('/', function(req, res) {
  const html = fs.readFileSync(path.resolve(__dirname, './dist/index.html'), 'utf-8');
  res.send(html)
})

const port = 9999;
app.listen(port);
console.log('success listen on ' + port +' http://127.0.0.1:' + port);
```

#### 安装依赖

```
// 获取项目package.json、package-lock.json，npm install 会读取这两个文件下载依赖到 node_modules 文件夹
npm install
```

#### 获取 dist

```
npm run build
```

#### web

```
$ ls web
dist              index.js          node_modules      package-lock.json package.json
```

#### 运行

```
node index.js
```



## npm

### 安装方式

有两种方式用来安装 npm 包：本地安装和全局安装。

至于选择哪种方式来安装，取决于我们如何使用这个包。

#### 全局安装

 如果你自己的模块依赖于某个包，并通过 Node.js 的 `require` 加载，那么你应该选择本地安装，这种方式也是 `npm install` 命令的默认行为。



#### 本地安装

如果你想将包作为一个命令行工具，（比如 grunt CLI），那么你应该选择[全局安装](https://www.npmjs.cn/getting-started/installing-npm-packages-globally)。

```
npm install -g jshint
```



#### 版本 package.json

在本地目录中如果没有 `package.json` 这个文件的话，那么最新版本的包会被安装。

如果存在 `package.json` 文件，则会在 `package.json` 文件中查找针对这个包所约定的[语义化版本规则](https://www.npmjs.cn/getting-started/semantic-versioning)，然后安装符合此规则的最新版本。



#### 使用已安装的包

一旦将包安装到 `node_modules` 目录中，你就可以使用它了。比如在你所创建的 Node.js 模块中，你可以 `require` 这个包。



创建一个名为 `index.js` 的文件，并保存如下代码：

```
// index.js
var lodash = require('lodash');
 
var output = lodash.without([1, 2, 3], 1);
console.log(output);
```

运行 `node index.js` 命令。应当输出 `[2, 3]`。



如果你没能正确安装 `lodash`，你将会看到如下的错误信息：

```
module.js:340
    throw err;
          ^
Error: Cannot find module 'lodash'
```

可以在 `index.js` 所在的目录中运行 `npm install lodash` 命令来修复这个问题。



#### 更新已经安装的包

```
npm update
```

#### --save

> 在 npm 5 之前的版本

使用 npm install 默认选项安装包时，仅仅会把包下载到 node_modules/ 中，并不会同时修改 package.json。而使用 --save 选项就可以在安装包的同时，修改 package.json 文件。

> 在 npm 5 之后的版本

npm install 安装包时，默认便会修改 package.json 文件，所以 --save 选项已经不再需要了。

