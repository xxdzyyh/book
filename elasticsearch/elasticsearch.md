elk



[TOC]

## 测试机器



界面：http://124.71.70.101:32123

接口：http://124.71.70.101:19200

elastic

ASD!asd#123





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

ES默认为一个索引创建5个主分片, 并分别为其创建一个副本分片。（10个分片）

主分片的数目在索引创建时就已经确定了下来。实际上，这个数目定义了这个索引能够 *存储* 的最大数据量。（实际大小取决于你的数据、硬件和使用场景。）



```
GET /v2-loginfo/_search_shards
```



* 对于多大的分片没有固定的限制，但是**分片大小为50GB通常被界定为适用于各种用例的限制**。

* 您可以在集群节点上保存的分片数量与您可用的堆内存大小成正比，但这在Elasticsearch中没有的固定限制。 一个很好的经验法则是：确保每个节点的分片数量保持在低于**每1GB堆内存对应集群的分片在20-25之间**。 因此，具有30GB堆内存的节点最多可以有600-750个分片，但是进一步低于此限制，您可以保持更好。 这通常会帮助群体保持处于健康状态。

* 当在ElasticSearch集群中配置好你的索引后, 你要明白在集群运行中你无法调整分片设置. 既便以后你发现需要调整分片数量, 你也只能新建创建并对数据进行重新索引(reindex)(虽然reindex会比较耗时, 但至少能保证你不会停机).

分片是针对 Index 的。Index 可以被拆分为多个分片，分片可以位于集群中的任意节点上。

查询 Index 的数据等于先查询 Index 所有分片上数据，然后再汇总。这个过程中计算实际被拆分了，但是也会带来一些新的问题。查询100条数据是在每个分片上查找100条数据，然后汇总排序返回100条数据。实际查出的数据量是 100 * 分片数量。



### 副本 Replica

ES默认为一个索引创建5个主分片, 并分别为其创建一个副本分片. 也就是说每个索引都由5个主分片成本, 而每个主分片都相应的有一个copy.



### 映射 Mapping

mapping 是定义一个文档包含哪些字段、如何存储和索引的过程。

`GET /loginfo/_mapping`

_mapping 可以增加字段，但是已有字段无法修改类型。



### Refresh



节点收到请求后，会将请求写入到 Memory Buffer,然后定时（默认是每隔1秒）写入到 Filesystem Cache,这个从MomeryBuffer到 Filesystem Cache 的过程称之为refresh





### Flush



### Translog





## 性能数据

https://cloud.tencent.com/document/product/845/55185



## 数据类型

#### 字符串类型

* keyword 字段不会进行分词
* text 字段会进行分词

```
// 元数据
{
	"sessionID" : "84eaea57-3d9d-4b7a-a464-2d9497ac0922"
}

// 如果 sessionID 的类型是 keyword ,那下面的查询可以找到，如果是 text 那就找不到。因为 text 会被分词器分词
// [84eaea57 3d9d 4b7a a464 2d9497ac0922]

GET /t-loginfo/_search
{
  "query": {
    "term": {
      "sessionID" : {
        "value": "84eaea57-3d9d-4b7a-a464-2d9497ac0922"
      }
    }
  }
}
```





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



keyword 类型可以使用 ignoreAbove 来修饰，超过 ignoreAbove 指定的将不会被检索到。对超过 `ignore_above` 的字符串，analyzer 不会进行处理；所以就不会索引起来。导致的结果就是最终搜索引擎搜索不到了。这个选项主要对 `not_analyzed` 字段有用，这些字段通常用来进行过滤、聚合和排序。而且这些字段都是结构化的，所以一般不会允许在这些字段中索引过长的项。



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



## Aggs



aggs最重要的两个概念

1. Buckets：符合bucket条件的文档会放入bucket中，一个文档可以属于多个bucket , bucket 可以被嵌套。
2. Metrics : 对 bucket 里的文档进行统计计算，文档划分到 bucket 里并不是最终的目的，对 bucket 里的数据进行指标计算（min/max/avg/sum）等等



