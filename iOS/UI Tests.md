### UI Tests

UI Tests 的添加方式和 Unit Tests一样，测试方法也一样，但是检查的角度是不同的。

一个值得注意的地方：

创建单元测试后，有个选项"Allow testing Host Application APIs",UI Tests 是没有这个选项的，即使配置了Header Search Path也无法像单元测试那样测试 Target Application 的代码。

![屏幕快照2019-09-03上午10.32.10.png](https://i.loli.net/2019/09/03/uXROScH4VwbyKMC.png)



![屏幕快照2019-09-03上午10.32.24.png](https://i.loli.net/2019/09/03/YhSkwbNTm4VfoqO.png)



### 相关类型

![屏幕快照2019-08-30下午4.00.23.png](https://i.loli.net/2019/08/30/N78lRSHbmagcGX5.png) 

这一类通用框架基本处理模式都是一样的，在视图树种查找特定节点，然后操作节点(XCUIElement)。

#### XCUIElementTypeQueryProvider

这个协议声明了如何去查询元素，XCUIElement 和 XCUIElementQuery 都实现了这个协议，具备查询元素的能力。这个协议声明了查询所有UI控件的方法，关键看怎么组合。

常用的的方法应该是下面几个

```
@property (readonly, copy) XCUIElementQuery *buttons;
@property (readonly, copy) XCUIElementQuery *tables;
@property (readonly, copy) XCUIElementQuery *cells;
@property (readonly, copy) XCUIElementQuery *staticTexts;
@property (readonly, copy) XCUIElementQuery *textFields;
```

#### XCUIElement 节点

XCUIElement 不能通过init创建，只能通过XCUIElementQuery相关的方法产生，找到了就有，没有找到就没有。

对 XCUIElement 可以进行各种操作，比如tap,doubleTap,swipeLeft。

![Simulator Screen Shot - iPhone 5s - 2019-08-30 at 16.17.41.png](https://i.loli.net/2019/08/30/sUrlbX1neVcNPOE.png)

如上图，想要点击第三行，可以添加下面的代码

```
- (void)testExample {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.tables.cells.staticTexts[@"XFCollectionViewFlowLayout"] tap];
}
```

> **@property** (**readonly**) **BOOL** exists;

元素是否存在

> **@property** (**readonly**, **getter** = isHittable) **BOOL** hittable;

元素能不能被点击，如果显示了但是被挡住了（比如弹出一个模态视图），isHittable = NO;

> waitForExistenceWithTimeout:

```
// 进入页面之后，空数据提示要等请求结束才会显示，这个假设请求3秒内会完成，所以 @"没有相关记录" 会在3秒内显示
BOOL exist = [app.staticTexts[@"没有相关记录"] waitForExistenceWithTimeout:3];
XCTAssert(exist,"空数据提示异常");
```

#### XCUIElementQuery 

特定类型查询结果的集合。

```
@property (readonly) NSUInteger count;
- (XCUIElement *)elementBoundByIndex:(NSUInteger)index;
```

#### XCUIElementAttributes

元素的属性

> **@property** (**readonly**, **copy**) NSString *label;

获取UILabel.text 可以使用 label

```
NSString *count = [[cell.staticTexts elementBoundByIndex:1] label];
```

> **@property** (**readonly**, **getter** = isEnabled) **BOOL** enabled;

能不能接受用户交互。



### 附录

![屏幕快照2019-09-03下午3.47.39.png](https://i.loli.net/2019/09/03/CiI7JYjfVAvwbRx.png)



```
- (void)testFavorite {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.tabBars.buttons[@"我的"] tap];

    if ([app.tables.staticTexts[@"我的收藏"] isHittable] == NO) {
        [app.textFields.element tap];
        [app.textFields.firstMatch typeText:@"15118174201"];
        [app.buttons[@"下一步"] tap];
        
        [app.buttons[@"获取验证码"] tap];
        [app.textFields.element tap];
        [app.textFields.firstMatch typeText:@"1111"];
        [app.buttons[@"登录"] tap];
    } 
    
    // 等待请求
    sleep(1);
    
    XCUIElement *cell = [app.cells elementBoundByIndex:1];
    NSString *count = [[cell.staticTexts elementBoundByIndex:1] label];

    BOOL hasFavorite = ![count isEqualToString:@"暂无"];
    [app.tables.staticTexts[@"我的收藏"] tap]; 
    
    if (hasFavorite == NO) {
        BOOL exist = [app.staticTexts[@"没有相关记录"] waitForExistenceWithTimeout:3];
        XCTAssert(exist,"空数据异常");
    } else {
        XCTAssert([app.cells.element waitForExistenceWithTimeout:3],"请求异常");
        if (app.cells.count < 20) {
            XCTAssert(count.integerValue == app.cells.count,"数量异常");
        }
        XCTAssert(app.cells.count>0,"数据显示异常");
    }
}
```























在MVVM中，通过Unit Tests确保viewModel中数据的正确性可以很大程度上减少UI Tests。

UI Tests 代码不熟的话可以先录制再修改，熟练了应该可以直接敲。