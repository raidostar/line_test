<template>
  <div class="page" id="page4">
    <div class="col col-left">
      <div class="label">
        <i class="material-icons people">group</i>
        友達リスト
      </div>
      <ul class="friendsList">
        <li v-for="friend in friendsList">
          <button class="frBtn" @click="fetchMessages(friend.fr_account,friend.id)">
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
          <i class="material-icons animated fadeIn infinite duration-5s" style="color: white; padding-left: 7em;">loop</i>
        </button>
      </div>
    </div>
    <div class="col col-right">
      <div class="label">
        <i class="material-icons profile">face</i>
        友達プロファイル
      </div>

      <div style="text-align: center;" v-model="friend">
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
        <hr/>
        <div>
          <router-link class="personalPage" :to="personalLink">{{personalLinkBtn}}</router-link>
        </div>
      </div>

    </div>
  </div>
</template>
<script>
  import axios from 'axios'
  export default {
    name: 'personalMessages',
    data(){
      return {
        friendsList: [],
        messages: [],
        friend: {},
        personalLink: '',
        personalLinkBtn: null
      }
    },
    mounted: function(){
      this.fetchFriends();
      //setInterval(this.fetchFriends(), 1000);
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
      fetchMessages(req,id){
        this.personalLink = '/personalPage/'+id
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
          this.personalLinkBtn = '詳細ページ'
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
<style scoped src="../components/page4/page4.css"/>