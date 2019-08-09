<template>
  <div class="page" id="page4">
    <div class="col col-left">
      <div class="label">
        <i class="material-icons people">group</i>
        友達リスト
      </div>
      <ul class="friendsList">
        <li v-for="friend in friendsList">
          <button @click="fetchMessages(friend.fr_account)">
            <img :src="friend.profile_pic" class="profile_img">
            {{friend.fr_name}}
          </button>
        </li>
      </ul>
    </div>
    <div class="col col-center">
      <div class="label">
        <i class="material-icons">phonelink_ring</i>
        メッセージ
      </div>
      <ul class="message chatting-content">
        <div v-for="msg in messages">
          <li v-if="msg.message_type=='text'">
            {{msg.contents}}
            <span style="float: right; opacity: 0.5;">{{msg.created_at}}</span>
          </li>
          <li v-if="msg.message_type=='sticker'" style="height: 50px;">
            <img :src="msg.contents" class="sticker">
            <span style="float: right; opacity: 0.5;">{{msg.created_at}}</span>
          </li>
        </div>
      </ul>
      <div class="message chatting-text" v-model="friend">
        <button class="refresh" @click="fetchMessages(friend.fr_account)">
          <i class="material-icons" style="color: white; padding-left: 7em;">loop</i>
        </button>
      </div>
    </div>
    <div class="col col-right">
      <div class="label">
        <i class="material-icons profile">face</i>
        友達プロファイル
      </div>

      <div style="text-align: center;"v-model="friend">
        <div style="margin-top: 10px;">
          <img :src="friend.profile_pic" class="profile_img_for_one">
        </div>
        <div>
          {{friend.fr_name}}
        </div>
        <hr/>
        <div>
          <p>プロファイルメッセージ</p>{{friend.profile_msg}}
        </div>
        <hr/>
        <div>
          <p>登録日時</p>{{friend.created_at}}
        </div>
      </div>

    </div>
  </div>
</template>
<script>


  import axios from 'axios'
  export default {
    name: 'page4',
    data(){
      return {
        friendsList: [],
        messages: [],
        friend: {}
      }
    },
    mounted: function(){
      this.fetchFriends();
      setInterval(this.fetchFriends(), 1000);
    },
    methods: {
      fetchFriends(){
        axios.get('/api/friends').then((res) => {
          //console.log(res.data.friends)
          this.friendsList = res.data.friends
        }, (error) => {
          console.log(error)
        })
      },
      fetchMessages(req){
        this.showFriend(req);
        axios.post('/find_messages', {
          fr_account: req
        }).then((res)=>{
          const fr_account=''
          for(let message of res.data.messages){
            let time = message.created_at+""
            message.created_at = time.substr(0,19).replace('T'," ")
          }
          this.messages = res.data.messages
        }, (error)=>{
          console.log(error)
        })
      },
      showFriend(req){
        console.log(req);
        //console.log(this.friendsList)
        for(let friend of this.friendsList){
          let time = friend.created_at+""
          friend.created_at = time.substr(0,19).replace('T'," ")
          if(friend.fr_account==req){
            console.log(friend)
            this.friend = friend
          }
        }
      }
    }
  }
</script>
<style scoped>
.col {
  float: left;
  padding: 2px 5px;
  margin: 10px 2px;
  text-align: left;
}
.col-left {
  width: 25%;
}
.col-center {
  width: 49%;
}
.col-right {
  width: 25%;
}
.label{
  border-bottom: 2px solid grey;
  padding: 0;
  margin: 0;
  line-height: 40px;
  font-size: 20px;
  font-weight: 700;
}
.material-icons {
  font-size: 40px;
  color: #00B900;
  margin-right: 30px;
}
.label-friend {
  font-size: 15px;
  font-weight: 600;
  border-radius: 5px;
  padding: 0px;
  margin: 0px;
}
.friendsList {
  padding-top: 10px;
  height: 37em;
  max-height: 100%;
}
.message {
  width: 100%;
}
.message li {
  height: 50px;
  line-height: 50px;
  text-align: left;
  padding-left: 30px;
  padding-top: 0px;
  margin: 0 auto;
}
.chatting-content {
  height: 37em;
  max-height: 100%;
}
.chatting-text {
  height: 2em;
}
.refresh {
  border:0px white;
  background-color: #00B900;
  padding: 0;
  margin: 0;
  float: right;
  width: 100%;
  text-align: center;
  opacity: 0.6;
}
.refresh:hover {
  opacity: 1.1;
}
.send {
  font-size: 10px;
}
.profile_img {
  width: 35px;
  height: 100%;
  border-radius: 100%;
}
.friendsList ul {
  margin: 0px 5px;
  padding: 0px 5px;
  padding-top: 0px;
}
.friendsList li {
  height: 35px;
  text-align: left;
  padding-left: 30px;
  padding-bottom: 10px;
  margin-bottom: 15px;
}
.friendsList button {
  background-color: white;
  color: black;
  height: 38px;
  margin:  0px 0px;
  padding: 0px 0px;
}
.profile_img_for_one {
  width: 9em;
  height: 9em;
  align-content: center;
}
.sticker {
  width: 50px;
  height: 50px;
  margin: 0px 0px;
  padding: 0px 0px;
}
</style>