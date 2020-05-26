<template>
  <div class="page" id="page4">
    <div v-show="loading" class="waiting-screen">
      <div class="spinner">
        <div class="bounce1"></div>
        <div class="bounce2"></div>
        <div class="bounce3"></div>
      </div>
    </div>
    <div class="tips" v-show="tipsPage!=tips.length">
      <div class="cover top_cover" :style="topCover"></div>
      <div class="cover left_cover" :style="leftCover"></div>
      <div class="cover bottom_cover" :style="bottomCover"></div>
      <div class="cover right_cover" :style="rightCover"></div>
      <div class="focus_line" :style="focusLineCSS"></div>
      <div class="explanation" :style="explanationCSS">
        <div class="tips_detail">
          <i class="material-icons info_mark">wb_incandescent</i>
          <div class="tips_letter" v-html="tips[tipsPage]"></div>
        </div>
        <div class="page_move">
          <span class="left_move mover" v-if="tipsPage>0" @click="prevTip">戻る</span>
          <span class="right_move mover" @click="nextTip" v-model="nextWord">{{ nextWord }}</span>
        </div>
      </div>
    </div>
    <div class="col col-left">
      <div class="label">
        <i class="material-icons people">group</i>
        友達リスト
      </div>
      <ul class="friendsList">
        <li v-for="(friend,i) in friendsList">
          <button class="frBtn" v-if="friend==selectedFriend" style="background-color: #aac5F2">
            <img ref="profile_image" v-if="friend.profile_pic" :src="friend.profile_pic" class="profile_img">
            <i v-else class="material-icons profile">account_circle</i>
            <span class="profile-name">{{friend.fr_name}}</span>
          </button>
          <button class="frBtn" v-else @click="fetchMessages(friend)">
            <img v-if="friend.profile_pic" :src="friend.profile_pic" class="profile_img">
            <i v-else class="material-icons profile">account_circle</i>
            <span class="profile-name">{{friend.fr_name}}</span>
          </button>
        </li>
      </ul>
    </div>
    <div class="col col-center">
      <div class="label">
        <i class="material-icons">phonelink_ring</i>
        メッセージ
      </div>
      <div class="message chatting-content" id="chatting-content" ref="result">
        <div v-for="msg in messages">
          <div class="chatting-line" v-if="msg.check_status!='answered'&&msg.check_status!='notified'&&msg.check_status!='reminded'&&msg.check_status!='welcome'">
            <div class="balloon-left" v-if="msg.message_type=='text'">
              <span v-html="msg.contents">{{msg.contents}}</span>
            </div>
            <div class="balloon-leftimage" v-else-if="msg.message_type=='stamp'">
              <img class="attachedStamp" :src="getImgUrl(msg.contents)"/>
            </div>
            <div class="balloon-leftimage" v-else-if="msg.message_type=='image'">
              <img class="attachedImg" :src="msg.image.url+''">
            </div>
            <span class="left-time">{{msg.created_at}}</span>
          </div>
          <div v-else>
            <div class="balloon-right" v-if="msg.message_type=='text'">
              <span v-if="msg.check_status=='answered'" v-html="msg.contents">
                {{msg.contents}}
              </span>
              <span v-else v-html="msg.contents" style="color: #ffc107;">
                {{msg.contents}}
              </span>
            </div>
            <div class="balloon-image" v-else-if="msg.message_type=='stamp'">
              <img class="attachedStamp" :src="getImgUrl(msg.contents)" style="width: 10em;"/>
            </div>
            <div class="balloon-image" v-else-if="msg.message_type=='image'">
              <img class="attachedImg" :src="msg.image.url">
            </div>
            <div class="balloon-image" v-else-if="msg.message_type=='carousel'" style="height: 27em;">
              <!-- <div style="color: black;">{{bubbles.length}}</div> -->
              <div class="carousel-box" style="margin-bottom: 1em; width: 21em;">
                <div class="bubble-box"  style="height: 100%; display: inline-flex;">
                  <div v-for="(bubble,index) in bubbles">
                    <div class="bubble" style="height: 100%;" :style="bubbleChecker(bubble,msg.contents)">
                      <div style="height: 100%;">
                        <div class="result-blocks header-block rounder1" :style="resultHeaderCSS[index]">
                          <div class="header-text rounder1" v-html="bubble.header">
                          </div>
                        </div>
                        <div class="result-blocks hero-block" v-show="bubble.image.url" :style="resultHeroCSS[index]">
                          <div class="carousel-img-area">
                            <img class="carousel-img" :src="bubble.image.url">
                          </div>
                        </div>
                        <div class="result-blocks body-block" :style="resultBodyCSS[index]">
                          <div class="body-text" v-html="bubble.body" >
                          </div>
                        </div>
                        <div class="result-blocks footer-block" style="line-height: 4.5vh" :style="resultFooterCSS[index]">
                          <div class="footer-text rounder2" v-html="bubble.footer">
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="balloon-image" v-else>
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
          </div>
          <span class="right-time">{{msg.created_at}}</span>
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
      <div style="margin-top: 10px;height: 10em;">
        <img ref="profile_image" v-if="friend.profile_pic" :src="friend.profile_pic" class="profile_img_for_one">
        <i v-else class="material-icons big-profile">account_box</i>
      </div>
      <div>
        {{friend.fr_name}}
      </div>
      <hr/>
      <div>
        <p>ステータスメッセージ</p>{{friend.profile_msg}}
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
        resultHeaderCSS: [],
        resultImageCSS: [],
        resultHeroCSS: [],
        resultBodyCSS: [],
        resultFooterCSS: [],
        bubbles: [],
        bubble_ids: [],
        loading: true,
        topCover: {'height':'7.5%'},
        bottomCover: {'height':'84%'},
        leftCover: {'width':'14.5%'},
        rightCover: {'width':'63.5%'},
        focusLineCSS: {'width':'22%','height':'7.5%','left':'14.5%','top':'8%'},
        explanationCSS: {'right':'55%','top':'17%','width': '30%','height': '18%'},
        tips: [
        '<p>ここで友だちを選択するとメッセージのヒストリを確認することができます。</p>',//0
        '<p>ここにメッセージのヒストリが表示されます。</p>',//1
        '<p>ここで選択された友だちのLINEプロフィル情報が表示されます。</p>',//2
        '<p>ここをクリックすると</p><p>メッセージヒストリをアップデートします。</p>',//3
        ],
        tipsPage: 0,
        nextWord: '次へ',
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
            this.fetchChannels();
          }
        },(error)=>{
          console.log(error)
        })
      },
      fetchChannels(){
        axios.post('/api/fetch_channels').then((res)=>{
          if(res.data==null){
            alert("まず、チャンネルを登録してご利用ください。");
            location.href = "/channelManage"
          } else {
            this.fetchFriends();
          }
        },(error)=>{
          console.log(error)
        })
      },
      fetchFriends(){
        this.loading = true
        axios.get('/api/friends').then((res) => {
          this.friendsList = res.data.friends
          this.fetchMessages(this.friendsList[0])
        }, (error) => {
          console.log(error)
        })
      },
      fetchMessages(friend){
        this.selectedFriend = friend
        if(this.friendsList.length>0){
          for(var id in this.friendsList){
            if(this.friendsList[id]==friend){
              this.personalLink = '/personalPage/'+id
              break
            }
          }
        }
        this.showFriend(friend.fr_account);
        this.loading = true
        axios.post('/find_messages', {
          fr_account: friend.fr_account
        }).then((res)=>{
          this.bubble_ids = []
          for(let message of res.data.messages){
            if(message.message_type=="carousel"){
              this.bubble_ids.push(message.contents)
            }
            let time = message.created_at+""
            message.created_at = time.substr(0,19).replace('T'," ")
          }
          this.messages = res.data.messages
          this.personalLinkBtn = '詳細ページ'
          this.fetchBubbles(this.bubble_ids.toString())
        }, (error)=>{
          console.log(error)
        })
      },
      showFriend(req){
        for(let friend of this.friendsList){
          let time = friend.created_at+""
          friend.created_at = time.substr(0,19).replace('T'," ")
          if(friend.fr_account==req){
            this.friend = friend
          }
        }
      },
      getImgUrl(para) {
        var images = 'https://cdn.lineml.jp/api/media/sticker/'+para
        return images
      },
      mapConvert(contents){
        let tempArr = contents.split("+")
        const tempLength = tempArr[1].length
        tempArr = tempArr[1].substring(6,tempLength-2).split(",")
        tempArr[0] = tempArr[0]*1
        tempArr[1] = tempArr[1]*1
        return {lat: tempArr[0], lng: tempArr[1]}
      },
      fetchBubbles(ids){
        this.loading = true
        axios.post('/api/fetch_bubbles_archives',{
          ids: ids
        }).then((res)=>{
          this.bubbles = []
          this.resultHeaderCSS = []
          this.resultImageCSS = []
          this.resultHeroCSS = []
          this.resultBodyCSS = []
          this.resultFooterCSS = []
          for(var bubble of res.data){
            this.bubbles.push(bubble)
            var headerResult = {'display':'flex'}
            var imageResult = {}
            var heroResult = {'display':'flex', 'align-items': 'center'}
            var bodyResult = {'display':'flex'}
            var footerResult = {'display':'flex'}

            headerResult = this.gravityResultConverter(bubble.header_gravity,headerResult)
            headerResult = this.alignResultConverter(bubble.header_align,headerResult)
            headerResult = this.boldResultConverter(bubble.header_bold,headerResult)
            headerResult = this.sizeResultConverter(bubble.header_size,headerResult)
            headerResult = this.colorResultConverter(bubble.header_color,headerResult)
            headerResult = this.backgroundResultConverter(bubble.header_background,headerResult)

            heroResult = this.alignResultConverter(bubble.hero_align,heroResult)
            heroResult = this.backgroundResultConverter(bubble.hero_background,heroResult)

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
            this.resultHeroCSS.push(heroResult)
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
      bubbleChecker(bubble,contents){
        var temp = contents.split(",")
        for(var id of temp){
          if(bubble.id==id*1){
            return {'display': 'inline-block'}
          }
        }
        return {'display':'none'}
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
      nextTip(){
        this.tipsPage = this.tipsPage + 1
        this.tipsChecker(this.tipsPage)
      },
      prevTip(){
        this.tipsPage = this.tipsPage - 1
        this.tipsChecker(this.tipsPage)
      },
      tipsChecker(page){
        switch(page){
          case 0:
          this.topCover = {'height':'7.5%'}
          this.bottomCover = {'height':'84%'}
          this.leftCover = {'width':'14.5%'}
          this.rightCover = {'width':'63.5%'}
          this.focusLineCSS = {'width':'22%','height':'7.5%','left':'14.5%','top':'8%'}
          this.explanationCSS = {'right':'55%','top':'17%','width': '30%','height': '18%'}
          break;
          case 1:
          this.topCover = {'height':'7.5%'}
          this.bottomCover = {'height':'84%'}
          this.leftCover = {'width':'36.5%'}
          this.rightCover = {'width':'21.5%'}
          this.focusLineCSS = {'width':'42%','height':'7.5%','left':'36.5%','top':'8%'}
          this.explanationCSS = {'right':'34%','top':'17%','width': '30%','height': '18%'}
          break;
          case 2:
          this.topCover = {'height':'7.5%'}
          this.bottomCover = {'height':'84%'}
          this.leftCover = {'width':'78.5%'}
          this.rightCover = {'width':'0.5%'}
          this.focusLineCSS = {'width':'21%','height':'7.5%','left':'78.5%','top':'8%'}
          this.explanationCSS = {'right':'1%','top':'17%','width': '30%','height': '18%'}
          break;
          case 3:
          this.topCover = {'height':'92.5%'}
          this.bottomCover = {'height':'0%'}
          this.leftCover = {'width':'36.5%'}
          this.rightCover = {'width':'21.5%'}
          this.focusLineCSS = {'width':'42%','height':'7.5%','left':'36.5%','top':'92.5%'}
          this.explanationCSS = {'right':'21%','top':'73%','width': '30%','height': '18%'}
          break;
          case 4:
          this.topCover = {'height':'18.5%'}
          this.bottomCover = {'height':'76%'}
          this.leftCover = {'width':'67%'}
          this.rightCover = {'width':'19.3%'}
          this.focusLineCSS = {'width':'13.6%','height':'5.5%','left':'67%','top':'18.5%'}
          this.explanationCSS = {'right':'9%','top':'26%','width': '30%','height': '18%'}
          break;
          case 5:
          this.topCover = {'height':'18.5%'}
          this.bottomCover = {'height':'76%'}
          this.leftCover = {'width':'83.5%'}
          this.rightCover = {'width':'8.5%'}
          this.focusLineCSS = {'width':'8%','height':'5.5%','left':'83.5%','top':'18.5%'}
          this.explanationCSS = {'right':'1%','top':'26%','width': '30%','height': '18%'}
          break;
          case 6:
          this.topCover = {'height':'18.5%'}
          this.bottomCover = {'height':'76%'}
          this.leftCover = {'width':'83.5%'}
          this.rightCover = {'width':'8.5%'}
          this.focusLineCSS = {'width':'8%','height':'5.5%','left':'83.5%','top':'18.5%'}
          this.explanationCSS = {'right':'1%','top':'26%','width': '30%','height': '18%'}
          break;
          case 7:
          this.topCover = {'height':'18.5%', 'opacity':'80%'}
          this.bottomCover = {'height':'76%'}
          this.leftCover = {'width':'93%'}
          this.rightCover = {'width':'2.5%'}
          this.focusLineCSS = {'width':'4.5%','height':'5.5%','left':'93.1%','top':'18.5%'}
          this.explanationCSS = {'right':'1%','top':'26%','width': '30%','height': '18%'}
          break;
          case 8:
          this.topCover = {'height':'14.5%'}
          this.bottomCover = {'height':'79%'}
          this.leftCover = {'width':'16%'}
          this.rightCover = {'width':'80.6%'}
          this.focusLineCSS = {'width':'3.3%','height':'6.3%','left':'16%','top':'14.5%'}
          this.explanationCSS = {'right':'54%','top':'26%','width': '30%','height': '18%'}
          break;
          case 9:
          this.topCover = {'height':'55.5%'}
          this.bottomCover = {'height':'20%'}
          this.leftCover = {'width':'19.5%'}
          this.rightCover = {'width':'40%'}
          this.focusLineCSS = {'width':'40.2%','height':'24.5%','left':'19.5%','top':'55.5%'}
          this.explanationCSS = {'right':'9%','top':'58%','width': '30%','height': '18%'}
          break;
          case 10:
          this.topCover = {'height':'20.5%'}
          this.bottomCover = {'height':'72.4%'}
          this.leftCover = {'width':'16%'}
          this.rightCover = {'width':'80.6%'}
          this.focusLineCSS = {'width':'3.3%','height':'6.8%','left':'16%','top':'20.6%'}
          this.explanationCSS = {'right':'54%','top':'29%','width': '30%','height': '18%'}
          break;
          case 11:
          this.topCover = {'height':'55.5%'}
          this.bottomCover = {'height':'20%'}
          this.leftCover = {'width':'19.5%'}
          this.rightCover = {'width':'40%'}
          this.focusLineCSS = {'width':'40.2%','height':'24.5%','left':'19.5%','top':'55.5%'}
          this.explanationCSS = {'right':'9%','top':'58%','width': '30%','height': '18%'}
          break;
          case 12:
          this.topCover = {'height':'27%'}
          this.bottomCover = {'height':'66.4%'}
          this.leftCover = {'width':'16%'}
          this.rightCover = {'width':'80.6%'}
          this.focusLineCSS = {'width':'3.3%','height':'6.8%','left':'16%','top':'27%'}
          this.explanationCSS = {'right':'54%','top':'36%','width': '30%','height': '18%'}
          break;
          case 13:
          this.topCover = {'height':'33.7%'}
          this.bottomCover = {'height':'59.4%'}
          this.leftCover = {'width':'16%'}
          this.rightCover = {'width':'80.6%'}
          this.focusLineCSS = {'width':'3.3%','height':'6.8%','left':'16%','top':'33.7%'}
          this.explanationCSS = {'right':'54%','top':'42%','width': '30%','height': '18%'}
          break;
          case 14:
          this.topCover = {'height':'15%'}
          this.bottomCover = {'height':'21.4%'}
          this.leftCover = {'width':'30.5%'}
          this.rightCover = {'width':'49%'}
          this.focusLineCSS = {'width':'20.3%','height':'11%','left':'30.5%','top':'14.7%'}
          this.explanationCSS = {'right':'41%','top':'27%','width': '30%','height': '18%'}
          break;
          case 15:
          this.topCover = {'height':'15%'}
          this.bottomCover = {'height':'20%'}
          this.leftCover = {'width':'18.6%'}
          this.rightCover = {'width':'69%'}
          this.focusLineCSS = {'width':'12.3%','height':'65.8%','left':'18.7%','top':'14%'}
          this.explanationCSS = {'right':'38%','top':'27%','width': '30%','height': '18%'}
          break;
          case 16:
          this.topCover = {'height':'74.7%'}
          this.bottomCover = {'height':'25.2%'}
          this.leftCover = {'width':'51%'}
          this.rightCover = {'width':'29%'}
          this.focusLineCSS = {'width':'20%','height':'61.2%','left':'51%','top':'14.7%'}
          this.explanationCSS = {'right':'50%','top':'15%','width': '30%','height': '18%'}
          break;
          case 17:
          this.topCover = {'height':'74.7%'}
          this.bottomCover = {'height':'20.4%'}
          this.leftCover = {'width':'30.5%'}
          this.rightCover = {'width':'49%'}
          this.focusLineCSS = {'width':'20.3%','height':'4.8%','left':'30.5%','top':'74.7%'}
          this.explanationCSS = {'right':'18%','top':'72%','width': '30%','height': '18%'}
          break;
          case 18:
          this.topCover = {'height':'39.7%'}
          this.bottomCover = {'height':'53.4%'}
          this.leftCover = {'width':'16%'}
          this.rightCover = {'width':'80.5%'}
          this.focusLineCSS = {'width':'3.3%','height':'6.8%','left':'16%','top':'40%'}
          this.explanationCSS = {'right':'50%','top':'39%','width': '30%','height': '18%'}
          break;
          case 19:
          this.topCover = {'height':'8.7%'}
          this.bottomCover = {'height':'22.4%'}
          this.leftCover = {'width':'38.5%'}
          this.rightCover = {'width':'40%'}
          this.focusLineCSS = {'width':'14.3%','height':'7.5%','left':'41.5%','top':'9%'}
          this.explanationCSS = {'right':'13%','top':'8%','width': '30%','height': '18%'}
          break;
          case 20:
          this.topCover = {'height':'13.7%'}
          this.bottomCover = {'height':'13.4%'}
          this.leftCover = {'width':'59%'}
          this.rightCover = {'width':'0%'}
          this.focusLineCSS = {'width':'40.5%','height':'72.5%','left':'59.2%','top':'13.6%'}
          this.explanationCSS = {'right':'41.5%','top':'15%','width': '30%','height': '18%'}
          break;
          case 21:
          this.topCover = {'height':'7.5%'}
          this.bottomCover = {'height':'86.4%'}
          this.leftCover = {'width':'92.6%'}
          this.rightCover = {'width':'0%'}
          this.focusLineCSS = {'width':'6.5%','height':'6%','left':'92.7%','top':'7.6%'}
          this.explanationCSS = {'right':'1%','top':'15%','width': '30%','height': '18%'}
          break;
        }
        if(page==this.tips.length-1){
          this.nextWord = '完了'
        } else if(page==this.tips.length){
          this.closeAll();
        }else {
          this.nextWord = '次へ'
        }
        if(page>7&&page<this.tips.length){
          this.replyShow = true;
        } else {
          this.replyShow = false;
        }
        if(page==9){
          this.stampShow = true
        } else {
          this.stampShow = false
        }
        if(page==11){
          this.emojiShow = true
        } else {
          this.emojiShow = false
        }
        if(page==14){
          this.stretchCarouselToggle();
        }
        if(page>13&&page<18){
          this.carouselAreaShow = true
        } else {
          this.carouselAreaShow = false
        }
        if(page==19){
          this.mapShow = true
        } else{
          this.mapShow = false
        }
      },
    },
    updated(){
      this.$nextTick(function(){
        var profile = this.$refs.profile_image
        if(profile != null){
          if( profile.src != '' && profile.complete == true && profile.naturalWidth == 0 ){
            this.friend.profile_pic = null
          }
        }
      })
    }
  }
</script>
<style scoped src="../components/PersonalMessages/personalMessages.css"/>