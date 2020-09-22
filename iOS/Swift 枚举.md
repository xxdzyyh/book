## Swift 枚举

```
enum ApiType {
    case home
    case userInfo(userId:String)
}

var apiType = ApiType.userInfo(userId: "12345")

if case let ApiType.userInfo(userId) = apiType {
    // "12345"
    print(userId)
}

apiType = ApiType.home

if case ApiType.home = apiType {
    // "ApiType.home"
    print("ApiType.home")
}

switch apiType {
case .home:
    print("home")
case .userInfo("12345"):
    print("userInfo(\"12345\")")
case let .userInfo(userId):
    print("userInfo \(userId)")
}
```
注意```case```和```case let```,如果只想处理部分情况，可以考虑使用 ```if case```进行匹配，而不需要写```switch```。

### rawValue

枚举类型和基础类型进行比较时，可以考虑使用 rawValue。


```
enum Direction : Int {
		// e = 0
    case e
    case s = 3
    // w = 4
    case w
    case n = 9
}

enum Name : String {
    case Tom
    case Tony = "122"
    // 没有设置对应的值，rawValue默认为"Ted"，即 case 的名字
    case Ted
}
```

### RawRepresentable

在声明枚举的时候，可以选择遵循 RawRepresentable 协议。

associatedtype ： associatedtype 只能用在协议中，是一个编译期起作用的关键字。

```
public protocol RawRepresentable {
		// 被associatedtype关键字修饰的变量，具体的类型需要让实现的类来指定
    associatedtype RawValue

    init?(rawValue: Self.RawValue)

    var rawValue: Self.RawValue { get }
}

// ExpressibleByStringLiteral
// 
struct MyApi : Equatable,ExpressibleByStringLiteral {
    var url : String?
    
    static func == (obj1:MyApi,obj2:MyApi) -> Bool {
        if obj1.url == nil && obj2.url == nil {
            return true
        }
        
        if obj1.url == nil || obj2.url == nil {
            return false
        }
        
        if obj1.url!.elementsEqual(obj2.url!) {
            return true
        } else {
            return false
        }
    }
    
    init(stringLiteral value: StringLiteralType) {
        self.url = value
    }
}

enum MyApiEnum : MyApi,RawRepresentable {
    typealias RawValue = MyApi
    
    case home, detail
    case unknown
    
    // Enum with raw type cannot have cases with arguments
    // case userInfo(userId:String)

    var rawValue: RawValue {
        switch self {
        case .home:
            return MyApi("123")
        case .detail:
            return MyApi("234")
        default:
            return MyApi("xxxx")
        }
    }
    
    init?(rawValue: MyApi) {
        switch rawValue {
        case MyApi("123") : self = MyApiEnum.home
        case MyApi("234") : self = MyApiEnum.detail
        default:
            self = MyApiEnum.unknown
        }
    }
}

let kk = MyApiEnum.detail.rawValue

// MyApi(url: Optional("234"))
print(kk)
```

