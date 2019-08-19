<template>
  <div class="page">
    <div class="col-left">
      <h2 class="title">{{ title }}<hr/></h2>

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
          <td class="text-center" style="width: auto;">
            <b v-model="monthlyNum">{{monthlyNum}}</b>
            <small>通</small>
          </td>
          <td class="text-center" style="width: auto;">
            <b v-model="weeklyNum">{{weeklyNum}}</b>
            <small>通</small>
          </td>
          <td class="text-center" style="width: auto;">
            <b v-model="dailyNum">{{dailyNum}}</b>
            <small>通</small>
          </td>
        </tr>
      </table>

      <div>
        <div class="panel-left">
          <div class="panel-heading">現在のマーク別人数</div>
          <div class="list-group">
            <button>
              <span class="label label-danger">要対応（クロージング...)</span>
            </button>
            <button>
              <span class="label label-primary">未返信（重要度低）</span>
            </button>
            <button>
              <span class="label label-primary">未返信（マガジンコメ...)</span>
            </button>
            <button>
              <span class="label label-info">未確認</span>
            </button>
            <button>
              <span class="label label-default">確認済み</span>
            </button>
          </div>
        </div>
        <div >
          <div class="friend sub-title">友だち数遷移</div>
          <table class="friend">
            <thead>
              <tr>
                <th class="date text-center">日付</th>
                <th class="change text-center">前日比</th>
                <th class="joinNum text-center">登録数</th>
                <th class="blockNum text-center">ブロックされた数</th>
                <th class="text-center">有効友だち数</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="time in times">
                <td class="date text-center">{{ time }}</td>
                <td class="change text-center">+100</td>
                <td class="joinNum text-center">147 <button>リスト</button></td>
                <td class="blockNum text-center">37</td>
                <td class="text-center">12471</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <div class="col-right">
      <div>
        <h2>最新情報</h2>
        <hr/>
        <div class="panel-right">
          <div class="panel-heading">LINE_MANAGERのお知らせ</div>
          <div class="list-group">
            <button>
              <span class="label label-danger">お知らせ２</span>
            </button>
            <button>
              <span class="label label-primary">お知らせ３</span>
            </button>
            <button>
              <span class="label label-primary">お知らせ４</span>
            </button>
            <button>
              <span class="label label-info">お知らせ５</span>
            </button>
            <button>
              <span class="label label-default">お知らせ６</span>
            </button>
            <button>
              <span class="label label-danger">お知らせ７</span>
            </button>
            <button>
              <span class="label label-primary">お知らせ８</span>
            </button>
            <button>
              <span class="label label-primary">お知らせ９</span>
            </button>
            <button>
              <span class="label label-info">お知らせ１０</span>
            </button>
            <button>
              <span class="label label-default">お知らせ１１</span>
            </button>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
  import axios from 'axios'
  export default {
    name: 'global_footer',
    data: function(){
      return{
        title: 'ホーム',
        month: null,
        times: [],
        unblockList: [],
        blockList: [],
        monthlyNum: 0,
        weeklyNum: 0,
        dailyNum: 0,
      }
    },
    mounted: function(){
      this.fetchFriends();
      this.getTime();
      this.getThisMonth();
      this.getThisWeek();
      this.getToday();
      this.getSevenDays();
    },
    methods: {
      getTime(){
        let date = new Date();
        this.month = date.getMonth()+1;
      },
      fetchFriends(){
        axios.get('/api/friends').then((res) => {
          for (let friend of res.data.friends){
            if(friend.block==0){
              this.unblockList.push(friend)
            } else {
              this.blockList.push(friend)
            }
          }
        }, (error) => {
          console.log(error)
        })
      },
      getThisMonth(){
        axios.post('/number_of_monthly').then((res)=>{
          this.monthlyNum = res.data.messages.length
          //console.log(res.data.messages)
          // for(let message of res.data.messages){
          //   console.log(message.created_at)
          // }
        }, (error)=>{
          console.log(error)
        })
      },
      getThisWeek(){
        axios.post('/number_of_weekly').then((res)=>{
          this.weeklyNum = res.data.messages.length
        },(error)=>{
          console.log(error)
        })
      },
      getToday(){
        axios.post('/number_of_daily').then((res)=>{
          this.dailyNum = res.data.messages.length
        },(error)=>{
          console.log(error)
        })
      },
      getSevenDays(){
        axios.post('/number_of_seven_days').then((res)=>{
          console.log(res.data.messages)
        },(error)=>{
          console.log(error)
        })
      },
    }
  }
</script>

<style scoped src="../components/page1/page1.css"/>
