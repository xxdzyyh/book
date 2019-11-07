### XMSport Wiki



### 后台环境设置

XMNetworkConsts.h

```
// 想默认调试哪个环境就把相对应的环境放到第一个枚举位置就可以了.
typedef NS_ENUM(NSUInteger, NetEnvironmentType) {
    NetEnvironmentTypeUat, //演示环境
    NetEnvironmentTypeSit, //测试环境
    NetEnvironmentTypeDev, //开发环境
    NetEnvironmentTypePrd, //正式环境
};
```

