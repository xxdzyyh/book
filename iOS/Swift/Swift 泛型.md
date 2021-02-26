

## Swift 泛型

### 定义

泛型程序设计是程序设计语言的一种风格或范式。允许程序员在强类型程序设计语言中编写代码时使用一些以后才指定的类型，在实例化时作为参数指明这些类型。



一般在声明方法的的时候，就需要明确的指出相关的类型

```
// 指明参数类型为Data，返回类型为 UIImage
func imageWithData(data:Data) -> UIImage
```

调用者在调用的时候，一切都是确定的，只能按照设置的类型去赋值，在类型信息方面没有任何话语权。

泛型相当于给了调用者一个机会，可以指定一些类型信息，也就是将类型信息延迟到调用时才确定。

### 使用

<T> 没有任何限制 

```
/// 交换两个对象
/// - Parameters:
///   - a: T
///   - b: T
/// 两个参数是同一类型即可，不需要知道这两个参数的任何信息
func swap<T>(a:inout T,b:inout T) {
    let tmp = a
    a = b
    b = tmp
}

var a = 8;
var b = 16;
swap(&a, &b)
```

`<T:类名 或者 协议名>`一定程度限制 

```
func instanceOfClass<T:NSObject>(object:T.Type) -> T {
    return T.init()
}

let obj = instanceOfClass(object: NSDate.self)
```



实际使用场景，后台返回的数据，json 转 model。

```
{
	"code" : 0,
	"messgae" : "操作成功",
	"data" : {
			"list" : [],
			"total" : 3,
			"page" : 1,
			"size: : 20
	}
}
```

```
class Goods : BaseModel {
    override class func description() -> String {
        return "Goods"
    }
}

class User : BaseModel {
    override class func description() -> String {
        return "User"
    }
}
```

list里面存放的数据对应的具体类型是不确的，可能是Goods或者User,也可能是其他，调用者才知道具体类型，这个时候可以由调用者来指明类型信息。

```
class PageModel<T:BaseModel> : BaseModel {
    var page : Int = 0
    var total : Int = 0
    var list : [T] = [T.init()]
    var size : Int = 20
}

class Root<T> {
		var code : Int = 0
    var messgae : String = ""
    var data : PageModel<T>?
}

class Root2<T,D> : NSObject where D : PageModel<T> {
		var code : Int = 0
    var messgae : String = ""
    var data : D?
    override init() {
        data = PageModel<T>.init() as! D
        print(data!)
    }
}

var resp = Root<Goods>()
var resp2 = Root2<Goods,PageModel<Goods>>()
```

