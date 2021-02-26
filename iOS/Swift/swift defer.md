## swift defer

defer后面跟的block在defer所有在的作用域结束时被执行

```
final class MyClass : NSObject {
    var _lock = NSRecursiveLock()
    func insert() {
        self._lock.lock()
        print("lock")
        defer {
            print("unlock")
            self._lock.unlock()
        }
        print("insert")
    }
}

MyClass.init().insert()
// output
lock
insert
unlock

func test() {
    defer {
        // 无论是否catch到异常，都会执行defer跟的block
        print("finally")
    }
    do {
        print("do")
//        throw NSError()
    } catch {
        print("catch")
    }
}
test()
// output
ca
```

