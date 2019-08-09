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
          <td class="text-center">
            <b>113170</b>
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
            <tbody v-for="time in times">
              <tr>
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
        blockList: []
      }
    },
    mounted: function(){
      this.fetchFriends();
      this.getTime();
    },
    methods: {
      getTime(){
        let date = new Date();
        this.month = date.getMonth();
      },
      fetchFriends(){
        axios.get('/api/friends').then((res) => {
          console.log(res.data.friends)
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
      }
    }
  }
</script>

<style scoped>
.title {
  float: left;
}
hr {
  margin: 10px;
}
.status {
  border: 1px grey;
  border-top: 2px solid grey;
  margin-bottom: 3em;
  background-color: #EFF2FB;
}
.status th {
  padding: 5px;
  margin: 0;
  height: 10px;
  width: auto;
  background-color: #E0E0F8;
}
td {
  border: 2px  grey;
  width: 50%;
}
.message td {
  padding: 5px;
  margin: 0;
  height: 10px;
}
b {
  font-size: 30px;
}
.col-left {
  width: 65%;
  margin-left: 10px;
  margin-right: 0px;
  padding-right: 0px;
  float: left;
}
.panel-left {
  width: 33%;
  border: 1px grey;
  border-top: 2px solid grey;
  padding: 1px;
  margin: 1px;
  float: left;
}
.panel-right {
  width: 33%;
  border: 1px grey;
  border-top: 2px solid grey;
  padding: 1px;
  margin: 1px;
  float: right;
  margin-top: 8px;
  margin-right: 4px;
}
.panel-heading {
  font-weight: 700;
  min-height: 100%;
  text-align: center;
  line-height: 3.5;
  background-color: #E0E0F8;
}
.list-group button {
  color: #00B900;
  background-color: white;
  height: 53px;
  max-height: 100%;
  background-color: #EFF2FB;
  padding: 1px;
  margin: 1px;
  border: 1px grey;
}
.list-group button:hover {
  background-color: #E9E9FB;
}
.label {
  font-size: 10px;
  font-weight: 600;
  border-radius: 5px;
  padding: 3px;
  margin: 3px;
}
.label-danger {
  background-color: #d9534f;
  color: white;
}
.label-primary {
  background-color: #337ab7;
  color: white;
}
.label-info {
  background-color: #5bc0de;
  color: white;
}
.label-default {
  background-color: #777;
  color: white;
}
.friend {
  float: right;
  width: 65%;
  text-align: center;
}
.friend td{
  padding: 1px 5px;
}
.sub-title {
  font-weight: 700;
  border-top: 2px solid grey;
  background-color: #E0E0F8;
  min-height: 100%;
  line-height: 3.5;
}
.date {
  width: 20%;
}
.change {
  width: 13%;
}
.joinNum {
  width: 20%;
}
.joinNum button {
  padding-left: 5px;
  background-color: white;
  border: 1px solid grey;
  border-radius: 5%;
  color: grey;
  font-size: 10px;
}
.blockNum {
  width: 26%;
}
.frNum {
  text-align: center;
}
</style>
