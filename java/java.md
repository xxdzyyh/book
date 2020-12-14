# JAVA



## 注解

注解的本质就是一个继承了 Annotation 接口的接口



* @Decumented 

   控制 javadoc 是否显示注解内容。

* @Target

  - ElementType.TYPE：允许被修饰的注解作用在类、接口和枚举上
  - ElementType.FIELD：允许作用在属性字段上
  - ElementType.METHOD：允许作用在方法上
  - ElementType.PARAMETER：允许作用在方法参数上
  - ElementType.CONSTRUCTOR：允许作用在构造器上
  - ElementType.LOCAL_VARIABLE：允许作用在本地局部变量上
  - ElementType.ANNOTATION_TYPE：允许作用在注解上
  - ElementType.PACKAGE：允许作用在包上

* @Retention 用于指明当前注解的生命周期
  * RetentionPolicy.SOURCE：当前注解编译期可见，不会写入 class 文件
  * RetentionPolicy.CLASS：类加载阶段丢弃，会写入 class 文件
  * RetentionPolicy.RUNTIME：永久保存，可以反射获取

  ```
  @Target(ElementType.METHOD)
  @Retention(RetentionPolicy.SOURCE)
  public @interface Override {
  }
  ```

  @Override 只在编译期生效，就是一种编译提示。



虚拟机规范定义了一系列和注解相关的属性表，也就是说，无论是字段、方法或是类本身，如果被注解修饰了，就可以被写进字节码文件。属性表有以下几种：

- RuntimeVisibleAnnotations：运行时可见的注解
- RuntimeInVisibleAnnotations：运行时不可见的注解
- RuntimeVisibleParameterAnnotations：运行时可见的方法参数注解
- RuntimeInVisibleParameterAnnotations：运行时不可见的方法参数注解
- AnnotationDefault：注解类元素的默认值

注解本质上是继承了 Annotation 接口的接口，而当你通过反射，也就是我们这里的 getAnnotation 方法去获取一个注解类实例的时候，其实 JDK 是通过动态代理机制生成一个实现我们注解（接口）的代理类。



首先，设置一个虚拟机启动参数，用于捕获 JDK 动态代理类。

> -Dsun.misc.ProxyGenerator.saveGeneratedFiles=true



首先，我们通过键值对的形式可以为注解属性赋值，像这样：@Hello（value = "hello"）。

接着，你用注解修饰某个元素，编译器将在编译期扫描每个类或者方法上的注解，会做一个基本的检查，你的这个注解是否允许作用在当前位置，最后会将注解信息写入元素的属性表。

然后，当你进行反射的时候，虚拟机将所有生命周期在 RUNTIME 的注解取出来放到一个 map 中，并创建一个 AnnotationInvocationHandler 实例，把这个 map 传递给它。

最后，虚拟机将采用 JDK 动态代理机制生成一个目标注解的代理类，并初始化好处理器。

那么这样，一个注解的实例就创建出来了，它本质上就是一个代理类，你应当去理解好 AnnotationInvocationHandler 中 invoke 方法的实现逻辑，这是核心。一句话概括就是，**通过方法名返回注解属性值**。

