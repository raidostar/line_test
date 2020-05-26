<template>
  <div>
    <div v-show="loading" class="waiting-screen">
      <div class="spinner">
        <div class="bounce1"></div>
        <div class="bounce2"></div>
        <div class="bounce3"></div>
      </div>
    </div>
    <div class="statistics">
      <select v-model="timeLineOption" @change="fetchMessagesData">
        <option value="oneDay">今日</option>
        <option value="oneWeek">直近一週間</option>
        <option value="oneMonth">直近一ヶ月間</option>
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
    name: 'replyTimeData',
    props: [],
    data: function(){
      return {
        timeLineOption: 'oneDay',
        timeOption: 'hourly',
        timeLineMessages: [],
        timelyMessages: [],
        loading: true,
      }
    },
    mounted: function(){
      this.fetchMessagesData();
    },
    methods: {
      fetchMessagesData(){
        axios.post('/api/fetch_messages_data',{
          reply_boolean: true,
          timeOption: this.timeLineOption
        }).then((res)=>{
          this.timeLineMessages = res.data
          this.fetchMessagesTimeData();
        },(error)=>{
          console.log(error)
        })
      },
      fetchMessagesTimeData(){
        axios.post('/api/fetch_messages_time_data',{
          reply_boolean: true,
          timeOption: this.timeOption
        }).then((res)=>{
          this.timelyMessages = res.data
          this.loading = false
        },(error)=>{
          console.log(error)
        })
      },
    }
  }
</script>
<style scoped src="./dataAnalysis.css"/>