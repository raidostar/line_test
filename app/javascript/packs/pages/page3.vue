<template>
  <div class="page" id="page3">
    <transition name="fadeInOut">
      <div v-show="!replyShow">
        <div>
          <div>
            <h2 class="title">トーク一覧<hr/></h2>
            <i @click="fetchMessage" class="material-icons loop">loop</i><br/>
            <div class="search-keyword">
              <input class="searchBar" @keydown.enter="searchMessage" placeholder="検索" v-model="searchKey"/>
              <button class="searchBtn" @click="searchMessage"><i class="material-icons" style="color: grey;">search</i></button>
            </div>
            <div class="setting">
              <select v-model="parPage" @change="resetPage">
                <option value=5>5ライン別表示</option>
                <option value=10>10ライン別表示</option>
                <option value=50>50ライン別表示</option>
                <option value=100>100ライン別表示</option>
                <option value=500>500ライン別表示</option>
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
            <th>返事する</th>
          </tr>
          <tr v-for="msg in getMessage" v-model="messageList">
            <td><span>{{ msg.created_at }}</span></td>
            <td>{{ msg.sender }}</td>
            <td v-if="msg.message_type=='stamp'">
              <a @click="detailImage(msg.contents)">
                <img class="stampBtnImg" :src="msg.contents"/>
              </a>
            </td>
            <td v-else-if="msg.message_type=='image'">
              <a @click="detailImage(msg.contents)">
                <img class="stampBtnImg" :src="msg.contents"/>
              </a>
            </td>
            <td v-else>
              <a v-if="msg.contents.search('<img src=')>=0"
                @click="showFullContents(msg.contents)"
                v-html="msg.contents.substr(0,100)"
                >
              </a>
              <a v-else @click="showFullContents(msg.contents)">
                <span v-if="msg.contents.length>19" v-html="msg.contents.substr(0,20)+'...'"></span>
                <span v-else v-html="msg.contents.substr(0,20)"></span>
              </a>
            </td>
            <td>{{ msg.message_type }}</td>
            <td v-if="msg.check_status=='autoReplied'">自動返事</td>
            <td v-else-if="msg.check_status=='replied'">直接返事</td>
            <td v-else-if="msg.check_status=='urgent'" style="color: red;">要対応</td>
            <td v-else-if="msg.check_status=='checked'">確認完了</td>
            <td v-else-if="msg.check_status=='unreplied'" style="color: blue;">未返事</td>
            <td v-else style="color: grey;">未確認</td>
            <td v-if="msg.check_status=='autoReplied'||msg.check_status=='replied'||msg.check_status=='checked'" >
              <button class="replyBtn" @click="replyMessage(msg)" style="color: green;">
                処理完了
              </button>
            </td>
            <td v-else><button class="replyBtn" @click="replyMessage(msg)">返事</button></td>
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
  </transition>
  <transition name="fadeInOut">
    <div v-show="replyShow">
      <div>
        <button v-show="replyShow" @click="checkMessage" class="allSend-button" style="background-color: #2C3250; color: white;">
          確認処理
        </button>
        <button v-show="replyShow" @click="messageToggle" class="allSend-button">戻り</button>
      </div>
      <div class="right-panel" >
        <!-- side buttons -->
        <div class="contentBtns">
          <button class="stampBtn" @click="toggleStamp" title="スタンプ追加">
            <i class="material-icons stamp">child_care</i>
          </button>
          <button class="stampBtn" @click="toggleEmoji" title="emoji追加">
            <i class="material-icons stamp">sentiment_satisfied_alt</i>
          </button>
          <label class="stampBtn" title="イメージ追加">
            <i class="material-icons stamp">gif</i>
            <input type="file" @change="onFileChange" class="imageBtn" ref="fileInput" accept="img/*">
          </label>
          <button class="stampBtn"><i class="material-icons stamp">border_color</i></button>
          <button class="stampBtn" @click="mapToggle" title="マップ追加">
            <i class="material-icons stamp">location_on</i>
          </button>
          <button class="stampBtn" title="アクションプレビュー">
            <i class="material-icons stamp">remove_red_eye</i>
          </button>
        </div>
        <div class="resultArea">
          <div class="oneLine" v-for="msg in reverseMessageList">
            <div v-if="(msg.reply_token==replyToken)&&(msg.check_status!='answered')">
              <img :src="selectedFriend.profile_pic" class="profile_img">
              <div class="balloon-left">
                <span>{{msg.contents}}</span>
              </div>
              <span class="left-time">{{msg.created_at}}</span>
            </div>
            <div v-else-if="(msg.reply_token==replyToken)&&(msg.check_status=='answered')">
              <div class="balloon-right">
                <span v-if="msg.message_type=='text'" v-html="msg.contents">{{msg.contents}}</span>
                <span v-else-if="msg.message_type=='stamp'"><img :src="getImgUrl(msg.contents)"/></span>
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
            <span class="right-time">{{msg.created_at}}</span>
          </div>
        </div>
      </div>
      <div class="chattingArea">
        <div v-show="uploadedImage"  class="attachedImgPanel">
          <a class="closeStamp" @click="closeImage" style="margin-right: 1em;">X</a>
          <p>[イメージ]</p>
          <img class="attachedImg" :src="uploadedImage">
        </div>

        <div id="chattingContents" class="chattingContents" contenteditable="true" :style="flexablePadding" @input="sync" v-html="innerContent" v-model="innerContent" ref="chatting" autofocus="autofocus"></div>
        <input type="text" v-model="contents" style="display: none;">

        <!-- stamp list bottom -->
        <div class="sticker-panel" v-show="stampShow">
          <button class="stampBtn" v-for="num in stampNums" @click="selectStamp(num)">
            <img class="stampBtnImg" :src="getImgUrl(num)"/>
          </button>
        </div>

        <!-- emoji list bottom -->
        <div class="sticker-panel" v-show="emojiShow">
          <button class="emojiBtn stampBtn" v-for="emoji in emojis" @click="addEmoji(emoji.img_url)">
            <img class="stampBtnImg" :src="emoji.img_url">
          </button>
        </div>
      </div>

      <!-- stamp image area -->
      <div class="stampArea" v-show="stampAreaShow">
        <a class="closeStamp" @click="closeStamp">X</a>
        <p>[スタンプ]</p>
        <img class="selectStamp" :src="selectStampUrl">
      </div>

      <!--GoogleMap-->
      <div class="googleMap" v-show="mapShow">
        <div class="placeSearch">
          <GmapAutocomplete @place_changed="setPlace"/>
        </div>
        <button style="width: 100%; height: 5%;" id="location" @click="getAddress">
          住所取得
        </button>
        <GmapMap
        :center="default_center"
        :zoom="12"
        map-type-id="terrain"
        style="width: 100%; height: 95%;"
        @center_changed="onCenterChanged"
        >
        <GmapMarker
        :position="marker_center"
        :clickable="true"
        :draggable="false"
        />
      </GmapMap>
    </div>
    <div class="buttons">
      <!-- submit button -->
      <button class="sendBtn okBtn" @click="createReply">送る</button>
      <button class="sendBtn cancelBtn" @click="resetReply">再作成</button>
    </div>
  </div>
