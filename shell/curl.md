## curl

shell中获取网络数据，可以使用curl。

> get

```
curl protocol://ip:port/url?args
```

> post

```
curl -d "key1=value1&key2=value2&key3=value3" protocol://ip:port/path
```

> 获取cookie

```
# 将cookie保存在cookie.txt中
curl -c cookie.txt -d "username=${username}&password=${password}&login_type=pwd&client_language=zh-cn" http://127.0.01/login/
```


> 设置cookie

 ```
# 将cookie.txt中的内容作为cookie传给服务器
curl -b cookie.txt -d "UserIDs=${UserIDs}" http://127.0.0.1/CardTimes/

curl http://man.linuxde.net --cookie "user=root;pass=123456"
 ```

> 设置header

```
curl -H "User-Agent: my browser" -H 'Accept-Language: es' http://cnn.com
```

> 保存请求的数据

```
# 将请求结果保存在11.html中
curl -o 11.html https://www.baidu.com
```

