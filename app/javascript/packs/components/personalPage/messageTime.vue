<template>
  <div class="in-panel">
    <!-- <line-chart class="chart" :data="time"/>
     <table>
      <tr>
        <th>順位</th>
        <th>時間代</th>
        <th>頻度</th>
        <th>返事確率</th>
      </tr>
      <tr>
        <td><i class="material-icons" id="first">looks_one</i>位</td>
        <td>{{timeRank[0]}}</td>
        <td>{{timeFreqRank[0]}}%</td>
        <td>多多</td>
      </tr>
      <tr>
        <td><i class="material-icons" id="second">looks_two</i>位</td>
        <td>{{timeRank[1]}}</td>
        <td>{{timeFreqRank[1]}}%</td>
        <td>多</td>
      </tr>
      <tr>
        <td><i class="material-icons" id="third">looks_3</i>位</td>
        <td>{{timeRank[2]}}</td>
        <td>{{timeFreqRank[2]}}%</td>
        <td>中</td>
      </tr>
    </table> -->
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
        timeOption: 'hourly',
      }
    },
    mounted: function(){
      alert(this.id)
      this.fetchPersonalMessageData(false);
    },
    methods: {
      fetchPersonalMessageData(reply_boolean){
        console.log(reply_boolean)
        axios.post('api/fetch_personal_message_data',{
          id: this.id,
          reply_boolean: reply_boolean,
          time_option: this.timeOption
        }).then((res)=>{
          console.log(res.data)
        },(error)=>{
          console.log(error)
        })
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
</style>