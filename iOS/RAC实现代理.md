---
layout: post
title: RAC实现代理的细节
type: iOS
---


使用RAC通过下面的语句可以实现协议中的方法，无需在添加额外的代码

```
[[self rac_signalForSelector:@selector(test) fromProtocol:@protocol(ProtocolTest)] subscribeNext:^(RACTuple * _Nullable x) {
    NSLog(@"ProtocolTest test");
}];
```

原理就是通过运行时，动态创建了一个子类(有些情况不会创建)，然后给子类动态添加了协议中对应的方法。

不考虑异常情况，上面的方法和下面的方法效果相同

```
- (void)addTestMethod {
    SEL selector = @selector(test);
    
    Method method = class_getInstanceMethod(self.class, selector);
    
    IMP imp = imp_implementationWithBlock(^{
        NSLog(@"ProtocolTest test");
    });
    
    class_addMethod(self.class, selector, imp, method_getTypeEncoding(method));
}
```

#### RAC动态创建类

```
const char *subclassName = "DelegateVC_RACSelectorSignal"
	
Class subclass = objc_getClass(subclassName);
	
if (subclass == nil) {
	subclass = objc_allocateClassPair(baseClass, subclassName, 0);
	if (subclass == nil) return nil;

	RACSwizzleForwardInvocation(subclass);
	RACSwizzleRespondsToSelector(subclass);
	
	// 交换class方法，使用[subClass.instance class]返回[statedClass.instance class]
	RACSwizzleGetClass(subclass, statedClass);
	
	// metaClass返回是Class自身，同样进行交换。
	RACSwizzleGetClass(object_getClass(subclass), statedClass);

	RACSwizzleMethodSignatureForSelector(subclass);

	objc_registerClassPair(subclass);
}

// before objc_setClass
// po self -> isa 
// DelegateVC
	
objc_setClass(self, subclass)
	
// after objc_setClass
// po self -> isa
// DelegateVC_RACSelectorSignal
// po self.class
// DelegateVC
```

#### self.class 和 object_getClass(self)的区别

```
Class object_getClass(id obj) {
    if (obj) return obj -> getIsa();
    else return Nil;
}

// NSObject

+ (Class)class {
    return self;
}
 
- (Class)class {
    return object_getClass(self);
}
```

可以看到，一般情况，self.class 和 object\_getClass(self) 是相同的，都是返回 object\_getClass，
但是 - (Class)class 可能会被重写、被交换，比如KVO、类簇，而object_getClass()没有这个问题，object\_getClass()始终指向真实的结果。

RAC在创建子类的时候，会交换 -(Class)class,目的是隐藏动态创建类这个操作，所以self.class和object_getClass(self)输出不同。




