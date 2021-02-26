## Swift 函数派发

一般调用者是不用关心函数是怎么派发的，只要确定调用的函数执行了就可以。

但是在编码的过程中可能会遇到一些奇怪的东西，想要知道答案的话就需要进一步了解细节。


### 协议和子类到底使用哪个？？？

```
import Foundation

protocol DataRefreshViewModelProtocol: AnyObject {
    func refreshData()
    func loadNextPageData()
    func request(page: Int, limit: Int)
}

extension DataRefreshViewModelProtocol {
    func refreshData() {
        print("DataRefreshViewModelProtocol refreshData()")
        request(page: 1, limit: 1)
    }
    
    func loadNextPageData() {
        print("DataRefreshViewModelProtocol loadNextPageData()")
        request(page: 2, limit: 1)
    }
    
    func request(page: Int, limit: Int) {
        print("DataRefreshViewModelProtocol request(page: Int, limit: Int)")
    }
}

class DefaultDataRefreshViewModel : NSObject,DataRefreshViewModelProtocol {
    func refreshData() {
        print("DefaultDataRefreshViewModel refreshData()")
        request(page: 1, limit: 1)
    }
}

class PageContainerDataRefreshViewModel : DefaultDataRefreshViewModel {
    override func refreshData() {
        print("PageContainerDataRefreshViewModel refreshData()")
        // class_method
        request(page: 1, limit: 1)
    }
    
    /// 方法不能添加 override，在派发的时候，直接走协议的witness table,这个方法没有注册到witness table,
    /// 所以最终调用的是协议的方法，解决方法
    func loadNextPageData() {
        print("PageContainerDataRefreshViewModel loadNextPageData()")
        request(page: 2, limit: 1)
    }

    func request(page: Int, limit: Int) {
        print("PageContainerDataRefreshViewModel request(page: Int, limit: Int)")
    }
}

let vm : DefaultDataRefreshViewModel = PageContainerDataRefreshViewModel()

vm.refreshData()
// PageContainerDataRefreshViewModel refreshData()
// PageContainerDataRefreshViewModel request(page: Int, limit: Int)
vm.request(page: 1, limit: 1)
// DataRefreshViewModelProtocol request(page: Int, limit: Int)
vm.loadNextPageData()
// DataRefreshViewModelProtocol loadNextPageData()
// DataRefreshViewModelProtocol request(page: Int, limit: Int)
```



### sil

```
swiftc -emit-sil MyProtocolPlayground.playground/Contents.swift | xcrun swift-demangle > ClassFunc.silgen
```

`%0、%1 ...`：这些其实就是临时变量

`function_ref`：可以理解为获取函数地址，获取了地址就可以直接执行

`apply x(y)`：apply就代表执行某个函数， x代表那个函数 ，y指的是参数

`v-table` :class 类型会创建一个虚函数表，用来进行方法查找，多态就是这么实现的，先搜索子类的虚函数表

`class_method` ：查找虚函数表到具体的函数

`objc_method`: 消息查找，通过objc_method 查找派发表得到chunk函数，chunk函数和函数的具体实现一一对应。

#### Metatype类型

`SIL`内的metatype类型必须描述自身表示：

- `@thin` 意思是不需要内存
- `@thick` 指存储的是类型的引用或类型子类的引用
- `@objc` 指存储的是一个OC类对象的表示而不是Swift类型对象。

#### 函数类型

`SIL`中的函数类型和Swift中的函数类型有以下区别：

- `SIL`函数可能是泛型。例如，通过`function_ref`返回一个泛型函数类型。

- `SIL`函数可以声明为`@noescape`。`@noescape`函数类型必须是`convention(thin)`或者`@callee_guatanteed`。

- `SIL`函数类型声明了以下几种处理上下文的情景：

  - `@convention(thin)`不要求上下文。这种类型也可以通过`@noescape`声明。
  - `@callee_guatanteed`会被认为直接参数。也意味着`convention(thick)`。
  - `@callee_owned`上下文值被认为是不拥有的直接参数。也意味着`convention(thick)`。
  - `@convention(block)`上下文值被认为是不拥有的直接参数。
  - 其他函数类型会被描述为`Properties of Types` 和 `Calling Convention`

- `SIL`函数必须声明参数的协议。非直接的参数类型是`*T`,直接参数类型是`T`

  - `@in`是非直接参数。地址必须是已经初始化的对象，函数负责销毁内部持有的值。
  - `@inout`是非直接参数。内存必须是已经初始化的对象。在函数返回之前，必须保证内存是被初始化的。

