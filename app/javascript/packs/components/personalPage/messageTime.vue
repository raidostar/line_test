<template>
  <div class="in-panel">
    <div v-show="loading" class="waiting-screen">
      <div class="spinner">
        <div class="bounce1"></div>
        <div class="bounce2"></div>
        <div class="bounce3"></div>
      </div>
    </div>
    <div>
      <select class="time_option" v-model="timeOption" @change="fetchPersonalMessageData(false)">
        <option value="hourly">時間別</option>
        <option value="wdaily">曜日別</option>
        <option value="daily">日別</option>
        <option value="monthly">月鼈</option>
      </select>
      <span style="float: right;">全体のメッセージ数: {{ total }}件</span>
    </div>
    <div style="margin-bottom: 8vh;">
     <line-chart class="chart" :data="data"/>
   </div>
   <table>
    <tr>
      <th class="title">順位</th>
      <th class="title">時間代</th>
      <th class="title">頻度</th>
      <th class="title">返事確率</th>
    </tr>
    <tr>
      <td>
        <div class="inner-ranking">
          <i class="material-icons ranking-mark" id="first">looks_one</i>位
        </div>
      </td>
      <td class="ranking">{{timeRank[0]}}</td>
      <td class="ranking">{{timeFreqRank[0]}}%</td>
      <td class="ranking">多多</td>
    </tr>
    <tr>
      <td>
        <div class="inner-ranking">
          <i class="material-icons ranking-mark" id="second">looks_two</i>位
        </div>
      </td>
      <td class="ranking">{{timeRank[1]}}</td>
      <td class="ranking">{{timeFreqRank[1]}}%</td>
      <td class="ranking">多</td>
    </tr>
    <tr>
      <td>
        <div class="inner-ranking">
          <i class="material-icons ranking-mark" id="third">looks_3</i>位
        </div>
      </td>
      <td class="ranking">{{timeRank[2]}}</td>
      <td class="ranking">{{timeFreqRank[2]}}%</td>
      <td class="ranking">中</td>
    </tr>
  </table>
</div>
</template>
<script>
  import axios from 'axios'
  export default {
    name: 'time_chart',
    props: {
      // time: Array,
      // timeRank: Array,
      // timeFreqRank: Array
      id: String,
    },
    data: function(){
      return {
        data: [],
        timeOption: 'hourly',
        timeFreqRank: [],
        timeRank: [],
        total: 0,
        loading: true,
      }
    },
    mounted: function(){
      this.fetchPersonalMessageData(false);
    },
    methods: {
      fetchPersonalMessageData(reply_boolean){
        axios.post('api/fetch_personal_message_data',{
          id: this.id,
          reply_boolean: reply_boolean,
          time_option: this.timeOption
        }).then((res)=>{
          this.data = res.data
          this.rankingData(res.data)
        },(error)=>{
          console.log(error)
        })
      },
      rankingData(data){
        this.total = 0
        let list = data[0].data
        this.timeRank = Object.keys(list).sort(function(a,b){return list[b]-list[a]})
        this.timeFreqRank = Object.values(list).sort(function(a,b){return b-a})
        for(var i of this.timeFreqRank){
          this.total += i
        }
        for(let i in this.timeFreqRank){
          this.timeFreqRank[i]=((this.timeFreqRank[i]/this.total)*100).toFixed(1)
        }
        this.loading = false
      },
    }
  }
</script>
<style scoped>
.in-panel {
  height: 100%;
  max-height: 100%;
  overflow: scroll;
}
table td {
  height: 20px;
  padding: 10px 5px;
}
.material-icons {
  font-size: 20px;
}
#first {
  color: #ffcc00;
}
#second {
  color: #aaaaaa;
}
#third {
  color: #CD853F;
}
.time_option {
  display: flex;
  width: 25%;
  background-color: cornflowerblue;
  float: left;
}
.title {
  text-align: center;
}
.ranking {
  text-align: center;
}
.inner-ranking {
  width: fit-content;
  margin: 0 auto;
}
</style>