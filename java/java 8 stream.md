# Java 8 Stream



```
List<String> strings = Arrays.asList("abc", "", "bc", "efg", "abcd","", "jkl");
List<String> filtered = strings.stream().filter(string -> !string.isEmpty()).collect(Collectors.toList());


```





### forEach

Stream 提供了新的方法 'forEach' 来迭代流中的每个数据。

```
strings.forEach(System.out::println);
```



### filter

filter 方法用于通过设置的条件过滤出元素。以下代码片段使用 filter 方法过滤出空字符串：



### map

map 方法用于映射每个元素到对应的结果

```
numbers.stream().map( i -> i*i).distinct().collect(Collectors.toList());
```



### limit

limit 方法用于获取指定数量的流。

```
numbers.limit(10).forEach(System.out::println);
```



### sorted

sorted 方法用于对流进行排序。

```
numbers.limit(10).sorted().forEach(System.out::println);
```



### parallelStream



parallelStream 是流并行处理程序的代替方法。



### Collectors

Collectors 类实现了很多归约操作，例如将流转换成集合和聚合元素。

```
List<String>strings = Arrays.asList("abc", "", "bc", "efg", "abcd","", "jkl");
List<String> filtered = strings.stream().filter(string -> !string.isEmpty()).collect(Collectors.toList());
 
System.out.println("筛选列表: " + filtered);
String mergedString = strings.stream().filter(string -> !string.isEmpty()).collect(Collectors.joining(", "));
System.out.println("合并字符串: " + mergedString);
```

