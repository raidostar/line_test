<template>
  <div class="page" id="page11">
    <div class="title area">
      <h2 class="title">友達追加メッセージ設定<hr/></h2>
      <div style="float: left;" class="settings">
        <i class="material-icons setting-icon" @click="detailToggle">settings</i>
      </div>
      <transition name="fadeInOut">
        <div class="personDetails" v-if="detailShow">
          <div class="detail panel-left">

          </div>
          <div class="detail panel-right">

          </div>
        </div>
      </transition>
    </div>
    <div>
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
      <button class="sendBtn okBtn">セーブ</button>
      <button class="sendBtn cancelBtn" @click="resetReply">再作成</button>
    </div>
  </div>
</div>
</div>
</template>
<script>
  import axios from 'axios'
  import {gmapApi} from 'vue2-google-maps'
  export default {
    name: 'followEvent',
    data: function(){
      return {
        reverseMessageList: [],
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
        detailShow: false,
      }
    },
    mounted: function(){
      this.fetchEmojis();
      this.fetchStamps();
    },
    methods: {
      detailToggle(){
        this.detailShow = !this.detailShow
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
      mapConvert(contents){
        let tempArr = contents.split("+")
        const tempLength = tempArr[1].length
        tempArr = tempArr[1].substring(6,tempLength-2).split(",")
        tempArr[0] = tempArr[0]*1
        tempArr[1] = tempArr[1]*1
        return {lat: tempArr[0], lng: tempArr[1]}
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
    }
  }
</script>
<style scoped src="../components/page11/page11.css"/>
