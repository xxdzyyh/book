### iOS Mach-O加载过程

### Mach-O

在Xcode Build Setting中搜索mach,在Linking栏下面会有一个Mach-O Type，可选的项目如下

* Executable (MH_EXECUTE)
* Dynamic Library (MH_DYLIB)
* Bundle (MH_BUNDLE)
* static Library ()
* Relocatable Object File (MH_OBJECT)
  * .o文件 类编译的产物就是.o文件
  * .a静态库，其实就是N个.o文件的集合

完整的可以参考下面。

```
# relocatable object file
MH_OBJECT = 0x1

# demand paged executable file
MH_EXECUTE = 0x2

# fixed VM shared library file
MH_FVMLIB = 0x3

# core dump file
MH_CORE = 0x4

# preloaded executable file
MH_PRELOAD = 0x5

# dynamically bound shared library
MH_DYLIB = 0x6

# dynamic link editor
MH_DYLINKER = 0x7

# dynamically bound bundle file
MH_BUNDLE = 0x8

# shared library stub for static linking only, no section contents
MH_DYLIB_STUB = 0x9

# companion file with only debug sections
MH_DSYM = 0xa

# x86_64 kexts
MH_KEXT_BUNDLE = 0xb
```

对同一个framework

* 设置 Mach-O Type 为 Dynamic Library ，使用file命令查看mach-o.

```
$ file OfferSDK 
OfferSDK: Mach-O universal binary with 2 architectures: [arm_v7:Mach-O dynamically linked shared library arm_v7] [arm64:Mach-O 64-bit dynamically linked shared library arm64]
OfferSDK (for architecture armv7):	Mach-O dynamically linked shared library arm_v7
OfferSDK (for architecture arm64):	Mach-O 64-bit dynamically linked shared library arm64
```

* 设置 Mach-O Type 为 static Library ，使用file命令查看mach-o.

```
$ file OfferSDK
OfferSDK: Mach-O universal binary with 2 architectures: [arm_v7:current ar archive random library] [arm64:current ar archive random library]
OfferSDK (for architecture armv7):	current ar archive random library
OfferSDK (for architecture arm64):	current ar archive random library
```



一般我们认为，main函数就是我们程序的入口，实际上这么说也没有问题。但是更深入一点，main函数之前发生了什么？+load方法怎么在main之前就被调用了？

添加符号断点 `_objc_init`

```
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.1
libobjc.A.dylib`_objc_init
libdispatch.dylib`_os_object_init + 13
libdispatch.dylib`libdispatch_init + 300
libSystem.B.dylib`libSystem_initializer + 252
dyld_sim`ImageLoaderMachO::doModInitFunctions(ImageLoader::LinkContext const&) + 517
dyld_sim`ImageLoaderMachO::doInitialization(ImageLoader::LinkContext const&) + 40

// 调用 +load 方法

dyld_sim`ImageLoader::recursiveInitialization(ImageLoader::LinkContext const&, unsigned int, char const*, ImageLoader::InitializerTimingList&, ImageLoader::UninitedUpwards&) + 456
dyld_sim`ImageLoader::recursiveInitialization(ImageLoader::LinkContext const&, unsigned int, char const*, ImageLoader::InitializerTimingList&, ImageLoader::UninitedUpwards&) + 309
dyld_sim`ImageLoader::processInitializers(ImageLoader::LinkContext const&, unsigned int, ImageLoader::InitializerTimingList&, ImageLoader::UninitedUpwards&) + 188
dyld_sim`ImageLoader::runInitializers(ImageLoader::LinkContext const&, ImageLoader::InitializerTimingList&) + 82
dyld_sim`dyld::initializeMainExecutable() + 129
dyld_sim`dyld::_main(macho_header const*, unsigned long, int, char const**, char const**, char const**, unsigned long*) + 3831
dyld_sim`start_sim + 122
dyld`dyld::useSimulatorDyld(int, macho_header const*, char const*, int, char const**, char const**, char const**, unsigned long*, unsigned long*) + 2308
dyld`dyld::_main(macho_header const*, unsigned long, int, char const**, char const**, char const**, unsigned long*) + 818
dyld`dyldbootstrap::start(dyld3::MachOLoaded const*, int, char const**, dyld3::MachOLoaded const*, unsigned long*) + 453
dyld`_dyld_start + 37
```



###  _objc_init

_objc_init()方法是runtime被加载后第一个执行的方法

```
// objc-os.mm

