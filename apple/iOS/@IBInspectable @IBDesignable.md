@IBInspectable @IBDesignable

如果项目UI以xib为主，那就绝对不能错过 `@IBInspectable @IBDesignable`。使用xib设置UI时，对于系统的控件，可以在Xcode右边的

inspectors对控件的属性进行设置，使用 `@IBInspectable`可以让我们自定义的属性出现在 inspectors 中，直接进行复制。

```
extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            self.addCornerRadius(newValue)
        }
        get {
            return self.layer.cornerRadius
        }
    }
    
    /// 添加圆角并设置masksToBounds为true
    /// - Parameter cornerRadius: 圆角的值，默认为0，不传或者传0，cornerRadius为高度的1/2
    func addCornerRadius(_ cornerRadius:CGFloat = 0) {
        if cornerRadius == 0 {
            self.layer.cornerRadius = self.bounds.size.height / 2.0
        } else {
            self.layer.cornerRadius = cornerRadius
        }
        self.layer.masksToBounds = true
    }
}
```

在xib中，很多时候一个view只需设置圆角，但是为了实现这一点，需要一个outlet或者使用`User Defined Runtime Attributes`，这个还是比较麻烦的。添加了上面的extension后，就可以想设置背景颜色那样直接设置圆角。

<img src="/Users/sckj/Desktop/截屏2020-08-21 上午9.58.11.png" alt="截屏2020-08-21 上午9.58.11" style="zoom:50%;" /><img src="/Users/sckj/Desktop/截屏2020-08-21 上午10.00.58.png" alt="截屏2020-08-21 上午10.00.58" style="zoom:50%;" />

设置了cornerRadius后，`User Defined Runtime Attributes`会自动添加一条runtime attribute.

`@IBDesignable`设置以后，xcode 会尝试直接渲染view，实现预览效果。



```
import UIKit

enum XInputItemViewStyle : Int {
    case onlyTextField
    case leftLabel
    case titleAndLeftLabel
    case leftImageView
    case titleAndLeftImageView
    case leftImageViewAndRightButton
}

@IBDesignable
class XInputItemView: UIView {
    
    @IBInspectable var leading : Int = 0  {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var trailing : Int = 0  {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var textFieldLeading : Int = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var textFieldTrailing : Int = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var leftImage: UIImage? {
        set {
            self.leftImageView.image = newValue
        }
        get {
            return self.leftImageView.image
        }
    }
    
    @IBInspectable var rightImage: UIImage? {
        set {
            self.rightButton.setImage(newValue, for: .normal)
        }
        get {
            return  self.rightButton.image(for: .normal)
        }
    }
    
    @IBInspectable var rightText: String? {
        set {
            self.rightButton.setTitle(newValue, for: .normal)
        }
        get {
            return  self.rightButton.title(for: .normal)
        }
    }
    
    @IBInspectable var placeHolder: String? {
        set {
            self.textField.placeholder = newValue
        }
        get {
            return self.textField.placeholder
        }
    }
    
    @IBInspectable var leftText : String? {
        set {
            self.leftLabel.text = newValue
        }
        get {
            return self.leftLabel.text
        }
    }
    
    @IBInspectable var style : Int = 0 {
        didSet {
            let s : XInputItemViewStyle = XInputItemViewStyle(rawValue: self.style) ?? XInputItemViewStyle.onlyTextField
            switch s {
            case .onlyTextField:
                self.addSubview(self.textField)
                self.textField.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.leading)
                    make.right.equalTo(self.trailing)
                    make.top.bottom.equalToSuperview()
                }
            case .leftImageView:
                self.addSubview(self.leftImageView)
                self.leftImageView.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
                self.leftImageView.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.leading)
                    make.top.bottom.equalToSuperview()
                }
                self.addSubview(self.textField)
                self.textField.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.leftImageView.snp.right).offset(self.textFieldLeading)
                    make.right.equalTo(self.trailing)
                    make.top.bottom.equalToSuperview()
                }
            case .leftLabel:
                self.addSubview(self.leftLabel)
                self.leftLabel.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
                self.leftLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.leading)
                    make.top.bottom.equalToSuperview()
                }
                self.addSubview(self.textField)
                self.textField.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.leftLabel.snp.right).offset(self.textFieldLeading)
                    make.right.equalTo(self.trailing)
                    make.top.bottom.equalToSuperview()
                }
            case .leftImageViewAndRightButton:
                self.addSubview(self.leftImageView)
                self.leftImageView.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
                self.leftImageView.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.leading)
                    make.top.bottom.equalToSuperview()
                }
                self.addSubview(self.textField)
                self.textField.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.leftImageView.snp.right).offset(self.textFieldLeading)
                    make.top.bottom.equalToSuperview()
                }
                self.addSubview(self.rightButton)
                self.rightButton.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
                self.rightButton.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.textField.snp.right).offset(self.textFieldTrailing)
                    make.right.equalTo(self.trailing)
                    make.top.bottom.equalToSuperview()
                }
            default:
                self.addSubview(self.textField)
                self.textField.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.leading)
                    make.right.equalTo(self.trailing)
                    make.top.bottom.equalToSuperview()
                }
            }
        }
    }
        
    // MARK: Lazy Init
    lazy var leftImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = UIView.ContentMode.scaleAspectFit
        return v
    }()
    
    lazy var leftLabel: UILabel = {
        let v = UILabel()
        v.textColor = UIColor.qd_titleText
        return v
    }()
    
    lazy var topLabel: UILabel = {
        let v = UILabel()
        return v
    }()
    
    lazy var rightButton: UIButton = {
        let v = UIButton(type: .custom)
        return v
    }()
    
    lazy var textField: QMUITextField = {
        let tf = QMUITextField.init()
        tf.placeholderColor = UIColor.qd_background
        tf.textAlignment = NSTextAlignment.left
        tf.font = UIFont.systemFont(ofSize: 13)
        tf.textColor = .qd_mainText
        tf.tintColor = .white
        return tf
    }()
}
```

