<template>
  <div class="page">
    <div class="col-left">
      <h2 class="title">ホーム<hr/></h2>

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
                <td class="change text-center" id="gap" v-if="data.gap<0" :style="redFont">{{data.gap}}</td>
                <td class="change text-center" id="gap" v-else :style="greenFont">{{data.gap}}</td>

                <td class="followNum text-center">{{data.add}}名</td>
                <td class="blockNum text-center">{{data.block}}名</td>
                <td class="friendsNum text-center"></td>
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
        redFont: {color: 'red'},
        greenFont: {color: 'green'},
      }
    },
    mounted: function(){
      this.fetchFriends();
      this.getTime();
      this.getThisMonth();
      this.getThisWeek();
      this.getToday();
      //this.getAddFriendNum();
      //this.getDateInfo();
      this.weekly_data();
    },
    methods: {
      getTime(){
        let date = new Date();
        this.month = date.getMonth()+1;
      },
      fetchFriends(){
        axios.get('/api/friends').then((res) => {
          console.log("friends")
          console.log(res.data.friends)
          this.friendsNum = res.data.friends.length
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
          //for(let message of res.data.messages){
          //  console.log(message.created_at)
          //}
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
      // getAddFriendNum(){
      //   axios.post('/add_number').then((res)=>{
      //     this.addNum = Object.keys(res.data).length
      //     this.getBlockFriendNum();
      //   },(error)=>{
      //     console.log(error)
      //   })
      // },
      // getBlockFriendNum(){
      //   axios.post('/block_number').then((res)=>{
      //     //console.log(res.data.friends[0].created_at.substr(0,10))************
      //     this.blockNum = Object.keys(res.data).length
      //     this.makeData();
      //   },(error)=>{
      //     console.log(error)
      //   })
      // },
      // makeData(){
      //   let date = new Date
      //   let dayNum = date.getDay();
      //   let datestr = (date.getMonth()+1)+"月"+date.getDate()+"日 ("+this.dayType[dayNum]+")";
      //   this.friends.push({
      //     "date":datestr,
      //     "add":this.addNum,
      //     "block":this.blockNum,
      //     "friendsNum":this.friendsNum
      //   })
      // },
      // getDateInfo(){
      //   axios.post('/week_date').then((res)=>{
      //     console.log(res.data)
      //     for(let date of res.data){
      //       date = date.replace("-", "月");
      //       date = date.replace("-", "日");
      //       let dayNum = date.substr(-1)*1
      //       date=date.substr(0,date.length-1);
      //       date=date+'('+this.dayType[dayNum]+')'
      //       this.dateInfo.push(date)
      //     }
      //     console.log(this.dateInfo)
      //     console.log(this.unblockList.length)
      //   },(error)=>{
      //     console.log(error)
      //   })
      // },
      weekly_data(){
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
        },(error)=>{
          console.log(error)
        })
      },

    }
  }
</script>

<style scoped src="../components/page1/page1.css"/>
