# Swift





## 内存管理

Swift 内存管理还是和 OC 的 ARC 一样，自动管理内存分配。

### 构造函数和析构函数

这两个概念最早在学习C++的时候接触过。

Swift class默认就有构造函数和析构函数，而OC中，一个类不指定基类都没有办法声明。

```
class MyObject {
    var name = ""
    
    init() {
        print("MyObject init")
    }
    
    deinit {
    		// 变量释放的时候调用
        print("MyObject deinit")
    }
}

// 调用
{
	// ...
	let obj = MyObject()
  obj.name = "www"
  print(obj)
}

MyObject init
LearnSwift.MyObject
MyObject deinit
```

对 Struct 而言，有构造函数，没有析构函数。

### 参数

实参和形参之间的关系一般就两种，值传递和引用传递。

引用传递额外开销会比较小，只需要创建一个引用，一般就是指针，指针的大小是固定的，和对象本身无关。但是引用传递会有一个附加属性，'在不同的地方，可以对一个对象进行修改’，有时候这个附加是你想要的，有时候不是。值传递，形参和实参是两个不同的对象，但是值是一样的，值传递会消耗较多空间。

和其他的语言一样，针对不同的类型，实参和形参的关系会不同。swift中，class 是引用传递，其他都是值传递，可以使用 inout 将值传递改成引用传递。

将值传递改成引用传递可以参考下面的代码

```
func updateName(_ myStruct : inout MyStruct) {
    myStruct.name = "lalalala"
}

// 不加inout时，形参是个常量
func errorUpdateName(_ myStruct : MyStruct) {
✘    myStruct.name = "lalalala" // Cannot assign to property: 'myStruct' is a 'let' constant
}
```

### 指针

指针比其他的数据更接近底层，通过指针，我们能更加了解一门语言。

对于一块内存而言，如果不知道它对应的类型，那就没有办法正确的解读它记录的信息。

```
struct MyStruct {
    var name = "init name"
    init() {
        print("MyStruct init")
    }
}

var myStruct = MyStruct()

// 获取变量的指针
withUnsafePointer(to: &myStruct) { print("\($0)")}
withUnsafePointer(to: &myStruct) { (pointer) in
    print(pointer)
}

func getConstPointerType<T> (ptr:UnsafePointer<T>) -> UnsafePointer<T> {
    return ptr
}

let p = getConstPointerType(ptr: &myStruct)
// p.pointee 和 C 语言的 *p 是一样的
p.pointee.name = "haha"
print(p)

// 指针的内存不是自动管理的，需要自己手动释放
p.deallocate()

let p1 = UnsafePointer<MyStruct>(&myStruct)
var p2 = UnsafeMutablePointer<MyStruct>(&myStruct)
// 不能直接对变量使用&,
✘ let p1 = &myStruct // Use of extraneous '&'

// 'inout' may only be used on parameters
✘ let p1 : inout UnsafePointer = &myStruct
```



### MemoryLayout 

MemoryLayout 用来计算对象占用的内存,有stride、size、aligment三个属性，因为内存对齐的原因，对象占用的空间 stride 可能会大于其实际大小size,stride = size + aligment。

```
struct User {
    var age : Int = 0
}

let classSize = MemoryLayout<User>.size            // 8
let classStride = MemoryLayout<User>.stride        // 8
let classAligment = MemoryLayout<User>.alignment   // 8

let user = User()

// stride = size + aligment
let size = MemoryLayout.size(ofValue: user)           // 8
let stride = MemoryLayout.stride(ofValue: user)       // 8
let aligment = MemoryLayout.alignment(ofValue: user)  // 8
```







