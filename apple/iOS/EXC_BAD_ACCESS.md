# EXC_BAD_ACCESS 



lldb有一个内存调试工具malloc stack，开启以后就可以查看某个内存地址的malloc和free记录，追踪对象是在哪里创建的。

这个工具可以打印出对象创建的堆栈，而在逆向时，也经常需要追踪某些方法的调用栈，如果可以随时打印出某个对象的创建记录，也就能直接找到其所在的类和方法，不用再花费大量的时间去打log和动态调试追踪了。



https://www.jianshu.com/p/759015369b6f

## malloc stack

在自己的项目中，要开启malloc stack，需要在`Product->Scheme->Edit Scheme->Diagnistic`里勾选`Malloc Stack`选项。

效果如下。

测试代码：

```
- (IBAction)create:(id)sender {



    NSString *testString = [NSString stringWithFormat:@"string created by %@",self];



    



}



复制代码
```

断点后在lldb中使用`lldb.macosx.heap`里的`malloc_info`命令，虽然官网上说是Mac app才能用的命令，但是经测试现在在iOS上也能用了：

```
(lldb) p/x testString
(__NSCFString *) $3 = 0x16eac000 @"string created by <ViewController: 0x16e9d7c0>"

(lldb) command script import lldb.macosx.heap //加载lldb.macosx.heap
"malloc_info", "ptr_refs", "cstr_refs", "find_variable", and "objc_refs" commands have been installed, use the "--help" options on these commands for detailed help.

(lldb) malloc_info -s 0x16eac000
0x0000000016eac000: malloc(    64) -> 0x16eac000 __NSCFString.NSMutableString.NSString.NSObject.isa
stack[0]: addr = 0x16eac000, type=malloc, frames:
     [0] 0x00000000242948ab libsystem_malloc.dylib`malloc_zone_malloc + 123
     [1] 0x00000000244e3bc1 CoreFoundation`_CFRuntimeCreateInstance + 237
     [2] 0x00000000245a6ffd CoreFoundation`__CFStringCreateImmutableFunnel3 + 1657
     [3] 0x00000000244ee0f7 CoreFoundation`CFStringCreateCopy + 359
     [4] 0x00000000245a725d CoreFoundation`_CFStringCreateWithFormatAndArgumentsAux2 + 89
     [5] 0x0000000024d17dd3 Foundation`-[NSPlaceholderString initWithFormat:locale:arguments:] + 139
     [6] 0x0000000024d17cd1 Foundation`+[NSString stringWithFormat:] + 61
     [7] 0x00000000000d7343 testMallocStack`-[ViewController create:] + 97 at ViewController.m:23:28
		 [8] 0x00000000287a5771 UIKit`-[UIApplication sendAction:to:from:forEvent:] + 81
     [9] 0x00000000287a5701 UIKit`-[UIControl sendAction:to:forEvent:] + 65
     [10] 0x000000002878d61f UIKit`-[UIControl _sendActionsForEvents:withEvent:] + 447
     [11] 0x00000000287a5051 UIKit`-[UIControl touchesEnded:withEvent:] + 617
     [12] 0x00000000287a4cbf UIKit`-[UIWindow _sendTouchesForEvent:] + 647
     [13] 0x000000002879d5d7 UIKit`-[UIWindow sendEvent:] + 643
     [14] 0x000000002876e119 UIKit`-[UIApplication sendEvent:] + 205
     [15] 0x000000002876c757 UIKit`_UIApplicationHandleEventQueue + 5135
     [16] 0x0000000024599257 CoreFoundation`__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 15
     [17] 0x0000000024598e47 CoreFoundation`__CFRunLoopDoSources0 + 455
     [18] 0x00000000245971af CoreFoundation`__CFRunLoopRun + 807
     [19] 0x00000000244e9bb9 CoreFoundation`CFRunLoopRunSpecific + 517
     [20] 0x00000000244e99ad CoreFoundation`CFRunLoopRunInMode + 109
     [21] 0x0000000025763af9 GraphicsServices`GSEventRunModal + 161
     [22] 0x00000000287d5fb5 UIKit`UIApplicationMain + 14
     [23] 0x00000000000d7587 testMallocStack`main + 107 at main.m:14:9
     [24] 0x000000002419c873 libdyld.dylib`start + 3
     [25] 0x000000003a9c0001 libsystem_pthread.dylib`_thread + 1
```

这个工具是继承自gdb的`malloc_history`，不过`malloc_history`只能用在模拟器上，而`malloc_info`在模拟器和真机上都可以使用。另外，新版Xcode又增加了一个新的lldb工具`memory history`，在`Product->Scheme->Edit Scheme->Diagnistic`里勾选`Address Sanitizer`即可，效果类似。

## 使用非官方版的heap.py

注意，在Xcode8.3以后使用`malloc_info`会导致lldb调试器crash，似乎是出bug了，一直没修复。在Xcode8.2上可以正常使用。

所以我们需要替换一下lldb自带的lldb.macosx.heap模块。使用这个非官方的版本：[heap.py](https://link.juejin.im/?target=https%3A%2F%2Fgithub.com%2Fllvm-mirror%2Flldb%2Fblob%2Fmaster%2Fexamples%2Fdarwin%2Fheap_find%2Fheap.py)。

lldb可以加载自定义的pthon脚本。只需要在lldb中输入：

```
command script import python脚本的地址



复制代码
```

因此把上面的`heap.py`下载到本地后，输入：

```
command script import /你的路径/lldb/examples/darwin/heap_find/heap.py



复制代码
```

即可。