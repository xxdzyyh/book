

| 控件描述 | ElementUI | iOS                    |      |
| -------- | --------- | ---------------------- | ---- |
| 弹窗     | el-dialog | UIAlertController      |      |
| 按钮     | el-button | UIButton               |      |
| tab      | el-tabs   | UITabbarViewController |      |
|          |           |                        |      |
|          |           |                        |      |
|          |           |                        |      |
|          |           |                        |      |
|          |           |                        |      |
|          |           |                        |      |



### el-button

```
// 点击的时候，设置visible变量为true
<el-button @click="visible = true">Button</el-button>
<el-button round>圆角按钮</el-button>
<el-button type="success" icon="el-icon-check" circle></el-button>
```

### el-dialog

```
<el-dialog :visible.sync="visible" title="Hello world">      
	<p>Try Element</p>
</el-dialog>
```

### el-link

```
<el-link href="https://element.eleme.io" target="_blank">默认链接</el-link>
<el-link type="primary" disabled>主要链接</el-link>
```

### el-select

```
 <el-table-column label="状态">
  <template slot-scope="scope">
    <el-select v-model="value" v-on:change="jsErrorStatusChanged($event,scope.row)">
      <el-option
        v-for="item in options"
        :key="item.value"
        :label="item.label"
        :value="item.value">
      </el-option>
    </el-select>
  </template>
</el-table-column>

// 选中的item的值，data：附带的菜蔬
jsErrorStatusChanged(index,data) {
  console.log(index)
  console.log(data)
}
```

### el-table

```
 <template>
    <el-table
      :data="tableData"
      style="width: 100%">
      <el-table-column
        prop="date"
        label="日期"
        width="180">
      </el-table-column>
      <el-table-column
        prop="name"
        label="姓名"
        width="180">
      </el-table-column>
      <el-table-column
        prop="address"
        label="地址">
      </el-table-column>
    </el-table>
  </template>

  <script>
    export default {
      data() {
        return {
          tableData: [{
            date: '2016-05-02',
            name: '王小虎',
            address: '上海市普陀区金沙江路 1518 弄'
          }, {
            date: '2016-05-04',
            name: '王小虎',
            address: '上海市普陀区金沙江路 1517 弄'
          }, {
            date: '2016-05-01',
            name: '王小虎',
            address: '上海市普陀区金沙江路 1519 弄'
          }, {
            date: '2016-05-03',
            name: '王小虎',
            address: '上海市普陀区金沙江路 1516 弄'
          }]
        }
      }
    }
  </script>
```



> 数据

```
<template>
  <el-container>
    <el-header>
      <el-button @click="getAppListData">获取数据列表</el-button>
    </el-header>
    <el-main>
      <el-table
      :data="dataSource">
        <el-table-column prop="app_name" label="应用名称">
        </el-table-column>
        <el-table-column prop="lastSessionTime" label="最近会话时间">
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间">
        </el-table-column>
      </el-table>
      <ul v-if="isDataReady">
        <li v-for="value in this.dataSource">
          {{ value }}
        </li>
      </ul>
    </el-main>
  </el-container>
</template>
<script>

import Util from '../common/js/util'

export default {
  name: 'app-tables',
  data() {
    return {
      isDataReady : false,
      dataSource : []
    }
  },
  methods: {
    getAppListData () {
      let uid = localStorage.getItem('USER')
      this.$http.get(window.serverConfig.SERVER + '/app?userId=' + uid).then(res => {
        if (res.body.code === 200) {
          this.dataSource = res.body.data

          for(let i in this.dataSource) {
            let data = this.dataSource[i]
            data.lastSessionTime = data.lastSessionTime === 0?'-':Util.TimeFormat.formatTimestamp(data.lastSessionTime,
              'yyyy-MM-dd HH:mm:ss')
            data.createTime = new Date(data.createTime).toLocaleDateString()
          }

          this.isDataReady = true
        }
      })
    }
  }
}
</script>
<style scoped>
</style>
```





#### 自定义cell

```
<el-table-column
  label="姓名"
  width="180">
  <template slot-scope="scope">
    <el-popover trigger="hover" placement="top">
      <p>姓名: {{ scope.row.name }}</p>
      <p>住址: {{ scope.row.address }}</p>
      <div slot="reference" class="name-wrapper">
        <el-tag size="medium">{{ scope.row.name }}</el-tag>
      </div>
    </el-popover>
  </template>
</el-table-column>
```

