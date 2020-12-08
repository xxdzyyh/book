# MySQL



## 函数

### concat

返回结果为连接参数产生的字符串，如果有任何一个参数为null，则返回值为null。

```
select concat(id,name,score) as info from score_table
```

### concat_ws

concat_ws(separator, str1, str2, ...)

说明：第一个参数指定分隔符。需要注意的是分隔符不能为null，如果为null，则返回结果为null。

### group_concat

在有group by的查询语句中，select指定的字段要么就包含在group by语句的后面，作为分组的依据，要么就包含在聚合函数中。

group_concat可以将group by产生的同一个分组中的值连接起来，返回一个字符串结果。

group_concat( [distinct] 要连接的字段 [order by 排序字段 asc/desc ] [separator '分隔符'] )

```
SELECT
	url,
	COUNT(url) as count,
	AVG(duration),
	GROUP_CONCAT(t.duration ORDER BY t.duration) times 
FROM
	( SELECT * FROM network WHERE mp_session_id='9a0247d342205425') t 
GROUP BY
	url
```

可以看到 group_concat 其实和AVG这些函数一样的，只是一个是求平均值，一个是拼接。

### group by

对数据进行分组，可以依据多个字段进行分组，所有分组字段都一样的将被分到同一组。

```
SELECT
	url,
	app_version,
	COUNT(url) as url_count,
	AVG(duration) as duration
FROM network WHERE token='04dddc869e26755a694b72bc3582f6d6' 
GROUP BY
url,
app_version
```

`url` 和 `app_version`一致的会被分到同一组。

在有group by的查询语句中，select指定的字段要么就包含在group by语句的后面，作为分组的依据，要么就包含在聚合函数中。

### where

条件查询



### 按日/按月汇总

> 按月

```
select date_format(create_time, '%Y-%m') mont, count(*) coun
from t_content
group by date_format(create_time, '%Y-%m');
```

> 按日

1. 字段是日期

    ```
    select date_format(create_time, '%Y-%m-%d') dat, count(*) coun
    from t_content
    group by date_format(create_time, '%Y-%m-%d');
    ```

2. 字段是时间戳

   ```
   select from_unixtime(create_time / 1000, '%Y-%m-%d') dat, count(*) coun
   from t_content
   group by from_unixtime(create_time / 1000, '%Y-%m-%d')
   ```


格式转换

```
select from_unixtime(create_time / 1000, '%Y-%m-%d %H:%i:%S') create_time
from t_content
```



### 两列相加



```
SELECT IFNULL(page_start_time,0) + IFNULL(offset_timestamp,0) AS errorTime FROM TABLENAME
```

