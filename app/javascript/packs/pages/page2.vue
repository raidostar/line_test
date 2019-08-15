<template>
  <div class="page" id="page2">
    <div>
      <div>
        <h2 class="title">友達リスト<hr/></h2>
      </div>
    </div>
    <table class="fList">
      <thead>
        <tr>
          <th><input type="checkbox" name="allUser" value="1" class="checkbox"/></th>
          <th>状況</th>
          <th>名前</th>
          <th>シナリオ</th>
          <th>受信メッセージ</th>
          <th>タグ・友だち情報</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="friend in friendsList" >
          <td><input type="checkbox" value="1" class="checkbox"/></td>
          <td><span>確認済み</span></td>
          <td style="text-align: left; padding-left: 100px;">
            <img :src="friend.profile_pic" class="profile_img">
            {{friend.fr_name}}
          </td>
          <td>停止中</td>
          <td
          v-for="msg in message"
          v-if="msg.fr_account==friend.fr_account"
          >
          <span v-if="msg.message_type=='text'" class="last_msg">
            {{msg.contents}}
            <div class="msg_time">{{msg.created_at}}</div>
          </span>
          <span v-if="msg.message_type=='sticker'" class="last_msg">
            <img :src="msg.contents" class="sticker">
            <div class="msg_time">{{msg.created_at}}</div>
          </span>
        </td>
        <td>タグ・友だち情報</td>
      </tr>
    </tbody>
  </table>
</div>
</template>

<script>
  import axios from 'axios'
  export default {
    name: 'friendslist',
    data: function(){
      return {
        friendsList: [],
        message: []
      }
    },
    mounted: function(){
      this.fetchFriends();
    },
    methods: {
      fetchFriends(){
        axios.get('/api/friends').then((res) => {
          this.friendsList = res.data.friends
          for(let friend of res.data.friends){
            this.findMessage(friend.fr_account);
          }
        }, (error) => {
          console.log(error)
        })
      },
      findMessage(req){
        axios.post('/find_message', {
          fr_account: req
        }).then((res) => {
          let fr_account = res.data.message.fr_account
          let contents = res.data.message.contents
          let message_type = res.data.message.message_type
          let created_at = res.data.message.created_at+""
          created_at = created_at.substr(5,14).replace('T'," ")
          this.message.push({
            fr_account: fr_account,
            contents: contents,
            message_type: message_type,
            created_at: created_at
          })
        }, (error) => {
          console.log(error)
        })
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
.fList {
  width: 98%;
  padding: 15px;
  margin: 15px;
  float: inherit;
}
.fList th{
  padding: 5px;
  margin: 0;
  height: 10px;
  width: auto;
  background-color: #E0E0F8;
  border-top: 2px solid grey;
}
.fList td {
  padding: 15px 5px;
  display: table-cell;
  text-align: center;
  vertical-align: middle;
  border-radius: 2px;
}
hr {
  margin: 10px;
}
.profile_img {
  width: 40px;
  height: 40px;
  border-radius: 100%;
}
.sticker {
  width: 50px;
  height: 50px;
  margin: 0px 0px;
  padding: 0px 0px;
}
.msg_time {
  opacity: 0.6;
  font-size: 13px;
  padding-top: 7px;
}
.last_msg {
  line-height: 0px;
}
</style>