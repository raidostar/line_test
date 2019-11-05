<template>
  <div>
    <div class="statistics">
      <select v-model="timeLineOption" @change="fetchMessagesData">
        <option value="oneDay">今日</option>
        <option value="oneWeek">最近一週間</option>
        <option value="oneMonth">最近一ヶ月間</option>
        <option value="oneYear">今年</option>
      </select>
      <line-chart class="chart" :data="timeLineMessages" :colors="['#007bff']"/>
    </div>
    <div class="statistics">
      <select v-model="timeOption" @change="fetchMessagesTimeData">
        <option value="hourly">時間別累積値</option>
        <option value="wdaily">曜日別累積値</option>
        <option value="daily">日別累積値</option>
        <option value="monthly">月別累積値</option>
      </select>
      <column-chart class="chart" :data="timelyMessages" :colors="['#007bff']"/>
    </div>
  </div>
</template>
<script>
  import axios from 'axios'
  export default {
    name: 'messageTimeData',
    props: [],
    data: function(){
      return {
        timeLineOption: 'oneDay',
        timeOption: 'hourly',
        timeLineMessages: [],
        timelyMessages: [],
      }
    },
    mounted: function(){
      this.fetchMessagesData();
    },
    methods: {
      fetchMessagesData(){
        axios.post('api/fetch_messages_data',{
          reply_boolean: false,
          timeOption: this.timeLineOption
        }).then((res)=>{
          //console.log(res.data)
          this.timeLineMessages = res.data
          this.fetchMessagesTimeData();
        },(error)=>{
          console.log(error)
        })
      },
      fetchMessagesTimeData(){
        axios.post('api/fetch_messages_time_data',{
          reply_boolean: false,
          timeOption: this.timeOption
        }).then((res)=>{
          //console.log(res.data)
          this.timelyMessages = res.data
        },(error)=>{
          console.log(error)
        })
      },
    }
  }
</script>
<style scoped src="./page5.css"/>
