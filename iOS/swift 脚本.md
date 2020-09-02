## swift 脚本

swift也可以用来写脚本，对于 iOS 开发而言是一件非常好事情，swift能做的事情越多越好。脚本配合workflow还是能提高不少工作效率的。

### 获取参数

```
#!/usr/bin/env swift

import Foundation

let argsCount = CommandLine.argc
print("有\(argsCount)个参数")
let arguments = CommandLine.arguments
print(arguments)

for i in 0..<Int(argsCount) {
    // print(i)
    print("\(arguments[i])")
}
```

```
// 调用
$ ./TestSwiftShell.sh 1 2 3
有4个参数
["./TestSwiftShell.sh", "1", "2", "3"]
./TestSwiftShell.sh
1
2
3
```

### 常用

#### Moya API 通过枚举定义完成剩余代码

```
#!/usr/bin/env swift

import Foundation

func subString(pattern:String,str:String) -> [String] {
    var subStr = [String]()
    let regex = try! NSRegularExpression(pattern: pattern, options:[])
    let matches = regex.matches(in: str, options: [], range: NSRange(str.startIndex...,in: str))
    for  match in matches {
        for i in 1..<match.numberOfRanges  {
            let str = String(str[Range(match.range(at: i), in: str)!])
            subStr.append(str)
        }
    }
    return subStr
}

let argsCount = CommandLine.argc
let arguments = CommandLine.arguments

if argsCount > 1 {
    let string = arguments[1]
    
    let pattern0 = "case (.*?)\\("
    let name = subString(pattern: pattern0, str: string).first
    var caseString = "case let .\(name!)("
    let pattern = ".*?\\((.*)\\)"
    let args = subString(pattern:pattern,str: string)
    var keys = [String]()
    for i in args {
        let keyvaluePairs = i.components(separatedBy: ",")
        for j in keyvaluePairs {
            let key = String(j.split(separator: ":").first ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            keys.append(key)
        }
    }
    
    caseString.append(keys.joined(separator: ","))
    caseString.append("):")
    print(caseString)
    for key in keys {
        print("params[\"\(key)\"] = \(key)")
    }
}
```
调用
```
$ ./EnumHelper.swift "case upgradePartner(agentId: String, areaId: String, payPass: String)("234":234)"
case let .upgradePartner(agentId,areaId,payPass):
params["agentId"] = agentId
params["areaId"] = areaId
params["payPass"] = payPass
```
配合 mac "自动操作"

1. 打开应用 "自动操作"选择 “快速操作”
2. 工作流程收到当前 "文本"位于 "Xcode"
3. 运行shell脚本，传递输入  ”作为自变量“
4. 添加shell代码 `/Users/workSpace/EnumHelper.swift $1`

5. 拷贝至剪贴板

保存为 EnumHelper

在Xcode中选中文本后，右键可以在Services中选择EnumHelper就可以了，粘贴代码到相应的位置

