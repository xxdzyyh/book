# elk



[TOC]



## 术语

### 集群 Cluster

一个集群包含一个或多个节点。



### 节点 Node

单台服务器，存储数据并参与集群的索引和搜索功能。

节点默认加入到名为 elasticsearch 的集群，多个节点会自动组建集群。

### 索引 Index

查看索引信息

```
GET /test-loginfo/


...
"settings" : {
  "index" : {
    "routing" : {
      "allocation" : {
        "include" : {
          "_tier_preference" : "data_content"
        }
      }
    },
    "number_of_shards" : "1",
    "provided_name" : "test-loginfo",
    "creation_date" : "1625213950732",
    "number_of_replicas" : "1",
    "uuid" : "Nr0T5FTgRd6GX75WR51KPw",
    "version" : {
      "created" : "7130299"
    }
  }
}
...
```



### 分片 Shard

ES默认为一个索引创建5个主分片, 并分别为其创建一个副本分片。



分片是针对 Index 的。Index 可以被拆分为多个分片，分片可以位于集群中的任意节点上。

查询 Index 的数据等于先查询 Index 所有分片上数据，然后再汇总。这个过程中计算实际被拆分了，但是也会带来一些新的问题。查询100条数据是在每个分片上查找100条数据，然后汇总排序返回100条数据。实际查出的数据量是 100 * 分片数量。



### 副本 Replica

ES默认为一个索引创建5个主分片, 并分别为其创建一个副本分片. 也就是说每个索引都由5个主分片成本, 而每个主分片都相应的有一个copy.



### 映射 Mapping

mapping 是定义一个文档包含哪些字段、如何存储和索引的过程。

`GET /loginfo/_mapping`

_mapping 可以增加字段，但是已有字段无法修改类型。



## 数据类型

#### 字符串类型

* keyword 字段不会进行分词
* text 字段会进行分词

### keyword VS text



| 类型      | 参数定义                         | 赋值                                  |
| :-------- | :------------------------------- | :------------------------------------ |
| text      | "name":{"type":"text"}           | "name": "zhangsan"                    |
| keyword   | "tags":{"type":"keyword"}        | "tags": "food"                        |
| date      | "date":{"type": "date"}          | "date":"2015-01-01T12:10:30"          |
| long      | "age":{"type":"long"}            | "age" :28                             |
| double    | "score":{"type":"double"}        | "score":98.8                          |
| boolean   | "isgirl": { "type": "boolean" }  | "isgirl" :true                        |
| ip        | "ip_addr":{"type":"ip"}          | "ip_addr": "192.168.1.1"              |
| geo_point | "location": {"type":"geo_point"} | "location":{"lat":40.12,"lon":-71.34} |



## Routing



解决文档应该存储在那个分片中

默认

```
shard = hash(routing) % number_of_primary_shards

# 默认routing是文档 _id
```









## index

* 创建索引 `PUT  /indexName`  

* 索引状态 `GET /_cat/indices?v`

* 索引详情 `GET /indexName`

* 索引映射中增加一个字段 `PUT /indexName/_mapping/newName`

* 删除index `DELETE /indexName`



#### 条件查询并排序

　　　　查询host名为salt-test的主机，只显示message和host字段，按时间倒序排列，从头开始页大小为2

```
GET /system-log-2019.09/_search
{
  "query": {
    "match": {
      "host":"salt-test"
    }
  },
  "_source": [
    "host",
    "@timestamp"
    ],
  "sort": [
    {
        "@timestamp": "desc"
    }
  ],
  "from": 0,
  "size": 2
}
```







## 常见问题



```
{
		"type" : "illegal_argument_exception",
    "reason" : "Text fields are not optimised for operations that require per-document field data like aggregations and sorting, so these operations are disabled by default. Please use a keyword field instead. Alternatively, set fielddata=true on [interests] in order to load field data by uninverting the inverted index. Note that this can use significant memory."
}
```



```
PUT /loginfo/_mapping
{
  "properties":{
    "sessionID" : {
      "type" : "text",
      "fielddata" : true,
      "index" : "not_analyzed"
    }
  }
}
```



## 分组查询



因为聚合总是对查询范围内的结果进行操作的，所以一个隔离的聚合实际上是在对 `match_all` 的结果范围操作，即所有的文档。现实中，Elasticsearch 认为 "没有指定查询" 和 "查询所有文档" 是等价的。

```
GET /cars/transactions/_search
{
    "size" : 0,
    "aggs" : {
        "colors" : {
            "terms" : {
              "field" : "color"
            }
        }
    }
}

GET /cars/transactions/_search
{
    "size" : 0,
    "query" : {
        "match_all" : {}
    },
    "aggs" : {
        "colors" : {
            "terms" : {
              "field" : "color"
            }
        }
    }
}
```







