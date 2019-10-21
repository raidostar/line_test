<template>
  <div class="page" id="page4">
    <div class="col col-left">
      <div class="label">
        <i class="material-icons people">group</i>
        友達リスト
      </div>
      <ul class="friendsList">
        <li v-for="friend in friendsList">
          <button class="frBtn" @click="fetchMessages(friend)">
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
      <div class="message chatting-content" id="chatting-content">
        <div v-for="msg in messages">
          <div class="chatting-line" v-if="msg.check_status!='answered'">
            <div class="balloon-left">
              <span v-if="msg.message_type=='text'" v-html="msg.contents">{{msg.contents}}</span>
              <span v-else-if="msg.message_type=='stamp'"><img class="attachedStamp" :src="msg.contents"/></span>
              <span v-else-if="msg.message_type=='image'"><img class="attachedImg" :src="msg.image.url+''"></span>
              <span v-else>
                <GmapMap
                :center="mapConvert(msg.contents)"
                :zoom="12"
                map-type-id="terrain"
                style="width: 16em; height: 16em;"
                >
                <GmapMarker
                :position="mapConvert(msg.contents)"
                :clickable="true"
                :draggable="false"
                />
              </GmapMap>
            </span>
          </div>
        </div>
        <div class="balloon-right" v-if="msg.check_status=='answered'">
          <span v-if="msg.message_type=='text'" v-html="msg.contents">{{msg.contents}}</span>
          <span v-else-if="msg.message_type=='stamp'"><img class="attachedStamp" :src="msg.contents"/></span>
          <span v-else-if="msg.message_type=='image'"><img class="attachedImg" :src="msg.image.url+''"></span>
          <span v-else>
            <GmapMap
            :center="mapConvert(msg.contents)"
            :zoom="12"
            map-type-id="terrain"
            style="width: 16em; height: 16em;"
            >
            <GmapMarker
            :position="mapConvert(msg.contents)"
            :clickable="true"
            :draggable="false"
            />
          </GmapMap>
        </span>
      </div>
    </div>
  </div>
  <div class="message chatting-text" v-model="friend">
    <button class="refresh" @click="fetchMessages(friend)">
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
        personalLinkBtn: null,
        selectedFriend: null,
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
      fetchMessages(friend){
        this.selectedFriend = friend
        this.personalLink = '/personalPage/'+friend.id
        this.showFriend(friend.fr_account);
        axios.post('/find_messages', {
          fr_account: friend.fr_account
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
            this.friend = friend
          }
        }
      },
      getImgUrl(para) {
        var images = require.context('../images/', false, /\.png$/)
        return images('./' + para + ".png")
      },
      mapConvert(contents){
        let tempArr = contents.split("+")
        const tempLength = tempArr[1].length
        tempArr = tempArr[1].substring(6,tempLength-2).split(",")
        tempArr[0] = tempArr[0]*1
        tempArr[1] = tempArr[1]*1
        return {lat: tempArr[0], lng: tempArr[1]}
      },
    }
  }
</script>
<style scoped src="../components/page4/page4.css"/>