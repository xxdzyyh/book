## curl

shell中获取网络数据，可以使用curl。

[TOC]

### --request/-X

指定http method，默认是 GET

```
curl -X GET http://www.baidu.com
curl -X POST http://www.baidu.com
curl -d "key1=value1&key2=value2&key3=value3" protocol://ip:port/path
```







### --cookie

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



### --header/-H

设置header

```
curl -H "User-Agent: my browser" -H 'Accept-Language: es' http://cnn.com
```

> 保存请求的数据

```
# 将请求结果保存在11.html中
curl -o 11.html https://www.baidu.com
```

### --user/-u

如果请求需要认证，可以使用 -u

```
curl --request GET \
  --url 'http://106.75.140.11:8888/rest/api/2/issuetype' \
  --user '591392966:wxf3127138' \
  --header 'Accept: application/json'
```

等价写法如下

```
echo -n 591392966:wxf3127138 | base64                                       
NTkxMzkyOTY2Ond4ZjMxMjcxMzg=

curl -X GET -H "Authorization: Basic NTkxMzkyOTY2Ond4ZjMxMjcxMzg" -H 'Accept: application/json' 'http://106.75.140.11:8888/rest/api/2/issuetype' 
```



```
curl -d '{"dataVer":"1.0.1","secLevel":0,"dataType":1,"data":{"packageList":[{"osType":3,"osVersion":"19.6.0","arch":"x64","packageName":"com.tingyun.executerserver","versionName":"1.0.0","versionCode":"100000000"}]}}' -H 'Content-Type: application/json' https://appandroidalpha1.tingyun.com/apptasksvr/official/upgrade

```