/***********************************************************************
* _objc_init
* Bootstrap initialization. Registers our image notifier with dyld.
* Called by libSystem BEFORE library initialization time
**********************************************************************/

void _objc_init(void)
{
    static bool initialized = false;
    if (initialized) return;
    initialized = true;
    
    // fixme defer initialization until an objc-using image is found?
    environ_init();
    tls_init();
    static_init();
    lock_init();
    exception_init();

    _dyld_objc_notify_register(&map_images, load_images, unmap_image);
}
```



```
// dyldAPIs.cpp

void _dyld_objc_notify_register(_dyld_objc_notify_mapped    mapped,
                                _dyld_objc_notify_init      init,
                                _dyld_objc_notify_unmapped  unmapped)
{
	dyld::registerObjCNotifiers(mapped, init, unmapped);
}

```



```
// dyld.cpp
void registerObjCNotifiers(_dyld_objc_notify_mapped mapped, _dyld_objc_notify_init init, _dyld_objc_notify_unmapped unmapped)
{
	// record functions to call
	sNotifyObjCMapped	= mapped;
	sNotifyObjCInit		= init;
	sNotifyObjCUnmapped = unmapped;

	// call 'mapped' function with all images mapped so far
	try {
		notifyBatchPartial(dyld_image_state_bound, true, NULL, false, true);
	}
	catch (const char* msg) {
		// ignore request to abort during registration
	}

	// <rdar://problem/32209809> call 'init' function on all images already init'ed (below libSystem)
	for (std::vector<ImageLoader*>::iterator it=sAllImages.begin(); it != sAllImages.end(); it++) {
		ImageLoader* image = *it;
		if ( (image->getState() == dyld_image_state_initialized) && image->notifyObjC() ) {
			dyld3::ScopedTimer timer(DBG_DYLD_TIMING_OBJC_INIT, (uint64_t)image->machHeader(), 0, 0);
			(*sNotifyObjCInit)(image->getRealPath(), image->machHeader());
		}
	}
}

```



### +load

直接通过函数地址调用

1. dyld initializeMainExecutable 初始化程序二进制文件
2. 利用dyld中的ImageLoader类的recursiveInitialization()来递归加载image
3. 由于runtime想dyld注册了回调，当image被mapping到内存后，dyld::notifySingle通知runtime进行处理
3. runtime调用load_images方法，libobjc -> load_images
4. +load 方法被调用

> load 调用栈

```
OfferApp`+[RuntimeVC load](self=RuntimeVC,_cmd="load")atRuntimeVC.m:61:2
libobjc.A.dylib`load_images+1317
dyld_sim`dyld::notifySingle(dyld_image_states,ImageLoaderconst*,ImageLoader::InitializerTimingList*)+418
dyld_sim`ImageLoader::recursiveInitialization(ImageLoader::LinkContextconst&,unsignedint,charconst*,ImageLoader::InitializerTimingList&,ImageLoader::UninitedUpwards&)+438
dyld_sim`ImageLoader::processInitializers(ImageLoader::LinkContextconst&,unsignedint,ImageLoader::InitializerTimingList&,ImageLoader::UninitedUpwards&)+188
dyld_sim`ImageLoader::runInitializers(ImageLoader::LinkContextconst&,ImageLoader::InitializerTimingList&)+82
dyld_sim`dyld::initializeMainExecutable()+199
dyld_sim`dyld::_main(macho_headerconst*,unsignedlong,int,charconst**,charconst**,charconst**,unsignedlong*)+3831
dyld_sim`start_sim+122
dyld`dyld::useSimulatorDyld(int,macho_headerconst*,charconst*,int,charconst**,charconst**,charconst**,unsignedlong*,unsignedlong*)+2308
dyld`dyld::_main(macho_headerconst*,unsignedlong,int,charconst**,charconst**,charconst**,unsignedlong*)+818
dyld`dyldbootstrap::start(dyld3::MachOLoadedconst*,int,charconst**,dyld3::MachOLoadedconst*,unsignedlong*)+453
dyld`_dyld_start+37
```

