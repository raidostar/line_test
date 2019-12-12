<template>
  <div class="page" id="page4">
    <div class="col col-left">
      <div class="label">
        <i class="material-icons people">group</i>
        友達リスト
      </div>
      <ul class="friendsList">
        <li v-for="friend in friendsList">
          <button class="frBtn" v-if="friend==selectedFriend" style="background-color: #aac5F2">
            <img :src="friend.profile_pic" class="profile_img">
            <span class="profile-name">{{friend.fr_name}}</span>
          </button>
          <button class="frBtn" v-else @click="fetchMessages(friend)">
            <img :src="friend.profile_pic" class="profile_img">
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
          <div class="chatting-line" v-if="msg.check_status!='answered'">
            <div class="balloon-left" v-if="msg.message_type=='text'">
              <span v-html="msg.contents">{{msg.contents}}</span>
            </div>
            <div class="balloon-leftimage" v-else-if="msg.message_type=='stamp'">
              <img class="attachedStamp" :src="getImgUrl(msg.contents)"/>
            </div>
            <div class="balloon-leftimage" v-else-if="msg.message_type=='image'">
              <img class="attachedImg" :src="msg.image.url+''">
            </div>
          </div>
          <div v-else>
            <div class="balloon-right" v-if="msg.message_type=='text'">
              <span v-html="msg.contents">{{msg.contents}}</span>
            </div>
            <div class="balloon-image" v-else-if="msg.message_type=='stamp'">
              <img :src="getImgUrl(msg.contents)" style="width: 10em;"/>
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
                          <div class="header-text rounder1" v-html="bubble.header" >
                          </div>
                        </div>
                        <div class="result-blocks hero-block" v-show="bubble.image.url">
                          <div class="carousel-img-area" style="bottom: -1%; display: grid; align-items: center;justify-content: center;">
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
  <div v-show="loading" class="waiting-screen">
    <div class="spinner">
      <div class="bounce1"></div>
      <div class="bounce2"></div>
      <div class="bounce3"></div>
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
        resultHeroCSS: [],
        resultBodyCSS: [],
        resultFooterCSS: [],
        bubbles: [],
        bubble_ids: [],
        loading: true,
      }
    },
    mounted: function(){
      this.fetchFriends();
      //setInterval(this.fetchFriends(), 1000);
    },
    methods: {
      fetchFriends(){
        this.loading = true
        axios.get('/api/friends').then((res) => {
          //console.log(res.data.friends)
          this.friendsList = res.data.friends
          this.fetchMessages(this.friendsList[0])
        }, (error) => {
          console.log(error)
        })
      },
      fetchMessages(friend){
        this.selectedFriend = friend
        this.personalLink = '/personalPage/'+friend.id
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
        //console.log(req);
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
      fetchBubbles(ids){
        this.loading = true
        axios.post('api/fetch_bubbles_archives',{
          ids: ids
        }).then((res)=>{
          this.bubbles = []
          this.resultHeaderCSS = []
          this.resultBodyCSS = []
          this.resultFooterCSS = []
          for(var bubble of res.data){
            this.bubbles.push(bubble)
            var headerResult = {'display':'grid'}
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
          //console.log(this.bubbles)
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
      // mouseScroll(){
      //   let height = this.$refs.result.clientHeight
      //   let scrollTop = this.$refs.result.scrollTop
      //   let scrollHeight = this.$refs.result.scrollHeight
      //   console.log(height)
      //   console.log(scrollTop)
      //   console.log(scrollHeight)
      //   scrollTop = scrollHeight - height
      //   console.log(scrollTop)
      //   this.$refs.result.scrollTop = scrollTop
      // },
    }
  }
</script>
<style scoped src="../components/page4/page4.css"/>