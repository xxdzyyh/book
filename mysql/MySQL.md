# MySQL



### 命令行使用

```
// 用户名 root 密码 123456 远程地址 106.75.169.229 端口 3306
mysql -uroot -p123456 -h106.75.169.229 -P3306;

// 显示所有数据库
show databases;
// 选择数据库
use buginsight;
// 显示所有的表
show tables;
// 显示表结构
desc network;
```

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



###  查询结果插入另外一张表

需要将查询结果列名保证和目标表一直，否则，可以指定字段和名字

```
INSERT INTO network_summary SELECT
		token,
		app_version,
		url,
		date_format( begin_time, '%Y-%m-%d' ) AS `date`,
		count( * ) AS `url_count`,
		AVG( is_star ),
		AVG( duration ) AS duration,
		AVG( dns ) AS `dns`,
		AVG( ssl_time ) AS `ssl`,
		AVG( tcp ) AS `tcp`,
		AVG( first_package ) AS first_package,
		AVG( remain_package ) AS remain_package,
		AVG( send_length ) AS send_length,
		AVG( recv_length ) AS recv_length
	FROM
		network 
	WHERE
		is_web_view = FALSE 
		AND status_code BETWEEN 1 
		AND 399 
	GROUP BY
		date_format( begin_time, '%Y-%m-%d' ),
		url,
		token,
	app_version 
```

### SQL 语句优化

索引类似于字典目录。

为什么使用首字母呢，因为首字母区分度大，就26个，根据第一个字母就能大幅缩小搜索方位。

索引长度越长，匹配索引就会花很多时间。

索引越多，维护索引的消耗就越多。



单表查询相对来说比较好优化，大部分时候只需要把where条件里面的字段依照规则加上索引就好，如果只是这种“无脑”优化的话，显然一些区分度非常低的列，不应该加索引的列也会被加上索引，这样会对插入、更新性能造成严重的影响，同时也有可能影响其它的查询语句。



### network

```
SELECT url, duration FROM network WHERE token = 'b427fcfb1f9af05c8d7766ca60b02eb7' AND is_web_view = FALSE AND UNIX_TIMESTAMP( begin_time ) * 1000 BETWEEN 1606924800000 AND 1607615999000 
```



没有使用 token 建立索引，27w行数据，2s，用 token 建立索引， 0.019s。token 的区分度很高。

```
+----+-------------+---------+------------+------+---------------+-------------+---------+-------+------+----------+-------------+
| id | select_type | table   | partitions | type | possible_keys | key         | key_len | ref   | rows | filtered | Extra       |
+----+-------------+---------+------------+------+---------------+-------------+---------+-------+------+----------+-------------+
|  1 | SIMPLE      | network | NULL       | ref  | index_token   | index_token | 82      | const | 3341 |    10.00 | Using where |
+----+-------------+---------+------------+------+---------------+-------------+---------+-------+------+----------+-------------+
```

type

* ref 使用了索引

* all 没有使用索引



### delete

1. **delete是DML(data maintain language)，这个操作会被放到rollback segment中，事务提交之后才会生效，如果有相应的触发器trigger，那么执行的时候可以被触发**
2. **执行delete操作时，每次从表中删除一行，并且同时将该行的的删除操作记录在redo和undo表空间中以便进行回滚（rollback）和重做操作，但要注意表空间要足够大，需要手动提交（commit）操作才能生效，可以通过rollback撤消操作。**
3. **delete可根据条件删除表中满足条件的数据，如果不指定where子句，那么删除表中所有记录。**
4. **delete语句不影响表所占用的extent（就是表结构的中的区），高水线(high watermark)保持原位置不变。** （高水位线就存在于段（segment)中，它用于标识段中已使用过的数据块与未使用的数据块二者间交界，扫描表数据的时候，高水位线以下的所有数据块都必须被扫描。）

### truncate

1. **truncate是DDL（data define language）即操作会立即生效，原数据不会放到rollback segment中，不能回滚，也不会触发触发器**
2. **truncate会删除表中所有记录，并且将重新设置高水线和所有的索引，缺省情况下将空间释放到minextents的extent（就是表结构中的段内的区域），除非使用reuse storage（使用这句话，所在的extent空间不会被回收，只是将数据删除掉，数据删除之后的freespace空间，只能供本表使用，其他的不可以使用）。不会记录日志，所以执行速度很快，但不能通过rollback撤消操作（如果一不小心把一个表truncate掉，也是可以恢复的，只是不能通过rollback来恢复）。**
3. **对于外键（foreign key ）约束引用的表，不能使用 truncate table（会报错（Cannot truncate a table referenced in a foreign key constraint ）），也不能使用drop table（会报错（Cannot delete or update a parent row: a foreign key constraint fails）），而应使用不带 where 子句的 delete 语句。**
4. **truncate table不能用于参与了索引视图的表。**

### drop

------

1. **drop是DDL，会隐式提交，所以，不能回滚，不会触发触发器。**
2. **drop语句删除表结构及所有数据，并将表所占用的空间全部释放。**
3. **drop语句将删除表的结构所依赖的约束，触发器，索引，依赖于该表的存储过程/函数将保留,但是变为invalid状态。**

### update 

```
UPDATE network set os = 'iPhone',os_version = '12.4' WHERE token = 'b427fcfb1f9af05c8d7766ca60b02eb7'
```

### 清空表中数据

删除表信息的方式有两种 :

```
truncate table table_name;
delete * from table_name;
```

注 : truncate操作中的table可以省略，delete操作中的*可以省略

truncate、delete 清空表数据的区别 :
1> truncate 是整体删除 (速度较快)，delete是逐条删除 (速度较慢)
2> truncate 不写服务器 log，delete 写服务器 log，也就是 truncate 效率比 delete高的原因
3> truncate 不激活trigger (触发器)，但是会重置Identity (标识列、自增字段)，相当于自增列会被置为初始值，又重新从1开始记录，而不是接着原来的 ID数。而 delete 删除以后，identity 依旧是接着被删除的最近的那一条记录ID加1后进行记录。如果只需删除表中的部分记录，只能使用 DELETE语句配合 where条件

### 添加索引

```
ALTER TABLE `table_name` ADD INDEX index_name ( `column` ) 
```



### 增加列

```
ALTER TABLE `table name`
ADD COLUMN `column name` int(11) DEFAULT NULL,
ADD COLUMN `column name` int(11) DEFAULT NULL;
```



### 重命名列

```js
ALTER TABLE tableName CHANGE `oldcolname` `newcolname` datatype(length);
```