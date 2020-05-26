<template>
  <div class="page" id="personalPage">
    <div v-show="loading" class="waiting-screen">
      <div class="spinner">
        <div class="bounce1"></div>
        <div class="bounce2"></div>
        <div class="bounce3"></div>
      </div>
    </div>
    <div class="box">
      <h2 class="profile">
        <img v-if="friend.profile_pic" :src="friend.profile_pic" class="profile_img" ref="profile_image">
        <i v-else class="material-icons profile-image">account_circle</i>
        <span>{{friend.fr_name}}</span>
        <div style="float: right;" class="settings">
          <i class="material-icons setting" @click="detailToggle">settings</i>
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
            <span class="detailTitle">最後のリプライ時間</span>
            <span class="detailInfo">{{friend.last_message_time}}</span>
          </div>
          <div class="detailLine">
            <span class="detailTitle">リプライ数</span>
            <span class="detailInfo">{{ replyNumber }}件</span>
          </div>
          <div class="detailLine">
            <span class="detailTitle">メッセージ数</span>
            <span class="detailInfo">{{ messageNumber }}件</span>
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
            <button class="profile_menu" @click="updateTag">設定</button>
            <button class="profile_menu">キャンセル</button>
          </div>
        </div>
      </div>
    </transition>
    <div class="left-panel">
      <div>
        <button class="profile_menu_selected" to="/friendslist" v-if="baseNum==0">タイムライン</button>
        <button class="profile_menu" to="/friendslist" v-else @click="baseNum=0">タイムライン</button>

        <button class="profile_menu_selected" to="/friendslist" v-if="baseNum==1">時間別リプライ</button>
        <button class="profile_menu" to="/friendslist" v-else @click="baseNum=1">時間別リプライ</button>

        <button class="profile_menu_selected" to="/friendslist" v-if="baseNum==2">タイプ別リプライ</button>
        <button class="profile_menu" to="/friendslist" v-else @click="baseNum=2">タイプ別リプライ</button>

        <button class="profile_menu_selected" to="/friendslist" v-if="baseNum==3">タイプ別メッセージ</button>
        <button class="profile_menu" to="/friendslist" v-else @click="baseNum=3">タイプ別メッセージ</button>
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
      :id="id"
      v-show="baseNum==1"/>
      <message-type :id="id" v-show="baseNum==2"/>
      <message-response :id="id" v-show="baseNum==3"/>
    </div>
  </div>
</template>
<script>
  import axios from 'axios'
  import messageHistory from '../components/PersonalPage/messageHistory.vue'
  import messageTime from '../components/PersonalPage/messageTime.vue'
  import messageType from '../components/PersonalPage/messageType.vue'
  import messageResponse from '../components/PersonalPage/messageResponse.vue'
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
        detailShow: false,
        tag: '',
        tags: [],
        resultHeaderCSS: [],
        resultHeroCSS: [],
        resultBodyCSS: [],
        resultFooterCSS: [],
        loading: true,
        timeOption: 'hourly',
        selectedFriend: {},
        replyNumber: 0,
        messageNumber: 0,
      }
    },
    mounted: function(){
      this.accessCheck();
    },
    methods: {
      accessCheck(){
        this.loading = true
        axios.post('/api/show_current').then((res)=>{
          var status = res.data.user.status
          var admit = res.data.user.admit
          if((status=='client'||status=='master')&&!admit){
            alert("このページの接続権限がありません。")
            location.href = '/';
          } else {
            this.fetchFriend();
          }
        },(error)=>{
          console.log(error)
        })
      },
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
          this.getMessageNumber(fr_account)
          this.getReplyNumber(fr_account)
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
          this.loading = false
        }, (error)=>{
          console.log(error)
        })
      },
      getMessageNumber(fr_account){
        axios.post('/api/get_message_number',{
          fr_account: fr_account
        }).then((res)=>{
          this.messageNumber = res.data
        },(error)=>{
          console.log(error)
        })
      },
      getReplyNumber(fr_account){
        axios.post('/api/get_reply_number',{
          fr_account: fr_account
        }).then((res)=>{
          this.replyNumber = res.data
        },(error)=>{
          console.log(error)
        })
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
        axios.put('/api/friends/'+this.friend.id,{
          tags: this.tags.toString()
        }).then((res)=>{
          alert("タグ修正完了")
          this.tag = '';
          this.fetchFriend();
        },(error)=>{
          console.log(error)
        })
      },
      fetchBubbles(ids){
        this.loading = true
        axios.post('/api/fetch_bubbles_archives',{
          ids: ids
        }).then((res)=>{
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
          let height = this.$refs.result.clientHeight
          let scrollTop = this.$refs.result.scrollTop
          let scrollHeight = this.$refs.result.scrollHeight
          scrollTop = scrollHeight - height
          this.$refs.result.scrollTop = scrollTop
          this.loading = false
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
        var images = 'https://cdn.lineml.jp/api/media/sticker/'+para
        return images
      },
    },
    updated(){
      this.$nextTick(function(){
        var profile = this.$refs.profile_image
        if(profile != null){
          if(profile.src != null && profile.complete && profile.naturalWidth == 0){
            this.friend.profile_pic = null
          }
        }
      })
    }
  }
</script>
<style scoped src="../components/PersonalPage/personalPage.css"/>