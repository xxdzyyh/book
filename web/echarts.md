# echarts

```
var option = {
    // option 每个属性是一类组件。
    legend: {...},
    grid: {...},
    tooltip: {...},
    toolbox: {...},
    dataZoom: {...},
    visualMap: {...},
    // 如果有多个同类组件，那么就是个数组。例如这里有三个 X 轴。
    xAxis: [
        // 数组每项表示一个组件实例，用 type 描述“子类型”。
        {type: 'category', ...},
        {type: 'category', ...},
        {type: 'value', ...}
    ],
    yAxis: [{...}, {...}],
    // 这里有多个系列，也是构成一个数组。
    series: [
        // 每个系列，也有 type 描述“子类型”，即“图表类型”。
        {type: 'line', data: [['AA', 332], ['CC', 124], ['FF', 412], ... ]},
        {type: 'line', data: [2231, 1234, 552, ... ]},
        {type: 'line', data: [[4, 51], [8, 12], ... ]}
    }]
};

```

### series

数组，数组里的每个元素代表一种图，可以在一个坐标系里绘制多张图。



### echarts 封装为组件

```
<template>
  <div :id="nodeId" style="height: 400px"></div>
</template>
<script>

import * as echarts from 'echarts/lib/echarts';
import 'echarts/theme/macarons';
import 'echarts/lib/chart/bar';

export default {
  props: {
    nodeId:String,
    yData: {
      type: Array,
      require: true,
      default: function() {
        return [];
      }
    },
    sData: {
      type: Array,
      require: true,
      default: function() {
        return [];
      }
    },
    isVisible: Boolean
  },
  name: 'distribute-bar-chart',
  watch: {
    isVisible: function (newVal,oldVal) {
      if (newVal === true) {
        this.createChartIfNeed()
        this.fillChartIfNeed()
        this.chart.resize()
      }
    }
  },
  data() {
    return {
      chart: null
    }
  },
  created () {
    console.log("created")
  },
  updated () {
    console.log("updated")
  },
  mounted () {
    console.log("mounted")
    this.$nextTick(()=> {
      this.createChartIfNeed()
      this.fillChartIfNeed()
      this.chart.resize()
    })

    let _this = this;
    window.onresize = function() {
      if (_this.chart) {
        _this.chart.resize()
      }
    }
  },
  methods: {
    createChartIfNeed() {
      if (this.chart == null) {
        // let node = this.$el.querySelector("#manufacturerDistributeChart")
        let node = window.document.getElementById(this.nodeId)
        if (node != null) {
          this.chart = echarts.init(node,'walden')
        }
      } else {
        console.log('createChart = ',this.chart)
      }
    },
    fillChartIfNeed() {
      console.log('fill Chart',this.yData,this.sData)
      if (this.chart == null) {
        console.log('fillChart chart is null')
        return
      }
      this.chart.setOption({
        title: {
          text: '',
          subtext: ''
        },
        tooltip: {
          trigger: 'axis',
          axisPointer: {
            type: 'shadow'
          }
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '3%',
          containLabel: true
        },
        xAxis: {
          type: 'value',
        },
        yAxis: {
          type: 'category',
          data: this.yData
        },
        series: [
          {
            type: 'bar',
            data: this.sData
          },
        ]
      })
    }
  }
}
</script>
<style scoped>
</style>
```



创建echart的时候，要保证关联的node已经被加载。

如果echart不显示，可以在浏览器里检查元素，看看canvas是否存在，如果存在，看看width和height是否为0。

如果canvas不存在，那很可能是关联的node没有取到。如果是和el-tabs搭配使用，需要特别注意这一点。上面的isVisible就是用来解决el-tabs中element取不到，导致chart创建失败的问题。

如果width为0，调用chart.resize()试试。