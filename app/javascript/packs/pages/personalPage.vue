<template>
  <div class="page" id="personalPage">
    <div class="box">
      <h2 class="profile">
        <img :src="friend.profile_pic" class="profile_img">
        <span>{{friend.fr_name}}</span>
        <div style="float: right;" class="settings">
          <i class="material-icons" @click="detailToggle">settings</i>
        </div>
      </h2>
    </div>
    <transition name="fadeInOut">
      <div class="personDetails" v-if="detailShow">
        <div class="detail panel-left">
          <div class="detailLine">
            <span class="detailTitle">登録日時</span>
            <span class="detailInfo">{{friend.created_at}}</span>
          </div>
          <div class="detailLine">
            <span class="detailTitle">平均応答時間</span>
            <span class="detailInfo">15分(sample)</span>
          </div>
          <div class="detailLine">
            <span class="detailTitle">メッセージ値</span>
            <span class="detailInfo">10000件(sample)</span>
          </div>
        </div>
        <div class="detail panel-right">
          <div style="line-height: 42px;">
            <span class="settingTag" style="float: left;">タグ設定</span>
            <input type="text" name="option[target_keyword]" v-model="tag" class="tagInput" @keydown.enter="createTag">
            <a @click="clearTagInput" v-if="tag">
              <i class="material-icons tag_cancel">cancel</i>
            </a>
          </div>
          <div style="margin-top: 60px;">
            <span style="font-size: 14px;">タグ : </span>
            <span v-for="(tag,index) in tags" v-model="tags" style="margin-top: 10px;">
              <button class="keywordsTag" @click="removeTag(index)">{{tag}}</button>
            </span>
          </div>
          <div style="margin-top: 10px; float: right;">
            <button @click="updateTag">設定</button>
            <button>キャンセル</button>
          </div>
        </div>
      </div>
    </transition>
    <div class="left-panel">
      <div>
        <button class="profile_menu" to="/friendslist" @click="baseNum=0">タイムライン</button>
        <button class="profile_menu" to="/friendslist" @click="baseNum=1">メッセージ遷移</button>
        <button class="profile_menu" to="/friendslist" @click="baseNum=2">メッセージタイプ別</button>
        <button class="profile_menu" to="/friendslist" @click="baseNum=3">友達リスト</button>
      </div>
    </div>
    <div class="bottom-panel">
      <message-history
      :messages="messages"
      v-show="(baseNum%4)==0"/>
      <message-time
      :time="time"
      :timeRank="timeRank"
      :timeFreqRank="timeFreqRank"
      v-show="(baseNum%4)==1"/>
      <message-type :messageType="messageType" v-show="(baseNum%4)==2"/>
      <message-response v-show="(baseNum%4)==3"/>
    </div>
  </div>
</template>
<script>
  import axios from 'axios'
  import messageHistory from '../components/personalPage/messageHistory.vue'
  import messageTime from '../components/personalPage/messageTime.vue'
  import messageType from '../components/personalPage/messageType.vue'
  import messageResponse from '../components/personalPage/messageResponse.vue'
  export default {
    name: 'personalPage',
    props: ['id'],
    components: {
      messageHistory,
      messageTime,
      messageType,
      messageResponse
    },
    data: function(){
      return {
        friend: {},
        baseNum: 0,
        text: 0,
        sticker: 0,
        messageType: [],
        messages: [],
        timeRank: [],
        timeFreqRank: [],
        time : [],
        zero: 0, one: 0, two: 0, three: 0, four: 0, five: 0, six: 0, seven: 0, eight: 0, nine: 0, ten: 0,
        eleven: 0,twelve: 0, thirteen: 0, fourteen: 0, fifteen: 0, sixteen: 0, seventeen: 0, eighteen: 0,
        nineteen: 0, twenty: 0, t_one: 0, t_two: 0, t_three: 0,
        detailShow: false,
        tag: '',
        tags: [],
      }
    },
    mounted: function(){
      this.fetchFriend();
    },
    methods: {
      fetchFriend(){
        const url = '/api/friends/'+this.id
        axios.get(url).then((res)=>{
          this.friend = res.data.friend
          let fr_account = this.friend.fr_account
          this.friend.created_at = this.friend.created_at.substr(0,16).replace('T',' ');
          if(this.friend.tags.length>0){
            this.tags = this.friend.tags.split(",")
          }
          this.fetchMessages(fr_account)
        },(error)=>{
          console.log(error)
        })
      },
      fetchMessages(req){
        axios.post('/find_messages', {
          fr_account: req
        }).then((res)=>{
          for(let message of res.data.messages){
            let time = message.created_at+""
            message.created_at = time.substr(0,19).replace('T'," ")
          }
          this.messages = res.data.messages
          this.makeData1(this.messages)
          this.makeData2(this.messages)
        }, (error)=>{
          console.log(error)
        })
      },
      makeData1(messages){
        for(let msg of messages){
          let hour = msg.created_at.substr(11,2)
          switch(hour){
            case '00':
            this.zero++;
            break
            case '01':
            this.one++;
            break
            case '02':
            this.two++;
            break
            case '03':
            this.three++;
            break
            case '04':
            this.four++;
            break
            case '05':
            this.five++;
            break
            case '06':
            this.six++;
            break
            case '07':
            this.seven++;
            break
            case '08':
            this.eight++;
            break
            case '09':
            this.nine++;
            break
            case '10':
            this.ten++;
            break
            case '11':
            this.eleven++;
            break
            case '12':
            this.twelve++;
            break
            case '13':
            this.thirteen++;
            break
            case '14':
            this.fourteen++;
            break
            case '15':
            this.fifteen++;
            break
            case '16':
            this.sixteen++;
            break
            case '17':
            this.seventeen++;
            break
            case '18':
            this.eighteen++;
            break
            case '19':
            this.nineteen++;
            break
            case '20':
            this.twenty++;
            break
            case '21':
            this.t_one++;
            break
            case '22':
            this.t_two++;
            break
            case '23':
            this.t_three++;
            break
          }
        }
        this.time.push({'name': 'メッセージ',
          data: {
            '00:00': this.zero, '01:00': this.one, '02:00': this.two, '03:00': this.three, '04:00': this.four,
            '05:00': this.five, '06:00': this.six, '07:00': this.seven, '08:00': this.eight, '09:00': this.nine,
            '10:00': this.ten, '11:00': this.eleven, '12:00': this.twelve, '13:00': this.thirteen, '14:00': this.fourteen,
            '15:00': this.fifteen, '16:00': this.sixteen, '17:00': this.seventeen, '18:00': this.eighteen,
            '19:00': this.nineteen, '20:00': this.twenty, '21:00': this.t_one, '22:00': this.t_two, '23:00': this.t_three,
          }
        })
        let list = this.time[0].data
        this.timeRank = Object.keys(list).sort(function(a,b){return list[b]-list[a]})
        this.timeFreqRank = Object.values(list).sort(function(a,b){return b-a})
        for(let i in this.timeFreqRank){
          let length = this.messages.length;
          this.timeFreqRank[i]=((this.timeFreqRank[i]/length)*100).toFixed(1)
        }
      },
      makeData2(messages){
        console.log(messages)
        for(let msg of messages){
          switch(msg.message_type){
            case 'text':
            this.text++;
            break;
            case 'sticker':
            this.sticker++;
            break;
          }
        }
        this.messageType.push(['テキスト', this.text]);
        this.messageType.push(['スタンプ', this.sticker]);
        console.log(this.messageType)
      },
      detailToggle(){
        this.detailShow = !this.detailShow
      },
      createTag(){
        if(!this.tag) return;
        if(this.tag.search(",")>-1||this.tag.search("、")>-1) {
          alert("タグはキーワードになれません。")
          return;
        }
        if(this.tags.length>=10){
          alert("タグは最大10個まで登録できます。")
          return;
        }
        this.tags.push(this.tag)
        this.tag = '';
      },
      clearTagInput(){
        this.tag = ""
      },
      removeTag(index){
        var start = index;
        if (index != this.tags.length-1){
          for(var i=start;i<this.tags.length-1;i++){
            this.tags[i] = this.tags[i+1]
          }
        }
        this.tags.pop();
      },
      updateTag(){
        axios.put('api/friends/'+this.friend.id,{
          tags: this.tags.toString()
        }).then((res)=>{
          alert("タグ修正完了")
          this.tag = '';
          this.fetchFriend();
        },(error)=>{
          console.log(error)
        })
        this.friend.id
      }
    }
  }