一个aggs 可以有很多个聚合，每个聚合彼此之间都是独立的，因此可以一个聚合拿来统计数量、一个聚合拿来分析数据、一个聚合拿来计算标准差...，让一次搜索就可以把想要做的事情一次做完。



聚合如果不指定 size 会返回全部结果，设置为0，会返回全部结果



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



#### 按特定字段分组

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



#### 分组后再分组

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



### 多个字段聚合



```
GET /v2-loginfo/_search
{
  "aggs": {
    "level_group": {
      "terms": {
        "field": "level"
      },
      "aggs": {
        "distinct_group": {
          "terms": {
            "script": "doc['file.keyword'].value + ' ' + doc['functionName.keyword'].value + '' + doc['line'].value",
            "size": 10
          }
        }
      }
    }
  }
}
```





### agg_type



#### date_histogram



#### histogram 直方图

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



#### date_histogram

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



#### terms

对 keyword 按值进行分组

```
GET /v2-loginfo/_search
{
  "size": 0, 
  "aggs": {
    "os_group": {
      "terms": {
        "field": "os"
      }
    }
  }
}
```



#### top_hits

获取符合分组的条件的数据

```
GET /v2-loginfo/_search
{
  "size": 0, 
  "aggs": {
    "level_group": {
      "terms": {
        "field": "level"
      }
    }
  }
}

// 一般aggs 只是返回文档的数量，没有返回符合条件的数据，可以使用 top_hits 获取指定数量的数据
"aggregations" : {
  "level_group" : {
    "doc_count_error_upper_bound" : 0,
    "sum_other_doc_count" : 0,
    "buckets" : [
      {
        "key" : 4,
        "doc_count" : 427
      },
      {
        "key" : 3,
        "doc_count" : 73
      },
      {
        "key" : 0,
        "doc_count" : 4
      },
      {
        "key" : 1,
        "doc_count" : 4
      },
      {
        "key" : 2,
        "doc_count" : 1
      }
    ]
  }
}


// 分组后获取组内数据
GET /v2-loginfo/_search
{
  "size": 0, 
  "aggs": {
    "level_group": {
      "terms": {
        "field": "level"
      },
      "aggs": {
        "top_log": {
          "top_hits": {
            "size": 10,
            "sort": [
              {
                "timestamp": {
                  "order": "desc"
                }
              }
            ]
          }
        }
      }
    }
  }
}


"aggregations" : {
    "level_group" : {
      "doc_count_error_upper_bound" : 0,
      "sum_other_doc_count" : 0,
      "buckets" : [
        {
          "key" : 4,
          "doc_count" : 427,
          "top_log" : {
            "hits" : {
              "total" : {
                "value" : 427,
                "relation" : "eq"
              },
              "max_score" : null,
              "hits" : [
                {
                  "_index" : "v2-loginfo",
                  "_type" : "_doc",
                  "_id" : "c8cd5b38-233c-4c10-8f95-1051493955bf",
                  "_score" : null,
                  "_routing" : "b09913d18fd519e1",
                  "_source" : {
                    "_class" : "com.appinsight.core.dataaccessorlog.model.LogESDetailModel",
                    "id" : "c8cd5b38-233c-4c10-8f95-1051493955bf",
                    "timestamp" : 1626851150825,
                    "content" : "render image, app is active:1, replayPaused:0",
                    "logTime" : 1626851104492,
                    "sessionId" : "b09913d18fd519e1",
                    "functionName" : "-[SJLogger level:format:]",
                    "file" : "SJLogger.m",
                    "line" : 102,
                    "tag" : "AppInsight",
                    "appIndex" : 21,
                    "level" : 4,
                    "relation" : {
                      "name" : "log",
                      "parent" : "b09913d18fd519e1"
                    },
                    "userIndex" : 0,
                    "sessionStartTime" : 0
                  },
                  "sort" : [
                    1626851150825
                  ]
                },

```



#### filter



```
GET 127.0.0.1/mytest/doc/_search
{
    "query":
    {
        "match_all":
  			{}
    },
    "size": 0,
    "aggs":
    {
        "my_name":
        {
            "filter":
            {
                "bool":
                {
                    "must":
                    {
                        "terms":
                        {
                            "color":
                            [
                                "red",
                                "blue"
                            ]
                        }
                    }
                }
            }
        }
    }
}
```





