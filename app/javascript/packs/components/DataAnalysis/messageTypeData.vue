<template>
  <div>
    <div v-show="loading" class="waiting-screen">
      <div class="spinner">
        <div class="bounce1"></div>
        <div class="bounce2"></div>
        <div class="bounce3"></div>
      </div>
    </div>
    <div class="pie-chart">
      <div class="div-left">
        <pie-chart class="chart" :data="messageType" :colors="['#006400','#212529']" :donut="true"/>
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
        </table>
      </div>
    </div>
    <hr/>
    <div class="pie-chart">
      <div class="div-left">
        <pie-chart class="chart" :data="checkStatus" :colors="['#007bff','#dc3545','#fd7e14','#28a745','#6f42c1']" :donut="true"/>
        <p style="text-align: center; color: grey; margin: 20px auto;"> メッセージ状態別データ </p>
      </div>
      <div class="div-right">
        <table class="table">
          <tr>
            <th>順位</th>
            <th>状態</th>
            <th>メッセージ値</th>
            <th>頻度</th>
          </tr>
          <tr v-model="firstCheck">
            <td><i class="material-icons" id="first">looks_one</i>位</td>
            <td>{{firstCheck[0]}}</td>
            <td>{{firstCheck[1]}}件</td>
            <td v-model="messageTotal">{{((firstCheck[1] / messageTotal)*100).toFixed(2)}}%</td>
          </tr>
          <tr v-model="secondCheck">
            <td><i class="material-icons" id="second">looks_two</i>位</td>
            <td>{{secondCheck[0]}}</td>
            <td>{{secondCheck[1]}}件</td>
            <td v-model="messageTotal">{{((secondCheck[1] / messageTotal)*100).toFixed(2)}}%</td>
          </tr>
          <tr v-model="thirdCheck">
            <td><i class="material-icons" id="third">looks_3</i>位</td>
            <td>{{thirdCheck[0]}}</td>
            <td>{{thirdCheck[1]}}件</td>
            <td v-model="messageTotal">{{((thirdCheck[1] / messageTotal)*100).toFixed(2)}}%</td>
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
        firstCheck: [],
        secondCheck: [],
        thirdCheck: [],
        messageTotal: 0,
        loading: true,
      }
    },
    mounted: function(){
      this.fetchMessageTypeData();
    },
    methods: {
      fetchMessageTypeData(){
        axios.post('api/fetch_message_type_data',{
          reply_boolean: false
        }).then((res)=>{
          //console.log(res.data)
          this.messageType = res.data
          this.firstType = res.data[0]
          this.secondType = res.data[1]
          let sum = 0
          for(var msg of res.data){
            sum += msg[1]
          }
          this.messageTotal = sum
          this.fetchMessageCheckData();
        },(error)=>{
          console.log(error)
        })
      },
      fetchMessageCheckData(){
        axios.post('api/fetch_message_check_data',{
          reply_boolean: false
        }).then((res)=>{
          for(var msg of res.data){
            if(msg[0]=="checked"){
              msg[0] = "確認完了"
            } else if(msg[0]=="unchecked"){
              msg[0] = "未確認"
            } else if(msg[0]=="auto_replied"){
              msg[0] = "自動応答"
            } else if(msg[0]=="replied"){
              msg[0] = "直接応答"
            } else if(msg[0]=="unreplied"){
              msg[0] = "未対応"
            }
          }
          this.checkStatus = res.data
          this.firstCheck = res.data[0]
          this.secondCheck = res.data[1]
          this.thirdCheck = res.data[2]
          this.loading = false
        },(error)=>{
          console.log(error)
        })
      },
    }
  }
</script>
<style scoped src="./dataAnalysis.css"/>
