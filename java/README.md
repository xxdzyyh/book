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



### 定时器

java 没有 block 这种东西，又特别强调设计模式，所以在实现一个小功能的时候，代码特别多。 

```
import java.util.Timer;
import java.util.TimerTask;

class MyTimerTask extends TimerTask {
		public void run() {
				System.out.println("开始检查更新");
		}
}

public class Main {

		Timer timer;
    public static void main(String[] args) {
        System.out.println("main start");
        // 每天执行一次
        timer = new Timer();
        
        // 第一个参数指明任务
        // 第二个参数指明Timer第一次触发延迟
        // 第三个参数代表Timer触发的间隔
        timer.schedule(new MyTimerTask(),1000, seconds * 1000);
    }
}
```



### 多线程

匿名内部类还是很方便的，这样不用继承写一个类。

```
public static void parse(String result) {
    JsonObject object = JsonParser.parseString(result).getAsJsonObject();
    JsonArray data = object.get("data").getAsJsonArray();

    for (int i=0;i<data.size();i++) {
        JsonObject obj = data.get(i).getAsJsonObject();
        UpdateItem item = UpdateItem.fromJsonObject(obj);
        // 匿名类别类
        new Thread() {
            public void run() {
                item.updateIfNeed();
            }
        }.start();
    }
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





## 常用



### 获取文件 MD5

```
/**
 * 根据文件计算出文件的MD5
 * @param file
 * @return
 */
public static String getFileMD5(File file) {
    if (!file.isFile()) {
        return null;
    }

    MessageDigest digest = null;
    FileInputStream in = null;
    byte buffer[] = new byte[1024];
    int len;
    try {
        digest = MessageDigest.getInstance("MD5");
        in = new FileInputStream(file);
        while ((len = in.read(buffer, 0, 1024)) != -1) {
            digest.update(buffer, 0, len);
        }
        in.close();

    } catch (NoSuchAlgorithmException e) {
        e.printStackTrace();
    } catch (FileNotFoundException e) {
        e.printStackTrace();
    } catch (IOException e) {
        e.printStackTrace();
    }
    BigInteger bigInt = new BigInteger(1, digest.digest());
    return bigInt.toString(16);
}
```



### 获取 jar 根目录

```
public static String rootPath() {
    String jarWholePath = FileHelper.class.getProtectionDomain().getCodeSource().getLocation().getFile();
    try {
        jarWholePath = java.net.URLDecoder.decode(jarWholePath, "UTF-8");
    } catch (Exception e) {
        System.out.println(e.toString());
    }

    String jarPath = new File(jarWholePath).getParentFile().getAbsolutePath();
    return jarPath;
}
```



### 读取文件全部内容

```
public static String readFile(String filePath) {
    StringBuffer stringBuffer = new StringBuffer("");
    byte[] buffer = new byte[1024];
    int count = 0;
    File file = new File(filePath);
    try {
        InputStream inputStream = new FileInputStream(file);
        while (-1 != (count = inputStream.read(buffer))) {
            stringBuffer.append(new String(buffer, 0, count));
        }
        inputStream.close();
    } catch (IOException ex) {
        ex.printStackTrace();
    }
    return stringBuffer.toString();
}
```



### 文件解压



```
package com.shujiantec;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

public class ZipUtil {

    private static final int BUFFER_SIZE = 1024;

