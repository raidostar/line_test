<template>
  <div class="page" id="page5">
    <div>
      <div class="title area">
        <h2 class="title">データ分析<hr/></h2>
      </div>
    </div>
    <div class="service-add big-panel" >
      <div class="panel">
        <div class="top-panel">
          <div>
            <button class="friend_analysis" to="/friendslist" @click="loadPage(0)">友だち時間データ</button>
            <button class="friend_analysis" to="/friendslist" @click="loadPage(1)">メッセージ時間データ</button>
            <button class="friend_analysis" to="/friendslist" @click="loadPage(2)">メッセージタイプデータ</button>
            <button class="friend_analysis" to="/friendslist" @click="loadPage(3)">返事時間データ</button>
            <button class="friend_analysis" to="/friendslist" @click="loadPage(4)">返事タイプデータ</button>
          </div>
        </div>
        <div class="bottom-panel">
          <friendsData v-if="baseNum==0"/>
          <messageTimeData v-if="baseNum==1"/>
          <messageTypeData v-if="baseNum==2"/>
          <replyTimeData v-if="baseNum==3"/>
          <replyTypeData v-if="baseNum==4"/>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import axios from 'axios'
  import friendsData from '../components/page5/friendsData.vue'
  import messageTimeData from '../components/page5/messageTimeData.vue'
  import messageTypeData from '../components/page5/messageTypeData.vue'
  import replyTimeData from '../components/page5/replyTimeData.vue'
  import replyTypeData from '../components/page5/replyTypeData.vue'
  export default {
    name: 'analysis',
    components: {
      friendsData,
      messageTimeData,
      messageTypeData,
      replyTimeData,
      replyTypeData
    },
    data: function(){
      return {
        formShow: false,
        baseNum: 0,
      }
    },
    mounted: function(){
    },
    methods: {
      formToggle(){
        this.formShow = !this.formShow
      },
      loadPage(index){
        this.baseNum = index
      },
    }
  }
</script>
<style scoped src="../components/page5/page5.css"/>