> load_images

```
// objc-runtime-new.mm
/***********************************************************************
* load_images
* Process +load in the given images which are being mapped in by dyld.
*
* Locking: write-locks runtimeLock and loadMethodLock
**********************************************************************/
extern bool hasLoadMethods(const headerType *mhdr);
extern void prepare_load_methods(const headerType *mhdr);

void load_images(const char *path __unused, const struct mach_header *mh)
{
    // Return without taking locks if there are no +load methods here.
    if (!hasLoadMethods((const headerType *)mh)) return;

    recursive_mutex_locker_t lock(loadMethodLock);

    // Discover load methods
    {
        mutex_locker_t lock2(runtimeLock);
        prepare_load_methods((const headerType *)mh);
    }

    // Call +load methods (without runtimeLock - re-entrant)
    call_load_methods();
}
```

> prepare_load_methods

```
void prepare_load_methods(const headerType *mhdr)
{
    size_t count, i;

    runtimeLock.assertLocked();

    classref_t *classlist = 
        _getObjc2NonlazyClassList(mhdr, &count);
    for (i = 0; i < count; i++) {
        schedule_class_load(remapClass(classlist[i]));
    }

    category_t **categorylist = _getObjc2NonlazyCategoryList(mhdr, &count);
    for (i = 0; i < count; i++) {
        category_t *cat = categorylist[i];
        Class cls = remapClass(cat->cls);
        if (!cls) continue;  // category for ignored weak-linked class
        if (cls->isSwiftStable()) {
            _objc_fatal("Swift class extensions and categories on Swift "
                        "classes are not allowed to have +load methods");
        }
        realizeClassWithoutSwift(cls);
        assert(cls->ISA()->isRealized());
        add_category_to_loadable_list(cat);
    }
}

```



```
/***********************************************************************
* prepare_load_methods
* Schedule +load for classes in this image, any un-+load-ed 
* superclasses in other images, and any categories in this image.
**********************************************************************/
// Recursively schedule +load for cls and any un-+load-ed superclasses.
// cls must already be connected.
static void schedule_class_load(Class cls)
{
    if (!cls) return;
    assert(cls->isRealized());  // _read_images should realize

    if (cls->data()->flags & RW_LOADED) return;

    // Ensure superclass-first ordering
    schedule_class_load(cls->superclass);

    add_class_to_loadable_list(cls);
    cls->setInfo(RW_LOADED); 
}

```



```
/***********************************************************************
* call_load_methods
* Call all pending class and category +load methods.
* Class +load methods are called superclass-first. 
* Category +load methods are not called until after the parent class's +load.
* 
* This method must be RE-ENTRANT, because a +load could trigger 
* more image mapping. In addition, the superclass-first ordering 
* must be preserved in the face of re-entrant calls. Therefore, 
* only the OUTERMOST call of this function will do anything, and 
* that call will handle all loadable classes, even those generated 
* while it was running.
*
* The sequence below preserves +load ordering in the face of 
* image loading during a +load, and make sure that no 
* +load method is forgotten because it was added during 
* a +load call.
* Sequence:
* 1. Repeatedly call class +loads until there aren't any more
* 2. Call category +loads ONCE.
* 3. Run more +loads if:
*    (a) there are more classes to load, OR
*    (b) there are some potential category +loads that have 
*        still never been attempted.
* Category +loads are only run once to ensure "parent class first" 
* ordering, even if a category +load triggers a new loadable class 
* and a new loadable category attached to that class. 
*
* Locking: loadMethodLock must be held by the caller 
*   All other locks must not be held.
**********************************************************************/
void call_load_methods(void)
{
    static bool loading = NO;
    bool more_categories;

    loadMethodLock.assertLocked();

    // Re-entrant calls do nothing; the outermost call will finish the job.
    if (loading) return;
    loading = YES;

    void *pool = objc_autoreleasePoolPush();

    do {
        // 1. Repeatedly call class +loads until there aren't any more
        while (loadable_classes_used > 0) {
            call_class_loads();
        }

        // 2. Call category +loads ONCE
        more_categories = call_category_loads();

        // 3. Run more +loads if there are classes OR more untried categories
    } while (loadable_classes_used > 0  ||  more_categories);

    objc_autoreleasePoolPop(pool);

    loading = NO;
}

```



