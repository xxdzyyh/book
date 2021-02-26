# UI 刷新机制

当在操作 UI 时，比如改变了 Frame、更新了 UIView/CALayer 的层次时，或者手动调用了 UIView/CALayer 的 setNeedsLayout/setNeedsDisplay方法后，这个 UIView/CALayer 就被标记为待处理，并被提交到一个全局的容器去。

苹果注册了一个 Observer 监听 BeforeWaiting(即将进入休眠) 和 Exit (即将退出Loop) 事件，回调去执行一个很长的函数：
_ZN2CA11Transaction17observer_callbackEP19__CFRunLoopObservermPv()。这个函数里会遍历所有待处理的 UIView/CAlayer 以执行实际的绘制和调整，并更新 UI 界面。

```
_ZN2CA11Transaction17observer_callbackEP19__CFRunLoopObservermPv()
    QuartzCore:CA::Transaction::observer_callback:
        CA::Transaction::commit();
            CA::Context::commit_transaction();
                CA::Layer::layout_and_display_if_needed();
                    CA::Layer::layout_if_needed();
                        [CALayer layoutSublayers];
                            [UIView layoutSubviews];
                    CA::Layer::display_if_needed();
                        [CALayer display];
                            [UIView drawRect]; //只有初始化frame的时候才会触发，更新界面并不会再次触发。如果想触发，可手动调setNeedsDisplay方法。
```

关于setNeedsLayout、setNeedsDisplay以及layoutIfNeeded方法的说明：

* setNeedsLayout：会触发上面的界面刷新流程，runloop休眠或退出后会触发layoutSubviews方法

* setNeedsDisplay：会触发上面的界面刷新流程，runloop休眠或退出后会触发drawRect方法

* layoutIfNeeded：如果有需要刷新的标记（frame变化或者约束变化），立即调用layoutSubviews进行布局（如果没有标记，不会调用layoutSubviews）



### 监听UI变化

如果想要监听 UI 是否发生了变化，可以 hook `-[CALayer display]`，CALayer才是视图内容的载体。

UIView = CALayer + UIResponser

但是这里有个问题，WKWebview的内容发生变化时，hook 不一定会触发，估计一些特殊的CALayer也可能出问题。

暂时不知道怎么 hook `CA::Transaction::commit()`，而且

`[window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];`也会触发 `commit()`