# MongoDB



* Database
* Collection
* Nested Sub-Document or Array
* Index
* Document
* Field
* Embedding 

* Bucket

* View





## BSON

BSON是一种类json的一种二进制形式的存储格式，简称Binary JSON，它和JSON一样，支持内嵌的文档对象和数组对象，但是BSON有JSON没有的一些数据类型，如Date和BinData类型。
BSON可以做为网络数据交换的一种存储形式，这个有点类似于Google的Protocol Buffer，但是BSON是一种schema-less的存储形式，它的优点是灵活性高，但它的缺点是空间利用率不是很理想，

## 数据类型



Double

String

Object

Array





## 

/bin.mongod --dbpath /data/db



## 分片集群





### 复制集





### 插入新文档



* insertOne

* insertMany



### 删除文档

* deleteOne
* deleteMany
* remove



### 删除集合和数据库



* drop

* db.dropDatabase()



### 查询

db.movies.find({'year':1974})

db.movies





### 更新操作



Update



db.movies.insert([

])



db.movies.update({"title":"xxx",})



$addToSet: 如果不存在，增加数组



## Aggs



pipeline = [$stage1,$stage2,...$stateN]



### 管道 Pipeline



### 步骤 Stage 

| 运算符       | 作用     | SQL等价运算符   |
| ------------ | -------- | --------------- |
| $match       | 过滤     | WHERE           |
| $project     | 投影     | AS              |
| $sort        | 排序     | ORDER BY        |
| $group       | 分组     | GROUP BY        |
| $skip/$limit | 结果限制 | SKIP/LIMIT      |
| $lookup      | 左外连接 | LEFT OUTER JOIN |
| $unwind      | 展开数组 |                 |
| $faced       |          |                 |
| $bucket      |          |                 |





* $match
  * $eq/gt/gte/lt/lte/and/or/not/in/geoWithin/intersec

* $project  
  * $map
  * 



## View

视图可以用来做权限控制





## 实战



db.student.aggregate([

​	

])

