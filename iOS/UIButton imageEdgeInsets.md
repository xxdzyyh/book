## UIButton imageEdgeInsets & 

使用 swift playgrounds 进行测试，这样可以较快的看到调整的结果。



```
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let button = UIButton.init(frame: CGRect.init(x: 100, y: 100, width: 0, height: 0))
        
        button.setImage(self.image(withColor: UIColor.orange, size: CGSize.init(width: 30, height: 30)), for: .normal)
        button.setTitle("12345", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .green
        button.sizeToFit()
        
        print(button.titleLabel.intrinsicContentSize) // (51.5,21.5)
        print(button.intrinsicContentSize) // (30.0, 30.0)
   
        view.addSubview(button)
        
        self.view = view
    }
```



| edgeInserts                                                  | 效果图                                                       |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| 未设置                                                       | ![屏幕快照2019-06-24上午9.37.49.png](https://i.loli.net/2019/06/24/5d102981e06d399765.png) |
| imageEdgeInsets=(button.titleLabel!.intrinsicContentSize,height,0,0,0) | ![屏幕快照2019-06-24上午9.40.25.png](https://i.loli.net/2019/06/24/5d102a12a167736806.png) |
| imageEdgeInsets=((button.intrinsicContentSize.height+button.titleLabel!.intrinsicContentSize.height)/2,0,0,0) | ![屏幕快照2019-06-24上午9.48.44.png](https://i.loli.net/2019/06/24/5d102c0ed753e99089.png) |
|                                                              |                                                              |



> imageEdgeInsets：(button.titleLabel!.intrinsicContentSize,height,0,0,0)

只设置了imageEdgeInsert.top = button.titleLabel!.intrinsicContentSize,height,可以看到image 的确下移了，但是没有在title的下面，因为移动是相对 button 整体来说的，所以但image的高度大于title的高度，需要移动更多的距离才能是image在title下面。



