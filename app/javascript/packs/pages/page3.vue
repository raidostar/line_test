<template>
  <div class="page" id="page3">
    <div>
      <div>
        <h2 class="title">トーク一覧<hr/></h2>
        <i @click="fetchMessage" class="material-icons">loop</i><br/>
        <div class="setting">
          <select v-model="parPage" @change="resetPage">
            <option value=5>5ラインで表示</option>
            <option value=10>10ラインで表示</option>
            <option value=50>50ラインで表示</option>
            <option value=100>100ラインで表示</option>
            <option value=500>500ラインで表示</option>
            <option :value="messageList.length">全体表示</option>
          </select>
        </div>
      </div>
    </div>
    <table class="msgList">
      <tr>
        <th>送信日時</th>
        <th>名前</th>
        <th>メッセージ</th>
        <th>メッセージタイプ</th>
        <th>状態</th>
        <th>履歴</th>
      </tr>
      <tr v-for="msg in getMessage">
        <td><span>{{ msg.created_at }}</span></td>
        <td>{{ msg.sender }}</td>
        <td v-if="msg.message_type=='text'">
          {{ msg.contents }}
        </td>
        <td v-if="msg.message_type=='sticker'">
          <img :src="msg.contents" class="sticker">
        </td>
        <td>{{ msg.message_type }}</td>
        <td>自動返事</td>
        <td><button>メッセージ履歴</button></td>
      </tr>
    </table>
    <paginate
    :page-count="getPageCount"
    :page-range="3"
    :margin-pages="2"
    :click-handler="clickCallback"
    :prev-text="'Prev'"
    :next-text="'Next'"
    :container-class="'pagination'"
    :page-class="'page-item'"
    >
  </paginate>
</div>
</template>

<script>
  import axios from 'axios'
  export default {
    name: 'messageList',
    data(){
      return {
        messageList: [],
        parPage: 5,
        currentPage: 1,
      }
    },
    mounted: function(){
      this.fetchMessage();
      //setInterval(this.fetchMessage, 1000);
    },
    methods: {
      fetchMessage(){
        axios.get('/api/messages').then((res) => {
          for(let message of res.data.messages){
            let time = message.created_at+""
            message.created_at = time.substr(0,19).replace('T'," ")
          }
          this.messageList = res.data.messages
        }, (error) => {
          console.log(error)
        })
      },
      clickCallback(pageNum){
        this.currentPage = Number(pageNum);
      },
      resetPage(){
        this.currentPage = 1;
      }
    },
    computed: {
      getMessage(){
        let current = this.currentPage * this.parPage;
        let start = current - this.parPage;
        return this.messageList.slice(start, current);
      },
      getPageCount(){
        return Math.ceil(this.messageList.length / this.parPage)
      }
    }
  }
</script>

<style scoped>
input[type=checkbox] {
  display: none;
}
.title {
  float: left;
  padding-left: 20px;
}
.checkbox {
  opacity: 1;
}
.msgList {
  width: 98%;
  padding: 15px;
  margin: 15px;
  float: inherit;
}
.msgList th{
  padding: 5px;
  margin: 0;
  height: 10px;
  width: auto;
  background-color: #E0E0F8;
  border-top: 2px solid grey;
}
.msgList td {
  padding: 15px 5px;
  display: table-cell;
  text-align: center;
  vertical-align: middle;
  border-radius: 2px;
}
hr {
  margin: 10px;
}
.material-icons {
  margin-top: 30px;
  margin-right: 30px;
  float: right;
  font-size: 30px;
  color: #4EE0F8;
}
.material-icons:hover {
  cursor: pointer;
  transform: rotate(-90deg);
}
.refresh small {
  font-size: 10px;
  width: 5em;
}
.sticker {
  width: 50px;
  height: 50px;
  margin: 0px 0px;
  padding: 0px 0px;
}
.setting {
  float: right;
  padding-right: 25px;
}
select {
  background-color: white;
  width: 100%;
  padding: 5px;
  border: 1px solid #f2f2f2;
  border-radius: 2px;
  height: 3rem;
  display: -webkit-inline-box;
}
</style>