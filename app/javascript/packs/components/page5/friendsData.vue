<template>
  <div>
    <div class="statistics">
      <select v-model="timeLineOption" @change="fetchFollowsData">
        <option value="oneWeek">最近一週間</option>
        <option value="oneMonth">最近一ヶ月間</option>
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
      }
    },
    mounted: function(){
      this.fetchFollowsData();
    },
    methods: {
      fetchFollowsData(){
        axios.post('api/fetch_follows_data',{
          timeOption: this.timeLineOption
        }).then((res)=>{
          //console.log(res.data)
          this.timeLineFollows = res.data
          this.fetchFollowsTimeData();
        },(error)=>{
          console.log(error)
        })
      },
      fetchFollowsTimeData(){
        axios.post('api/fetch_follows_time_data',{
          timeOption: this.timeOption
        }).then((res)=>{
          //console.log(res.data)
          this.timelyFollows = res.data
        },(error)=>{
          //console.log(error)
        })
      }
    }
  }
</script>
<style scoped src="./page5.css"/>
