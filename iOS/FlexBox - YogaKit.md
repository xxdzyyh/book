## FlexBox - YogaKit

FlexBox是一套通用的布局协议，YogaKit实现了这个协议，iOS端可以使用YogaKit来实现FlexBox布局。

FlexBox和UIStackView以及Android的LineLayout有相通的地方，但FlexBox现在是跨平台的。。。



> flex-wrap (适用于父类容器上)

设置或检索伸缩盒对象的子元素超出父容器时是否换行

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