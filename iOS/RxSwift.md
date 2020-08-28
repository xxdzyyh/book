## RxSwift

[Toc]



### 响应式

```
a = 3,b = 4
c = a + b // 7
b = 5
// b发生变化，C会跟着改变吗，在命令式编程中是不会跟着变得，在响应式编程中会跟着改变
c // 7
```





Element ： 元素

Sequence : 序列

序列中的元素必须是指定的类型，swift的泛型可以很好的完成这个任务。

Observable :  ObservableType : ObservableConvertibleType

```
public protocol ObservableConvertibleType {
    /// Type of elements in sequence.
    associatedtype Element

    @available(*, deprecated, renamed: "Element")
    typealias E = Element

    /// Converts `self` to `Observable` sequence.
    ///
    /// - returns: Observable sequence that represents `self`.
    func asObservable() -> Observable<Element>
}
```

ObservableType

​		-- asObservable

​		-- subscribe

序列可以产生一个或多个元素，所以observer可以收到一个或多个Next类型的事件.一旦发送了 Error或者Completed类型的事件，就标志着序列结束了，再也不能产生任何元素了，observer也就收不到任何类型的事件。不同的事件有可能在不同的线程发送，但是两个事件不可能并发的发送的observer。

资源管理：如果序列发送了 Complete 或者 Error（Complete + Error  = Stop Event ）其内部和元素相关的资源就会被释放。如果想立即停止元素并释放资源，订阅后返回一个Disposable实例，调用Disposable实例的dispose()方法，



```
/// Represents a push style sequence.
public protocol ObservableType: ObservableConvertibleType {
    /**
    Subscribes `observer` to receive events for this sequence.
    
    ### Grammar
    
    **Next\* (Error | Completed)?**
    
    * sequences can produce zero or more elements so zero or more `Next` events can be sent to `observer`
    * once an `Error` or `Completed` event is sent, the sequence terminates and can't produce any other elements
    
    It is possible that events are sent from different threads, but no two events can be sent concurrently to
    `observer`.
    
    ### Resource Management
    
    When sequence sends `Complete` or `Error` event all internal resources that compute sequence elements
    will be freed.
    
    To cancel production of sequence elements and free resources immediately, call `dispose` on returned
    subscription.
    
    - returns: Subscription for `observer` that can be used to cancel production of sequence elements and free resources.
    */
    func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element
}

extension ObservableType {
    
    /// Default implementation of converting `ObservableType` to `Observable`.
    public func asObservable() -> Observable<Element> {
        // temporary workaround
        //return Observable.create(subscribe: self.subscribe)
        return Observable.create { o in
            return self.subscribe(o)
        }
    }
}

```





```
public class Observable<Element> : ObservableType {
    init() {
#if TRACE_RESOURCES
        _ = Resources.incrementTotal()
#endif
    }
    
    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        rxAbstractMethod()
    }
    
    public func asObservable() -> Observable<Element> {
        return self
    }
    
    deinit {
#if TRACE_RESOURCES
        _ = Resources.decrementTotal()
#endif
    }
}
```



```
/// Supports push-style iteration over an observable sequence.
public protocol ObserverType {
    /// The type of elements in sequence that observer can observe.
    associatedtype E

    /// Notify observer about sequence event.
    ///
    /// - parameter event: Event that occurred.
    func on(_ event: Event<E>)
}


```



### throttle

```
// 3秒内只接收第一次

throttle(DispatchTimeInterval.seconds(3), latest: false, scheduler: MainScheduler.instance)

// 3秒内第一次和最后一次都会被接收

throttle(DispatchTimeInterval.seconds(3), latest: true, scheduler: MainScheduler.instance)
```





```
NotificationCenter.default.rx.notification(UserManager.Notifications.didLogin).throttle(DispatchTimeInterval.seconds(3), latest: false, scheduler: MainScheduler.instance).asObservable().subscribe(onNext: { (notification) in
            
            if currentUserToken != nil {
                if self.viewModel.isRequestTaskInfo == false {
                    self.getUserTaskInfoAfterLogin()
                }
            }
}).disposed(by: self.disposeBag)
```



### merge

o1:		1				2				 3

o2: 				c				  d

merge: 1      c		2		d		3

zip                 1c               2d



### zip







### withLatestFrom

将两个Observable关联起来生成一个新的Observable，当第一个Observable发送event的时候，获取第二个Observable最新的event作为新Observable的事件，发送出去。



```
// o3
// o1 发送next event,获取o2最新的值，如果值存在，o3发送next event，不存在不发送
// o1 和 o2 任何一个发送finish event,o3 发送对应的finish event
// 只要 o2曾经发送过值，o1发送值得时候，o3就会收到
// 当o2为Single类型的时候，效果相当于o1等待o2

let o3 = o1.withLatestFrom(o2)
            
o3.subscribe { event in
    switch event {
    case .next(let element):
        print("element:", element)
    case .error(let error):
        print("error:", error)
    case .completed:
        print("completed")
    }}.disposed(by: self.disposeBag)

o1.onNext(0)
o2.onNext("aaaa")
o2.onNext("1234")
o1.onNext(1)
o2.onNext("kkkkk")
o1.onNext(2)
o2.onNext("9876")
o2.onError(NSError(domain: "2222", code: 0, userInfo: nil))
o1.onNext(3)
o1.onError(NSError(domain: "1111", code: 0, userInfo: nil))

/**
  // 输出
  element: 1234
	element: kkkkk
	error: Error Domain=2222 Code=0 "(null)"
 */

```

### Single

```
//
//  SingleVC.swift
//  LearnSwift
//
//  Created by sckj on 2020/7/20.
//  Copyright © 2020 yunmai. All rights reserved.
//

import UIKit
import RxSwift

class SingleVC: UIViewController {

    let disposeBag = DisposeBag()
        
    override func viewDidLoad() {
       //获取第0个频道的歌曲信息
       getPlaylist("0")
           .subscribe { event in
               switch event {
               case .success(let json):
                   print("JSON结果: ", json)
               case .error(let error):
                   print("发生错误: ", error)
               }
           }
           .disposed(by: disposeBag)
    }
    
    //获取豆瓣某频道下的歌曲信息
    func getPlaylist(_ channel: String) -> Single<[String: Any]> {
        return Single<[String: Any]>.create { single in
            let url = "https://douban.fm/j/mine/playlist?"
                + "type=n&channel=\(channel)&from=mainsite"
            let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, _, error in
                if let error = error {
                    single(.error(error))
                    return
                }
                 
                guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data,
                                                            options: .mutableLeaves),
                    let result = json as? [String: Any] else {
                        single(.error(DataError.cantParseJSON))
                        return
                }
                single(.success(result))
            }
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
     
    //与数据相关的错误类型
    enum DataError: Error {
        case cantParseJSON
    }   
}
```

