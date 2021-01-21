## valueForKeyPath:

对集合使用 valueForKeyPath ，相当于对集合中的每个元素使用 valueForKey:

 ```
Person *person0 = [[Person alloc] init];
    
person0.firstName = @"zero";
person0.lastName = @"number";
person0.age = 18;

Person *person1 = [[Person alloc] init];

person1.firstName = @"one";
person1.lastName = @"number";
person1.age = 28;

NSArray *persons = @[person0,person1];
 ```

```
NSLog(@"%@",[persons valueForKeyPath:@"firstName"]);
(
    zero,
    one
)
```

```
NSLog(@"%@",[persons valueForKeyPath:@"firstName.uppercaseString"]);
(
    ZERO,
    ONE
)
```

```
NSLog(@"%@",[persons valueForKeyPath:@"age.@sum.self"]);

46
```



```
NSLog(@"%@",[persons valueForKeyPath:@"lastName.@distinctUnionOfObjects.self"]);

(
    number
)
```

### 数组中元素为NSNumber

```
NSArray *numbers = @[@1,@3,@4,@8,@7,@3];
    
NSLog(@"%@",[numbers valueForKeyPath:@"@sum.self"]);
NSLog(@"%@",[numbers valueForKeyPath:@"@max.self"]);
NSLog(@"%@",[numbers valueForKeyPath:@"@min.self"]);
NSLog(@"%@",[numbers valueForKeyPath:@"@avg.self"]);
NSLog(@"%@",[numbers valueForKeyPath:@"@distinctUnionOfObjects.self"]);

26
8
1
4.333333333333333
(
  8,
  3,
  7,
  1,
  4
)
```



### NSDictionary

```
NSDictionary *dict = @{
    @"data": @{@"name" : @"hahah"}
};

NSLog(@"%@",[dict valueForKeyPath:@"data.name"]);

hahah
```