</div>
</transition>

<transition name="tadaInOut">
  <div class="detailWindow" v-show="showDetail">
    <div class="detailPanel">
      <a class="closeDetail" @click="closeDetail">X</a>
      <div class="detailContents">
        <div class="detail" readonly="readonly">
          <span v-html="fullContents" v-if="fullContents.search('@map')<0"></span>
          <GmapMap
          v-else
          :center="selected_center"
          :zoom="12"
          map-type-id="terrain"
          style="width: 100%; height: 95%;"
          >
          <GmapMarker
          :position="selected_center"
          :clickable="true"
          :draggable="false"
          />
        </GmapMap>
      </div>
    </div>
  </div>
</div>
</transition>
</div>
</template>

<script>
  import axios from 'axios'
  import {gmapApi} from 'vue2-google-maps'
  export default {
    name: 'MessageList',
    data(){
      return {
        allMessageList: [],
        messageList: [],
        replyList: [],
        reverseMessageList: [],
        parPage: 5,
        currentPage: 1,
        contents: '',
        innerContent:'',
        reactions: [],
        stampNums: [],
        stampShow: false,
        stampAreaShow: false,
        selectStampUrl: null,
        flexablePadding: {},
        parPage: 5,
        currentPage: 1,
        showDetail: false,
        fullContents: '',
        emojis:[],
        emojiShow: false,
        image: null,
        uploadedImage: '',
        imageFile: null,
        mapShow: false,
        default_center: {lat: 35.681236,lng: 139.767125},
        marker_center: {lat: 35.681236,lng: 139.767125},
        text_address: '',
        google: gmapApi,
        replyShow: false,
        selectedCSS: {'background-color': '#AAA', 'color': 'white'},
        mapDisplay: {'display': 'block;'},
        selected_center: null,
        personalMessages: [],
        editMode: false,
        replyToken: '',
        selectedMessage: null,
        selectedFriend: '',
        searchKey:'',
      }
    },
    mounted: function(){
      this.fetchMessage();
      this.fetchEmojis();
      this.fetchStamps();
    },
    methods: {
      fetchMessage(){
        axios.get('/api/messages').then((res) => {
          this.messageList = []
          this.reverseMessageList = []
          for(let message of res.data.messages){
            let time = message.created_at+""
            message.created_at = time.substr(0,19).replace('T'," ")
            if(message.check_status != 'answered'){
              this.messageList.push(message)
            } else {
              this.replyList.push(message)
            }
          }
          var last = res.data.messages.length - 1
          for(var i=last; i>=0; i--){
            this.reverseMessageList.push(res.data.messages[i])
          }
          this.allMessageList = res.data.messages
        }, (error) => {
          console.log(error)
        })
      },
      clickCallback(pageNum){
        this.currentPage = Number(pageNum);
      },
      resetPage(){
        this.currentPage = 1;
      },
      messageToggle(){
        this.emptyAll();
        this.replyShow = !this.replyShow
      },
      emptyAll(){
        this.stampShow= false;
        this.stampAreaShow= false;
        this.emojiShow= false;
        this.marker_center = {lat: 35.681236,lng: 139.767125}
        this.mapShow = false;
        this.uploadedImage = "";
        this.contents = "";
        this.$refs.chatting.innerHTML = "";
        this.editMode = false;
        this.reactionListShow = false;
        this.flexablePadding = {"padding-right": "30px"}
        this.fetchMessage();
      },
      toggleStamp(){
        this.emojiShow = false;
        this.mapShow = false;
        this.stampShow = !this.stampShow
      },
      toggleEmoji(){
        this.stampShow = false;
        this.emojiShow = !this.emojiShow
      },
      onFileChange(e){
        this.stampShow = false;
        this.stampAreaShow = false;
        this.mapShow = false;
        let files = e.target.files || e.dataTransfer.files;
        this.imageFile = files[0]
        this.createImage(files[0]);
      },
      createImage(file){
        let reader = new FileReader();
        this.flexablePadding = {"padding-right": "300px"}
        let vm = this
        reader.onload = (e) => {
          this.uploadedImage = e.target.result;
        }
        reader.readAsDataURL(file);
      },
      closeImage(){
        this.uploadedImage = ''
        this.flexablePadding = {"padding-right": "30px"}
      },
      mapToggle(){
        this.uploadedImage = ""
        this.stampShow = false
        this.stampAreaShow = false
        this.emojiShow = false
        this.mapShow = !this.mapShow
        if (this.mapShow==true){
          this.flexablePadding = {"padding-right": "330px"}
        } else {
          this.flexablePadding = {"padding-right": "30px"}
        }
      },
      onCenterChanged(center){
        this.marker_center = {lat: center.lat(),lng: center.lng()}
      },
      getAddress(){
        var geocoder = new google.maps.Geocoder();
        geocoder.geocode({ 'location':this.marker_center},(results, status)=>{
          if (status == google.maps.GeocoderStatus.OK){
            let address = results[5].formatted_address
            this.innerContent = this.contents + ' ['+address.substr(3,address.length)+'] '
            this.contents += this.innerContent
          }
        });
      },
      setPlace(place){
        this.default_center = place.geometry.location
        this.marker_center = place.geometry.location
      },
      fetchEmojis(){
        axios.get('api/emojis').then((res)=>{
          // console.log("emojis")
          // console.log(res.data.emojis)
          this.emojis = res.data.emojis
        },(error)=>{
          console.log(error)
        })
      },
      sync(e){
        this.contents = e.target.innerHTML
      },
      addEmoji(img_url){
        this.contents += '<img src="'+img_url+'" style="width: 30px;">'
        this.$refs.chatting.innerHTML = this.contents
        this.$refs.chatting.focus();
      },
      closeStamp(){
        this.stampAreaShow = false;
        this.flexablePadding = {"padding-right": "30px"}
      },
      createReply(){
        if (this.reactions.length>=5){
          alert("最大アクション値は５つです。");
          return;
        }
        if(!this.stampAreaShow&&!this.contents&&!this.uploadedImage&&!this.mapShow){//empty
          alert("一応アクションを作成してください。")
          return;
        }
        else if(this.contents&&!this.uploadedImage&&!this.stampAreaShow&&!this.mapShow){//text only
          axios.post('api/direct_reply', {
            message_id: this.selectedMessage.id,
            message_type: 'text',
            contents: this.contents,
          })
          .then((res)=>{
            this.fetchMessage();
            this.emptyAll();
          }, (error) =>{
            console.log(error)
          })
        } else if(this.stampAreaShow&&!this.contents){//stamp only
          let arr = this.selectStampUrl.split('-')
          let target = arr[0]
          axios.post('api/direct_reply',{
            message_id: this.selectedMessage.id,
            message_type: 'stamp',
            contents: target.substr(26,10),
          })
          .then((res)=>{
            this.fetchMessage();
            this.emptyAll();
          },(error)=>{
            console.log(error)
          })
        } else if(this.stampAreaShow&&this.contents){//text+stamp
          if(this.reactions.length>=4){
            alert("最大アクション値は５つです。");
            return;
          }
          axios.post('api/direct_reply',{
            message_id: this.selectedMessage.id,
            message_type: 'text',
            contents: this.contents,
          }).then((res)=>{
            let arr = this.selectStampUrl.split('-')
            let target = arr[0]
            axios.post('/api/reactions',{
              message_id: this.selectedMessage.id,
              message_type: 'stamp',
              contents: target.substr(26,10),
            }).then((res)=>{
              this.fetchMessage();
              this.emptyAll();
            },(error)=>{
              console.log(error)
            })
          },(error)=>{
            console.log(error)
          })
        } else if(!this.contents&&this.uploadedImage){//only image
          var data = new FormData()
          var file = this.$refs.fileInput.files[0]
          data.append('message_id', this.selectedMessage.id)
          data.append('message_type','image')
          data.append('contents','[NO_TEXT]')
          data.append('image',file)
          axios.post('api/direct_reply',data)
          .then((res)=>{
            this.fetchMessage();
            this.emptyAll();
          },(error)=>{
            console.log(error)
          })
        } else if(this.contents&&this.uploadedImage){//text+image
          if(this.reactions.length>=4){
            alert("最大アクションは五つです。");
            return;
          }
          axios.post('api/direct_reply',{
            message_id: this.selectedMessage.id,
            reaction_type: 'text',
            contents: this.contents,
          }).then((res)=>{
            var data = new FormData();
            var file = this.$refs.fileInput.files[0];
            data.append('message_id', this.selectedMessage.id);
            data.append('message_type','image');
            data.append('contents','[ IMAGE ]');
            data.append('image',file);
            axios.post('api/direct_reply',data)
            .then((res)=>{
              this.fetchMessage();
              this.emptyAll();
            },(error)=>{
              console.log(error)
            })
          },(error)=>{
            console.log(error)
          })
        } else if(!this.contents&&this.mapShow){//only map
          let geocoder = new google.maps.Geocoder();
          const latlng = this.marker_center
          geocoder.geocode({'location':this.marker_center,'language': 'ja'},(results,status)=>{
            if(status == 'OK'){
              console.log(results)
              let data = '['+results[5].formatted_address+']+[@map('+latlng.lat+','+latlng.lng+')]'
              axios.post('api/direct_reply',{
                message_id: this.selectedMessage.id,
                message_type: 'map',
                contents: data,
              }).then((res)=>{
                this.fetchMessage();
                this.emptyAll();
              },(error)=>{
                console.log(error)
              })
            }
          })
        } else {//text+map
          if(this.reactions.length>=4){
            alert("最大アクションは五つです。");
            return;
          }
          axios.post('api/direct_reply',{
            message_id: this.selectedMessage.id,
            message_type: 'text',
            contents: this.contents,
          }).then((res)=>{
            let geocoder = new google.maps.Geocoder();
            const latlng = this.marker_center
            geocoder.geocode({'location':this.marker_center,'language': 'ja'},(results,status)=>{
              if(status == 'OK'){
                console.log(results)
                let data = '['+results[5].formatted_address+']+[@map('+latlng.lat+','+latlng.lng+')]'
                axios.post('api/direct_reply',{
                  message_id: this.selectedMessage.id,
                  message_type: 'map',
                  contents: data,
                }).then((res)=>{
                  this.fetchMessage();
                  this.emptyAll();
                },(error)=>{
                  console.log(error)
                })
              }
            })
          },(error)=>{
            console.log(error)
          })
        }
      },
      resetReply(){
        this.stampShow= false;
        this.stampAreaShow= false;
        this.emojiShow= false;
        this.marker_center = {lat: 35.681236,lng: 139.767125}
        this.mapShow = false;
        this.uploadedImage = "";
        this.contents = "";
        this.$refs.chatting.innerHTML = "";
      },
      getImgUrl(para) {
        var images = require.context('../images/', false, /\.png$/)
        return images('./' + para + ".png")
      },
      detailImage(url){
        let imageHTML = '<img src='+url+' style="width: 21em;height: 26em;">'
        this.fullContents = imageHTML;
        this.showDetail = true;
      },
      closeDetail(){
        this.showDetail = false
      },
      showFullContents(contents){
        if (contents.search("@map")>=0){
          var tempArr = this.mapConvert(contents)
          // tempArr[0] = tempArr[0]*1
          // tempArr[1] = tempArr[1]*1
          this.selected_center = tempArr
        }
        this.fullContents = contents;
        this.showDetail = true;
      },
      mapConvert(contents){
        let tempArr = contents.split("+")
        const tempLength = tempArr[1].length
        tempArr = tempArr[1].substring(6,tempLength-2).split(",")
        tempArr[0] = tempArr[0]*1
        tempArr[1] = tempArr[1]*1
        return {lat: tempArr[0], lng: tempArr[1]}
      },
      replyMessage(msg){
        this.messageToggle();
        this.replyToken = msg.reply_token
        this.selectedMessage = msg
        this.loadProfile(msg.fr_account)
        axios.post('api/read_message',{
          id: msg.id
        }).then((res)=>{
          this.fetchMessage();
        },(error)=>{
          console.log(error)
        })
      },
      fetchStamps(){
        for(let i=1; i<47;i++){
          let add = '1_'+i
          this.stampNums.push(add)
        }
        for(let i=100; i<180;i++){
          let add = '1_'+i
          this.stampNums.push(add)
        }
        for(let i=401; i<431;i++){
          let add = '1_'+i
          this.stampNums.push(add)
        }
        for(let i=501; i<528;i++){
          let add = '1_'+i
          this.stampNums.push(add)
        }
      },
      selectStamp(num){
        this.uploadedImage = "";
        this.stampAreaShow = true
        let images = require.context('../images/', false, /\.png$/)
        this.selectStampUrl = images('./' + num + ".png")
        this.flexablePadding = {"padding-right": "300px"}
      },
      loadProfile(fr_account){
        axios.post('api/by_fr_account',{
          fr_account: fr_account
        }).then((res)=>{
          this.selectedFriend = res.data
          console.log(this.selectedFriend)
        },(error)=>{
          console.log(error)
        })
      },
      searchMessage(){
        if(this.searchKey.length==0) {
          this.fetchMessage();
        } else {
          let searchResult = []
          for(let msg of this.messageList){
            if(msg.contents.search(this.searchKey)>-1){
              searchResult.push(msg)
            }
          }
          this.messageList = searchResult
        }
      },
      checkMessage(){
        axios.post('api/check_message',{
          id: this.selectedMessage.id
        }).then((res)=>{
          this.messageToggle();
        },(error)=>{
          console.log(error)
        })
      },
    },
    computed: {
      getMessage(){
        let current = this.currentPage * this.parPage;
        let start = current - this.parPage;
        return this.messageList.slice(start, current);
      },
      getPageCount(){
        return Math.ceil(this.messageList.length / this.parPage)
      },
    }
  }
</script>

<style scoped src="../components/page3/page3.css"/>