## FlexBox - YogaKit

FlexBox是一套通用的布局协议，YogaKit实现了这个协议，iOS端可以使用YogaKit来实现FlexBox布局。

FlexBox和UIStackView以及Android的LineLayout有相通的地方，优势在于FlexBox是跨平台的，功能上也更强一点。

### flex direction 

布局延伸的方向，确定了主轴和副轴，添加的元素沿着主轴的方向进行排列。

> Row

水平方向从左往右进行延伸，主轴为水平方向，副轴为竖直方向

> Row Reverse

水平方向从左往右进行延伸，主轴为水平方向，副轴为竖直方向

> Column

竖直方向从上往下进行延伸，主轴为竖直方向，副轴为水平方向

> Column Reverse

竖直方向从下往上进行延伸，主轴为竖直方向，副轴为水平方向

### justify & align

justify 进一步明确了元素在主轴方向如何排列，align 进一步明确了元素在副轴方向如何排列

* flex start
* center
* end
* space between
* space around
* space evenly

> flex-wrap (适用于父类容器上)

设置或检索伸缩盒对象的子元素超出父容器时是否换行

### padding & margin

iOS 上 padding 对应的是 content inserts，但是 iOS 大部分控件都没有padding,相信很多人都写过一个继承自 UILabel的控件来提供设置 content inserts 的控件，有了YogaKit，那个类以后用不上了。

padding 指的是自身内边距，margin 指的是外边距，@"H:|-20-[redView]-20-|"，这条VFL里的20就是margin。

### display

是否显示这个元素，如果为none,则不显示，也不参与计算

### markDirty

标记元素需要重新计算位置，只对叶子节点生效。

```
// 获取验证码 -> 重发
- (void)codeButtonClicked:(UIButton *)button {
    [button setTitle:@"重发" forState:UIControlStateNormal];
    button.superview.yoga.marginTop = YGPointValue(0);
    [button.yoga markDirty];
    [button.superview.yoga applyLayoutPreservingOrigin:YES];
}
```



### flexGrow & flexShrink

flexGrow决定剩余空间怎么分配，含义类似于layout_weight.如果flex item的flexGrow为0，该flex item不会占用剩余的空间。如果多个flex item的flexGrow不为0，则按flexGrow的值按比例进行划分。

flexShrink决定空间不足，怎么缩放



### alignSelf/alignContent/alignItems

align-item 属性需要施加在 flex 容器上，它规定的是 flex 容器中所有 item 在交叉轴中的对齐方式；设置flex 容器中所有的 item 都按一个方向对齐时用它

align-self 属性则施加在 flex 容器中的 item 上，允许单个项目有与其他项目不一样的对齐方式，它覆盖了外部容器规定的 align-items 属性，同样也只规定在交叉轴上的对齐方式，如果想设置某一个item有不一样的对齐方式的时候，可以用它

align-content 移动的是容器自身的 flex line，并仅对多行的项目起作用

对于iOS开发而言，首选 align-item，因为UIStackView也是这种方式，先创建容器，在进行布局设置。



### 问题

使用```pod 'YogaKit' ```安装的时候，这个库包含了一个swift文件，对于纯OC的项目，这会报错。

可以改成

```
pod 'IGListKit','2.1.0'
pod 'Yoga','1.14.0'
```

然后将YogaKit的代码(删除掉swfit文件后)copy到项目中，这部分不使用cocopods进行管理，这样改动比较小。



### 实践

> 标签流式布局

```
- (void)tagLayout {
    NSArray *tags = @[@"投资理财",@"超高收益",@"七日年化收益",@"支付宝",@"微信",@"云闪付",@"花呗"];
    
    UIView *tagBgView = [[UIView alloc] init];
    
    tagBgView.backgroundColor = [UIColor lightGrayColor];
    [tagBgView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.marginTop = YGPointValue(100);
        layout.paddingBottom = YGPointValue(10);
        layout.width = YGPointValue([UIScreen mainScreen].bounds.size.width); 
        // 不设置高度，让高度自适应
        layout.flexWrap = YGWrapWrap;
    }];
    
    [self.view addSubview:tagBgView];
    
    for (NSString *obj in tags) {
        UILabel *label = [[UILabel alloc] init];
        
        label.text = obj;
        label.backgroundColor = [UIColor orangeColor];
        [label configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isEnabled =YES;
            layout.marginLeft = YGPointValue(10);
            layout.marginTop = YGPointValue(10);
        }];
        
        [tagBgView addSubview:label];
    }
        
    self.view.yoga.isEnabled = YES;
    [self.view.yoga applyLayoutPreservingOrigin:NO];
}
```



<img src="https://i.loli.net/2019/10/10/sdIMwUluPVoCBrN.png" alt="截屏2019-10-10下午5.30.21.png" style="zoom:50%;" />

> 更新布局

很多时候，我们的视图大小是依据视图内容来决定的,比如按钮的宽依据title进行调整。

```
- (void)inputLayout {
    UIView *bgView = [[UIView alloc] init];
    
    bgView.backgroundColor = [UIColor whiteColor];
    [bgView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.height = YGPointValue(40);
        layout.width = YGPointValue([UIScreen mainScreen].bounds.size.width);
        layout.marginTop = YGPointValue(20);
        layout.flexDirection = YGFlexDirectionRow;
    }];
    
    [self.view addSubview:bgView];
    
    UIImageView *leftImageView = [[UIImageView alloc] init];
    
    leftImageView.backgroundColor = [UIColor greenColor];
    [leftImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.width = YGPointValue(40);
        layout.height = YGPointValue(40);
    }];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(40, 0, 200, 40)];
    textField.placeholder = @"这就是占位符";
    textField.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    [textField configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginLeft = YGPointValue(10);
        layout.flexGrow = 1;
        layout.borderWidth = 1;
    }];
    
    UIButton *codeButton = [[UIButton alloc] init];
    codeButton.backgroundColor = [UIColor blueColor];
    [codeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [codeButton configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginRight = YGPointValue(10);
    }];
    
    [codeButton addTarget:self action:@selector(codeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [bgView addSubview:leftImageView];
    [bgView addSubview:textField];
    [bgView addSubview:codeButton];
    
    self.view.yoga.isEnabled = YES;
    [self.view.yoga applyLayoutPreservingOrigin:NO];
}

- (void)codeButtonClicked:(UIButton *)button {
    [button setTitle:@"验证" forState:UIControlStateNormal];
    button.superview.yoga.marginTop = YGPointValue(0);
    [button.yoga markDirty];
    [button.superview.yoga applyLayoutPreservingOrigin:YES];
}
```

