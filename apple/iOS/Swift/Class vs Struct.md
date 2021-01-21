## Class vs Struct 



| 名称     | class                                                        | struct                    |
| -------- | ------------------------------------------------------------ | ------------------------- |
| 继承     | 可以继承，可以被final修饰                                    | 不能继承，不能被final修饰 |
| 内存     | 自动引用计数                                                 | stack栈，自动管理         |
| 传值     | 指针传递                                                     | 值传递 copy on write      |
| 函数派发 | 1 初始声明 函数表派发 2 extensions 直接派发 3 extensions with @objc 消息派发 | 直接派发                  |

Class 

* NSObject 
* SwiftObject 隐藏基类

Swift 为每一个类都建立了一个被称之为虚表的数组结构，这个数组会保存着类中所有定义的常规成员方法函数的地址。每个 Swift 类对象实例的内存布局中的第一个数据成员和 OC 对象相似，保存有一个类似 isa 的数据成员。isa 中保存着 Swift 类的描述信息。对于 Swift 类的类描述结构，每个虚表条目中保存着一个常规方法的函数地址指针。每一个对象方法调用的源代码在编译时就会转化为从虚表中取对应偏移位置的函数地址来实现间接的函数调用。



class

| 类内存分布 | 大小                              |
| ---------- | --------------------------------- |
| type       | 4 or 8byte (32位机器 or 64位机器) |
| refcount   | 8btye                             |
| 父类成员   |                                   |
| 自身成员   |                                   |

类型信息区域在 32bit 的机子上是 4byte，在 64bit 机子上是 8 byte。引用计数占用 8 byte。

所以，在堆上，类属性的地址是从第 16 个字节开始的。

```
class Human {
    var age: Int?
    var name: String?
    var nicknames: [String] = [String]()

    //返回指向 Human 实例头部的指针
    func headPointerOfClass() -> UnsafeMutablePointer<Int8> {
        let opaquePointer = Unmanaged.passUnretained(self as AnyObject).toOpaque()
        let mutableTypedPointer = opaquePointer.bindMemory(to: Int8.self, capacity: MemoryLayout<Human>.stride)        
        return UnsafeMutablePointer<Int8>(mutableTypedPointer)
    }
}

MemoryLayout<Human>.size       //8


let human = Human()
let arrFormJson = ["goudan","zhaosi", "wangwu"]

//拿到指向 human 堆内存的 void * 指针
let humanRawPtr = unsafeMutableRawPointer(human.headerPointerOfClass())

//nicknames 数组在内存中偏移 64byte 的位置(16 + 16 + 32) (类型信息和引用计数 16、age:Int? = 16、name:String? = 32)
let humanNickNamesPtr =  humanRawPtr.advance(by: 64).assumingMemoryBound(to: Array<String>.self)
human.nicknames      
     //[]

humanNickNamePtr.initialize(arrFormJson)
human.nicknames           //["goudan","zhaosi", "wangwu"]
```





https://www.jianshu.com/p/76c365635212



在 Swift 中，struct 是值类型，一个没有引用类型的 Struct 临时变量都是在栈上存储的。

```
struct Point {
    var a: Double
    var b: Double
}
```

Double 8byte

Point 16byte



```
struct Point {
    var a: Double?
    var b: Double
}

MemoryLayout<Point>.size    //24
MemoryLayout<Double>.size               //8
MemoryLayout<Optional<Double>>.size     //9
```

a : Double? 占据9byte，每个属性起始位置只能为alignment的整数倍，所以b从16开始,整个占据24byte

因为值类型的函数是直接调用的，其函数地址在编译期就可以确定，编译时直接将调用语句替换为地址即可，不需要在期内部添加一个类似isa的数据去记录其类型信息。