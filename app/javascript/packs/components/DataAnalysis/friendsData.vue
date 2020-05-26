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
      <select v-model="timeLineOption" @change="fetchFollowsData">
        <option value="oneWeek">直近一週間</option>
        <option value="oneMonth">直近一ヶ月間</option>
        <option value="oneYear">今年</option>
      </select>
      <line-chart class="chart" :data="timeLineFollows" :colors="['#212529','#006400','#FF4500']"/>
    </div>
    <div class="statistics">
      <select v-model="timeOption" @change="fetchFollowsTimeData">
        <option value="wdaily">曜日別累積値</option>
        <option value="daily">日別累積値</option>
        <option value="monthly">月別累積値</option>
      </select>
      <column-chart class="chart" :data="timelyFollows" :colors="['#007bff','#006400','#FF4500']"/>
    </div>
  </div>
</template>
<script>
  import axios from 'axios'
  export default {
    name: 'friendData',
    data: function(){
      return {
        timeLineOption: 'oneWeek',
        timeOption: 'wdaily',
        timeLineFollows: [],
        timelyFollows: [],
        loading: true,
      }
    },
    mounted: function(){
      this.fetchFollowsData();
    },
    methods: {
      fetchFollowsData(){
        axios.post('/api/fetch_follows_data',{
          timeOption: this.timeLineOption
        }).then((res)=>{
          this.timeLineFollows = res.data
          this.fetchFollowsTimeData();
        },(error)=>{
          console.log(error)
        })
      },
      fetchFollowsTimeData(){
        axios.post('/api/fetch_follows_time_data',{
          timeOption: this.timeOption
        }).then((res)=>{
          console.log(res.data)
          this.timelyFollows = res.data
          this.loading =false
        },(error)=>{
          console.log(error)
        })
      }
    }
  }
</script>
<style scoped src="./dataAnalysis.css"/>
