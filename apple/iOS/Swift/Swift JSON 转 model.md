---
type : iOS
---



在 OC 运行时支持下，JSON 和 model 互相转换根本不算什么问题，到了 swift 这里就出现了一些问题。

### Codable

Codable 是系统提供的协议，`public typealias Codable = Decodable & Encodable`

实际上和 OC 的 encode 和 decoder 是一样的，通过两个方法来实现 JSON和model的相互转换。

只是 swfit 系统基础数据类型都实现了 Codable，如果你的 model 属性都是遵循 Codable,你可以直接声明 model 遵循 Codable，而不需要另外实现这两个方法。

```
init(from decoder: Decoder)
func encode(to encoder: Encoder)
```
user.json

```
{
    "base" : {
        "id" : "20190523",
        "name" : {
            "first" : "ying",
            "last" : "long"
        }
    },
    "address" : [
        {
            "desc" : "work",
            "detail" : "fucheng"
        },
        {
            "desc" : "home",
            "detail" : "xili"
        },
        {
            "desc" : "home",
        }
    ]
}

struct Name : Codable {
    var first : String?
    var last : String?
}

struct Address : Codable {
    var desc : String
    var detail : String?
}

struct Base : Codable {
    var id : String
    var name : Name?
    var age : Int?
}

struct User : Codable {
    var base : Base 
    var address : [Address]?
}

override func viewDidLoad() {
 		super.viewDidLoad()
 
    // json to model
    let jsonDecoder = JSONDecoder()
    let model: User = try! jsonDecoder.decode(User.self, from: testData() as Data)

    print(model.base.id)
    print(model.address?.first?.detail)

    // model to json
    let jsonEncoder = JSONEncoder()
    let jsonData = try? jsonEncoder.encode(model)

}

func testData() -> NSData! {
    let path : String = Bundle.main.path(forResource: "user", ofType: "json")!
    let data = NSData(contentsOfFile: path)

    return data
}
```

### 自定义 key

有时候，后台会使用 id、description 这种作为key,这个时候前段可能需要调整一下key的名字，避免冲突

```
struct Base : Codable {
    var userId : String
    var name : Name?
    var age : Int?
    
    // 自定义key
    // 虽然 age和name 没有变，但是还是要列出来，非常2
    enum CodingKeys:String, CodingKey {
        case userId = "id"
        case age
        case name
    }
}
```

### 类型不确定

之前使用过 YYModel，YYModel 就针对这一情况进行了特殊的处理

```
struct NumberType : Codable {
    var intValue : Int {
        didSet {
            let value = String(intValue)
            if value != stringValue {
                stringValue = value
            }
        }
    }
    
    var stringValue : String {
        didSet {
            let value = Int(stringValue)
            if value != intValue {
                intValue = value ?? 0
            }
        }
    }
    
    init(from decoder: Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        
        if let value = try? singleValueContainer.decode(String.self) {
            stringValue = value
            intValue = Int(stringValue) ?? 0
        } else if let value = try? singleValueContainer.decode(Int.self) {
            intValue = value
            stringValue = String(intValue)
        } else {
            intValue = 0
            stringValue = ""
        }
    }
}

struct Base : Codable {
    var userId : NumberType
    var name : Name?
    var age : Int?
    
    // 自定义key
    enum CodingKeys:String, CodingKey {
        case userId = "id"
        case age
        case name
    }
}
```











