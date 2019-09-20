## UINavigationBar颜色相关

### clipsToBounds

设置 navigationBar.clipsToBounds = true 会去掉 bounds以外的东西

1. shadow(底部横线) 
2. 状态栏颜色不再受 navigationBar 影响

### shadowImage

设置 ```navigationBar.shadowImage = UIImage.init()``` 可以去掉底部阴影，也就是横线。设置为nil会使用默认的图片

### backgroundImage

设置导航栏背景图片，```clipsToBounds = false```时还会影响状态栏



### setTitleTextAttributes

```
[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor redColor],
                                                                      NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:17]}];
```