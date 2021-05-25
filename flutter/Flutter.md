### 环境搭建

[在macOS上搭建Flutter开发环境](https://flutterchina.club/setup-macos/)

1. 下载flutter

   ```
   git clone -b beta https://github.com/flutter/flutter.git
   export PUB_HOSTED_URL=https://pub.flutter-io.cn 
   export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn 设置
   export PATH=[你的位置]/flutter/bin:$PATH
   
   ```

2. 运行 ```flutter doctor```,按照提示进行安装缺失的依赖项，安装iOS相关的就可以，Android可以先不管。

### Hello World

flutter项目名称不能像 iOS 那样有大写.必须全是小写，使用'_'分割字符。

1. 全小写

2. a-z0-9_

3. 不能是保留关键字

   ```
   // 创建flutter工程，名字是myapp，入口是myapp/lib/main.dart
   $ flutter create myapp
   
   $ flutter run 
   // 如果有多设备需要选择一个设备或者选择全部
   $ flutter run -d DeviceID 
   
   main() {
   	runApp(Center(child : Text('wwww')));
   }
   ```

### IDE

下载一个VSCode,安装 Dart 和 Flutter 扩展。

使用 VSCode 打开项目即可显示运行。
注意选择一个设备，如果是已开启的模拟器，就可以运行成功；如果是真机，可能会遇到iOS证书问题问题。
注意看调试控制台输出的信息，按照提示去做就可以了。

1. open ios/Runner.xcworkspace
2. 在xcode中配置证书，Run.

可能遇到的问题

```
Launching lib/main.dart on iPhone in debug mode...
Automatically signing iOS for device deployment using specified development team in Xcode project: BN7E4W99SM
Xcode build done.                                           11.8s
env: ios-deploy: No such file or directory
Could not install build/ios/iphoneos/Runner.app on f1ab52ed8dcf23ab2ab3eccafdd0d37ede0a03f5.
Try launching Xcode and selecting "Product > Run" to fix the problem:
  open ios/Runner.xcworkspace
Error launching application on iPhone.
```

运行一下 

```
$ flutter doctor

...
✗ ios-deploy not installed. To install with Brew:
        brew install ios-deploy
[✓] Android Studio (version 3.2)

# 运行
$ brew install ios-deploy
```

### Widget & State

一切皆为widget。

从设计上来讲，widget是临时的，state可以保存状态。所以在Demo中，可以看到使用widget的地方都是零时创建，而不是像iOS/Android那样作为一个成员被持有，但不代表widget不能被持有，iOS/Android懒加载那一套同样可以用在Flutter上。

Flutter的widget被设计成可以快速频繁创建的对象是出于简化代码的目的，使用Flutter就不需要维护很多状态，直接创建一个就可以，不用把界面从一个状态更新到另一个状态。

### StatelessWidget & StatefulWidget

1. 什么时候使用StatelessWidget？什么时候使用StatefulWidget？

   如果widget在创建后不再改变，使用StatelessWidget，
   如果widget在创建后需要改变，比如常见的需要显示网络请求返回的数据，使用StatefulWidget

2. 如果一个widget中部分内容可变，有没有必要仅仅针对需要改变的部分创建StatefulWidget？

   Flutter framework针对 build 方法进行了优化，不需要单独针对变化的部分创建StatefulWidget，
   build 的效率由Flutter framework来保证。

3. StatefulWidget 的流程

   ```
   // 不需要手动调用build,调用setState,将变化的内容设置好，setState会自动触发build
   setState((){
   	// 变化的内容	
   })
   	
   Widget build(BuildContext context) {
   	return ...;
   }
   ```

因为这个和之前的iOS/Android区别很大，所以在Flutter生成的模板文件中做了特别的注释说明，仔细阅读main.dart就可以。

Cupertino & Material

- Cupertino，iOS风格的widget
- Material，Android风格的widget

```
CupertinoApp (UIApplication)
	CupertinoTabScaffold (UITabBarController)
		CupertinoPageScaffold (UINavigationController)
		CupertinoPageScaffold (UINavigationController)
```

大部分Demo都是用Material风格的widget,Cupertino使用就需要自己探索。

```
import 'package:flutter/cupertino.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
     return CupertinoApp(home:MyHomePage(title: 'Flutter Demo Home Page'),);
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<Object>dataSources = [1,2,3,4];
  
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(tabBar: 
      CupertinoTabBar(items: 
          <BottomNavigationBarItem>[BottomNavigationBarItem(icon: Icon(IconData(1)),title: Text("tab1")),
                                    BottomNavigationBarItem(icon: Icon(IconData(1)),title: Text("tab2"))],), 
      tabBuilder: (BuildContext context, int index) {
         return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(),
            child:BaseListVC(dataSources),);
      },
      );
  }
}
```



### CupertinoButton 

iOS 风格的按钮，使用的时候需要注意 minSize 和 padding 都是有默认值的，设置了minSize < 44 后，如果不设置 padding，就会导致 title 没有居中

```dart
var withDrawButton = CupertinoButton(
  child: Text("提现",style: TextStyle(color: xn_orange,fontSize: 14),), 
  onPressed: null,
  minSize: 30,
  padding: EdgeInsets.all(0),
);  
```



### 资源加载

> 本地资源

获取本地资源比较麻烦，需要编辑 pubspec.yaml 文件，这个文件在项目根目录下。

找到被注释的assets

```
# To add assets to your application, add an assets section, like this:
# assets:

```

打开注释，将资源文件copy到项目里面，图片位置需要申明才能使用

```
# The following section is specific to Flutter.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  assets:
   - images/icon_order.png
   - images/icon_order1.png
   - images/icon_right.png
   # 也可以直接指定目录，这样整个目录下的文件都可以被引用
   - image/

```

在根目录下创建了一个images文件夹，将@1x图片直接放进去。

分辨率处理：在images下面创建文件夹，2.0x表示@2x。通过flutter提供的方法获取图片时会自动返回最适合的分辨率图片，如果对应的分辨率没有图片，会从低分辨率往上查找，使用最先找到的图片，可以只提供@2x或者@3x。

```
$ ls -1 images

2.0x
	icon_order.png
3.0x
	icon_order.png
	icon_order1.png
	icon_right.png
  icon_order.png

```

flutter 应该存在一些bug,如果在代码中加载了一张没有声明的图片，那么已经声明的图片也无法加载。

> 网络资源

### ListView

```
 Widget _setupListView() {
    return ListView.builder(
      itemCount: 1+this.accountVM.singleItems.length,
      itemBuilder: (context,i) {
        if (i == 0) {
          return _setupHeader();
        } else {
          XNAccountSingleCellModel vm = this.accountVM.singleItems[i-1];
          return Text(vm.title);
        }
      });
  }

```



### 绝对布局 Stack + Positioned

```
Stack stack = Stack(
  children: <Widget>[
    Positioned(child: image,top: _backImageY,left: _backImageX,width: _backImageWidth,height: _backImageHeight,),
    notify
],)

```

使用 Stack 作为上层容器，就可以使用 iOS frame 的方式进行布局。

### Row

多个控件作为一行的时候，可以使用Row。配合 Expanded 可以实现android matchParent、weight 的效果。

### Column

多个空间形成一列的时候，可以使用column。配合 Expanded 可以实现android matchParent、weight 的效果。

### 富文本

```
Text.rich(
    TextSpan(text: "注册送",
      style: TextStyle(fontSize: 14,color:Colors.white),
      children: <TextSpan>[
        TextSpan(text: '518',style: TextStyle(fontSize: 32,color: xn_orange),),
        TextSpan(text: "元",style: TextStyle(fontSize: 14,color:xn_orange)),
        TextSpan(text: "红包",style: TextStyle(fontSize: 14,color:Colors.white))
  ]),
);

```





### ScrollView 滑动距离监听

```dart
// 设置 controller 为 TrackingScrollController()，这里 controller 有点代理的意思
var _scrollController = TrackingScrollController();

_setupListView() {
	return ListView.builder(
    itemCount: dataSource.count
    itemBuilder: (context,i) {
      return Text("$i")
    },
    controller: _scrollController,
  )
}

// 监听 ListView 发出的通知
NotificationListener(onNotification: dataNotification,child:_setupListView(),);

bool dataNotification(ScrollNotification notification) {
  if (notification is ScrollUpdateNotification) {
    var y = _scrollController.offset;
    print(y)
  }
}

```



## Dart

### 数组 List

```
var fruits = new List();
 // 添加元素
 fruits.add('apples');

 // 添加多个元素
 fruits.addAll(['oranges', 'bananas']);
 
List list = [10,9,1];


```

## 字典 map

```
Map company = {"alibaba":"阿里巴巴与四十大盗"};

```

