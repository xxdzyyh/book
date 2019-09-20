## HandyJSON

HandyJSON 的使用并不是一个问题，查查他们的文档就可以了，它怎么做的才是我们关心的问题。

### 测试代码

```
// user.json
{
    "index" : 1,
    "base" : {
        "id" : "20190523",
        "name" : {
            "first" : "ying",
            "last" : "long"
        },
        "age" : 25
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

struct HName : HandyJSON {
    var first : String?
    var last : String?
    
    init() {
        
    }
}

struct HAddress : HandyJSON {
    var desc : String?
    var detail : String?
    
    init() {
        
    }
}

struct HBase : HandyJSON {
    var id : Int?
    var name : HName?
    var age : Int?
    
    init() {
        
    }
}

struct HUser : HandyJSON {
    var index : Int = 0
    var base : HBase? 
    var address : [HAddress]?
    
    init() {
        
    }
}

class HandyJSONVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let object = try? JSONSerialization.jsonObject(with: testData() as Data, options: JSONSerialization.ReadingOptions.mutableLeaves)
        
        let user = HUser.deserialize(from: object as? NSDictionary)
        
        print(user?.base?.name)
    }
    
    func testData() -> NSData! {
        let path : String = Bundle.main.path(forResource: "user", ofType: "json")!
        let data = NSData(contentsOfFile: path)
        
        return data
    }
}

```

### 源代码分析

```
let user = HUser.deserialize(from: object as? NSDictionary)

public extension HandyJSON {

    static func deserialize(from dict: NSDictionary?, designatedPath: String? = nil) -> Self? {
    		// 因为传入的NSDictionary,所以先触发，下一步，NSDictionary 转成了 Dictionary
        return deserialize(from: dict as? [String: Any], designatedPath: designatedPath)
    }

    static func deserialize(from dict: [String: Any]?, designatedPath: String? = nil) -> Self? {
    		// 最终触发了这个方法
        return JSONDeserializer<Self>.deserializeFrom(dict: dict, designatedPath: designatedPath)
    }
    
    static func deserialize(from json: String?, designatedPath: String? = nil) -> Self? {
        return JSONDeserializer<Self>.deserializeFrom(json: json, designatedPath: designatedPath)
    }
}
```

HandyJSON 是一个协议，协议可以有extension，好吧。



```
public class JSONDeserializer<T: HandyJSON> {
    public static func deserializeFrom(dict: [String: Any]?, designatedPath: String? = nil) -> T? {
        var targetDict = dict
        if let path = designatedPath {
            targetDict = getInnerObject(inside: targetDict, by: path) as? [String: Any]
        }
        if let _dict = targetDict {
            return T._transform(dict: _dict) as? T
        }
        return nil
    }
}
```



```
extension _ExtendCustomModelType {
		static func _transform(dict: [String: Any]) -> _ExtendCustomModelType? {
       
       // 生成 model 实例
       var instance: Self
        if let _nsType = Self.self as? NSObject.Type {
            instance = _nsType.createInstance() as! Self
        } else {
            instance = Self.init()
        }
        
        // 发送一个开始赋值通知
        instance.willStartMapping()
        
      	// 为model 属性赋值
        _transform(dict: dict, to: &instance)
        
        // 发送一个结束赋值通知
        instance.didFinishMapping()
        
        return instance
    }
    
    static func _transform(dict: [String: Any], to instance: inout Self) {
    		
    		// 获取所有的属性
    		po properties
        ▿ 3 elements
          ▿ 0 : Description
            - key : "index"
            - type : Swift.Int
            - offset : 0
          ▿ 1 : Description
            - key : "base"
            - type : Swift.Optional<LearnSwift.HBase>
            - offset : 8
          ▿ 2 : Description
            - key : "address"
            - type : Swift.Optional<Swift.Array<LearnSwift.HAddress>>
            - offset : 72
				
				// 在Objective-C中我们可以用 class_copyIvarList 来获取变量名
				
        guard let properties = getProperties(forType: Self.self) else {
            InternalLogger.logDebug("Failed when try to get properties from type: \(type(of: Self.self))")
            return
        }

        // do user-specified mapping first
        let mapper = HelpingMapper()
        
        
        instance.mapping(mapper: mapper)

        // get head addr
        let rawPointer = instance.headPointer()
        InternalLogger.logVerbose("instance start at: ", Int(bitPattern: rawPointer))

        // process dictionary
        let _dict = convertKeyIfNeeded(dict: dict)

        let instanceIsNsObject = instance.isNSObjectType()
        let bridgedPropertyList = instance.getBridgedPropertyList()

        for property in properties {
            let isBridgedProperty = instanceIsNsObject && bridgedPropertyList.contains(property.key)

            let propAddr = rawPointer.advanced(by: property.offset)
            InternalLogger.logVerbose(property.key, "address at: ", Int(bitPattern: propAddr))
            if mapper.propertyExcluded(key: Int(bitPattern: propAddr)) {
                InternalLogger.logDebug("Exclude property: \(property.key)")
                continue
            }

            let propertyDetail = PropertyInfo(key: property.key, type: property.type, address: propAddr, bridged: isBridgedProperty)
            InternalLogger.logVerbose("field: ", property.key, "  offset: ", property.offset, "  isBridgeProperty: ", isBridgedProperty)

            if let rawValue = getRawValueFrom(dict: _dict, property: propertyDetail, mapper: mapper) {
                if let convertedValue = convertValue(rawValue: rawValue, property: propertyDetail, mapper: mapper) {
                    assignProperty(convertedValue: convertedValue, instance: instance, property: propertyDetail)
                    continue
                }
            }
            InternalLogger.logDebug("Property: \(property.key) hasn't been written in")
        }
    }
}
```





```
func propertyDescriptions() -> [Property.Description]? {
            guard let fieldOffsets = self.fieldOffsets else {
                return []
            }
            var result: [Property.Description] = []
            class NameAndType {
                var name: String?
                var type: Any.Type?
            }
            for i in 0..<self.numberOfFields {
                if let name = self.reflectionFieldDescriptor?.fieldRecords[i].fieldName,
                    let cMangledTypeName = self.reflectionFieldDescriptor?.fieldRecords[i].mangledTypeName,
                    let fieldType = _getTypeByMangledNameInContext(cMangledTypeName, getMangledTypeNameSize(cMangledTypeName), genericContext: self.contextDescriptorPointer, genericArguments: self.genericArgumentVector) {

                    result.append(Property.Description(key: name, type: fieldType, offset: fieldOffsets[i]))
                }
            }
            return result
        }
```







