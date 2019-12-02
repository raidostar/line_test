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
            <span class="detailTitle">最後のメッセージ時間</span>
            <span class="detailInfo">{{friend.last_message_time}}</span>
          </div>
          <div class="detailLine">
            <span class="detailTitle">メッセージ値</span>
            <span class="detailInfo">{{messages.length}}件</span>
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
    <div class="bottom-panel" ref="result">
      <message-history
      :messages="messages"
      :bubbles="bubbles"
      :resultHeaderCSS="resultHeaderCSS"
      :resultHeroCSS="resultHeroCSS"
      :resultBodyCSS="resultBodyCSS"
      :resultFooterCSS="resultFooterCSS"
      :getImgUrl="getImgUrl"
      v-show="baseNum==0"
      />
      <message-time
      :time="time"
      :timeRank="timeRank"
      :timeFreqRank="timeFreqRank"
      v-show="baseNum==1"/>
      <message-type :messageType="messageType" v-show="baseNum==2"/>
      <message-response v-show="baseNum==3"/>
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
    props: {
      id: String
    },
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
        stamp: 0,
        messageType: [],
        messages: [],
        bubbles: [],
        timeRank: [],
        timeFreqRank: [],
        time : [],
        zero: 0, one: 0, two: 0, three: 0, four: 0, five: 0, six: 0, seven: 0, eight: 0, nine: 0, ten: 0,
        eleven: 0,twelve: 0, thirteen: 0, fourteen: 0, fifteen: 0, sixteen: 0, seventeen: 0, eighteen: 0,
        nineteen: 0, twenty: 0, t_one: 0, t_two: 0, t_three: 0,
        detailShow: false,
        tag: '',
        tags: [],
        resultHeaderCSS: [],
        resultHeroCSS: [],
        resultBodyCSS: [],
        resultFooterCSS: [],
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
          if(this.friend.last_message_time != null){
            this.friend.last_message_time = this.friend.last_message_time.substr(0,16).replace('T',' ');
          }
          if(this.friend.tags != null){
            if(this.friend.tags.length>0){
              this.tags = this.friend.tags.split(",")
            }
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
          this.bubbles = []
          this.resultHeaderCSS = []
          this.resultBodyCSS = []
          this.resultFooterCSS = []
          for(let message of res.data.messages){
            if(message.message_type=="carousel"){
              this.fetchBubbles(message.contents)
            }
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
          if(msg.check_status!='answered'){
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
        // console.log(this.timeRank)
        // console.log(this.timeFreqRank)
        for(let i in this.timeFreqRank){
          let length = this.messages.length;
          this.timeFreqRank[i]=((this.timeFreqRank[i]/length)*100).toFixed(1)
        }
      },
      makeData2(messages){
        //console.log(messages)
        for(let msg of messages){
          if(msg.check_status!='answered'){
            switch(msg.message_type){
              case 'text':
              this.text++;
              break;
              case 'stamp':
              this.stamp++;
              break;
            }
          }
        }
        this.messageType.push(['テキスト', this.text]);
        this.messageType.push(['スタンプ', this.stamp]);
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
      },
      fetchBubbles(ids){
        axios.post('api/fetch_bubbles',{
          ids: ids
        }).then((res)=>{
          // console.log("bubble수집")
          // console.log(res.data)
          console.log(this.bubbles)
          for(var bubble of res.data){
            this.bubbles.push(bubble)
            var headerResult = {'display':'grid', 'height': '7vh'}
            var bodyResult = {'display':'grid'}
            var footerResult = {'display':'grid'}

            headerResult = this.gravityResultConverter(bubble.header_gravity,headerResult)
            headerResult = this.alignResultConverter(bubble.header_align,headerResult)
            headerResult = this.boldResultConverter(bubble.header_bold,headerResult)
            headerResult = this.sizeResultConverter(bubble.header_size,headerResult)
            headerResult = this.colorResultConverter(bubble.header_color,headerResult)
            headerResult = this.backgroundResultConverter(bubble.header_background,headerResult)

            bodyResult = this.gravityResultConverter(bubble.body_gravity,bodyResult)
            bodyResult = this.alignResultConverter(bubble.body_align,bodyResult)
            bodyResult = this.boldResultConverter(bubble.body_bold,bodyResult)
            bodyResult = this.sizeResultConverter(bubble.body_size,bodyResult)
            bodyResult = this.colorResultConverter(bubble.body_color,bodyResult)
            bodyResult = this.backgroundResultConverter(bubble.body_background,bodyResult)

            footerResult = this.gravityResultConverter(bubble.footer_gravity,footerResult)
            footerResult = this.alignResultConverter(bubble.footer_align,footerResult)
            footerResult = this.boldResultConverter(bubble.footer_bold,footerResult)
            footerResult = this.sizeResultConverter(bubble.footer_size,footerResult)
            footerResult = this.colorResultConverter(bubble.footer_color,footerResult)
            footerResult = this.backgroundResultConverter(bubble.footer_background,footerResult)

            this.resultHeaderCSS.push(headerResult)
            this.resultBodyCSS.push(bodyResult)
            this.resultFooterCSS.push(footerResult)
          }
          // console.log(this.bubbles)
          // console.log(this.resultHeaderCSS)
          // console.log(this.resultBodyCSS)
          // console.log(this.resultFooterCSS)
          let height = this.$refs.result.clientHeight
          let scrollTop = this.$refs.result.scrollTop
          let scrollHeight = this.$refs.result.scrollHeight
          scrollTop = scrollHeight - height
          this.$refs.result.scrollTop = scrollTop
        },(error)=>{
          console.log(error)
        })
      },
      gravityResultConverter(gravity,result){
        switch(gravity){
          case 'top':
          result['align-items'] = 'flex-start'
          break
          case 'center':
          result['align-items'] = 'center'
          break
          case 'bottom':
          result['align-items'] = 'flex-end'
          break
          default:
          console.log('gravityResultConverter error!')
        }
        return result
      },
      alignResultConverter(align,result){
        if(align=='center'){
          result['justify-content'] = 'center'
          result['text-align'] = 'center'
        }else {
          result['justify-content'] = 'flex-' + align
          result['text-align'] = align
        }
        return result
      },
      boldResultConverter(bold,result){
        if(bold=='bold'){
          result['font-weight'] = 'bold'
        }else {
          result['font-weight'] = 'normal'
        }
        return result
      },
      sizeResultConverter(size,result){
        switch(size){
          case 'xxs':
          result['font-size'] = '10px'
          break
          case 'xs':
          result['font-size'] = '12px'
          break
          case 'sm':
          result['font-size'] = '14px'
          break
          case 'md':
          result['font-size'] = '16px'
          break
          case 'lg':
          result['font-size'] = '19px'
          break
          case 'xl':
          result['font-size'] = '22px'
          break
          case 'xxl':
          result['font-size'] = '25px'
          break
          case '3xl':
          result['font-size'] = '29px'
          break
          case '4xl':
          result['font-size'] = '33px'
          break
          case '5xl':
          result['font-size'] = '37px'
          break
          default:
        }
        return result
      },
      colorResultConverter(color,result){
        result['color'] = color
        return result
      },
      backgroundResultConverter(background,result){
        result['background-color'] = background
        return result
      },
      getImgUrl(para) {
        var images = require.context('../images/', false, /\.png$/)
        return images('./' + para + ".png")
      },
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
  height: 74vh;
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