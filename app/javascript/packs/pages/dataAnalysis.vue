<template>
  <div class="page" id="page5">
    <div class="service-add big-panel" >
      <div class="panel">
        <div class="top-panel">
          <div>
            <button class="friend_analysis_selected" to="/friendslist" v-if="baseNum==0">日時別友だち数</button>
            <button class="friend_analysis" to="/friendslist" v-else @click="loadPage(0)">日時別友だち数</button>

            <button class="friend_analysis_selected" to="/friendslist" v-if="baseNum==1">日時別メッセージ</button>
            <button class="friend_analysis" to="/friendslist" v-else @click="loadPage(1)">日時別メッセージ</button>

            <button class="friend_analysis_selected" to="/friendslist" v-if="baseNum==2">タイプ別メッセージ</button>
            <button class="friend_analysis" to="/friendslist" v-else @click="loadPage(2)">タイプ別メッセージ</button>

            <button class="friend_analysis_selected" to="/friendslist" v-if="baseNum==3">日時別リプライ</button>
            <button class="friend_analysis" to="/friendslist" v-else @click="loadPage(3)">日時別リプライ</button>

            <button class="friend_analysis_selected" to="/friendslist" v-if="baseNum==4">タイプ別リプライ</button>
            <button class="friend_analysis" to="/friendslist" v-else @click="loadPage(4)">タイプ別リプライ</button>
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
  import friendsData from '../components/DataAnalysis/friendsData.vue'
  import messageTimeData from '../components/DataAnalysis/messageTimeData.vue'
  import messageTypeData from '../components/DataAnalysis/messageTypeData.vue'
  import replyTimeData from '../components/DataAnalysis/replyTimeData.vue'
  import replyTypeData from '../components/DataAnalysis/replyTypeData.vue'
  export default {
    name: 'analysis',
    props: {
      dataType: String
    },
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
      this.accessCheck();
    },
    methods: {
      accessCheck(){
        this.loading = true
        axios.post('/api/show_current').then((res)=>{
          var status = res.data.user.status
          var admit = res.data.user.admit
          if((status=='client'||status=='master')&&!admit){
            alert("このページの接続権限がありません。\nCSD事業部に問い合わせてください。")
            axios.delete('users/sign_out').then((res)=>{
              location.href = '/';
            },(error)=>{
              console.log(error)
            })
          } else {
            this.fetchChannels();
          }
        },(error)=>{
          console.log(error)
        })
      },
      fetchChannels(){
        axios.post('/api/fetch_channels').then((res)=>{
          if(res.data==null){
            alert("まず、チャンネルを登録してご利用ください。");
            location.href = "/channelManage"
          } else {
            this.fetchData();
          }
        },(error)=>{
          console.log(error)
        })
      },
      fetchData(){
        if(this.dataType.length==0){
          alert("come????")
          this.loadPage(0)
        } else {
          switch(this.dataType){
            case 'friendsData':
              this.loadPage(0)
            break
            case 'messageTimeData':
              this.loadPage(1)
            break
            case 'replyTimeData':
              this.loadPage(3)
            break
          }
        }
      },
      formToggle(){
        this.formShow = !this.formShow
      },
      loadPage(index){
        this.baseNum = index
      },
    }
  }
</script>
<style scoped src="../components/DataAnalysis/dataAnalysis.css"/>
