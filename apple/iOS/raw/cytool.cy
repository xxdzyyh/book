
(function(exports) {
	var invalidParamStr = 'Invalid parameter';
	var missingParamStr = 'Missing parameter';

	// app id
	CJAppId = [NSBundle mainBundle].bundleIdentifier;

	// mainBundlePath
	CJAppPath = [NSBundle mainBundle].bundlePath;

	// document path
	CJDocPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];

	// caches path
	CJCachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];

	// 加载系统动态库
	CJLoadFramework = function(name) {
		var head = "/System/Library/";
		var foot = "Frameworks/" + name + ".framework";
		var bundle = [NSBundle bundleWithPath:head + foot] || [NSBundle bundleWithPath:head + "Private" + foot];
  		[bundle load];
  		return bundle;
	};

	// keyWindow
	CJKeyWin = function() {
		return UIApp.keyWindow;
	};

	// 根控制器
	CJRootVc =  function() {
		return UIApp.keyWindow.rootViewController;
	};

	// 找到显示在最前面的控制器
	var _CJFrontVc = function(vc) {
		if (vc.presentedViewController) {
        	return _CJFrontVc(vc.presentedViewController);
	    }else if ([vc isKindOfClass:[UITabBarController class]]) {
	        return _CJFrontVc(vc.selectedViewController);
	    } else if ([vc isKindOfClass:[UINavigationController class]]) {
	        return _CJFrontVc(vc.visibleViewController);
	    } else {
	    	var count = vc.childViewControllers.count;
    		for (var i = count - 1; i >= 0; i--) {
    			var childVc = vc.childViewControllers[i];
    			if (childVc && childVc.view.window) {
    				vc = _CJFrontVc(childVc);
    				break;
    			}
    		}
	        return vc;
    	}
	};

	CJFrontVc = function() {
		return _CJFrontVc(UIApp.keyWindow.rootViewController);
	};

	// 递归打印UIViewController view的层级结构
	CJVcSubviews = function(vc) {
		if (![vc isKindOfClass:[UIViewController class]]) throw new Error(invalidParamStr);
		return vc.view.recursiveDescription().toString(); 
	};

	// 递归打印最上层UIViewController view的层级结构
	CJFrontVcSubViews = function() {
		return CJVcSubviews(_CJFrontVc(UIApp.keyWindow.rootViewController));
	};

	// 获取按钮绑定的所有TouchUpInside事件的方法名
	CJBtnTouchUpEvent = function(btn) {
		var events = [];
		var allTargets = btn.allTargets().allObjects()
		var count = allTargets.count;
    	for (var i = count - 1; i >= 0; i--) { 
    		if (btn != allTargets[i]) {
    			var e = [btn actionsForTarget:allTargets[i] forControlEvent:UIControlEventTouchUpInside];
    			events.push(e);
    		}
    	}
	   return events;
	};

	// CG函数
	CJPointMake = function(x, y) {
		return {0 : x, 1 : y}; 
	};

	CJSizeMake = function(w, h) {
		return {0 : w, 1 : h}; 
	};

	CJRectMake = function(x, y, w, h) {
		return {0 : CJPointMake(x, y), 1 : CJSizeMake(w, h)};
	};

	// 递归打印controller的层级结构
	CJChildVcs = function(vc) {
		if (![vc isKindOfClass:[UIViewController class]]) throw new Error(invalidParamStr);
		return [vc _printHierarchy].toString();
	};

	// 递归打印view的层级结构
	CJSubviews = function(view) {
		if (![view isKindOfClass:[UIView class]]) throw new Error(invalidParamStr);
		return view.recursiveDescription().toString(); 
	};

	// 判断是否为字符串 "str" @"str"
	CJIsString = function(str) {
		return typeof str == 'string' || str instanceof String;
	};

	// 判断是否为数组 []、@[]
	CJIsArray = function(arr) {
		return arr instanceof Array;
	};

	// 判断num是否为数字
	CJIsNumber = function(num) {
		return typeof num == 'number' || num instanceof Number;
	};

	var _CJClass = function(className) {
		if (!className) throw new Error(missingParamStr);
		if (CJIsString(className)) {
			return NSClassFromString(className);
		} 
		if (!className) throw new Error(invalidParamStr);
		// 对象或者类
		return className.class();
	};

	// 打印所有的子类
	CJSubclasses = function(className, reg) {
		className = _CJClass(className);

		return [c for each (c in ObjectiveC.classes) 
		if (c != className 
			&& class_getSuperclass(c) 
			&& [c isSubclassOfClass:className] 
			&& (!reg || reg.test(c)))
			];
	};

	// 打印所有的方法
	var _CJGetMethods = function(className, reg, clazz) {
		className = _CJClass(className);

		var count = new new Type('I');
		var classObj = clazz ? className.constructor : className;
		var methodList = class_copyMethodList(classObj, count);
		var methodsArray = [];
		var methodNamesArray = [];
		for(var i = 0; i < *count; i++) {
			var method = methodList[i];
			var selector = method_getName(method);
			var name = sel_getName(selector);
			if (reg && !reg.test(name)) continue;
			methodsArray.push({
				selector : selector, 
				type : method_getTypeEncoding(method)
			});
			methodNamesArray.push(name);
		}
		free(methodList);
		return [methodsArray, methodNamesArray];
	};

	var _CJMethods = function(className, reg, clazz) {
		return _CJGetMethods(className, reg, clazz)[0];
	};

	// 打印所有的方法名字
	var _CJMethodNames = function(className, reg, clazz) {
		return _CJGetMethods(className, reg, clazz)[1];
	};

	// 打印所有的对象方法
	CJInstanceMethods = function(className, reg) {
		return _CJMethods(className, reg);
	};

	// 打印所有的对象方法名字
	CJInstanceMethodNames = function(className, reg) {
		return _CJMethodNames(className, reg);
	};

	// 打印所有的类方法
	CJClassMethods = function(className, reg) {
		return _CJMethods(className, reg, true);
	};

	// 打印所有的类方法名字
	CJClassMethodNames = function(className, reg) {
		return _CJMethodNames(className, reg, true);
	};

	// 打印所有的成员变量
	CJIvars = function(obj, reg){
		if (!obj) throw new Error(missingParamStr);
		var x = {}; 
		for(var i in *obj) { 
			try { 
				var value = (*obj)[i];
				if (reg && !reg.test(i) && !reg.test(value)) continue;
				x[i] = value; 
			} catch(e){} 
		} 
		return x; 
	};

	// 打印所有的成员变量名字
	CJIvarNames = function(obj, reg) {
		if (!obj) throw new Error(missingParamStr);
		var array = [];
		for(var name in *obj) { 
			if (reg && !reg.test(name)) continue;
			array.push(name);
		}
		return array;
	};
})(exports);
