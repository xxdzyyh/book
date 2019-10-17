## FlexBox - YogaKit

FlexBox是一套通用的布局协议，YogaKit实现了这个协议，iOS端可以使用YogaKit来实现FlexBox布局。

FlexBox和UIStackView以及Android的LineLayout有相通的地方，优势在于FlexBox是跨平台的，功能上也更强一点。

### flex direction 

布局延伸的方向，确定了主轴和副轴，添加的元素沿着主轴的方向进行排列。这个方向应该是否和地区有关，有的地区默认是从右往左。

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

iOS 上 padding 对应的是 content inserts，但是 iOS 大部分控件都没有padding,我曾经写过一个继承自 UILabel

的控件来提供设置 content inserts 的控件，有了YogaKit，那个类以后用不上了。

padding 指的是自身内边距，margin 指的是外边距，@"H:|-20-[redView]-20-|"，这条VFL里的20就是margin。

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