## 查找

### term

完全匹配，term指定的值不会进行分词处理，对应field的值必须等于term指定的值。

避免对 text 类型的 field 使用 term，因为 text 字段默认会进行分析处理。



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



### range 范围检索

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



### exists 存在查询

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



## prefix 前缀查询



应用场景：前缀自动补全的业务场景

适用类型：keyword

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



### regexp 正则查询



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



### wildcard 模糊匹配

- 核心功能：匹配具有匹配通配符表达式 keyword 类型的文档。支持的通配符： *，它匹配任何字符序列（包括空字符序列）；？，它匹配任何单个字符。

- 应用场景：请注意，选型务必要慎重！此查询可能很慢多组关键次的情况下可能会导致宕机，因为它需要遍历多个术语。为了防止非常慢的通配符查询，通配符不能以任何一个通配符*或？开头。
- 适用类型：keyword



###  match_phrase 短语匹配

* 核心功能：match_phrase 查询首先将查询字符串解析成一个词项列表，然后对这些词项进行搜索;只保留那些包含 全部 搜索词项，且位置"position" 与搜索词项相同的文档
* 应用场景：业务开发中 90%+ 的全文检索都会使用 match_phrase 或者 query_string 类型，而不是 match。

- 适用类型：text



### 分页查询

from、size、n（主分片数）

请求会分发到对应主分片或者副本分片上，**分片向协调节点返回(from+size)条数据**，n个分片共返回数据**(from+size)\*n**条数据；

协调节点对数据进行排序，然后向客户端返回**from到from+size之间的数据**



### scroll查询

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



## Nested

嵌套类型，一对多。



### 限制

* 单个索引 Nested 类型的字段最多为50个
* 单个文档 包含的对象上限为 10000，否则容易内存溢出。



## Join field type

如果数据是一对多的情况，可以使用 join field type，在同一个 Index 中创建不同的doc，doc 可以设置 parent-child 关系。

* https://www.elastic.co/guide/en/elasticsearch/reference/7.13/parent-join.html

* https://docs.spring.io/spring-data/elasticsearch/docs/current/reference/html/#elasticsearch.jointype

```
@JoinTypeRelations(
        relations = {
                @JoinTypeRelation(parent = "session",children = "log")
        }
)
private JoinField<String>relation;


GET /t-loginfo/_mapping
...

"relation" : {
  "type" : "join",
  "eager_global_ordinals" : true,
  "relations" : {
    "session" : "log"
  }
},

...
```



### has_child

使用子文档的字段作为查询条件，查询出符合条件的父文档的数据

```
GET /t-loginfo/_search
{
  "query": {
    "has_child": {
      "type": "log",
      "query": {
        "match_all": {}
      }
    }
  }
}
```





### has_parent

使用父文档的字段作为查询条件，查询出符合条件的子文档数据

```
GET /t-loginfo/_search
{
  "query": {
    "has_parent": {
      "parent_type": "session",
      "query": {
        "match_all": {}
      }
    }
  }
}
```



### 添加父文档

因为父子文档需要放到同一个shard，所以需要指明 routing，默认routing 是 _id。如果父文档id是routing,那就不需要额外设置routing

```
@Data
@Document(indexName = "t-loginfo")
@Routing("routing")
public class LogESDetailModel implements Serializable {

	  @Id
	  private String id;
	  
    @Field(type = FieldType.Keyword,name = "sessionId")
    private String sessionId;
    
    
    @Field(type = FieldType.Keyword)
    private String routing;
}

// 保存父文档
// 保存父文档的时候用id作为路由
public void saveSession(LogSessionModel model) {
    LogESDetailModel model1 = new LogESDetailModel();
    model1.fromLogSessionModel(model);
    model1.setId(model.getSessionId());
    model1.setRelation(new JoinField<>("session"));
    productRepo.save(model1);
}

// 保存子文档
// 子文档使用父文档的id作为路由
public void saveAll(List<LogDetailModel> models) {
    List<LogESDetailModel> modelList = new ArrayList<>();
    for (int i=0;i<models.size();i++) {
        LogESDetailModel model = new LogESDetailModel();
        model.fromLogDetailModel(models.get(i));
        model.setRelation(new JoinField<>("log", model.getSessionId()));
        modelList.add(model);
    }
    productRepo.saveAll(modelList);
}
```



