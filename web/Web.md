# Web

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

  