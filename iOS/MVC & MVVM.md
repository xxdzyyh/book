## MVC & MVVM

客户端要做的事情就是将后台的数据显示出来，从数据到显示中间存在一些问题

* 后台返回的数据有些不能直接显示，对后台返回的数据进行处理后，可能直接显示

* 前端自行处理的逻辑带来的一些变量，比如状态

### MVC

* Model

  * 瘦model ：后台请求的数据直接映射为对象，没有任何额外的处理

    ```objc
    {"uid" : @"123"}
    
    @interface User
    
    // 123
    @property (nonatomic, copy) NSString *uid;
    
    @end
    ```

  * 胖model ：将上面的问题放到model中处理，model会变胖

    ```objective-c
    {"firstName" : @"xuefeng","lastName" : @"wang"}
    
    @interface User
    
    @property (nonatomic, copy) NSString *firstName;
    @property (nonatomic, copy) NSString *lastName;
    
    // custom
    @property (nonatomic, copy) NSString *name; // @"wangxuefeng"
    
    @end
    ```
  	

* View

* Controller

  

### MVVM

胖Model只能对自身的数据进行处理，但是ViewModel有更强的整合的能力，多个Model的数据也可以整合到一起。

MVVM的通信方式和MVC有本质区别。