- `SIL`函数需要声明返回值的协议。

  - `@out`是非直接的结果。地址必须是未初始化的对象。

  `SIL`使用[class_method](https://github.com/apple/swift/blob/2ddc92a51a4c6d216a9b2dc3a2e41e9b592afbdf/docs/SIL.rst#class-method), [super_method](https://github.com/apple/swift/blob/2ddc92a51a4c6d216a9b2dc3a2e41e9b592afbdf/docs/SIL.rst#super-method), [objc_method](https://github.com/apple/swift/blob/2ddc92a51a4c6d216a9b2dc3a2e41e9b592afbdf/docs/SIL.rst#objc-method),和 [objc_super_method](https://github.com/apple/swift/blob/2ddc92a51a4c6d216a9b2dc3a2e41e9b592afbdf/docs/SIL.rst#objc-super-method)来表示类方法的动态分派`dynamic dispatch`[class_method](https://github.com/apple/swift/blob/2ddc92a51a4c6d216a9b2dc3a2e41e9b592afbdf/docs/SIL.rst#class-method) 和 [super_method](https://github.com/apple/swift/blob/2ddc92a51a4c6d216a9b2dc3a2e41e9b592afbdf/docs/SIL.rst#super-method)的实现是通过`sil_vtable`进行追踪的.`sil_vtable`的声明包含一个类的所有方法.

  

> let vm : DefaultDataRefreshViewModel = PageContainerDataRefreshViewModel()
>
> vm.refreshData()

```
sil_vtable PageContainerDataRefreshViewModel {
  #DefaultDataRefreshViewModel.refreshData!1: (DefaultDataRefreshViewModel) -> () -> () : @Contents.PageContainerDataRefreshViewModel.refreshData() -> () [override]	// PageContainerDataRefreshViewModel.refreshData()
}
```

在v-table中 DefaultDataRefreshViewModel.refreshData 映射到了 PageContainerDataRefreshViewModel.refreshData，所以下面的语句调用的是PageContainerDataRefreshViewModel的refreshData。

>let vm : DefaultDataRefreshViewModel = PageContainerDataRefreshViewModel()
>
>vm.loadNextPageData()

在虚表中

```

```

 DefaultDataRefreshViewModel.loadNextPageData 并没有映射到 PageContainerDataRefreshViewModel.loadNextPageData ,所以

`vm.loadNextPageData`调用的是 DefaultDataRefreshViewModel.loadNextPageData ，也就是协议DataRefreshViewModelProtocol的默认实现。



> request(page: Int, limit: Int)



```
sil_stage canonical

import Builtin
import Swift
import SwiftShims

import Foundation

protocol DataRefreshViewModelProtocol : AnyObject {
  func refreshData()
  func loadNextPageData()
  func request(page: Int, limit: Int)
}

extension DataRefreshViewModelProtocol {
  func refreshData()
  func loadNextPageData()
  func request(page: Int, limit: Int)
}

@objc @_inheritsConvenienceInitializers class DefaultDataRefreshViewModel : NSObject, DataRefreshViewModelProtocol {
  func refreshData()
  @objc deinit
  override dynamic init()
}

@objc @_inheritsConvenienceInitializers class PageContainerDataRefreshViewModel : DefaultDataRefreshViewModel {
  override func refreshData()
  func loadNextPageData()
  func request(page: Int, limit: Int)
  @objc deinit
  override dynamic init()
}

@_hasStorage @_hasInitialValue let vm: DefaultDataRefreshViewModel { get }

// vm
sil_global hidden [let] @Contents.vm : Contents.DefaultDataRefreshViewModel : $DefaultDataRefreshViewModel

// main
sil @main : $@convention(c) (Int32, UnsafeMutablePointer<Optional<UnsafeMutablePointer<Int8>>>) -> Int32 {
bb0(%0 : $Int32, %1 : $UnsafeMutablePointer<Optional<UnsafeMutablePointer<Int8>>>):
  alloc_global @Contents.vm : Contents.DefaultDataRefreshViewModel // id: %2

  %3 = global_addr @Contents.vm : Contents.DefaultDataRefreshViewModel : $*DefaultDataRefreshViewModel // users: %12, %9, %8

  %4 = metatype $@thick PageContainerDataRefreshViewModel.Type // user: %6

  // function_ref PageContainerDataRefreshViewModel.__allocating_init()

  %5 = function_ref @Contents.PageContainerDataRefreshViewModel.__allocating_init() -> Contents.PageContainerDataRefreshViewModel : $@convention(method) 
  (@thick PageContainerDataRefreshViewModel.Type) -> @owned PageContainerDataRefreshViewModel // user: %6

  %6 = apply %5(%4) : $@convention(method) (@thick PageContainerDataRefreshViewModel.Type) -> @owned PageContainerDataRefreshViewModel // user: %7

  %7 = upcast %6 : $PageContainerDataRefreshViewModel to $DefaultDataRefreshViewModel // user: %8

  store %7 to %3 : $*DefaultDataRefreshViewModel  // id: %8

  %9 = load %3 : $*DefaultDataRefreshViewModel    // users: %10, %11

  %10 = class_method %9 : $DefaultDataRefreshViewModel, #DefaultDataRefreshViewModel.refreshData!1 : (DefaultDataRefreshViewModel) -> () -> (), $@convention(method) (@guaranteed DefaultDataRefreshViewModel) -> () // user: %11

  %11 = apply %10(%9) : $@convention(method) (@guaranteed DefaultDataRefreshViewModel) -> ()

  %12 = load %3 : $*DefaultDataRefreshViewModel   // user: %14

  // function_ref DataRefreshViewModelProtocol.loadNextPageData()
  %13 = function_ref @(extension in Contents):Contents.DataRefreshViewModelProtocol.loadNextPageData() -> () : $@convention(method) <τ_0_0 where τ_0_0 : DataRefreshViewModelProtocol> (@guaranteed τ_0_0) -> () // user: %14
  %14 = apply %13<DefaultDataRefreshViewModel>(%12) : $@convention(method) <τ_0_0 where τ_0_0 : DataRefreshViewModelProtocol> (@guaranteed τ_0_0) -> ()
  %15 = integer_literal $Builtin.Int32, 0         // user: %16
  %16 = struct $Int32 (%15 : $Builtin.Int32)      // user: %17
  return %16 : $Int32                             // id: %17
} // end sil function 'main'


// DataRefreshViewModelProtocol.refreshData()
sil hidden @(extension in Contents):Contents.DataRefreshViewModelProtocol.refreshData() -> () : $@convention(method) <Self where Self : DataRefreshViewModelProtocol> (@guaranteed Self) -> () {
// %0                                             // users: %30, %1
bb0(%0 : $Self):
  debug_value %0 : $Self, let, name "self", argno 1 // id: %1
  %2 = integer_literal $Builtin.Word, 1           // user: %4
  // function_ref _allocateUninitializedArray<A>(_:)
  %3 = function_ref @Swift._allocateUninitializedArray<A>(Builtin.Word) -> ([A], Builtin.RawPointer) : $@convention(thin) <τ_0_0> (Builtin.Word) -> (@owned Array<τ_0_0>, Builtin.RawPointer) // user: %4
  %4 = apply %3<Any>(%2) : $@convention(thin) <τ_0_0> (Builtin.Word) -> (@owned Array<τ_0_0>, Builtin.RawPointer) // users: %6, %5
  %5 = tuple_extract %4 : $(Array<Any>, Builtin.RawPointer), 0 // users: %24, %21
  %6 = tuple_extract %4 : $(Array<Any>, Builtin.RawPointer), 1 // user: %7
  %7 = pointer_to_address %6 : $Builtin.RawPointer to [strict] $*Any // user: %14
  %8 = string_literal utf8 "DataRefreshViewModelProtocol refreshData()" // user: %13
  %9 = integer_literal $Builtin.Word, 42          // user: %13
  %10 = integer_literal $Builtin.Int1, -1         // user: %13
  %11 = metatype $@thin String.Type               // user: %13
  // function_ref String.init(_builtinStringLiteral:utf8CodeUnitCount:isASCII:)
  %12 = function_ref @Swift.String.init(_builtinStringLiteral: Builtin.RawPointer, utf8CodeUnitCount: Builtin.Word, isASCII: Builtin.Int1) -> Swift.String : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String // user: %13
  %13 = apply %12(%8, %9, %10, %11) : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String // user: %15
  %14 = init_existential_addr %7 : $*Any, $String // user: %15
  store %13 to %14 : $*String                     // id: %15
  // function_ref default argument 1 of print(_:separator:terminator:)
  %16 = function_ref @default argument 1 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) () -> @owned String // user: %17
  %17 = apply %16() : $@convention(thin) () -> @owned String // users: %23, %21
  // function_ref default argument 2 of print(_:separator:terminator:)
  %18 = function_ref @default argument 2 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) () -> @owned String // user: %19
  %19 = apply %18() : $@convention(thin) () -> @owned String // users: %22, %21
  // function_ref print(_:separator:terminator:)
  %20 = function_ref @Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) (@guaranteed Array<Any>, @guaranteed String, @guaranteed String) -> () // user: %21
  %21 = apply %20(%5, %17, %19) : $@convention(thin) (@guaranteed Array<Any>, @guaranteed String, @guaranteed String) -> ()
  release_value %19 : $String                     // id: %22
  release_value %17 : $String                     // id: %23
  release_value %5 : $Array<Any>                  // id: %24
  %25 = integer_literal $Builtin.Int64, 1         // user: %26
  %26 = struct $Int (%25 : $Builtin.Int64)        // user: %30
  %27 = integer_literal $Builtin.Int64, 1         // user: %28
  %28 = struct $Int (%27 : $Builtin.Int64)        // user: %30
  %29 = witness_method $Self, #DataRefreshViewModelProtocol.request!1 : <Self where Self : DataRefreshViewModelProtocol> (Self) -> (Int, Int) -> () : $@convention(witness_method: DataRefreshViewModelProtocol) <τ_0_0 where τ_0_0 : DataRefreshViewModelProtocol> (Int, Int, @guaranteed τ_0_0) -> () // user: %30
  %30 = apply %29<Self>(%26, %28, %0) : $@convention(witness_method: DataRefreshViewModelProtocol) <τ_0_0 where τ_0_0 : DataRefreshViewModelProtocol> (Int, Int, @guaranteed τ_0_0) -> ()
  %31 = tuple ()                                  // user: %32
  return %31 : $()                                // id: %32
} // end sil function '(extension in Contents):Contents.DataRefreshViewModelProtocol.refreshData() -> ()'

// _allocateUninitializedArray<A>(_:)
sil [serialized] [always_inline] [_semantics "array.uninitialized_intrinsic"] @Swift._allocateUninitializedArray<A>(Builtin.Word) -> ([A], Builtin.RawPointer) : $@convention(thin) <τ_0_0> (Builtin.Word) -> (@owned Array<τ_0_0>, Builtin.RawPointer)

// String.init(_builtinStringLiteral:utf8CodeUnitCount:isASCII:)
sil [serialized] [always_inline] [readonly] [_semantics "string.makeUTF8"] @Swift.String.init(_builtinStringLiteral: Builtin.RawPointer, utf8CodeUnitCount: Builtin.Word, isASCII: Builtin.Int1) -> Swift.String : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String

// default argument 1 of print(_:separator:terminator:)
sil shared_external [serialized] @default argument 1 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) () -> @owned String {
bb0:
  %0 = string_literal utf8 " "                    // user: %5
  %1 = integer_literal $Builtin.Word, 1           // user: %5
  %2 = integer_literal $Builtin.Int1, -1          // user: %5
  %3 = metatype $@thin String.Type                // user: %5
  // function_ref String.init(_builtinStringLiteral:utf8CodeUnitCount:isASCII:)
  %4 = function_ref @Swift.String.init(_builtinStringLiteral: Builtin.RawPointer, utf8CodeUnitCount: Builtin.Word, isASCII: Builtin.Int1) -> Swift.String : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String // user: %5
  %5 = apply %4(%0, %1, %2, %3) : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String // user: %6
  return %5 : $String                             // id: %6
} // end sil function 'default argument 1 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> ()'

// default argument 2 of print(_:separator:terminator:)
sil shared_external [serialized] @default argument 2 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) () -> @owned String {
bb0:
  %0 = string_literal utf8 "\n"                   // user: %5
  %1 = integer_literal $Builtin.Word, 1           // user: %5
  %2 = integer_literal $Builtin.Int1, -1          // user: %5
  %3 = metatype $@thin String.Type                // user: %5
  // function_ref String.init(_builtinStringLiteral:utf8CodeUnitCount:isASCII:)
  %4 = function_ref @Swift.String.init(_builtinStringLiteral: Builtin.RawPointer, utf8CodeUnitCount: Builtin.Word, isASCII: Builtin.Int1) -> Swift.String : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String // user: %5
  %5 = apply %4(%0, %1, %2, %3) : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String // user: %6
  return %5 : $String                             // id: %6
} // end sil function 'default argument 2 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> ()'

// print(_:separator:terminator:)
sil @Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) (@guaranteed Array<Any>, @guaranteed String, @guaranteed String) -> ()

// Int.init(_builtinIntegerLiteral:)
sil public_external [transparent] [serialized] @Swift.Int.init(_builtinIntegerLiteral: Builtin.IntLiteral) -> Swift.Int : $@convention(method) (Builtin.IntLiteral, @thin Int.Type) -> Int {
// %0                                             // user: %2
bb0(%0 : $Builtin.IntLiteral, %1 : $@thin Int.Type):
  %2 = builtin "s_to_s_checked_trunc_IntLiteral_Int64"(%0 : $Builtin.IntLiteral) : $(Builtin.Int64, Builtin.Int1) // user: %3
  %3 = tuple_extract %2 : $(Builtin.Int64, Builtin.Int1), 0 // user: %4
  %4 = struct $Int (%3 : $Builtin.Int64)          // user: %5
  return %4 : $Int                                // id: %5
} // end sil function 'Swift.Int.init(_builtinIntegerLiteral: Builtin.IntLiteral) -> Swift.Int'

// DataRefreshViewModelProtocol.loadNextPageData()
sil hidden @(extension in Contents):Contents.DataRefreshViewModelProtocol.loadNextPageData() -> () : $@convention(method) <Self where Self : DataRefreshViewModelProtocol> (@guaranteed Self) -> () {
// %0                                             // users: %30, %1
bb0(%0 : $Self):
  debug_value %0 : $Self, let, name "self", argno 1 // id: %1
  %2 = integer_literal $Builtin.Word, 1           // user: %4
  // function_ref _allocateUninitializedArray<A>(_:)
  %3 = function_ref @Swift._allocateUninitializedArray<A>(Builtin.Word) -> ([A], Builtin.RawPointer) : $@convention(thin) <τ_0_0> (Builtin.Word) -> (@owned Array<τ_0_0>, Builtin.RawPointer) // user: %4
  %4 = apply %3<Any>(%2) : $@convention(thin) <τ_0_0> (Builtin.Word) -> (@owned Array<τ_0_0>, Builtin.RawPointer) // users: %6, %5
  %5 = tuple_extract %4 : $(Array<Any>, Builtin.RawPointer), 0 // users: %24, %21
  %6 = tuple_extract %4 : $(Array<Any>, Builtin.RawPointer), 1 // user: %7
  %7 = pointer_to_address %6 : $Builtin.RawPointer to [strict] $*Any // user: %14
  %8 = string_literal utf8 "DataRefreshViewModelProtocol loadNextPageData()" // user: %13
  %9 = integer_literal $Builtin.Word, 47          // user: %13
  %10 = integer_literal $Builtin.Int1, -1         // user: %13
  %11 = metatype $@thin String.Type               // user: %13
  // function_ref String.init(_builtinStringLiteral:utf8CodeUnitCount:isASCII:)
  %12 = function_ref @Swift.String.init(_builtinStringLiteral: Builtin.RawPointer, utf8CodeUnitCount: Builtin.Word, isASCII: Builtin.Int1) -> Swift.String : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String // user: %13
  %13 = apply %12(%8, %9, %10, %11) : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String // user: %15
  %14 = init_existential_addr %7 : $*Any, $String // user: %15
  store %13 to %14 : $*String                     // id: %15
  // function_ref default argument 1 of print(_:separator:terminator:)
  %16 = function_ref @default argument 1 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) () -> @owned String // user: %17
  %17 = apply %16() : $@convention(thin) () -> @owned String // users: %23, %21
  // function_ref default argument 2 of print(_:separator:terminator:)
  %18 = function_ref @default argument 2 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) () -> @owned String // user: %19
  %19 = apply %18() : $@convention(thin) () -> @owned String // users: %22, %21
  // function_ref print(_:separator:terminator:)
  %20 = function_ref @Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) (@guaranteed Array<Any>, @guaranteed String, @guaranteed String) -> () // user: %21
  %21 = apply %20(%5, %17, %19) : $@convention(thin) (@guaranteed Array<Any>, @guaranteed String, @guaranteed String) -> ()
  release_value %19 : $String                     // id: %22
  release_value %17 : $String                     // id: %23
  release_value %5 : $Array<Any>                  // id: %24
  %25 = integer_literal $Builtin.Int64, 2         // user: %26
  %26 = struct $Int (%25 : $Builtin.Int64)        // user: %30
  %27 = integer_literal $Builtin.Int64, 1         // user: %28
  %28 = struct $Int (%27 : $Builtin.Int64)        // user: %30
  %29 = witness_method $Self, #DataRefreshViewModelProtocol.request!1 : <Self where Self : DataRefreshViewModelProtocol> (Self) -> (Int, Int) -> () : $@convention(witness_method: DataRefreshViewModelProtocol) <τ_0_0 where τ_0_0 : DataRefreshViewModelProtocol> (Int, Int, @guaranteed τ_0_0) -> () // user: %30
  %30 = apply %29<Self>(%26, %28, %0) : $@convention(witness_method: DataRefreshViewModelProtocol) <τ_0_0 where τ_0_0 : DataRefreshViewModelProtocol> (Int, Int, @guaranteed τ_0_0) -> ()
  %31 = tuple ()                                  // user: %32
  return %31 : $()                                // id: %32
} // end sil function '(extension in Contents):Contents.DataRefreshViewModelProtocol.loadNextPageData() -> ()'

// DataRefreshViewModelProtocol.request(page:limit:)
sil hidden @(extension in Contents):Contents.DataRefreshViewModelProtocol.request(page: Swift.Int, limit: Swift.Int) -> () : $@convention(method) <Self where Self : DataRefreshViewModelProtocol> (Int, Int, @guaranteed Self) -> () {
// %0                                             // user: %3
// %1                                             // user: %4
// %2                                             // user: %5
bb0(%0 : $Int, %1 : $Int, %2 : $Self):
  debug_value %0 : $Int, let, name "page", argno 1 // id: %3
  debug_value %1 : $Int, let, name "limit", argno 2 // id: %4
  debug_value %2 : $Self, let, name "self", argno 3 // id: %5
  %6 = integer_literal $Builtin.Word, 1           // user: %8
  // function_ref _allocateUninitializedArray<A>(_:)
  %7 = function_ref @Swift._allocateUninitializedArray<A>(Builtin.Word) -> ([A], Builtin.RawPointer) : $@convention(thin) <τ_0_0> (Builtin.Word) -> (@owned Array<τ_0_0>, Builtin.RawPointer) // user: %8
  %8 = apply %7<Any>(%6) : $@convention(thin) <τ_0_0> (Builtin.Word) -> (@owned Array<τ_0_0>, Builtin.RawPointer) // users: %10, %9
  %9 = tuple_extract %8 : $(Array<Any>, Builtin.RawPointer), 0 // users: %28, %25
  %10 = tuple_extract %8 : $(Array<Any>, Builtin.RawPointer), 1 // user: %11
  %11 = pointer_to_address %10 : $Builtin.RawPointer to [strict] $*Any // user: %18
  %12 = string_literal utf8 "DataRefreshViewModelProtocol request(page: Int, limit: Int)" // user: %17
  %13 = integer_literal $Builtin.Word, 59         // user: %17
  %14 = integer_literal $Builtin.Int1, -1         // user: %17
  %15 = metatype $@thin String.Type               // user: %17
  // function_ref String.init(_builtinStringLiteral:utf8CodeUnitCount:isASCII:)
  %16 = function_ref @Swift.String.init(_builtinStringLiteral: Builtin.RawPointer, utf8CodeUnitCount: Builtin.Word, isASCII: Builtin.Int1) -> Swift.String : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String // user: %17
  %17 = apply %16(%12, %13, %14, %15) : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String // user: %19
  %18 = init_existential_addr %11 : $*Any, $String // user: %19
  store %17 to %18 : $*String                     // id: %19
  // function_ref default argument 1 of print(_:separator:terminator:)
  %20 = function_ref @default argument 1 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) () -> @owned String // user: %21
  %21 = apply %20() : $@convention(thin) () -> @owned String // users: %27, %25
  // function_ref default argument 2 of print(_:separator:terminator:)
  %22 = function_ref @default argument 2 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) () -> @owned String // user: %23
  %23 = apply %22() : $@convention(thin) () -> @owned String // users: %26, %25
  // function_ref print(_:separator:terminator:)
  %24 = function_ref @Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) (@guaranteed Array<Any>, @guaranteed String, @guaranteed String) -> () // user: %25
  %25 = apply %24(%9, %21, %23) : $@convention(thin) (@guaranteed Array<Any>, @guaranteed String, @guaranteed String) -> ()
  release_value %23 : $String                     // id: %26
  release_value %21 : $String                     // id: %27
  release_value %9 : $Array<Any>                  // id: %28
  %29 = tuple ()                                  // user: %30
  return %29 : $()                                // id: %30
} // end sil function '(extension in Contents):Contents.DataRefreshViewModelProtocol.request(page: Swift.Int, limit: Swift.Int) -> ()'

// DefaultDataRefreshViewModel.refreshData()
sil hidden @Contents.DefaultDataRefreshViewModel.refreshData() -> () : $@convention(method) (@guaranteed DefaultDataRefreshViewModel) -> () {
// %0                                             // users: %30, %1
bb0(%0 : $DefaultDataRefreshViewModel):
  debug_value %0 : $DefaultDataRefreshViewModel, let, name "self", argno 1 // id: %1
  %2 = integer_literal $Builtin.Word, 1           // user: %4
  // function_ref _allocateUninitializedArray<A>(_:)
  %3 = function_ref @Swift._allocateUninitializedArray<A>(Builtin.Word) -> ([A], Builtin.RawPointer) : $@convention(thin) <τ_0_0> (Builtin.Word) -> (@owned Array<τ_0_0>, Builtin.RawPointer) // user: %4
  %4 = apply %3<Any>(%2) : $@convention(thin) <τ_0_0> (Builtin.Word) -> (@owned Array<τ_0_0>, Builtin.RawPointer) // users: %6, %5
  %5 = tuple_extract %4 : $(Array<Any>, Builtin.RawPointer), 0 // users: %24, %21
  %6 = tuple_extract %4 : $(Array<Any>, Builtin.RawPointer), 1 // user: %7
  %7 = pointer_to_address %6 : $Builtin.RawPointer to [strict] $*Any // user: %14
  %8 = string_literal utf8 "DefaultDataRefreshViewModel refreshData()" // user: %13
  %9 = integer_literal $Builtin.Word, 41          // user: %13
  %10 = integer_literal $Builtin.Int1, -1         // user: %13
  %11 = metatype $@thin String.Type               // user: %13
  // function_ref String.init(_builtinStringLiteral:utf8CodeUnitCount:isASCII:)
  %12 = function_ref @Swift.String.init(_builtinStringLiteral: Builtin.RawPointer, utf8CodeUnitCount: Builtin.Word, isASCII: Builtin.Int1) -> Swift.String : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String // user: %13
  %13 = apply %12(%8, %9, %10, %11) : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String // user: %15
  %14 = init_existential_addr %7 : $*Any, $String // user: %15
  store %13 to %14 : $*String                     // id: %15
  // function_ref default argument 1 of print(_:separator:terminator:)
  %16 = function_ref @default argument 1 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) () -> @owned String // user: %17
  %17 = apply %16() : $@convention(thin) () -> @owned String // users: %23, %21
  // function_ref default argument 2 of print(_:separator:terminator:)
  %18 = function_ref @default argument 2 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) () -> @owned String // user: %19
  %19 = apply %18() : $@convention(thin) () -> @owned String // users: %22, %21
  // function_ref print(_:separator:terminator:)
  %20 = function_ref @Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) (@guaranteed Array<Any>, @guaranteed String, @guaranteed String) -> () // user: %21
  %21 = apply %20(%5, %17, %19) : $@convention(thin) (@guaranteed Array<Any>, @guaranteed String, @guaranteed String) -> ()
  release_value %19 : $String                     // id: %22
  release_value %17 : $String                     // id: %23
  release_value %5 : $Array<Any>                  // id: %24
  %25 = integer_literal $Builtin.Int64, 1         // user: %26
  %26 = struct $Int (%25 : $Builtin.Int64)        // user: %30
  %27 = integer_literal $Builtin.Int64, 1         // user: %28
  %28 = struct $Int (%27 : $Builtin.Int64)        // user: %30
  // function_ref DataRefreshViewModelProtocol.request(page:limit:)
  %29 = function_ref @(extension in Contents):Contents.DataRefreshViewModelProtocol.request(page: Swift.Int, limit: Swift.Int) -> () : $@convention(method) <τ_0_0 where τ_0_0 : DataRefreshViewModelProtocol> (Int, Int, @guaranteed τ_0_0) -> () // user: %30
  %30 = apply %29<DefaultDataRefreshViewModel>(%26, %28, %0) : $@convention(method) <τ_0_0 where τ_0_0 : DataRefreshViewModelProtocol> (Int, Int, @guaranteed τ_0_0) -> ()
  %31 = tuple ()                                  // user: %32
  return %31 : $()                                // id: %32
} // end sil function 'Contents.DefaultDataRefreshViewModel.refreshData() -> ()'

// DefaultDataRefreshViewModel.__deallocating_deinit
sil hidden @Contents.DefaultDataRefreshViewModel.__deallocating_deinit : $@convention(method) (@owned DefaultDataRefreshViewModel) -> () {
// %0                                             // users: %3, %2, %1
bb0(%0 : $DefaultDataRefreshViewModel):
  debug_value %0 : $DefaultDataRefreshViewModel, let, name "self", argno 1 // id: %1
  %2 = objc_super_method %0 : $DefaultDataRefreshViewModel, #NSObject.deinit!deallocator.1.foreign : (NSObject) -> () -> (), $@convention(objc_method) (NSObject) -> () // user: %4
  %3 = upcast %0 : $DefaultDataRefreshViewModel to $NSObject // user: %4
  %4 = apply %2(%3) : $@convention(objc_method) (NSObject) -> ()
  %5 = tuple ()                                   // user: %6
  return %5 : $()                                 // id: %6
} // end sil function 'Contents.DefaultDataRefreshViewModel.__deallocating_deinit'

// DefaultDataRefreshViewModel.__allocating_init()
sil hidden @Contents.DefaultDataRefreshViewModel.__allocating_init() -> Contents.DefaultDataRefreshViewModel : $@convention(method) (@thick DefaultDataRefreshViewModel.Type) -> @owned DefaultDataRefreshViewModel {
// %0                                             // user: %1
bb0(%0 : $@thick DefaultDataRefreshViewModel.Type):
  %1 = thick_to_objc_metatype %0 : $@thick DefaultDataRefreshViewModel.Type to $@objc_metatype DefaultDataRefreshViewModel.Type // user: %2
  %2 = alloc_ref_dynamic [objc] %1 : $@objc_metatype DefaultDataRefreshViewModel.Type, $DefaultDataRefreshViewModel // users: %4, %3
  %3 = objc_method %2 : $DefaultDataRefreshViewModel, #DefaultDataRefreshViewModel.init!initializer.1.foreign : (DefaultDataRefreshViewModel.Type) -> () -> DefaultDataRefreshViewModel, $@convention(objc_method) (@owned DefaultDataRefreshViewModel) -> @owned DefaultDataRefreshViewModel // user: %4
  %4 = apply %3(%2) : $@convention(objc_method) (@owned DefaultDataRefreshViewModel) -> @owned DefaultDataRefreshViewModel // user: %5
  return %4 : $DefaultDataRefreshViewModel        // id: %5
} // end sil function 'Contents.DefaultDataRefreshViewModel.__allocating_init() -> Contents.DefaultDataRefreshViewModel'

// DefaultDataRefreshViewModel.init()
sil hidden @Contents.DefaultDataRefreshViewModel.init() -> Contents.DefaultDataRefreshViewModel : $@convention(method) (@owned DefaultDataRefreshViewModel) -> @owned DefaultDataRefreshViewModel {
// %0                                             // user: %2
bb0(%0 : $DefaultDataRefreshViewModel):
  %1 = alloc_stack $DefaultDataRefreshViewModel, let, name "self" // users: %10, %3, %2, %11, %12
  store %0 to %1 : $*DefaultDataRefreshViewModel  // id: %2
  %3 = load %1 : $*DefaultDataRefreshViewModel    // user: %4
  %4 = upcast %3 : $DefaultDataRefreshViewModel to $NSObject // users: %5, %7
  %5 = unchecked_ref_cast %4 : $NSObject to $DefaultDataRefreshViewModel // user: %6
  %6 = objc_super_method %5 : $DefaultDataRefreshViewModel, #NSObject.init!initializer.1.foreign : (NSObject.Type) -> () -> NSObject, $@convention(objc_method) (@owned NSObject) -> @owned NSObject // user: %7
  %7 = apply %6(%4) : $@convention(objc_method) (@owned NSObject) -> @owned NSObject // user: %8
  %8 = unchecked_ref_cast %7 : $NSObject to $DefaultDataRefreshViewModel // users: %13, %10, %9
  strong_retain %8 : $DefaultDataRefreshViewModel // id: %9
  store %8 to %1 : $*DefaultDataRefreshViewModel  // id: %10
  destroy_addr %1 : $*DefaultDataRefreshViewModel // id: %11
  dealloc_stack %1 : $*DefaultDataRefreshViewModel // id: %12
  return %8 : $DefaultDataRefreshViewModel        // id: %13
} // end sil function 'Contents.DefaultDataRefreshViewModel.init() -> Contents.DefaultDataRefreshViewModel'

// @objc DefaultDataRefreshViewModel.init()
sil hidden [thunk] @@objc Contents.DefaultDataRefreshViewModel.init() -> Contents.DefaultDataRefreshViewModel : $@convention(objc_method) (@owned DefaultDataRefreshViewModel) -> @owned DefaultDataRefreshViewModel {
// %0                                             // user: %2
bb0(%0 : $DefaultDataRefreshViewModel):
  // function_ref DefaultDataRefreshViewModel.init()
  %1 = function_ref @Contents.DefaultDataRefreshViewModel.init() -> Contents.DefaultDataRefreshViewModel : $@convention(method) (@owned DefaultDataRefreshViewModel) -> @owned DefaultDataRefreshViewModel // user: %2
  %2 = apply %1(%0) : $@convention(method) (@owned DefaultDataRefreshViewModel) -> @owned DefaultDataRefreshViewModel // user: %3
  return %2 : $DefaultDataRefreshViewModel        // id: %3
} // end sil function '@objc Contents.DefaultDataRefreshViewModel.init() -> Contents.DefaultDataRefreshViewModel'

// protocol witness for DataRefreshViewModelProtocol.refreshData() in conformance DefaultDataRefreshViewModel
sil private [transparent] [thunk] @protocol witness for Contents.DataRefreshViewModelProtocol.refreshData() -> () in conformance Contents.DefaultDataRefreshViewModel : Contents.DataRefreshViewModelProtocol in Contents : $@convention(witness_method: DataRefreshViewModelProtocol) (@guaranteed DefaultDataRefreshViewModel) -> () {
// %0                                             // users: %2, %1
bb0(%0 : $DefaultDataRefreshViewModel):
  %1 = class_method %0 : $DefaultDataRefreshViewModel, #DefaultDataRefreshViewModel.refreshData!1 : (DefaultDataRefreshViewModel) -> () -> (), $@convention(method) (@guaranteed DefaultDataRefreshViewModel) -> () // user: %2
  %2 = apply %1(%0) : $@convention(method) (@guaranteed DefaultDataRefreshViewModel) -> ()
  %3 = tuple ()                                   // user: %4
  return %3 : $()                                 // id: %4
} // end sil function 'protocol witness for Contents.DataRefreshViewModelProtocol.refreshData() -> () in conformance Contents.DefaultDataRefreshViewModel : Contents.DataRefreshViewModelProtocol in Contents'

// protocol witness for DataRefreshViewModelProtocol.loadNextPageData() in conformance DefaultDataRefreshViewModel
sil private [transparent] [thunk] @protocol witness for Contents.DataRefreshViewModelProtocol.loadNextPageData() -> () in conformance Contents.DefaultDataRefreshViewModel : Contents.DataRefreshViewModelProtocol in Contents : $@convention(witness_method: DataRefreshViewModelProtocol) <τ_0_0 where τ_0_0 : DefaultDataRefreshViewModel> (@guaranteed τ_0_0) -> () {
// %0                                             // user: %2
bb0(%0 : $τ_0_0):
  // function_ref DataRefreshViewModelProtocol.loadNextPageData()
  %1 = function_ref @(extension in Contents):Contents.DataRefreshViewModelProtocol.loadNextPageData() -> () : $@convention(method) <τ_0_0 where τ_0_0 : DataRefreshViewModelProtocol> (@guaranteed τ_0_0) -> () // user: %2
  %2 = apply %1<τ_0_0>(%0) : $@convention(method) <τ_0_0 where τ_0_0 : DataRefreshViewModelProtocol> (@guaranteed τ_0_0) -> ()
  %3 = tuple ()                                   // user: %4
  return %3 : $()                                 // id: %4
} // end sil function 'protocol witness for Contents.DataRefreshViewModelProtocol.loadNextPageData() -> () in conformance Contents.DefaultDataRefreshViewModel : Contents.DataRefreshViewModelProtocol in Contents'

// protocol witness for DataRefreshViewModelProtocol.request(page:limit:) in conformance DefaultDataRefreshViewModel
sil private [transparent] [thunk] @protocol witness for Contents.DataRefreshViewModelProtocol.request(page: Swift.Int, limit: Swift.Int) -> () in conformance Contents.DefaultDataRefreshViewModel : Contents.DataRefreshViewModelProtocol in Contents : $@convention(witness_method: DataRefreshViewModelProtocol) <τ_0_0 where τ_0_0 : DefaultDataRefreshViewModel> (Int, Int, @guaranteed τ_0_0) -> () {
// %0                                             // user: %4
// %1                                             // user: %4
// %2                                             // user: %4
bb0(%0 : $Int, %1 : $Int, %2 : $τ_0_0):
  // function_ref DataRefreshViewModelProtocol.request(page:limit:)
  %3 = function_ref @(extension in Contents):Contents.DataRefreshViewModelProtocol.request(page: Swift.Int, limit: Swift.Int) -> () : $@convention(method) <τ_0_0 where τ_0_0 : DataRefreshViewModelProtocol> (Int, Int, @guaranteed τ_0_0) -> () // user: %4
  %4 = apply %3<τ_0_0>(%0, %1, %2) : $@convention(method) <τ_0_0 where τ_0_0 : DataRefreshViewModelProtocol> (Int, Int, @guaranteed τ_0_0) -> ()
  %5 = tuple ()                                   // user: %6
  return %5 : $()                                 // id: %6
} // end sil function 'protocol witness for Contents.DataRefreshViewModelProtocol.request(page: Swift.Int, limit: Swift.Int) -> () in conformance Contents.DefaultDataRefreshViewModel : Contents.DataRefreshViewModelProtocol in Contents'

// PageContainerDataRefreshViewModel.refreshData()
sil hidden @Contents.PageContainerDataRefreshViewModel.refreshData() -> () : $@convention(method) (@guaranteed PageContainerDataRefreshViewModel) -> () {
// %0                                             // users: %30, %29, %1
bb0(%0 : $PageContainerDataRefreshViewModel):
  debug_value %0 : $PageContainerDataRefreshViewModel, let, name "self", argno 1 // id: %1
  %2 = integer_literal $Builtin.Word, 1           // user: %4
  // function_ref _allocateUninitializedArray<A>(_:)
  %3 = function_ref @Swift._allocateUninitializedArray<A>(Builtin.Word) -> ([A], Builtin.RawPointer) : $@convention(thin) <τ_0_0> (Builtin.Word) -> (@owned Array<τ_0_0>, Builtin.RawPointer) // user: %4
  %4 = apply %3<Any>(%2) : $@convention(thin) <τ_0_0> (Builtin.Word) -> (@owned Array<τ_0_0>, Builtin.RawPointer) // users: %6, %5
  %5 = tuple_extract %4 : $(Array<Any>, Builtin.RawPointer), 0 // users: %24, %21
  %6 = tuple_extract %4 : $(Array<Any>, Builtin.RawPointer), 1 // user: %7
  %7 = pointer_to_address %6 : $Builtin.RawPointer to [strict] $*Any // user: %14
  %8 = string_literal utf8 "PageContainerDataRefreshViewModel refreshData()" // user: %13
  %9 = integer_literal $Builtin.Word, 47          // user: %13
  %10 = integer_literal $Builtin.Int1, -1         // user: %13
  %11 = metatype $@thin String.Type               // user: %13
  // function_ref String.init(_builtinStringLiteral:utf8CodeUnitCount:isASCII:)
  %12 = function_ref @Swift.String.init(_builtinStringLiteral: Builtin.RawPointer, utf8CodeUnitCount: Builtin.Word, isASCII: Builtin.Int1) -> Swift.String : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String // user: %13
  %13 = apply %12(%8, %9, %10, %11) : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String // user: %15
  %14 = init_existential_addr %7 : $*Any, $String // user: %15
  store %13 to %14 : $*String                     // id: %15
  // function_ref default argument 1 of print(_:separator:terminator:)
  %16 = function_ref @default argument 1 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) () -> @owned String // user: %17
  %17 = apply %16() : $@convention(thin) () -> @owned String // users: %23, %21
  // function_ref default argument 2 of print(_:separator:terminator:)
  %18 = function_ref @default argument 2 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) () -> @owned String // user: %19
  %19 = apply %18() : $@convention(thin) () -> @owned String // users: %22, %21
  // function_ref print(_:separator:terminator:)
  %20 = function_ref @Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) (@guaranteed Array<Any>, @guaranteed String, @guaranteed String) -> () // user: %21
  %21 = apply %20(%5, %17, %19) : $@convention(thin) (@guaranteed Array<Any>, @guaranteed String, @guaranteed String) -> ()
  release_value %19 : $String                     // id: %22
  release_value %17 : $String                     // id: %23
  release_value %5 : $Array<Any>                  // id: %24
  %25 = integer_literal $Builtin.Int64, 1         // user: %26
  %26 = struct $Int (%25 : $Builtin.Int64)        // user: %30
  %27 = integer_literal $Builtin.Int64, 1         // user: %28
  %28 = struct $Int (%27 : $Builtin.Int64)        // user: %30
  %29 = class_method %0 : $PageContainerDataRefreshViewModel, #PageContainerDataRefreshViewModel.request!1 : (PageContainerDataRefreshViewModel) -> (Int, Int) -> (), $@convention(method) (Int, Int, @guaranteed PageContainerDataRefreshViewModel) -> () // user: %30
  %30 = apply %29(%26, %28, %0) : $@convention(method) (Int, Int, @guaranteed PageContainerDataRefreshViewModel) -> ()
  %31 = tuple ()                                  // user: %32
  return %31 : $()                                // id: %32
} // end sil function 'Contents.PageContainerDataRefreshViewModel.refreshData() -> ()'

// PageContainerDataRefreshViewModel.loadNextPageData()
sil hidden @Contents.PageContainerDataRefreshViewModel.loadNextPageData() -> () : $@convention(method) (@guaranteed PageContainerDataRefreshViewModel) -> () {
// %0                                             // users: %30, %29, %1
bb0(%0 : $PageContainerDataRefreshViewModel):
  debug_value %0 : $PageContainerDataRefreshViewModel, let, name "self", argno 1 // id: %1
  %2 = integer_literal $Builtin.Word, 1           // user: %4
  // function_ref _allocateUninitializedArray<A>(_:)
  %3 = function_ref @Swift._allocateUninitializedArray<A>(Builtin.Word) -> ([A], Builtin.RawPointer) : $@convention(thin) <τ_0_0> (Builtin.Word) -> (@owned Array<τ_0_0>, Builtin.RawPointer) // user: %4
  %4 = apply %3<Any>(%2) : $@convention(thin) <τ_0_0> (Builtin.Word) -> (@owned Array<τ_0_0>, Builtin.RawPointer) // users: %6, %5
  %5 = tuple_extract %4 : $(Array<Any>, Builtin.RawPointer), 0 // users: %24, %21
  %6 = tuple_extract %4 : $(Array<Any>, Builtin.RawPointer), 1 // user: %7
  %7 = pointer_to_address %6 : $Builtin.RawPointer to [strict] $*Any // user: %14
  %8 = string_literal utf8 "PageContainerDataRefreshViewModel loadNextPageData()" // user: %13
  %9 = integer_literal $Builtin.Word, 52          // user: %13
  %10 = integer_literal $Builtin.Int1, -1         // user: %13
  %11 = metatype $@thin String.Type               // user: %13
  // function_ref String.init(_builtinStringLiteral:utf8CodeUnitCount:isASCII:)
  %12 = function_ref @Swift.String.init(_builtinStringLiteral: Builtin.RawPointer, utf8CodeUnitCount: Builtin.Word, isASCII: Builtin.Int1) -> Swift.String : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String // user: %13
  %13 = apply %12(%8, %9, %10, %11) : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String // user: %15
  %14 = init_existential_addr %7 : $*Any, $String // user: %15
  store %13 to %14 : $*String                     // id: %15
  // function_ref default argument 1 of print(_:separator:terminator:)
  %16 = function_ref @default argument 1 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) () -> @owned String // user: %17
  %17 = apply %16() : $@convention(thin) () -> @owned String // users: %23, %21
  // function_ref default argument 2 of print(_:separator:terminator:)
  %18 = function_ref @default argument 2 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) () -> @owned String // user: %19
  %19 = apply %18() : $@convention(thin) () -> @owned String // users: %22, %21
  // function_ref print(_:separator:terminator:)
  %20 = function_ref @Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) (@guaranteed Array<Any>, @guaranteed String, @guaranteed String) -> () // user: %21
  %21 = apply %20(%5, %17, %19) : $@convention(thin) (@guaranteed Array<Any>, @guaranteed String, @guaranteed String) -> ()
  release_value %19 : $String                     // id: %22
  release_value %17 : $String                     // id: %23
  release_value %5 : $Array<Any>                  // id: %24
  %25 = integer_literal $Builtin.Int64, 2         // user: %26
  %26 = struct $Int (%25 : $Builtin.Int64)        // user: %30
  %27 = integer_literal $Builtin.Int64, 1         // user: %28
  %28 = struct $Int (%27 : $Builtin.Int64)        // user: %30
  %29 = class_method %0 : $PageContainerDataRefreshViewModel, #PageContainerDataRefreshViewModel.request!1 : (PageContainerDataRefreshViewModel) -> (Int, Int) -> (), $@convention(method) (Int, Int, @guaranteed PageContainerDataRefreshViewModel) -> () // user: %30
  %30 = apply %29(%26, %28, %0) : $@convention(method) (Int, Int, @guaranteed PageContainerDataRefreshViewModel) -> ()
  %31 = tuple ()                                  // user: %32
  return %31 : $()                                // id: %32
} // end sil function 'Contents.PageContainerDataRefreshViewModel.loadNextPageData() -> ()'

// PageContainerDataRefreshViewModel.request(page:limit:)
sil hidden @Contents.PageContainerDataRefreshViewModel.request(page: Swift.Int, limit: Swift.Int) -> () : $@convention(method) (Int, Int, @guaranteed PageContainerDataRefreshViewModel) -> () {
// %0                                             // user: %3
// %1                                             // user: %4
// %2                                             // user: %5
bb0(%0 : $Int, %1 : $Int, %2 : $PageContainerDataRefreshViewModel):
  debug_value %0 : $Int, let, name "page", argno 1 // id: %3
  debug_value %1 : $Int, let, name "limit", argno 2 // id: %4
  debug_value %2 : $PageContainerDataRefreshViewModel, let, name "self", argno 3 // id: %5
  %6 = integer_literal $Builtin.Word, 1           // user: %8
  // function_ref _allocateUninitializedArray<A>(_:)
  %7 = function_ref @Swift._allocateUninitializedArray<A>(Builtin.Word) -> ([A], Builtin.RawPointer) : $@convention(thin) <τ_0_0> (Builtin.Word) -> (@owned Array<τ_0_0>, Builtin.RawPointer) // user: %8
  %8 = apply %7<Any>(%6) : $@convention(thin) <τ_0_0> (Builtin.Word) -> (@owned Array<τ_0_0>, Builtin.RawPointer) // users: %10, %9
  %9 = tuple_extract %8 : $(Array<Any>, Builtin.RawPointer), 0 // users: %28, %25
  %10 = tuple_extract %8 : $(Array<Any>, Builtin.RawPointer), 1 // user: %11
  %11 = pointer_to_address %10 : $Builtin.RawPointer to [strict] $*Any // user: %18
  %12 = string_literal utf8 "PageContainerDataRefreshViewModel request(page: Int, limit: Int)" // user: %17
  %13 = integer_literal $Builtin.Word, 64         // user: %17
  %14 = integer_literal $Builtin.Int1, -1         // user: %17
  %15 = metatype $@thin String.Type               // user: %17
  // function_ref String.init(_builtinStringLiteral:utf8CodeUnitCount:isASCII:)
  %16 = function_ref @Swift.String.init(_builtinStringLiteral: Builtin.RawPointer, utf8CodeUnitCount: Builtin.Word, isASCII: Builtin.Int1) -> Swift.String : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String // user: %17
  %17 = apply %16(%12, %13, %14, %15) : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String // user: %19
  %18 = init_existential_addr %11 : $*Any, $String // user: %19
  store %17 to %18 : $*String                     // id: %19
  // function_ref default argument 1 of print(_:separator:terminator:)
  %20 = function_ref @default argument 1 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) () -> @owned String // user: %21
  %21 = apply %20() : $@convention(thin) () -> @owned String // users: %27, %25
  // function_ref default argument 2 of print(_:separator:terminator:)
  %22 = function_ref @default argument 2 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) () -> @owned String // user: %23
  %23 = apply %22() : $@convention(thin) () -> @owned String // users: %26, %25
  // function_ref print(_:separator:terminator:)
  %24 = function_ref @Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) (@guaranteed Array<Any>, @guaranteed String, @guaranteed String) -> () // user: %25
  %25 = apply %24(%9, %21, %23) : $@convention(thin) (@guaranteed Array<Any>, @guaranteed String, @guaranteed String) -> ()
  release_value %23 : $String                     // id: %26
  release_value %21 : $String                     // id: %27
  release_value %9 : $Array<Any>                  // id: %28
  %29 = tuple ()                                  // user: %30
  return %29 : $()                                // id: %30
} // end sil function 'Contents.PageContainerDataRefreshViewModel.request(page: Swift.Int, limit: Swift.Int) -> ()'

// PageContainerDataRefreshViewModel.__deallocating_deinit
sil hidden @Contents.PageContainerDataRefreshViewModel.__deallocating_deinit : $@convention(method) (@owned PageContainerDataRefreshViewModel) -> () {
// %0                                             // users: %3, %2, %1
bb0(%0 : $PageContainerDataRefreshViewModel):
  debug_value %0 : $PageContainerDataRefreshViewModel, let, name "self", argno 1 // id: %1
  %2 = objc_super_method %0 : $PageContainerDataRefreshViewModel, #DefaultDataRefreshViewModel.deinit!deallocator.1.foreign : (DefaultDataRefreshViewModel) -> () -> (), $@convention(objc_method) (DefaultDataRefreshViewModel) -> () // user: %4
  %3 = upcast %0 : $PageContainerDataRefreshViewModel to $DefaultDataRefreshViewModel // user: %4
  %4 = apply %2(%3) : $@convention(objc_method) (DefaultDataRefreshViewModel) -> ()
  %5 = tuple ()                                   // user: %6
  return %5 : $()                                 // id: %6
} // end sil function 'Contents.PageContainerDataRefreshViewModel.__deallocating_deinit'

// PageContainerDataRefreshViewModel.__allocating_init()
sil hidden @Contents.PageContainerDataRefreshViewModel.__allocating_init() -> Contents.PageContainerDataRefreshViewModel : $@convention(method) (@thick PageContainerDataRefreshViewModel.Type) -> @owned PageContainerDataRefreshViewModel {
// %0                                             // user: %1
bb0(%0 : $@thick PageContainerDataRefreshViewModel.Type):
  %1 = thick_to_objc_metatype %0 : $@thick PageContainerDataRefreshViewModel.Type to $@objc_metatype PageContainerDataRefreshViewModel.Type // user: %2
  %2 = alloc_ref_dynamic [objc] %1 : $@objc_metatype PageContainerDataRefreshViewModel.Type, $PageContainerDataRefreshViewModel // users: %4, %3
  %3 = objc_method %2 : $PageContainerDataRefreshViewModel, #PageContainerDataRefreshViewModel.init!initializer.1.foreign : (PageContainerDataRefreshViewModel.Type) -> () -> PageContainerDataRefreshViewModel, $@convention(objc_method) (@owned PageContainerDataRefreshViewModel) -> @owned PageContainerDataRefreshViewModel // user: %4
  %4 = apply %3(%2) : $@convention(objc_method) (@owned PageContainerDataRefreshViewModel) -> @owned PageContainerDataRefreshViewModel // user: %5
  return %4 : $PageContainerDataRefreshViewModel  // id: %5
} // end sil function 'Contents.PageContainerDataRefreshViewModel.__allocating_init() -> Contents.PageContainerDataRefreshViewModel'

// PageContainerDataRefreshViewModel.init()
sil hidden @Contents.PageContainerDataRefreshViewModel.init() -> Contents.PageContainerDataRefreshViewModel : $@convention(method) (@owned PageContainerDataRefreshViewModel) -> @owned PageContainerDataRefreshViewModel {
// %0                                             // user: %2
bb0(%0 : $PageContainerDataRefreshViewModel):
  %1 = alloc_stack $PageContainerDataRefreshViewModel, let, name "self" // users: %10, %3, %2, %11, %12
  store %0 to %1 : $*PageContainerDataRefreshViewModel // id: %2
  %3 = load %1 : $*PageContainerDataRefreshViewModel // user: %4
  %4 = upcast %3 : $PageContainerDataRefreshViewModel to $DefaultDataRefreshViewModel // users: %5, %7
  %5 = unchecked_ref_cast %4 : $DefaultDataRefreshViewModel to $PageContainerDataRefreshViewModel // user: %6
  %6 = objc_super_method %5 : $PageContainerDataRefreshViewModel, #DefaultDataRefreshViewModel.init!initializer.1.foreign : (DefaultDataRefreshViewModel.Type) -> () -> DefaultDataRefreshViewModel, $@convention(objc_method) (@owned DefaultDataRefreshViewModel) -> @owned DefaultDataRefreshViewModel // user: %7
  %7 = apply %6(%4) : $@convention(objc_method) (@owned DefaultDataRefreshViewModel) -> @owned DefaultDataRefreshViewModel // user: %8
  %8 = unchecked_ref_cast %7 : $DefaultDataRefreshViewModel to $PageContainerDataRefreshViewModel // users: %13, %10, %9
  strong_retain %8 : $PageContainerDataRefreshViewModel // id: %9
  store %8 to %1 : $*PageContainerDataRefreshViewModel // id: %10
  destroy_addr %1 : $*PageContainerDataRefreshViewModel // id: %11
  dealloc_stack %1 : $*PageContainerDataRefreshViewModel // id: %12
  return %8 : $PageContainerDataRefreshViewModel  // id: %13
} // end sil function 'Contents.PageContainerDataRefreshViewModel.init() -> Contents.PageContainerDataRefreshViewModel'

// @objc PageContainerDataRefreshViewModel.init()
sil hidden [thunk] @@objc Contents.PageContainerDataRefreshViewModel.init() -> Contents.PageContainerDataRefreshViewModel : $@convention(objc_method) (@owned PageContainerDataRefreshViewModel) -> @owned PageContainerDataRefreshViewModel {
// %0                                             // user: %2
bb0(%0 : $PageContainerDataRefreshViewModel):
  // function_ref PageContainerDataRefreshViewModel.init()
  %1 = function_ref @Contents.PageContainerDataRefreshViewModel.init() -> Contents.PageContainerDataRefreshViewModel : $@convention(method) (@owned PageContainerDataRefreshViewModel) -> @owned PageContainerDataRefreshViewModel // user: %2
  %2 = apply %1(%0) : $@convention(method) (@owned PageContainerDataRefreshViewModel) -> @owned PageContainerDataRefreshViewModel // user: %3
  return %2 : $PageContainerDataRefreshViewModel  // id: %3
} // end sil function '@objc Contents.PageContainerDataRefreshViewModel.init() -> Contents.PageContainerDataRefreshViewModel'

sil_vtable DefaultDataRefreshViewModel {
  #DefaultDataRefreshViewModel.refreshData!1: (DefaultDataRefreshViewModel) -> () -> () : @Contents.DefaultDataRefreshViewModel.refreshData() -> ()	// DefaultDataRefreshViewModel.refreshData()
  #DefaultDataRefreshViewModel.deinit!deallocator.1: @Contents.DefaultDataRefreshViewModel.__deallocating_deinit	// DefaultDataRefreshViewModel.__deallocating_deinit
}

sil_vtable PageContainerDataRefreshViewModel {

  #DefaultDataRefreshViewModel.refreshData!1: (DefaultDataRefreshViewModel) -> () -> () : @Contents.PageContainerDataRefreshViewModel.refreshData() -> () [override]	// PageContainerDataRefreshViewModel.refreshData()
  
  #PageContainerDataRefreshViewModel.loadNextPageData!1: (PageContainerDataRefreshViewModel) -> () -> () : @Contents.PageContainerDataRefreshViewModel.loadNextPageData() -> ()	// PageContainerDataRefreshViewModel.loadNextPageData()
  
  #PageContainerDataRefreshViewModel.request!1: (PageContainerDataRefreshViewModel) -> (Int, Int) -> () : @Contents.PageContainerDataRefreshViewModel.request(page: Swift.Int, limit: Swift.Int) -> ()	// PageContainerDataRefreshViewModel.request(page:limit:)
  
  #PageContainerDataRefreshViewModel.deinit!deallocator.1: @Contents.PageContainerDataRefreshViewModel.__deallocating_deinit	// PageContainerDataRefreshViewModel.__deallocating_deinit
}

sil_witness_table hidden DefaultDataRefreshViewModel: DataRefreshViewModelProtocol module Contents {
  method #DataRefreshViewModelProtocol.refreshData!1: <Self where Self : DataRefreshViewModelProtocol> (Self) -> () -> () : @protocol witness for Contents.DataRefreshViewModelProtocol.refreshData() -> () in conformance Contents.DefaultDataRefreshViewModel : Contents.DataRefreshViewModelProtocol in Contents	// protocol witness for DataRefreshViewModelProtocol.refreshData() in conformance DefaultDataRefreshViewModel
  method #DataRefreshViewModelProtocol.loadNextPageData!1: <Self where Self : DataRefreshViewModelProtocol> (Self) -> () -> () : @protocol witness for Contents.DataRefreshViewModelProtocol.loadNextPageData() -> () in conformance Contents.DefaultDataRefreshViewModel : Contents.DataRefreshViewModelProtocol in Contents	// protocol witness for DataRefreshViewModelProtocol.loadNextPageData() in conformance DefaultDataRefreshViewModel
  method #DataRefreshViewModelProtocol.request!1: <Self where Self : DataRefreshViewModelProtocol> (Self) -> (Int, Int) -> () : @protocol witness for Contents.DataRefreshViewModelProtocol.request(page: Swift.Int, limit: Swift.Int) -> () in conformance Contents.DefaultDataRefreshViewModel : Contents.DataRefreshViewModelProtocol in Contents	// protocol witness for DataRefreshViewModelProtocol.request(page:limit:) in conformance DefaultDataRefreshViewModel
}
```