### 查询

因为父文档和子文档现在有了关联，通过父文档查找子文档应该有更高的效率。找到父文档所在的分片就可以，在当个分片上查询就可以。

#### 依据 join type 进行查询

```
// 获取 session 
GET /v2-loginfo/_search
{
  "query": {
    "term": {
      "relation": {
        "value": "session"
      }
    }
  }
}

"hits" : [
  {
    "_index" : "v2-loginfo",
    "_type" : "_doc",
    "_id" : "AePpwnoB3dYTHluUJh_Y",
    "_score" : 2.3671236,
    "_source" : {
      "_class" : "com.appinsight.core.dataaccessorlog.model.LogESDetailModel",
      "@timestamp" : 1626767680597,
      "logTime" : 0,
      "sessionId" : "9bb9eb341c17f54f",
      "line" : 0,
      "appIndex" : 21,
      "level" : 0,
      "relation" : {
        "name" : "session"
      },
      "appVersion" : "1.2.6",
      "brand" : "Simulator",
      "manufacturer" : "Apple",
      "model" : "Simulator",
      "os" : "IOS",
      "osVersion" : "14.5",
      "sdkVersion" : "1.4.2.1",
      "userIndex" : 7,
      "userId" : "1234",
      "sessionStartTime" : 0
    }
  }
]
```



### 利用父文档属性对子文档进行聚合

```
GET /v2-loginfo/_search
{
  "size": 0, 
  "aggs": {
    "os_group": {
      "terms": {
        "field": "os"
      },
      "aggs": {
        "to-logs": {
          "children": {
            "type": "log"
          }
        }
      }
    }
  }
}
```



### 利用子文档属性对父文档进行聚合



parent 应该是有些问题的







依据父属性对子文档进行分组,分组之后依据

```
GET /v2-loginfo/_search
{
  "query": {
    "term": {
      "os": {
        "value": "IOS"
      }
    }
  }, 
  "size": 0,
  "aggs": {
    "os_group": {
      "terms": {
        "field": "osVersion"
      },
      "aggs": {
        "log_group": {
          "children": {
            "type": "log"
          },
          "aggs": {
            "level_group": {
              "filter": {
                "term": {
                  "level": "1"
                }
              }
            }
          }
        }
      }
    }
  }
}
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

### 中文分词

https://github.com/medcl/elasticsearch-analysis-ik



```
cd your-es-root/plugins/ && mkdir ik


// 创建索引
PUT /my_index

# 添加field，设置分词
POST /my_index/_mapping
{
    "properties":
    {
        "content":
        {
            "type": "text",
            "analyzer": "ik_max_word",
            "search_analyzer": "ik_smart"
        }
    }
}

# 查看mapping
{
  "my_index" : {
    "mappings" : {
      "properties" : {
        "content" : {
          "type" : "text",
          "analyzer" : "ik_max_word",
          "search_analyzer" : "ik_smart"
        }
      }
    }
  }
}

# 创建数据
POST /my_index/_create/1
{
  "content" : "美国留给伊拉克的是个烂摊子吗"
}

# 查询
GET /my_index/_search
{
    "query" : { "match" : { "content" : "美国" }},
    "highlight" : {
        "pre_tags" : ["<tag1>", "<tag2>"],
        "post_tags" : ["</tag1>", "</tag2>"],
        "fields" : {
            "content" : {}
        }
    }
}


{
  "took" : 518,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 1,
      "relation" : "eq"
    },
    "max_score" : 0.2876821,
    "hits" : [
      {
        "_index" : "my_index",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 0.2876821,
        "_source" : {
          "content" : "美国留给伊拉克的是个烂摊子吗"
        },
        "highlight" : {
          "content" : [
            "<tag1>美国</tag1>留给伊拉克的是个烂摊子吗"
          ]
        }
      }
    ]
  }
}

