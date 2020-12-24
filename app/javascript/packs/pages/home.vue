<template>
  <div class="page">
    <div v-show="loading" class="waiting-screen">
      <div class="spinner">
        <div class="bounce1"></div>
        <div class="bounce2"></div>
        <div class="bounce3"></div>
      </div>
    </div>
    <!-- <div class="tips" v-show="tipsPage!=tips.length">
      <div class="cover top_cover" :style="topCover"></div>
      <div class="cover left_cover" :style="leftCover"></div>
      <div class="cover bottom_cover" :style="bottomCover"></div>
      <div class="cover right_cover" :style="rightCover"></div>
      <div class="focus_line" :style="focusLineCSS"></div>
      <div class="explanation" :style="explanationCSS">
        <div class="tips_detail">
          <i class="material-icons info_mark">wb_incandescent</i>
          <div class="tips_letter" v-html="tips[tipsPage]"></div>
        </div>
        <div class="page_move">
          <span class="left_move mover" v-if="tipsPage>0" @click="prevTip">戻る</span>
          <span class="right_move mover" @click="nextTip" v-model="nextWord">{{ nextWord }}</span>
        </div>
      </div>
    </div> -->
    <div class="col-left">
      <table class="status">
        <tr>
          <th class="follow-data">全友だち数</th>
          <th class="follow-data">有効友だち数</th>
          <th class="follow-data">ブロック数</th>
        </tr>
        <tr>
          <td class="text-center">
            <b>{{ friendsNum }}</b>
            <small>名</small>
          </td>
          <td class="text-center">
            <b>{{ targetedReaches }}</b>
            <small>名</small>
          </td>
          <td class="text-center">
            <b>{{ blocks }}</b>
            <small>名</small>
          </td>
        </tr>
      </table>
      <table class="status message">
        <tr>
          <th class="message-number">{{ month }} 月のメッセージ送信数</th>
          <th class="message-number">残っている送信数</th>
          <th class="message-number">配信率</th>
        </tr>
        <tr>
          <td class="text-center">
            <b v-model="monthlyNum">{{monthlyNum}}</b>
            <small>通</small>
            /
            <select class="goal" v-model="goal" style="display: inherit;" @change="countingSuccess">
              <option value=1000>1000</option>
              <option value=15000>15000</option>
              <option value=45000>45000</option>
            </select>
            <small>通</small>
          </td>
          <td class="text-center">
            <b>{{ goal - monthlyNum }}</b>
            <small>通</small>
          </td>
          <td class="text-center">
            <b>{{ success }}</b>
            <small>%</small>
          </td>
        </tr>
      </table>

      <div>
        <div class="panel-left">
          <div class="panel-heading">状態別リプライ</div>
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
                <th class="blockNum">ブロック数</th>
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
                <td class="friendsNum text-center">{{ data.current }}名</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <div class="col-right">
      <div>
        <div class="panel-right">
          <a href="/dataAnalysis/friendsData">
            <div class="statistics" v-model="timeLineOption">
              <line-chart class="chart" :data="timeLineFollows" :colors="['#212529','#006400','#FF4500']" style="height: 30vh;"/>
            </div>
          </a>
          <a href="/dataAnalysis/messageTimeData">
            <div class="statistics" v-model="timeLineOption">
              <line-chart class="chart" :data="timeLineMessages" :colors="['#007bff']" style="height: 30vh;"/>
            </div>
          </a>
          <a href="/dataAnalysis/replyTimeData">
            <div class="statistics" v-model="timeLineOption">
              <line-chart class="chart" :data="timeLineReplies" :colors="['#dc3545']" style="height: 30vh;"/>
            </div>
          </a>
        </div>
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
        monthlyNum: 0,
        weeklyNum: 0,
        dailyNum: 0,
        friendsNum: 0,
        targetedReaches: 0,
        blocks: 0,
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
        goal: 1000,
        success: 0,
        topCover: {'height':'8%'},
        bottomCover: {'height':'76%'},
        leftCover: {'width':'15.5%'},
        rightCover: {'width':'29%'},
        focusLineCSS: {'width':'55.6%','height':'16.5%','left':'15.5%','top':'8%'},
        explanationCSS: {'right':'29%','top':'26%','width': '30%','height': '18%'},
        tips: [
          '<p>昨日までの基準で</p><p>友だち数の状況を表示します。</p>',
          '<p>月別のメッセージ配信目標率によって</p><p>残っているメッセージ数と配信率を表示します。</p>',
          '<p>メッセージの状態別の数値が表示されます。</p>',
          '<p>クリックすると状態別のメッセージのリストを</p><p>確認することができます。</p>',
          '<p>一週間の友だちの遷移が表示されます。</p>',
          '<p>日別の統計情報が表示されます。</p>',
          '<p>クリックすると</p><p>データ分析のページに移動します。</p>',
          ],
        tipsPage: 0,
        nextWord: '次へ',
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
            this.updateFollows();
          }
        },(error)=>{
          console.log(error)
        })
      },
      updateFollows(){
        this.loading = true
        axios.post('/api/update_follows').then((res)=>{
          this.friendsNum = res.data.follower
          this.targetedReaches = res.data.targetedReaches
          this.blocks = res.data.blocks
          this.loading = false
          this.fetchMessages();
          this.getTime();
          this.timelyMessages();
          this.weekly_data();
          this.$nextTick(function(){
            this.fetchFollowsData();
            this.fetchMessagesData();
            this.fetchRepliesData();
          })
        },(error)=>{
          console.log(error)
        })
      },
      fetchFollowsData(){
        axios.post('/api/fetch_follows_data',{
          timeOption: this.timeLineOption
        }).then((res)=>{
          this.timeLineFollows = res.data
        },(error)=>{
          console.log(error)
        })
      },
      fetchMessagesData(){
        axios.post('/api/fetch_messages_data',{
          reply_boolean: false,
          timeOption: this.timeLineOption
        }).then((res)=>{
          this.timeLineReplies = res.data
        },(error)=>{
          console.log(error)
        })
      },
      fetchRepliesData(){
        axios.post('/api/fetch_messages_data',{
          reply_boolean: true,
          timeOption: this.timeLineOption
        }).then((res)=>{
          this.timeLineMessages = res.data
        },(error)=>{
          console.log(error)
        })
      },
      timelyMessages(){
        this.loading = true
        axios.post('/api/timely_messages').then((res)=>{
          this.dailyNum = res.data.daily
          this.weeklyNum = res.data.weekly
          this.monthlyNum = res.data.monthly
          this.loading = false
          this.countingSuccess();
        },(error)=>{
          console.log(error)
        })
      },
      getTime(){
        let date = new Date();
        this.month = date.getMonth()+1;
      },
      weekly_data(){
        this.loading = true
        axios.post('/api/weekly_friend_info').then((res)=>{
          for(let d of res.data){
            d.date = d.date.replace("-", "/");
            d.date = d.date.replace("-", " ");
            let dayNum = d.date.substr(-1)*1
            d.date=d.date.substr(0,d.date.length-1);
            d.date=d.date+'('+this.dayType[dayNum]+')'
          }
          this.weeklyData = res.data
          this.loading = false
        },(error)=>{
          console.log(error)
        })
      },
      fetchMessages(){
        this.loading = true
        axios.post('/api/fetch_message_check_data',{
          reply_boolean: false
        }).then((res)=>{
          for(var msg of res.data){
            this.messages[msg[0]] = msg[1]
          }
          this.loading = false
        },(error)=>{
          console.log(error)
        })
      },
      countingSuccess(){
        var percent = this.monthlyNum / this.goal * 10000
        percent = Math.round(percent)
        this.success = percent / 100
      },
      nextTip(){
        this.tipsPage = this.tipsPage + 1
        this.tipsChecker(this.tipsPage)
      },
      prevTip(){
        this.tipsPage = this.tipsPage - 1
        this.tipsChecker(this.tipsPage)
      },
      tipsChecker(page){
        switch(page){
          case 0:
          this.topCover = {'height':'8%'}
          this.bottomCover = {'height':'76%'}
          this.leftCover = {'width':'15.5%'}
          this.rightCover = {'width':'29%'}
          this.focusLineCSS = {'width':'55.6%','height':'16.5%','left':'15.5%','top':'8%'}
          this.explanationCSS = {'right':'29%','top':'26%','width': '30%','height': '18%'}
          break;
          case 1:
          this.topCover = {'height':'30%'}
          this.bottomCover = {'height':'57%'}
          this.leftCover = {'width':'15.7%'}
          this.rightCover = {'width':'29.2%'}
          this.focusLineCSS = {'width':'55.%','height':'13.5%','left':'15.7%','top':'29.8%'}
          this.explanationCSS = {'right':'29%','top':'44%','width': '30%','height': '18%'}
          break;
          case 2:
          this.topCover = {'height':'49%'}
          this.bottomCover = {'height':'3.5%'}
          this.leftCover = {'width':'15.7%'}
          this.rightCover = {'width':'65.7%'}
          this.focusLineCSS = {'width':'18.6%','height':'47.5%','left':'15.7%','top':'48.8%'}
          this.explanationCSS = {'right':'34%','top':'49%','width': '30%','height': '18%'}
          break;
          case 3:
          this.topCover = {'height':'49%'}
          this.bottomCover = {'height':'3.5%'}
          this.leftCover = {'width':'15.7%'}
          this.rightCover = {'width':'65.7%'}
          this.focusLineCSS = {'width':'18.6%','height':'47.5%','left':'15.7%','top':'48.8%'}
          this.explanationCSS = {'right':'34%','top':'49%','width': '30%','height': '18%'}
          break;
          case 4:
          this.topCover = {'height':'49%'}
          this.bottomCover = {'height':'0%'}
          this.leftCover = {'width':'34.7%'}
          this.rightCover = {'width':'28.7%'}
          this.focusLineCSS = {'width':'36.6%','height':'51%','left':'34.7%','top':'48.8%'}
          this.explanationCSS = {'right':'1%','top':'30%','width': '30%','height': '18%'}
          break;
          case 5:
          this.topCover = {'height':'7.5%'}
          this.bottomCover = {'height':'0%'}
          this.leftCover = {'width':'71.2%'}
          this.rightCover = {'width':'0%'}
          this.focusLineCSS = {'width':'28.6%','height':'92%','left':'71.3%','top':'7.7%'}
          this.explanationCSS = {'right':'29%','top':'8%','width': '30%','height': '18%'}
          break;
          case 6:
          this.topCover = {'height':'7.5%'}
          this.bottomCover = {'height':'0%'}
          this.leftCover = {'width':'71.2%'}
          this.rightCover = {'width':'0%'}
          this.focusLineCSS = {'width':'28.6%','height':'92%','left':'71.3%','top':'7.7%'}
          this.explanationCSS = {'right':'29%','top':'8%','width': '30%','height': '18%'}
          break;
        }
        if(page==this.tips.length-1){
          this.nextWord = '完了'
        }
      },
    }
  }
</script>

<style scoped src="../components/Home/home.css"/>