按特定字段分组

```
GET /loginfo/_search
{
  "aggs": {
    "group_yy": {
      "terms": {
        "field": "sessionID.keyword",
        "size": 100
      }
    }
  }
}      
```



分组后再分组

```
GET /test-loginfo/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "term": {
            "app_index": {
              "value": 21,
              "boost": 1
            }
          }
        },
        {
          "range": {
            "logTime": {
              "from": 1625155200000,
              "to": 1625241599766,
              "include_lower": true,
              "include_upper": true,
              "boost": 1
            }
          }
        }
      ],
      "adjust_pure_negative": true,
      "boost": 1
    }
  },
  "aggs": {
    "session_group": {
      "terms": {
        "field": "sessionID.keyword",
        "size": 10
      }, 
      "aggs": {
        "level_group": {
          "terms": {
            "field": "level"
          }
        }
      }
    }
  }
}
```



### agg_type



* date_histogram

* histogram 直方图

  ```
  "aggs": {
    "level_group": {
      "histogram": {
        "field": "level",
        "interval" : 1
      }
    }
  }
  ```

* date_histogram

  ```
  "aggs": {
    "level_group": {
      "histogram": {
        "field": "date",
        "interval" : "month"
      }
    }
  }
  ```

  

* terms

* 





## 精确查找

### term

完全匹配，term指定的值不会进行分词处理，对应field中必须等于整个值。



term 查询会查找我们指定的精确值。term 查询是简单的，它接受一个字段名以及我们希望查找的数值。

类似于 mysql 中的 select *  from loginfo where content = 'send message'

```
GET /loginfo/_search
{
  "query": {
    "term": {
      "content": "send message"
    }
  }
}
```

当进行精确值查找时， 我们会使用过滤器（filters）。过滤器很重要，因为它们执行速度非常快，不会计算相关度（直接跳过了整个评分阶段）而且很容易被缓存。



```
// content 是 text 类型
{
	"content" : "cloginsight header",
}

// term 查找不能匹配，因为分词的结果 cloginsight header 被拆开了，不能完全匹配"cloginsight header"
GET /test-loginfo/_search
{
  "query": {
    "term": {
      "content": {
        "value": "cloginsight header"
      }
    }
  }
}

// content.keyword 因为不会被分析，所以能够匹配
GET /test-loginfo/_search
{
  "query": {
    "term": {
      "content.keyword": {
        "value": "cloginsight header"
      }
    }
  }
}

// 可以匹配
GET /test-loginfo/_search
{
  "query": {
    "term": {
      "content": {
        "value": "cloginsight"
      }
    }
  }
}

// 不能匹配
GET /test-loginfo/_search
{
  "query": {
    "term": {
      "content.keyword": {
        "value": "cloginsight"
      }
    }
  }
}
```





### match

match 指定的值会进行分词，比如"宝马多少马力"会被分词为"宝马 多少 马力", 所有包含这三个词中的一个或多个的文档就会被搜索出来，并且根据lucene的评分机制(TF/IDF)来进行评分。

```
{
  "query": {
    "match": {
        "content" : {
            "query" : "我的宝马多少马力"
        }
    }
  }
}
```









## 范围检索

range 查询可同时提供包含（inclusive）和不包含（exclusive）这两种范围表达式，可供组合的选项如下：

```
gt: > 大于（greater than）
lt: < 小于（less than）
gte: >= 大于或等于（greater than or equal to）
lte: <= 小于或等于（less than or equal to）
```

Mysql:

`SELECT DOCUMENT FROM PRODUCTS WHERE logTime between 1624002260168 and 1627502260168` 



```
GET /loginfo/_search
{
  "query": {
    "constant_score": {
      "filter": {
        "range": {
          "logTime": {
            "gte": 1624002260168,
            "lte": 1627502260168
          }
        }
      }
    }
  }
}
```



## 存在与否



```
GET /my_index/posts/_search
{
    "query":
    {
        "constant_score":
        {
            "filter":
            {
                "exists":
                {
                    "field": "tags"
                }
            }
        }
    }
}
```



## 前缀查询

```
GET /test-loginfo/_search
{
  "query": {
    "prefix": {
      "content.keyword": {
        "value": "iOS"
      }
    }
  }
}
```




## 正则表达式

```
GET /test-loginfo/_search
{
  "query": {
    "regexp": {
      "content.keyword": {
        "value": ".*People.*"
      }
    }
  }
}
```