```



### 添加 keyword 字段

修改mapping。假设原来只是一个 text 现在要添加keyword

```
"sessionID" : {
		"type" : "text",
}
```



```
PUT /sessioninfo/_mapping
{
  "properties" : {
    "sessionId" : {
      "type" : "text",
      "fields": {
                "keyword": {
                  "type": "keyword",
                  "ignore_above": 256
                }
              }
    }
  }
}
```



## Filter



### query filter 





### bucket filter

和一般的 bucket 是一样的，符合条件的可以加入桶。

```
GET /cars/transactions/_search?search_type=count
{
   "query":{
      "match": {
         "make": "ford"
      }
   },
   "aggs":{
      "recent_sales": {
         "filter": { 
            "range": {
               "sold": {
                  "from": "now-1M"
               }
            }
         },
         "aggs": {
            "average_price":{
               "avg": {
                  "field": "price" 
               }
            }
         }
      }
   }
}
```

为什么不使用两个查询条件呢？多个查询条件之间的关系为或，满足一个，文档就会匹配。当然可以使用设置条件为and解决

使用桶过滤，和查询条件之间是且的关系，先判断是否满足查询条件，然后判断是否符合桶的条件，必须两个都满足才能进入桶。



### post filter

只过滤搜索结果，而不过滤聚合 。

该过滤器会在查询执行完毕后生效,正因为它在查询执行后才会运行，所以它并不会影响查询作用域 ,因此就不会对聚合有所影响。

我们可以利用这一行为在搜索条件中添加额外的过滤器。

下面的聚合按颜色对 ford 类型的进行聚合，满足条件的是各种颜色的 ford

```
GET /cars/transactions/_search?search_type=count
{
    "query": {
        "match": {
            "make": "ford"
        }
    },    
    "aggs" : {
        "all_colors": {
            "terms" : { "field" : "color" }
        }
    }
}
```

如果需要找出绿色的ford，但同时要保留聚合结果，可以使用 post_filter

```
GET /cars/transactions/_search?search_type=count
{
    "query": {
        "match": {
            "make": "ford"
        }
    },
    "post_filter": {    
        "term" : {
            "color" : "green"
        }
    },
    "aggs" : {
        "all_colors": {
            "terms" : { "field" : "color" }
        }
    }
}
```



只有当你需要对搜索结果和聚合使用不同的过滤方式时才考虑使用post_filter。有时一些用户会直接在常规搜索中使用post_filter。

不要这样做！post_filter会在查询之后才会被执行，因此会失去过滤在性能上帮助(比如缓存)。

post_filter应该只和聚合一起使用，并且仅当你使用了不同的过滤条件时。


## 部署



### 安装 elastic

1. 解压 elasticsearch-7.13.2-linux-x86_64.tar.gz

2. 修改  $ES_HOME/config/elasticsearch.yml

   ```
   # elasticsearch.yml
   
   network.host: 0.0.0.0
   xpack.security.enabled: true
   xpack.security.transport.ssl.enabled: true
   cluster.initial_master_nodes: ["node-1"]
   ```

3. 以非root用户执行  `bin/elasticsearch -d`

4. `bin/elasticsearch-setup-passwords interactive`

   将用户密码设置为 `ASD!asd#123`

5. 这个时候可以通过 http://localhost:9200 访问 elastic,

   账号是 elastic 密码是 ASD!asd#123



### 安装分词器

1. `unzip elasticsearch-analysis-ik-7.13.2.zip`
2. `mv elasticsearch-analysis-ik-7.13.2 ik`
3. `mv ik $ES_HOME/plugins/`



## 并发



由于在 Elasticsearch 中单个文档的增删改都是原子性操作,那么将相关实体数据都存储在同一文档中也就理所当然。 比如说,我们可以将订单及其明细数据存储在一个文档中。



## 段

### 段合并



## Translog





## Refresh



## spring data elasticsearch



