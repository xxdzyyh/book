## Shell JSON解析(jq)

使用curl命令，后台返回了json数据，要解析这个数据，可以使用 jq 框架。

```
{
  "id" : "123",
  "rows": [
    {
      "card_date": "2019-09-02",
      "ClockInTime": "09:21:02,12:14:09,20:01:17,",
      "times": "3"
    },
    {
      "card_date": "2019-09-03",
      "ClockInTime": "09:21:02,12:14:09,20:01:17,",
      "times": "3"
    }
  ]
}
```

### 安装jq

```
brew install jq
```

### 使用

```
$ jq .id daka.json
"123"

$ jq -r '.rows[]' daka.json
{
  "card_date": "2019-09-02",
  "ClockInTime": "09:21:02,12:14:09,20:01:17,",
  "times": "3"
}
{
  "card_date": "2019-09-03",
  "ClockInTime": "09:21:02,12:14:09,20:01:17,",
  "times": "3"
}


$ jq -r '.rows[0]' daka.json 
{
  "card_date": "2019-09-02",
  "ClockInTime": "09:21:02,12:14:09,20:01:17,",
  "times": "3"
}

$ jq -r '.rows[] | .ClockInTime' daka.json
09:21:02,12:14:09,20:01:17,
09:21:02,12:14:09,20:01:17,
```



