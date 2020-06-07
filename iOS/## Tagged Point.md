## Tagged Point


// 64为系统
0x(4位记载类型)(56位记载数据)(子类型)

__NSCFNumber, 0xb000000000000013

当String的内容有中文或者特殊字符（非 ASCII 字符）时，那么就只能存储为String指针
但是字面型字符串常量却从不存储为Tagged Pointer。

字符串常量必须在不同的操作系统版本下保持二进制兼容，而Tagged Pointer的内部细节是没有保证的。其能使用的前提是Tagged Pointer在运行时总是由Apple的代码生成（运行时才能确定），如果编译器把它们嵌入二进制里（编译），那么前提就被打破了（字符串常量就是这样）。

> 面试问题

1. Tagged Point 每一位的作用
2. isa的作用
	* 方法调用
	* Tagged Point

	


