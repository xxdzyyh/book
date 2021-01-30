## Ngrok 反向代理

本地Web项目外网访问

国内可以使用  https://www.ngrok.cc 作为反向代理服务器



前向代理作为客户端的代理，将从互联网上获取的资源返回给一个或多个的客户端，服务端（如Web服务器）只知道代理的IP地址而不知道客户端的IP地址；

反向代理是作为服务器端（如Web服务器）的代理使用，而不是客户端。

客户端借由前向代理可以间接访问很多不同互联网服务器（集群）的资源，而反向代理是供很多客户端都通过它间接访问不同后端服务器上的资源，而不需要知道这些后端服务器的存在，而以为所有资源都来自这个反向代理服务器。

网关可以认为是一种反向代理。





### 使用

http 8080

```
./sunny clientid 5810fb0b4b09ac10
```

tcp 9077

```
./sunny clientid 8d2f59bf03f70bee
```

Vue项目 

在 webpack.dev.conf.js 添加一行 ` disableHostCheck: true,`

```
devServer: {
  disableHostCheck: true,
  clientLogLevel: 'warning',
  historyApiFallback: {
```

