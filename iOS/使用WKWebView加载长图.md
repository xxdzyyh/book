## 使用WKWebView加载长图

```
import WebKit
import UIKit

/// 申请茶园主
class LongImageVC: XBaseViewController {

    lazy var webView: WKWebView = {
        let webView = WKWebView.init()
        return webView
    }()
    
    // 图片底部添加一个按钮
    lazy var commitButton : UIButton = {
        let v = UIButton(type:.custom)
        v.setImage(R.image.apply_commit(), for: .normal)
        v.addTarget(self, action: #selector(onCommit), for: .touchUpInside)
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
				
				// 图片名称apply_long_img.png ，存放在mainBundle下面
        let htmlString = " <img src=apply_long_img.png width=\"100%\"/>"
        let baseURL = NSURL.fileURL(withPath: Bundle.main.bundlePath)
        self.webView.loadHTMLString(htmlString, baseURL: baseURL)
    }

    override func setupSubviews() {
        super.setupSubviews()
        
        self.view.addSubview(self.webView)
        self.webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        webView.scrollView.rx.observe(CGSize.self, "contentSize").distinctUntilChanged().subscribe { [weak self](event) in
            if let strongSelf = self {
                var size = event.element ?? CGSize.zero
                if size == nil {
                    size = CGSize.zero
                }
                // 避免contentSize不是最终结果时显示异常
                if size!.height > SCREEN_HEIGHT {
                    strongSelf.commitButton.frame = CGRect(x: 50, y: size!.height-90, width: size!.width-100, height: 55)
                    strongSelf.webView.scrollView.addSubview(strongSelf.commitButton)
                }
            }
        }.disposed(by: self.disposeBag)
    }
    
    @objc func onCommit() {
        
    }
}

```

