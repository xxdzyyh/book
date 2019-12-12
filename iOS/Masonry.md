## Masonry

通过Masonry设置视图的约束有三个方法makeConstraints、updateConstraints和remakeConstraints，选择正确的方法才能达到目的。

* makeConstraints ： 将约束直接添加到视图上，重复调用会重复添加，导致视图约束可能会冲突。

* updateConstraints：查找通过Masonry添加的所有约束，如果找到相同类型的约束，移除旧的添加新的，如果没有找到，添加新的约束

* remakeConstraints：移除通过Masonry添加的所有约束，添加新的约束。



这三个方法最终调用的都是 `-[MASConstraintMaker install]`,区别只是调用前设置不同

```
makeConstraints

* removeExisting = NO;
* updateExisting = NO;

updateConstraints

* removeExisting = NO;
* updateExisting = YES;

remakeConstraints

* removeExisting = YES;
* updateExisting = NO;
```

```
- (NSArray *)install {
    if (self.removeExisting) {
        NSArray *installedConstraints = [MASViewConstraint installedConstraintsForView:self.view];
        for (MASConstraint *constraint in installedConstraints) {
            [constraint uninstall];
        }
    }
    NSArray *constraints = self.constraints.copy;
    for (MASConstraint *constraint in constraints) {
        constraint.updateExisting = self.updateExisting;
        [constraint install];
    }
    [self.constraints removeAllObjects];
    return constraints;
}
```

通过Masonry添加约束时，Masonry会把这些约束添加到一个数组mas_installedConstraints中，这个数组会动态关联到view上面。通过其他方法添加的约束也会作用到视图上，但是要注意Masonry只会管理通过自身添加的约束。所以 updateConstraints 和 remakeConstraints 不会影响通过其他方式添加的约束。





