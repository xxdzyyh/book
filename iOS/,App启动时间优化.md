### App启动时间优化

官方文档：[Optimizing App Startup Time](https://developer.apple.com/videos/play/wwdc2016/406)



1. 解析Info.plist
2. Mach-O加载
   * Parse images
   * Map images
   * Rebase images
   * Bind images
   * Run image initializers
3. 程序执行
   * Call `main()`
   * Call `UIApplicationMain()`
   * Call `applicationWillFinishLaunching`



### Warm launch VS Cold launch

Warm launch

* App and data already in memory

Cold launch

* App is not in kernel buffer cache

  

### 查看启动时间

Edit Scheme -> Arguments -> Environment Variables, 添加字段 DYLD_PRINT_STATISTICS 设置value = 1.

```
Total pre-main time: 988.15 milliseconds (100.0%)
         dylib loading time: 287.55 milliseconds (29.0%)
        rebase/binding time: 126687488.8 seconds (148793110.9%)
            ObjC setup time: 413.39 milliseconds (41.8%)
           initializer time: 392.24 milliseconds (39.6%)
           slowest intializers :
             libSystem.B.dylib :   7.92 milliseconds (0.8%)
    libMainThreadChecker.dylib : 327.33 milliseconds (33.1%)
                      OfferApp :  33.54 milliseconds (3.3%)
```



### Dylib Loading

Embedded dylibs are expensive

Use fewer dylibs

* Merge existiong dylibs
* User static archivers

Lazy load,but...

* `dlopen()` can cause issues
* Actually more work overall



### Rebase/Binding

Reduce __DATA pointers

Reduce Objective C metadata

* Classes,selectors,and categories

Reduce C++ virtual

Use Swift structs

Examine machine generated code

* Use offsets instead of pointers
* Marl read only

### Objc setup





### Initalizers



Objc `+load` methods

* Replace with `+initialize`





### load VS intialize



load

* 加载Mach-O的时候，load 就会被调用，每个类的load只会被调用一次。
* load不要手动调用
* 子类重写load不需要调用父类的load，父类的load会先调用,子类没有重写load,不会调用父类的load
* 类的load方法优先于category的load方法
* 多个category的load的执行顺序和Complie Sources的顺序一致



```
// objc-loadmethod.mm

/***********************************************************************
* call_class_loads
* Call all pending class +load methods.
* If new classes become loadable, +load is NOT called for them.
*
* Called only by call_load_methods().
**********************************************************************/
static void call_class_loads(void)
{
    int i;
    
    // Detach current loadable list.
    struct loadable_class *classes = loadable_classes;
    int used = loadable_classes_used;
    loadable_classes = nil;
    loadable_classes_allocated = 0;
    loadable_classes_used = 0;
    
    // Call all +loads for the detached list.
    for (i = 0; i < used; i++) {
        Class cls = classes[i].cls;
        load_method_t load_method = (load_method_t)classes[i].method;
        if (!cls) continue; 

        if (PrintLoading) {
            _objc_inform("LOAD: +[%s load]\n", cls->nameForLogging());
        }
        (*load_method)(cls, SEL_load);
    }
    
    // Destroy the detached list.
    if (classes) free(classes);
}
```



initialize

```
callInitialize(cls);

void callInitialize(Class cls)
{
    ((void(*)(Class, SEL))objc_msgSend)(cls, SEL_initialize);
    asm("");
}
```



* 自身或者子类第一个方法被调用的时候执行
* initialize不要手动调用
* 
* 多个category实现了initialize,只会执行最后一个category的initialize
* 