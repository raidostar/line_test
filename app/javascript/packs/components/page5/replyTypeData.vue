<template>
  <div>
    <div class="pie-chart">
      <div class="div-left">
        <pie-chart class="chart" :data="messageType" :colors="['#007bff','#dc3545','#fd7e14','#28a745','#6f42c1']" :donut="true"/>
        <p style="text-align: center; color: grey; margin: 20px auto;"> メッセージタイプ別データ </p>
      </div>
      <div class="div-right">
        <table class="table">
          <tr>
            <th>順位</th>
            <th>タイプ</th>
            <th>メッセージ値</th>
            <th>頻度</th>
          </tr>
          <tr v-model="firstType">
            <td><i class="material-icons" id="first">looks_one</i>位</td>
            <td>{{firstType[0]}}</td>
            <td>{{firstType[1]}}件</td>
            <td v-model="messageTotal">{{((firstType[1] / messageTotal)*100).toFixed(2)}}%</td>
          </tr>
          <tr v-model="secondType">
            <td><i class="material-icons" id="second">looks_two</i>位</td>
            <td>{{secondType[0]}}</td>
            <td>{{secondType[1]}}件</td>
            <td v-model="messageTotal">{{((secondType[1] / messageTotal)*100).toFixed(2)}}%</td>
          </tr>
          <tr v-model="thirdType">
            <td><i class="material-icons" id="third">looks_3</i>位</td>
            <td>{{thirdType[0]}}</td>
            <td>{{thirdType[1]}}件</td>
            <td v-model="messageTotal">{{((thirdType[1] / messageTotal)*100).toFixed(2)}}%</td>
          </tr>
        </table>
      </div>
    </div>
  </div>
</template>
<script>
  import axios from 'axios'
  export default {
    name: 'messageTypeData',
    props: [],
    data: function(){
      return {
        messageType: [],
        checkStatus: [],
        firstType: [],
        secondType: [],
        thirdType: [],
        messageTotal: 0,
      }
    },
    mounted: function(){
      this.fetchMessageTypeData();
    },
    methods: {
      fetchMessageTypeData(){
        axios.post('api/fetch_message_type_data',{
          reply_boolean: true
        }).then((res)=>{
          console.log(res.data)
          this.messageType = res.data
          this.firstType = res.data[0]
          this.secondType = res.data[1]
          this.thirdType = res.data[2]
          let sum = 0
          for(var msg of res.data){
            sum += msg[1]
          }
          this.messageTotal = sum
        },(error)=>{
          console.log(error)
        })
      },
    }
  }
</script>
<style scoped src="./page5.css"/>