> ImageLoader

```
//
// ImageLoader is an abstract base class.  To support loading a particular executable
// file format, you make a concrete subclass of ImageLoader.
//
// For each executable file (dynamic shared object) in use, an ImageLoader is instantiated.
//
// The ImageLoader base class does the work of linking together images, but it knows nothing
// about any particular file format.
//
//
class ImageLoader {
...


//
// ImageLoaderMachO is a subclass of ImageLoader which loads mach-o format files.
//
//
class ImageLoaderMachO : public ImageLoader {


//
// ImageLoaderMachOCompressed is the concrete subclass of ImageLoader which loads mach-o files 
// that use the compressed LINKEDIT format.  
//
class ImageLoaderMachOCompressed : public ImageLoaderMachO 


//
// ImageLoaderMachOClassic is the concrete subclass of ImageLoader which loads mach-o files 
// that use the traditional LINKEDIT format.  
//
class ImageLoaderMachOClassic : public ImageLoaderMachO
```



### +initialize

走的是消息转发机制，当第一个方法被调用时会触发。

> initialize 调用栈

```
OfferApp`+[RuntimeVCinitialize](self=RuntimeVC,_cmd="initialize")atRuntimeVC.m:63:2
libobjc.A.dylib`CALLING_SOME_+initialize_METHOD+17
libobjc.A.dylib`initializeNonMetaClass+624
libobjc.A.dylib`initializeAndMaybeRelock(objc_class*,objc_object*,mutex_tt<false>&,bool)+157
libobjc.A.dylib`lookUpImpOrForward+595
libobjc.A.dylib`_objc_msgSend_uncached+73
OfferApp`-[XFDemoTableViewVCtableView:didSelectRowAtIndexPath:](self=0x00007fe113e12490,_cmd="tableView:didSelectRowAtIndexPath:",tableView=0x00007fe11402e600,indexPath=0x96e8baf5a8764e80)atXFDemoTableViewVC.m:73:32
OfferApp`-[ViewControllertableView:didSelectRowAtIndexPath:](self=0x00007fe113e12490,_cmd="tableView:didSelectRowAtIndexPath:",tableView=0x00007fe11402e600,indexPath=0x96e8baf5a8764e80)atViewController.m:71:9
UIKitCore`-[UITableView_selectRowAtIndexPath:animated:scrollPosition:notifyDelegate:isCellMultiSelect:]+855
UIKitCore`-[UITableView_selectRowAtIndexPath:animated:scrollPosition:notifyDelegate:]+97
UIKitCore`-[UITableView_userSelectRowAtPendingSelectionIndexPath:]+334
UIKitCore`_runAfterCACommitDeferredBlocks+352
UIKitCore`_cleanUpAfterCAFlushAndRunDeferredBlocks+248
UIKitCore`_afterCACommitHandler+85
CoreFoundation`__CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__+23
CoreFoundation`__CFRunLoopDoObservers+430
CoreFoundation`__CFRunLoopRun+1514
CoreFoundation`CFRunLoopRunSpecific+438
GraphicsServices`GSEventRunModal+65
UIKitCore`UIApplicationMain+1621
OfferApp`main(argc=1,argv=0x00007ffeed3e5ca0)atmain.m:15:16
libdyld.dylib`start+1
```



### 附录



> only MH_BUNDLE, MH_DYLIB, and some MH_EXECUTE can be dynamically loaded

bt的结果可以使用下面的语句去掉前缀部分

```
awk -F " "  '{for (i=4;i<=NF;i++)printf("%s ", $i);print ""}' file
```