```
@Data
@Document(indexName = "t-loginfo")
public class LogESDetailModel implements Serializable {
    @Id
    private String id;
    
    @Field(type = FieldType.Text, name = "content", analyzer = "ik_smart", searchAnalyzer = "ik_smart")
    private String content;
    
    
    @Field(type = FieldType.Text, name = "sessionID")
    // @Field(type = FieldType.Text, name = "sessionID", fielddata = true,ignoreAbove = 256)
    private String sessionID;
}

@Repository
public interface LogInsightESRepository extends ElasticsearchRepository<LogESDetailModel, String> {

}
```



### ignoreAbove 会影响所有类型为 text 的 field，导致 analyzer 设置失败

如果没有 `ignoreAbove = 256` ，项目一启动，Index的mapping里的数据会立即创建，可以通过  `GET /t-loginfo/_mapping `查询到。

但是如果有字段设置了 ,那么mapping 是空的，需要等到数据写入到Index后 mapping 才有数据，不知道为什么。

```
GET /t-sessioninfo/_mapping

{
  "t-sessioninfo" : {
    "mappings" : { }
  }
}

```

上面的问题导致 analyzer = "ik_smart", searchAnalyzer = "ik_smart" 没有生效。![](/Users/wxf/AWorkSpace/Book-AppInsight/server/截屏2021-07-20 14.22.37.png)



### @Mapping

直接在字段上通过 @Field 注解设置mapping 的属性会有各种问题，比如 @Field(ignoreAbove = 256) 等导致Index 的属性没有第一时间生成，要到上传数据时才能确定属性，感觉这个mapping  是动态生成的，而不是自己配置的。

可以通过 @Mapping 从 json 读取，应用一启动，属性就都设置了。 

```
@Mapping(mappingPath = "logMapping.json")

// logMapping.json
{
  "properties" : {
    "@timestamp" : {
      "type" : "long"
    },
    "appIndex" : {
      "type" : "text"
    },
    "appVersion" : {
      "type" : "text"
    },
    "brand" : {
      "type" : "text"
    },
    "content" : {
      "type" : "text",
      "analyzer" : "ik_max_word",
      "search_analyzer" : "ik_smart"
    }
  }  
}
```



Child

```
HasChildQueryBuilder hasChildQueryBuilder = new HasChildQueryBuilder("log",filter, ScoreMode.None);
```









![11625799281_.pic_hd](/Users/wxf/AWorkSpace/Book-AppInsight/server/11625799281_.pic_hd.jpg)











## lucene

FST（Finite State Transducer）有限状态转移机



cat、deep、do、dog、dogs



1. start-> c  -> a -> t->end

2. start-> c  -> a -> t->end

   ​        -> d -> e -> e -> p

   

3. start-> c  -> a -> t->end

   ​        -> d -> e -> e -> p

   ​                -> o 

   







## http 请求数据



```
curl -H 'Content-Type: application/json' -XGET 'http://124.71.70.101:19200/remote-loginfo/_search?pretty' -d '{"from": 0, "size": 200, "query": {"match_all": {"boost": 1.0 } }, "post_filter": {"bool": {"must": [{"range": {"level": {"from": 0, "to": 5, "include_lower": false, "include_upper": true, "boost": 1.0 } } }, {"range": {"@timestamp": {"from": 1634774400000, "to": 1635350399758, "include_lower": true, "include_upper": true, "boost": 1.0 } } } ], "adjust_pure_negative": true, "boost": 1.0 } }, "version": true, "_source": {"includes": ["id", "taskId", "logType", "content", "logTime", "sessionID", "functionName", "file", "line", "tag", "level", "@timestamp"], "excludes": [] }, "sort": [{"@timestamp": {"order": "desc"} }, {"logTime": {"order": "asc"} } ], "aggregations": {"session_group": {"terms": {"field": "sessionID.keyword", "size": 200, "min_doc_count": 1, "shard_min_doc_count": 0, "show_term_doc_count_error": false, "order": [{"_count": "desc"}, {"_key": "asc"} ] }, "aggregations": {"level_group": {"terms": {"field": "level", "size": 10, "min_doc_count": 1, "shard_min_doc_count": 0, "show_term_doc_count_error": false, "order": [{"_count": "desc"}, {"_key": "asc"} ] } } } } }, "highlight": {"fields": {"content": {} } } }' --user 'elastic':'ASD!asd#123' 
```





