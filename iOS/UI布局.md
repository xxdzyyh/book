## UI布局

> 屏幕物理大小

> 屏幕分辨率

> 像素密度
>
> 坐标

### 绝对布局

对屏幕中的位置，可以建立一个坐标系，然后用坐标去描述这个位置。绝对布局就是直接指明控件的坐标，如 view.frame = CGRectMake(0,0,100,200) ，是所有布局的基础。即使使用了AutoLayout，最终也是通过约束计算出view的frame，复杂场景可以试试用frame替代AutoLayout来提高流畅度。

#### 屏幕旋转

绝对布局遇到的第一个问题，当屏幕旋转后，坐标参照物实际发生了变化，这个时候，还按照原坐标进行显示，可能是不合适的，重写一套坐标，程序员可能会掀桌子，这个时候可以使用UIViewAutoresizing，关键词就是flexible 可变的。

UIViewAutoresizing 

| UIViewAutoresizingNone                 | 不会随父视图的改变而改变                       |
| -------------------------------------- | ---------------------------------------------- |
| UIViewAutoresizingFlexibleLeftMargin   | 自动调整view与父视图左边距，以保证右边距不变   |
| UIViewAutoresizingFlexibleWidth        | 自动调整view的宽度，保证左边距和右边距不变     |
| UIViewAutoresizingFlexibleRightMargin  | 自动调整view与父视图右边距，以保证左边距不变   |
| UIViewAutoresizingFlexibleTopMargin    | 自动调整view与父视图上边距，以保证下边距不变   |
| UIViewAutoresizingFlexibleHeight       | 自动调整view的高度，以保证上边距和下边距不变   |
| UIViewAutoresizingFlexibleBottomMargin | 自动调整view与父视图的下边距，以保证上边距不变 |









