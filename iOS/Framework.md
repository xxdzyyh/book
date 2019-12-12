## Framework

### Mach-O

Mach-O type

* Executable
* Dylib Library
* Static Library
* Bundle
* Relocatable Object File

1. 创建一个 Static Framework 
2. build 得到一个 Debug-iphonesimulator/SDK.framework，不生成dSYM文件
3. 将这个framework添加到例外一个project,运行模拟器，可以直接查看framework的源码
4. 将 _CodeSignature 文件夹删掉，还是可以看到framework源码
5. 将 framework 项目移动一下位置，看不到源码了，只能看到汇编代码，这说明源码的路径被记录在某个位置
6. 使用Mach-O查看一下App的SDK.framework，可以看到 `Section(_DWARF,...)`记录了SDK.framework相关的信息

7. 进一步可以对比 release SDK.framework

* [MachOView下载地址](http://sourceforge.net/projects/machoview/)

* [MachOExplorer下载地址](https://github.com/everettjf/MachOExplorer)

### DWARF 

参考资料 

* [DWARF, 说不定你也需要它哦](https://blog.csdn.net/chenyijun/article/details/85284867)

* [DWARF官网](http://www.dwarfstd.org/)

