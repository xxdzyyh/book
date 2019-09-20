## Swift 泛型

泛型为程语言提供了更高层级的抽象，即参数化类型。换句话说，就是把一个原本特定于某个类型的算法或类当中的类型信息抽象出来。这个抽象出来的概念在C++的STL（Standard Template Library）中就是模版（Template）。STL展示了泛型编程的强大之处，一出现就成为了C++的强大武器。除C++之外，C#，Java，Haskell等编程语言都引入了泛型概念。

泛型编程是一个稍微局部一些的概念，它仅仅涉及如何更抽象地处理类型，即参数化类型。这并不足以支撑起一门语言的核心概念。我们不会听到一个编程语言是纯泛型编程的，而没有其他编程范式。但正因为泛型并不会改变程序语言的核心，所以在大多数时候，它可以很好的融入到其他的编程方式中。C++，Scala，Haskell这些风格迥异的编程语言都支持泛型。泛型编程提供了更高的抽象层次，这意味着更强的表达能力。这对大部分编程语言来说都是一道美味佐餐美酒。

在Swift中，泛型得到广泛使用，许多Swift标准库是通过泛型代码构建出来的。例如Swift的数组和字典类型都是泛型集。这样的例子在Swift中随处可见。

### 无约束泛型

在使用的时候完全不知道参数的任何信息

```
func swap<T>(a:inout T,b:inout T) {
    let tmp = a
    a = b
    b = tmp
}
```

### 有约束泛型

完全不知道参数的任何信息，限制会很大，有时候需要一点点的提示，通常和协议一起配合使用

```
// 任何实现了Hashable协议的对象
func printHash<T:Hashable>(a:T) {
    print(a.hashValue)
}
```

如果约束是class类型，则和指定参数类型没有区别

```
func printObject<T:NSObject>(obj:T) {
    print(obj.description)
}

// 接受 class 实例作为参数，其实就是泛型，<T> 只是一种形式，不必太过于拘泥于形式
func printObject(obj:NSObject) {
    print(obj.description)
}
```



