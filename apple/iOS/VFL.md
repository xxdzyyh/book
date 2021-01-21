# VFL

如果非要用原生写约束，那使用VFL还是方便一点点。

VFL将约束分为两个方向，所以设置竖直和水平两条VFL语句即可。

```
UIView *redView = [[UIView alloc] init];
  
redView.backgroundColor = [UIColor redColor];
redView.translatesAutoresizingMaskIntoConstraints = NO;

[self.view addSubview:redView];

NSArray *hLayout = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[redView]-20-|" options:NSLayoutFormatAlignAllTop metrics:nil views: NSDictionaryOfVariableBindings(redView)];

NSNumber *h = @([UIScreen mainScreen].bounds.size.width);
NSArray *yLayout = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-240-[redView(h)]|" options:NSLayoutFormatAlignAllTop metrics:@{@"h":h} views: NSDictionaryOfVariableBindings(redView)];

[self.view addConstraints:hLayout];
[self.view addConstraints:yLayout];
```

> @"H:|-20-[redView]-20-|"

水平方向上距离superview左右间距为20

> @"V:|-240-[redView(h)]|"

竖直方向上顶部距离superview 240,高度为h