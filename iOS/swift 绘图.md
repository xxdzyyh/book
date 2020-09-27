## swift 绘图

绘制圆形的进度条

```
import UIKit

class CircleProgressView: UIView {

    var lineWidth : CGFloat = 4.0
    var lineColor : UIColor = UIColor.orange
    var progress : CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var tip : String? {
        didSet {
            self.tipLabel.text = staticTip
            
            if (self.tipLabel.superview == nil) {
                self.tipLabel.frame = CGRect(x:0,y:0,width: self.bounds.size.width,height: self.tipLabel.font.lineHeight)
                self.tipLabel.center = CGPoint(x:self.bounds.size.width/2,y:self.bounds.size.height/2)
                self.addSubview(self.tipLabel)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        self.backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext();
        
        if context == nil {
            return
        }
        
        context!.addArc(center: CGPoint(x:rect.size.width * 0.5,y:rect.size.height * 0.5),
                    radius: rect.size.width * 0.5 - lineWidth * 0.5,
                    startAngle: CGFloat(-Double.pi/2),
                    endAngle: 2.0 * CGFloat(Double.pi) * progress - CGFloat(Double.pi/2),
                    clockwise: false)
        context!.setLineCap(.round);
        context!.setLineWidth(lineWidth);
        context!.setStrokeColor(lineColor.cgColor);
        context!.strokePath();
    }
    
    lazy var tipLabel: UILabel = {
        let v = UILabel.init()
        v.textColor = .white
        v.font = UIFont.systemFont(ofSize: 12)
        v.textAlignment = NSTextAlignment.center
        return v
    }()
}
```



角度设置旋转了 -Double.pi/2,也就是-90度，这是因为坐标系的问题，原地在屏幕左上角，整个屏幕坐标都是正的。



构建复杂的路径CGMutablePath也许能用上

```
let mPath = CGMutablePath()

mPath.addArc(center: CGPoint(x:rect.size.width * 0.5,y:rect.size.height * 0.5),
             radius: rect.size.width * 0.5 - lineWidth * 0.5,
             startAngle: CGFloat(-Double.pi/2),
             endAngle: 2.0 * CGFloat(Double.pi) * progress - CGFloat(Double.pi/2),
             clockwise: false)

mPath.addArc(center: CGPoint(x:0,y:0),
             radius: rect.size.width * 0.5 - lineWidth * 0.5,
             startAngle: CGFloat(-Double.pi/2),
             endAngle: 2.0 * CGFloat(Double.pi) * progress - CGFloat(Double.pi/2),
             clockwise: false)

context!.addPath(mPath)
```