</script>
<style scoped>
.box {
  margin: 10px 10px;
  padding: 10px 10px;
  margin-bottom: 0px;
  text-align: left;
  width: 98%;
  height: 6em;
  border: 1px solid #FFF;
  border-radius: 8px;
  box-shadow: 0 0 10px #666;
}
.profile_img {
  width: 2em  ;
  height: 100%;
  vertical-align: middle;
}
.profile {
  float: left;
  width: auto;
  text-align: left;
}
.material-icons {
  font-size: 25px;
  color: #111111;
  margin-right: 30px;
  opacity: 0.4;
  height: 20px;
  line-height: 52px;
  padding-left: 10px;
}
.material-icons:hover {
  font-size: 28px;
  opacity: 0.7;
  cursor: pointer;
}
.left-panel {
  width: 98%;
  text-align: left;
  margin: 0px 10px;
  padding: 0px 10px;
}
.profile_menu {
  font-weight: 600;
  background-color: #C0C0C0;
  color: #2C3250;
  padding: 5px 5px;
  border-radius: 10px;
  border: 1px solid #C0C0C0;
  box-shadow: 0 0 2px #666;
}
.profile_menu:hover {
  text-decoration: none;
  background-color: #2C3250;
  color: white;
}
.bottom-panel {
  margin: 0px 10px;
  padding: 0px 10px;
  text-align: left;
  width: 98%;
  height: 33em;
  border: 1px solid #FFF;
  border-radius: 8px;
  box-shadow: 0 0 2px #666;
  background-color: #EEECFF
}
button:focus {
  outline: none;
  background-color: #2C3250;
  color: white;
}
.personDetails {
  margin: 10px 10px;
  padding: 10px 10px;
  text-align: left;
  width: 98%;
  height: 13em;
  border: 1px solid #FFF;
  border-radius: 8px;
  box-shadow: 0 0 10px #666;
}
.fadeInOut-enter-active {
  animation: fadeInDown .5s;
}
.fadeInOut-leave-active {
  animation: fadeInDown .5s reverse;
}
.detail {
  width: 49%;
  height: 100%;
  border-radius: 8px;
}
.panel-left {
  border: 1px solid #FFF;
  box-shadow: 0 0 10px #666;
  float: left;
  padding: 15px 15px;
}
.panel-right {
  border: 1px solid #FFF;
  box-shadow: 0 0 10px #666;
  float: right;
  padding: 15px 15px;
}
.detailTitle {
  font-size: 20px;
  font-weight: 500;
  float: left;
}
.detailInfo {
  margin-left: 40px;
}
.detailLine {
  width: 100%;
  margin: 15px 0px;
}
input.tagInput {
  float: left;
  width: 60%;
  margin-left: 30px;
}
.settingTag {
  font-size: 20px;
  font-weight: 500;
  float: left;
}
</style>