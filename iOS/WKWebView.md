

## WKWebView 

### 加载长图

```
NSString *htmlString = @"<style>body{margin:0}</style><img src=store_bg.jpg width=\"100%\"/>";
```

如果不加样式`<style>body{margin:0}</style>`，图片四周会出现白边，因为html margin 默认不为0。

```
NSString *htmlString = @"<img src=store_bg.jpg width=\"100%\"/>";
```