    /**
     * zip解压
     * @param srcFile        zip源文件
     * @param destDirPath     解压后的目标文件夹
     * @throws RuntimeException 解压失败会抛出运行时异常
     */
    public static void unZip(File srcFile, String destDirPath) throws RuntimeException {
        long start = System.currentTimeMillis();
        // 判断源文件是否存在
        if (!srcFile.exists()) {
            throw new RuntimeException(srcFile.getPath() + "所指文件不存在");
        }

        // 开始解压
        ZipFile zipFile = null;
        try {
            zipFile = new ZipFile(srcFile);
            Enumeration<?> entries = zipFile.entries();
            while (entries.hasMoreElements()) {
                ZipEntry entry = (ZipEntry) entries.nextElement();
                // 如果是文件夹，就创建个文件夹
                if (entry.isDirectory()) {
                    String dirPath = destDirPath + "/" + entry.getName();
                    File dir = new File(dirPath);
                    dir.mkdirs();
                } else {
                    // 如果是文件，就先创建一个文件，然后用io流把内容copy过去
                    File targetFile = new File(destDirPath + "/" + entry.getName());
                    // 保证这个文件的父文件夹必须要存在
                    if(!targetFile.getParentFile().exists()){
                        targetFile.getParentFile().mkdirs();
                    }

                    targetFile.createNewFile();
                    // 将压缩文件内容写入到这个文件中
                    InputStream is = zipFile.getInputStream(entry);
                    FileOutputStream fos = new FileOutputStream(targetFile);

                    int len;
                    byte[] buf = new byte[BUFFER_SIZE];
                    while ((len = is.read(buf)) != -1) {
                        fos.write(buf, 0, len);
                    }

                    // 关流顺序，先打开的后关闭
                    fos.close();
                    is.close();
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("unzip error from ZipUtils", e);
        } finally {
            if(zipFile != null){
                try {
                    zipFile.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
```



## 第三方

### 网络请求 - org.apache.http.client

#### POST

```
import com.google.gson.*;
import org.apache.http.HttpEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

public class CheckUpdate {

    public String checkUpdate(String httpUrl,String params) {
        System.out.println(httpUrl + params);
        CloseableHttpClient httpClient = HttpClients.createDefault();
        HttpPost httpPost = new HttpPost(httpUrl);
        try {
            org.apache.http.entity.StringEntity paramEntity = new StringEntity(params, "UTF-8");
            paramEntity.setContentType("application/json; charset=utf-8");
            httpPost.setEntity(paramEntity);
            CloseableHttpResponse response = httpClient.execute(httpPost);
            HttpEntity entity = response.getEntity();
            if (entity != null) {
                String responseStr = EntityUtils.toString(entity, "UTF-8");
                System.out.println(responseStr);

                if (responseStr == null) {
                    responseStr = "{}";
                }

                int statusCode = response.getStatusLine().getStatusCode();
                if (statusCode == 200) {
                    System.out.println("请求成功");
                    parse(responseStr);
                } else {
                    System.out.println("请求失败");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return "";
    }
}
```

### JSON 解析 - com.google.gson

使用 gson 解析 json 数据，和使用 NSDictionary 和 NSArray 去解析没有任何区别。

JsonObject -> NSDictionary

JsonArray   -> NSArray

```
JsonObject object = JsonParser.parseString(result).getAsJsonObject();
JsonArray data = object.get("data").getAsJsonArray();
```







## 附录



### FileHelper

```
package com.shujiantec;

import java.io.*;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.math.BigInteger;

public class FileHelper {
    /**
     * 根据文件计算出文件的MD5
     * @param file
     * @return
     */
    public static String getFileMD5(File file) {
        if (!file.isFile()) {
            return null;
        }

        MessageDigest digest = null;
        FileInputStream in = null;
        byte buffer[] = new byte[1024];
        int len;
        try {
            digest = MessageDigest.getInstance("MD5");
            in = new FileInputStream(file);
            while ((len = in.read(buffer, 0, 1024)) != -1) {
                digest.update(buffer, 0, len);
            }
            in.close();

        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        BigInteger bigInt = new BigInteger(1, digest.digest());
        return bigInt.toString(16);
    }

    public static String rootPath() {
        String jarWholePath = FileHelper.class.getProtectionDomain().getCodeSource().getLocation().getFile();
        try {
            jarWholePath = java.net.URLDecoder.decode(jarWholePath, "UTF-8");
        } catch (Exception e) {
            System.out.println(e.toString());
        }

        String jarPath = new File(jarWholePath).getParentFile().getAbsolutePath();
        return jarPath;
    }

    public static String readFile(String filePath) {
        StringBuffer stringBuffer = new StringBuffer("");
        byte[] buffer = new byte[1024];
        int count = 0;
        File file = new File(filePath);
        try {
            InputStream inputStream = new FileInputStream(file);
            while (-1 != (count = inputStream.read(buffer))) {
                stringBuffer.append(new String(buffer, 0, count));
            }
            inputStream.close();
        } catch (IOException ex) {
            ex.printStackTrace();
        }
        return stringBuffer.toString();
    }
}
```

