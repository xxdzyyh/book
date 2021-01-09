# JAVA

[TOC]

## 入门

### 加锁

```
static Object lockObject = new Object();
public MyResponse addAccount(@RequestBody String param) {
      synchronized (lockObject) {
          if (accountDao.queryAccount(userName) != null) {
              return MyResponse.buildFail("该用户名已存在");
          }
          String psd = LoginController.transformPassword(userName, password);
          String encodeLicText = generateEncryptLic(param);
          accountDao.addNewAccount(initGroupId(userName), userName, psd, 0,encodeLicText );
      }
      return MyResponse.buildSuccess("success");
}
```



## 注解

注解的本质就是一个继承了 Annotation 接口的接口。个人理解注解是用来实现一些附加功能或者流程相对固定的功能。

### 元注解

注解的注解，它是作用在注解中，方便我们使用注解实现想要的功能。元注解分别有@Retention、 @Target、 @Document、 @Inherited和@Repeatable（JDK1.8加入）五种。

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
  * RetentionPolicy.SOURCE：注解编译期可见，不会写入 class 文件

    @Override 只在编译期生效，就是一种编译提示。

    ```
    @Target(ElementType.METHOD)
    @Retention(RetentionPolicy.SOURCE)
    public @interface Override {
    }
    ```

  * RetentionPolicy.CLASS：默认的保留策略，注解会在class字节码文件中存在，但运行时无法获得。

  * RetentionPolicy.RUNTIME：注解会在class字节码文件中存在，在运行时可以通过反射获取到

    一般自定义的注解都是 RetentionPolicy.RUNTIME 类型的，因为我们要获取数据

* @Inherited

  Inherited的英文意思是继承，但是这个继承和我们平时理解的继承大同小异，一个被@Inherited注解了的注解修饰了一个父类，如果他的子类没有被其他注解修饰，则它的子类也继承了父类的注解。

* Repeatable 说明被这个元注解修饰的注解可以同时作用一个对象多次，但是每次作用注解又可以代表不同的含义

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



```kotlin
@Documented
@Inherited
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
public @interface MyTestAnnotation {
    String name() default "mao";
    int age() default 18;
}

@MyTestAnnotation(name = "father",age = 50)
public class Father {
}

public void checkAnnotation() {
  
  /**
   * 获取类注解属性
   */
  class<Father> fatherClass = Father.class;
  boolean annotationPresent = fatherClass.isAnnotationPresent(MyTestAnnotation.class);
  if(annotationPresent){
      MyTestAnnotation annotation = fatherClass.getAnnotation(MyTestAnnotation.class);
      System.out.println(annotation.name());
      System.out.println(annotation.age());
  }
}

/**玩家注解*/
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
public @interface People {
    Game[] value() ;
}

/**游戏注解*/
@Repeatable(People.class)
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
public @interface Game {
    String value() default "";
}
/**玩游戏类*/
@Game(value = "LOL")
@Game(value = "PUBG")
@Game(value = "NFS")
@Game(value = "Dirt4")
public class PlayGame {
  
}

/**
 * 获取方法注解属性
 */
Method play = PlayGame.class.getDeclaredMethod("play");
if (play!=null){
    People annotation2 = play.getAnnotation(People.class);
    Game[] value = annotation2.value();
    for (Game game : value) {
        System.out.println(game.value());
    }
}

```



### MyBatis



