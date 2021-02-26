## Swift Pointer

一种类型转换为另外一种类型.

共用测试代码

```
struct NumberStruct {
    var age = 20
    var height = 180
    var weight = 70
}

var num = NumberStruct()
var numPtr = UnsafeMutablePointer<NumberStruct>(&num)
```

> capacity count

如果原来的内存空间比较大，比如 numPtr 指向的空间大小为 24，在转化为 Int 类型的时候，Int占用8，那count 可以设置为 3，这样新的指针能完全读取空间的值



![cao'z](https://i.loli.net/2019/05/30/5cefae9e7111266063.png)

```
func withMemoryRebound<T, Result>(to type: T.Type, capacity count: Int, _ body: (UnsafeMutablePointer<T>) throws -> Result) rethrows -> Result

var length = numPtr.withMemoryRebound(to: Int.self, capacity: 4) {
    return
}

// 下边没有越界检查，不要越界
print(length[0])
print(length[1])
print(length[2])
print(length[3])

// 20
// 180
// 70
// 4849579392

length[0] = 999

// NumberStruct(age: 999, height: 180, weight: 70)
```

