## swift 关键字

### defer

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
```

