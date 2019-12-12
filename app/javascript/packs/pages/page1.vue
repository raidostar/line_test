<template>
  <div class="page">
    <div class="col-left">
      <table class="status">
        <tr>
          <th>有効友だち数</th>
          <th>ブロック/友だち解除数</th>
        </tr>
        <tr>
          <td class="text-center">
            <b>{{ unblockList.length }}</b>
            <small>名</small>
          </td>
          <td class="text-center">
            <b>{{ blockList.length }}</b>
            <small>名</small>
          </td>
        </tr>
      </table>

      <table class="status message">
        <tr>
          <th>{{ month }} 月のメッセージ送信数</th>
          <th>今週のメッセージ送信数</th>
          <th>本日のメッセージ送信数</th>
        </tr>
        <tr>
          <td class="text-center">
            <b v-model="monthlyNum">{{monthlyNum}}</b>
            <small>通</small>
          </td>
          <td class="text-center">
            <b v-model="weeklyNum">{{weeklyNum}}</b>
            <small>通</small>
          </td>
          <td class="text-center">
            <b v-model="dailyNum">{{dailyNum}}</b>
            <small>通</small>
          </td>
        </tr>
      </table>

      <div>
        <div class="panel-left">
          <div class="panel-heading">現在のマーク別人数</div>
          <div class="list-group">
            <router-link class="status-button" :to="unchecked">
              <span class="label label-danger">未確認</span>
              <span class="msg-number" v-model="messages">{{ messages.unchecked }}件</span>
            </router-link>
            <router-link class="status-button" :to="unreplied">
              <span class="label label-primary">未対応</span>
              <span class="msg-number" v-model="messages">{{ messages.unreplied }}件</span>
            </router-link>
            <router-link class="status-button" :to="autoReplied">
              <span class="label label-answer">自動応答</span>
              <span class="msg-number" v-model="messages">{{ messages.auto_replied }}件</span>
            </router-link>
            <router-link class="status-button" :to="replied">
              <span class="label label-answer">直接応答</span>
              <span class="msg-number" v-model="messages">{{ messages.replied }}件</span>
            </router-link>
            <router-link class="status-button" :to="checked">
              <span class="label label-default">確認完了</span>
              <span class="msg-number" v-model="messages">{{ messages.checked }}件</span>
            </router-link>
          </div>
        </div>
        <div >
          <div class="friend sub-title">友だち数遷移</div>
          <table class="friend">
            <thead>
              <tr>
                <th class="date">日付</th>
                <th class="change">前日比</th>
                <th class="followNum">登録数</th>
                <th class="blockNum">ブロックされた数</th>
                <th class="friendsNum">有効友だち数</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="data in weeklyData">
                <td class="date text-center" style="height: 35px;">{{data.date}}</td>
                <td class="change text-center" id="gap" v-if="data.gap<0" style="color: red;">{{data.gap}}</td>
                <td class="change text-center" id="gap" v-else style="color: green;">{{data.gap}}</td>
                <td class="followNum text-center">{{data.add}}名</td>
                <td class="blockNum text-center">{{data.block}}名</td>
                <td class="friendsNum text-center">名</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <div class="col-right">
      <div>
        <div class="panel-right">
          <div class="statistics" v-model="timeLineOption">
            <line-chart class="chart" :data="timeLineFollows" :colors="['#212529','#006400','#FF4500']" style="height: 30vh;"/>
          </div>
          <div class="statistics" v-model="timeLineOption">
            <line-chart class="chart" :data="timeLineMessages" :colors="['#007bff']" style="height: 30vh;"/>
          </div>
          <div class="statistics" v-model="timeLineOption">
            <line-chart class="chart" :data="timeLineReplies" :colors="['#dc3545']" style="height: 30vh;"/>
          </div>
        </div>
      </div>
    </div>
    <div v-show="loading" class="waiting-screen">
      <div class="spinner">
        <div class="bounce1"></div>
        <div class="bounce2"></div>
        <div class="bounce3"></div>
      </div>
    </div>
  </div>