## 分页查询

from、size、n（主分片数）

请求会分发到对应主分片或者副本分片上，**分片向协调节点返回(from+size)条数据**，n个分片共返回数据**(from+size)\*n**条数据；

协调节点对数据进行排序，然后向客户端返回**from到from+size之间的数据**



## scroll查询

如果要使用分页查询100页数据，每页数据100条，则需重复上述过程100次，且随着from的增大，查询效率会越来越慢，使用scroll查询只要一次查询，查询过程：

每个分片返回10000条数据，协调节点共接收数据10000*n条；

协调节点对数据排序后，返回前10000条数据给客户端

`scroll` 查询 可以用来对 Elasticsearch 有效地执行大批量的文档查询，而又不用付出深度分页那种代价。

启用游标查询可以通过在查询的时候设置参数 `scroll` 的值为我们期望的游标查询的过期时间。 游标查询的过期时间会在每次做查询的时候刷新，所以这个时间只需要足够处理当前批的结果就可以了，而不是处理查询结果的所有文档的所需时间。 这个过期时间的参数很重要，因为保持这个游标查询窗口需要消耗资源，所以我们期望如果不再需要维护这种资源就该早点儿释放掉。 设置这个超时能够让 Elasticsearch 在稍后空闲的时候自动释放这部分资源。



在查询的时候，我们可以设置size,size上限是10000条，假设查询的结果超过10000条，就可以使用 scroll 查询。



## 更新

### _update

```json
POST student/_doc/2/_update
{
  "doc": {
    "age": 10
  }
}
```

###  _update_by_query

```
POST /test-sessioninfo/_update_by_query
{
  "query": {
    "match": {
      "sessionId.keyword": "82a4d82806491c1e"
    }
  },
  "script": {
    "inline": "ctx._source['errorCount'] = 1"
  }
}
```



`#! Deprecation: Deprecated field [inline] used, expected [source] instead`



```json
POST student/_update_by_query
{
  "query": { 
    "match": {
      "_id": 2
    }
  },
  "script": {
    "source": "ctx._source.age = 12"
  }
}
```





## 实战



1. 先过滤数据 , 依据时间进行过滤

   ```
   GET /xftest/_search
   {
     "query": {
       "bool": {
         "filter": [
           {
             "range": {
               "logTime": {
                 "gte": 1625155200000,
                 "lte": 1625241599000
               }
             }
           }
         ]
       }
     }
   }
   ```

   

2. 指定index

   ```
   GET /test-loginfo/_search
   {
     "query": {
       "bool": {
         "filter": [
           {
             "range": {
               "logTime": {
                 "gte": 1625155200000,
                 "lte": 1625241599000
               }
             }
           },{
             "term": {
               "app_index": "21"
             }
           }
         ]
       }
     }
   }
   ```

   

3. 排序

   ```
   GET /test-loginfo/_search
   {
     "size" : 200,
     "query": {
       "bool": {
         "filter": [
           {
             "range": {
               "logTime": {
                 "gte": 1625155200000,
                 "lte": 1625241599000
               }
             }
           },{
             "term": {
               "app_index": "21"
             }
           }
         ]
       }
     },
     "sort": [
       {
         "@timestamp" : {
           "order": "desc"
         }
       }
     ]
   }
   ```

   



## 构架

多索引 





## Join field type

* https://www.elastic.co/guide/en/elasticsearch/reference/7.13/parent-join.html

* https://docs.spring.io/spring-data/elasticsearch/docs/current/reference/html/#elasticsearch.jointype

```
@JoinTypeRelations(
        relations = {
                @JoinTypeRelation(parent = "session",children = "log")
        }
)
private JoinField<String>relation;
```





## 分词



### 查看分词结果

```
GET /_analyze?
{
    "analyzer": "standard",
    "text": "床前明月光"
}
```



分词结果会影响到查询结果

```
GET /test-loginfo/_analyze
{
  "analyzer": "standard",
  "text": "iOS 1625299536115.920898  Test Log Dog 4220513835 0"
}

{
  "tokens" : [
    {
      "token" : "ios",
      "start_offset" : 0,
      "end_offset" : 3,
      "type" : "<ALPHANUM>",
      "position" : 0
    },
    ...
    
    
默认分词将 iOS 将 转成了小写.

GET /test-loginfo/_search
{
  "query": {
      "regexp": {
        "content": "iO.*",
      }
  }    
}

使用正则匹配时，大小 iO 无法匹配小写的。
```



查询

```

```



### 中文分词

https://github.com/medcl/elasticsearch-analysis-ik

