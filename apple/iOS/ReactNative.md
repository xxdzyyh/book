# RN



## 安装依赖

Node、Watchman、Xcode 和 CocoaPods。

```
brew install node
brew install watchman
```

### Yarn

[Yarn](http://yarnpkg.com/)是 Facebook 提供的替代 npm 的工具，可以加速 node 模块的下载。

```
npm install -g yarn
```



### 创建新的项目

```
npx react-native init AwesomeProject
```

创建一个最新版本的 RN 项目，其实就是一个模板。



### 编译并运行 React Native 应用

运行 iOS 项目

```
// 进入项目根目录
cd AwesomeProject

yarn ios
# 或者
yarn react-native run-ios
```

此命令会对项目的原生部分进行编译，同时在另外一个命令行中启动`Metro`服务对 js 代码进行实时打包处理（类似 webpack）。

`Metro`服务也可以使用`yarn start`命令单独启动。

在正常编译完成后，开发期间请保持 `Metro` 命令行窗口运行而不要关闭。以后需要再次运行项目时，如果没有修改过 ios 目录中的任何文件，则只需单独启动 `yarn start` 命令。

如果对 ios 目录中任何文件有修改，则需要再次运行`yarn ios`命令完成原生部分的编译。

`yarn ios`只是运行应用的方式之一。你也可以在 Xcode 中直接运行应用。



首先创建一个空目录用于存放 React Native 项目，然后在其中创建一个`/ios`子目录，把你现有的 iOS 项目拷贝到`/ios`子目录中。



### 2. 安装 JavaScript 依赖包

在项目根目录下创建一个名为`package.json`的空文本文件，然后填入以下内容：

```
{
  "name": "MyReactNativeApp",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "start": "yarn react-native start"
  }
}
```



> 示例中的`version`字段没有太大意义（除非你要把你的项目发布到 npm 仓库）。`scripts`中是用于启动 Metro 服务的命令。





### 安装最新版本的 React Native

```
yarn add react-native
```



### 网络请求

```
import React from 'react';
import { StyleSheet, Button, View, SafeAreaView, Text, Alert } from 'react-native';

const Separator = () => {
  return <View style={styles.separator} />;
}

const App = () => {

  return (
    <SafeAreaView style={styles.container}>
      <View>
        <Text style={styles.title}>
          The title and onPress handler are required. It is recommended to set
          accessibilityLabel to help make your app usable by everyone.
        </Text>

        <Button
          title="Press me"
          onPress={() => {
          fetch('https://reactnative.dev/movies.json')
      			.then((response) => { console.log(response.json());response.json() })
      			.then((json) => setData(json.movies))
      			.catch((error) => console.error(error))
      			.finally(() => setLoading(false));}}
        />
      </View>
      <Separator />
      <View>
        <Text style={styles.title}>
          Adjust the color in a way that looks standard on each platform. On
          iOS, the color prop controls the color of the text. On Android, the
          color adjusts the background color of the button.
        </Text>
        <Button
          title="Press me"
          color="#f194ff"
          onPress={() => {
            const request = new XMLHttpRequest();
            request.onreadystatechange = (e) => {
              if (request.readyState !== 4) {
                return;
              }

              if (request.status === 200) {
                console.log("success", request.responseText);
              } else {
                console.warn("error");
              }
            };

            request.open("GET", "https://reactnative.dev/movies.json");
            request.send();
          }}
        />
      </View>
      <Separator />
      <View>
        <Text style={styles.title}>
          All interaction for the component are disabled.
        </Text>
        <Button
          title="Press me"
          disabled
          onPress={() => Alert.alert('Cannot press this one')}
        />
      </View>
      <Separator />
      <View>
        <Text style={styles.title}>
          This layout strategy lets the title define the width of the button.
        </Text>
        <View style={styles.fixToText}>
          <Button
            title="Left button"
            onPress={() => {
              var file = { 
                uri: "fb6e26261321a5c2.mp4",
                type: 'multipart/form-data', 
                name: 'fb6e26261321a5c2.mp4' 
              };

              let formdata = new FormData();
              formdata.append('file', file);
              
              fetch(
                "http://106.75.140.11:8082/dc/buginsight/replay",
                {
                  method: "POST",
                  bodyType: "file",//后端接收的类型
                  body: formdata,
                  headers:{
                    'Content-Type':'multipart/form-data',
                  },
                }
              ).then(res => {
                console.log('ssssssssrrrrrrrrrrrrrr', res);
              }).catch(error => {
                console.log('sssssssseeeeeeeeeeeeer', error);
              });
            }}
          />
          <Button
            title="Right button"
            onPress={() => Alert.alert('Right button pressed')}
          />
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    marginTop: 20,
    marginHorizontal: 16,
  },
  title: {
    textAlign: 'center',
    marginVertical: 8,
  },
  fixToText: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  separator: {
    marginVertical: 8,
    borderBottomColor: '#737373',
    borderBottomWidth: StyleSheet.hairlineWidth,
  },
});
export default App;
```