</template>

<script>
  import axios from 'axios'
  export default {
    name: 'MainPage',
    data: function(){
      return{
        month: null,
        times: [],
        unblockList: [],
        blockList: [],
        monthlyNum: 0,
        weeklyNum: 0,
        dailyNum: 0,
        friendsNum: 0,
        addNum: 0,
        blockNum: 0,
        friends: [],
        dayType: ['日','月','火','水','木','金','土',],
        weeklyData: [],
        messages: {},
        loading: true,
        unchecked: '/allMessages/unchecked',
        unreplied: '/allMessages/unreplied',
        checked: '/allMessages/checked',
        replied: '/allMessages/replied',
        autoReplied: '/allMessages/autoReplied',
        timeLineOption: 'oneWeek',
        timeLineFollows: [],
        timeLineMessages: [],
        timeLineReplies: [],
      }
    },
    mounted: function(){
      this.fetchMessages();
      this.fetchFriends();
      this.getTime();
      this.timelyMessages();
      this.weekly_data();
      this.$nextTick(function(){
        this.fetchFollowsData();
        this.fetchMessagesData();
        this.fetchRepliesData();
      })
    },
    methods: {
      fetchFollowsData(){
        axios.post('api/fetch_follows_data',{
          timeOption: this.timeLineOption
        }).then((res)=>{
          // console.log(res.data)
          this.timeLineFollows = res.data
        },(error)=>{
          console.log(error)
        })
      },
      fetchMessagesData(){
        axios.post('api/fetch_messages_data',{
          reply_boolean: false,
          timeOption: this.timeLineOption
        }).then((res)=>{
          //console.log(res.data)
          this.timeLineMessages = res.data
        },(error)=>{
          console.log(error)
        })
      },
      fetchRepliesData(){
        axios.post('api/fetch_messages_data',{
          reply_boolean: true,
          timeOption: this.timeLineOption
        }).then((res)=>{
          //console.log(res.data)
          this.timeLineReplies = res.data
        },(error)=>{
          console.log(error)
        })
      },
      timelyMessages(){
        this.loading = true
        axios.post('api/timely_messages').then((res)=>{
          this.dailyNum = res.data.daily
          this.weeklyNum = res.data.weekly
          this.monthlyNum = res.data.monthly
          this.loading = false
        },(error)=>{
          console.log(error)
        })
      },
      getTime(){
        let date = new Date();
        this.month = date.getMonth()+1;
        // console.log(date.getYear())
        // console.log(date.getMonth())
        // console.log(date.getDate())
        // console.log(date.getDay())
      },
      fetchFriends(){
        this.loading = true
        axios.get('/api/friends').then((res) => {
          // console.log("friends")
          // console.log(res.data.friends)
          this.friendsNum = res.data.friends.length
          for (let friend of res.data.friends){
            if(friend.block==0){
              this.unblockList.push(friend)
            } else {
              this.blockList.push(friend)
            }
          }
          this.loading = false
        }, (error) => {
          console.log(error)
        })
      },
      weekly_data(){
        this.loading = true
        axios.post('/weekly_friend_info').then((res)=>{
          for(let d of res.data){
            d.date = d.date.replace("-", "月");
            d.date = d.date.replace("-", "日");
            let dayNum = d.date.substr(-1)*1
            d.date=d.date.substr(0,d.date.length-1);
            d.date=d.date+'('+this.dayType[dayNum]+')'
          }
          //console.log(res.data)
          this.weeklyData = res.data
          this.loading = false
        },(error)=>{
          console.log(error)
        })
      },
      fetchMessages(){
        this.loading = true
        axios.post('api/fetch_message_check_data',{
          reply_boolean: false
        }).then((res)=>{
          for(var msg of res.data){
            this.messages[msg[0]] = msg[1]
          }
          // console.log(this.messages)
          this.loading = false
        },(error)=>{
          console.log(error)
        })
      },
    }
  }
</script>

<style scoped src="../components/page1/page1.css"/>
