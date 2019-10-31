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
            <p>友達新規登録メッセージ配信</p>
            <div class="inline-radio" v-if="welcome_bool">
              <div><button type="button" style="background: #28a745;">ON</button></div>
              <div><button type="button" @click="welcomeToggle">OFF</button></div>
            </div>
            <div class="inline-radio" v-else>
              <div><button type="button" @click="welcomeToggle">ON</button></div>
              <div><button type="button" style="background: #dc3545;">OFF</button></div>
            </div>
          </div>
          <div class="detail panel-right">
            <p>友達再登録メッセージ配信</p>
            <div class="inline-radio" v-if="remind_bool">
              <div><button type="button" style="background: #28a745;">ON</button></div>
              <div><button type="button" @click="remindToggle">OFF</button></div>
            </div>
            <div class="inline-radio" v-else>
              <div><button type="button" @click="remindToggle">ON</button></div>
              <div><button type="button" style="background: #dc3545;">OFF</button></div>
            </div>
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
          <button class="stampBtn" @click="toggleCarousel" title="キャルセル追加">
            <i class="material-icons stamp">border_color</i>
          </button>
          <button class="stampBtn" @click="toggleMap" title="マップ追加">
            <i class="material-icons stamp">location_on</i>
          </button>
        </div>
        <div class="resultArea">
          <div class="oneLine" v-for="reaction in reactions">
            <div v-if="!reaction.bool&&reaction.reaction_type=='text'" style="height: 4em;">
              <img src="" class="profile_img">
              <div class="balloon-left">
                <span v-html="reaction.contents">{{reaction.contents}}</span>
              </div>
              <a class="cancelBtn" @click="reactionDelete(reaction.id)">X</a>
            </div>
            <div v-else-if="!reaction.bool&&reaction.reaction_type!='text'" style="height: 6em;">
              <img src="" class="profile_img">
              <div v-if="reaction.reaction_type!='map'">
                <span v-if="reaction.reaction_type=='stamp'">
                  <img class="attachedStamp" :src="getImgUrl(reaction.contents)" style="width: 4em;" />
                </span>
                <span v-else>
                  <img class="attachedImg" :src="reaction.image.url+''" style="width: 8em;" />
                </span>
                <a class="cancelBtn" @click="reactionDelete(reaction.id)" style="margin-left: 10px;">X</a>
              </div>
              <div v-else>
                <span>
                  <GmapMap
                  :center="mapConvert(reaction.contents)"
                  :zoom="12"
                  map-type-id="terrain"
                  style="width: 16em; height: 16em; float: left;"
                  >
                  <GmapMarker
                  :position="mapConvert(reaction.contents)"
                  :clickable="true"
                  :draggable="false"
                  />
                </GmapMap>
                <a class="cancelBtn" @click="reactionDelete(reaction.id)" style="margin-left: 10px;">X</a>
              </span>
            </div>
          </div>
          <div v-else>
            <div class="balloon-right">
              <span></span>
              <span></span>
              <span><img class="attachedImg"></span>
              <span></span>
            </div>
            <span class="right-time"></span>
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

      <!-- carousel area -->
      <div class="carouselArea" v-show="carouselAreaShow">
        <div class="contol-box">
          <div class="bubble-box" ref="carousel">
            <div class="bubble" v-for="(bubble,index) in bubble_array" v-model="bubble_array">

              <div class="blocks header-block" ref="header" contenteditable="true" v-html="bubble.header" @input="syncHeader(index)">
              </div>
              <input type="text" v-model="headers[index]" style="display: none;">

              <div class="blocks hero-block">
                <label class="stampBtn" title="イメージ追加" style="margin-top: 7.5vh;">
                  <i class="material-icons stamp">add</i>
                  <input type="file" @change="onFileChange" class="imageBtn" ref="fileInput" accept="img/*">
                </label>
              </div>
              <div class="blocks body-block" ref="body" contenteditable="true" v-html="bubble.body" @input="syncBody(index)">
              </div>
              <div class="blocks footer-block" ref="footer" contenteditable="true" v-html="bubble.footer" @input="syncFooter(index)">
              </div>
              <div v-if="index>0">
                <button class="remove-bubble" @click="removeBubble(index)">
                  削　除
                </button>
              </div>
            </div>
          </div>
        </div>
        <div class="add-button">
          <i class="material-icons add-circle" @click="addBubble">
            add_circle_outline
          </i>
        </div>
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
      <button class="sendBtn okBtn" @click="createOption">追加</button>
      <button class="sendBtn okBtn" @click="resetReply">再作成</button>
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
        carouselAreaShow: false,
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
        selectedOption: null,
        reactions: [],
        welcome_bool: null,
        remind_bool: null,
        bubble_num: 0,
        bubble_array: [
        {
          header: 'header',
          image: null,
          body: 'body',
          footer: 'footer'
        }
        ],
        headers: [],
        bodies: [],
        footers: [],
      }
    },
    mounted: function(){
      this.fetchEmojis();
      this.fetchStamps();
      this.fetchReactions();
      this.fetchOption();
    },
    methods: {
      fetchOption(){
        axios.get('api/options?option_type=welcomeReply').then((res)=>{
          this.welcome_bool = res.data.options[0].bool
          if(res.data.options[0].remind_after=='1'){
            this.remind_bool = true
          } else{
            this.remind_bool = false
          }
        },(error)=>{
          console.log(error)
        })
      },
      fetchReactions(){
        axios.post('api/fetch_welcome_reactions').then((res)=>{
          //console.log(res.data)
          for(let reaction of res.data){
            reaction.created_at = reaction.created_at.substr(0,16).replace('T',' ');
          }
          //console.log(res.data.reactions)
          this.reactions = res.data
        },(error)=>{
          console.log(error)
        })
      },
      detailToggle(){
        this.detailShow = !this.detailShow
      },
      toggleStamp(){
        this.mapShow = false
        this.carouselAreaShow = false
        this.emojiShow = false
        this.stampShow = !this.stampShow
      },
      toggleEmoji(){
        this.stampShow = false
        this.stampAreaShow = false
        this.mapShow = false
        this.carouselAreaShow = false
        this.emojiShow = !this.emojiShow
      },
      onFileChange(e){
        this.stampShow = false;
        this.stampAreaShow = false;
        this.carouselAreaShow = false;
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
      toggleCarousel(){
        this.stampShow = false
        this.stampAreaShow = false
        this.emojiShow = false
        this.mapShow = false
        this.carouselAreaShow = !this.carouselAreaShow
      },
      toggleMap(){
        this.uploadedImage = ""
        this.stampShow = false
        this.stampAreaShow = false
        this.carouselAreaShow = false
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
      closeCarousel(){
        this.carouselAreaShow = false;
      },
      createOption(){
        axios.post('api/options',{
          name: 'friend_add_welcome_message',
          tag: 'ALL,',
          target_day: '0,1,2,3,4,5,6',
          target_time: '00:00,00:00',
          option_type: 'welcomeReply',
        }).then((res)=>{
          this.selectedId = res.data.option.id
          this.createReaction();
        },(error)=>{
          console.log(res.data)
        })
      },
      createReaction(){
        if (this.reactions.length>=5){
          alert("最大アクション値は５つです。");
          return;
        }
        if(!this.stampAreaShow&&!this.contents&&!this.uploadedImage&&!this.mapShow){//empty
          alert("一応アクションを作成してください。")
          return;
        }
        else if(this.contents&&!this.uploadedImage&&!this.stampAreaShow&&!this.mapShow){//text only
          if(this.reactions.length>4){
            alert("最大メッセージは５つです。");
            return;
          }
          axios.post('/api/reactions', {
            name: "text_welcome_message",
            reaction_type: 'text',
            contents: this.contents,
            match_option: this.selectedId+',',
            tag: 'ALL',
          })
          .then((res)=>{
            alert("メッセージセーブ完了")
            this.reactionClear();
            this.fetchReactions();
          }, (error) =>{
            console.log(error)
          })
        } else if(this.stampAreaShow&&!this.contents){//stamp only
          if(this.reactions.length>4){
            alert("最大メッセージは５つです。");
            return;
          }
          let arr = this.selectStampUrl.split('-')
          let target = arr[0]
          axios.post('/api/reactions',{
            name: "text_welcome_message",
            reaction_type: 'stamp',
            contents: target.substr(26,10),
            match_option: this.selectedId+',',
            tag: 'ALL',
          })
          .then((res)=>{
            alert("メッセージセーブ完了")
            this.reactionClear();
            this.fetchReactions();
          },(error)=>{
            console.log(error)
          })
        } else if(this.stampAreaShow&&this.contents){//text+stamp
          if(this.reactions.length>4){
            alert("最大メッセージは５つです。");
            return;
          }
          axios.post('/api/reactions',{
            name: "text_welcome_message",
            reaction_type: 'text',
            contents: this.contents,
            match_option: this.selectedId+',',
            tag: 'ALL',
          }).then((res)=>{
            let arr = this.selectStampUrl.split('-')
            let target = arr[0]
            axios.post('/api/reactions',{
              name: "text_welcome_message",
              reaction_type: 'stamp',
              contents: target.substr(26,10),
              match_option: this.selectedId+',',
              tag: 'ALL',
            }).then((res)=>{
              alert("メッセージセーブ完了")
              this.reactionClear();
              this.fetchReactions();
            },(error)=>{
              console.log(error)
            })
          },(error)=>{
            console.log(error)
          })
        } else if(!this.contents&&this.uploadedImage){//only image
          if(this.reactions.length>4){
            alert("最大メッセージは５つです。");
            return;
          }
          var data = new FormData();
          //var file = this.$refs.fileInput.files[0];

          data.append('name', 'text_welcome_message');
          data.append('reaction_type','image');
          data.append('contents','[ NO TEXT ]');
          data.append('image',this.imageFile);
          data.append('tag','ALL');
          data.append('match_option', this.selectedId+',')
          axios.post('/api/reactions',data)
          .then((res)=>{
            alert("メッセージセーブ完了")
            this.reactionClear();
            this.fetchReactions();
          },(error)=>{
            console.log(error)
          })
        } else if(this.contents&&this.uploadedImage){//text+image
          if(this.reactions.length>4){
            alert("最大メッセージは５つです。");
            return;
          }
          axios.post('/api/reactions',{
            name: "text_welcome_message",
            reaction_type: 'text',
            contents: this.contents,
            match_option: this.selectedId+',',
            tag: 'ALL',
          }).then((res)=>{
            var data = new FormData();
            var file = this.$refs.fileInput.files[0];
            data.append('name', 'text_welcome_message');
            data.append('reaction_type','image');
            data.append('contents','[ IMAGE ]');
            data.append('image',file);
            data.append('tag','ALL');
            data.append('match_option', this.selectedId+',')
            axios.post('/api/reactions',data)
            .then((res)=>{
              alert("メッセージセーブ完了")
              this.reactionClear();
              this.fetchReactions();
            },(error)=>{
              console.log(error)
            })
          },(error)=>{
            console.log(error)
          })

        } else if(!this.contents&&this.mapShow){//only map
          if(this.reactions.length>4){
            alert("最大メッセージは５つです。");
            return;
          }
          let geocoder = new google.maps.Geocoder();
          const latlng = this.marker_center
          geocoder.geocode({'location':this.marker_center,'language': 'ja'},(results,status)=>{
            if(status == 'OK'){
              //console.log(results)
              let data = '['+results[5].formatted_address+']+[@map('+latlng.lat+','+latlng.lng+')]'
              axios.post('/api/reactions',{
                name: "text_welcome_message",
                reaction_type: 'map',
                contents: data,
                match_option: this.selectedId+',',
                tag: 'ALL',
              }).then((res)=>{
                alert("メッセージセーブ完了")
                this.reactionClear();
                this.fetchReactions();
              },(error)=>{
                console.log(error)
              })
            }
          })
        } else {//text+map
          if(this.reactions.length>4){
            alert("最大メッセージは５つです。");
            return;
          }
          axios.post('/api/reactions',{
            name: "text_welcome_message",
            reaction_type: 'text',
            contents: this.contents,
            match_option: this.selectedId+',',
            tag: 'ALL',
          }).then((res)=>{
            let geocoder = new google.maps.Geocoder();
            const latlng = this.marker_center
            geocoder.geocode({'location':this.marker_center,'language': 'ja'},(results,status)=>{
              if(status == 'OK'){
                //console.log(results)
                let data = '['+results[5].formatted_address+']+[@map('+latlng.lat+','+latlng.lng+')]'
                axios.post('/api/reactions',{
                  name: "text_welcome_message",
                  reaction_type: 'map',
                  contents: data,
                  match_option: this.selectedId+',',
                  tag: 'ALL',
                }).then((res)=>{
                  alert("メッセージセーブ完了")
                  this.reactionClear();
                  this.fetchReactions();
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
      reactionClear(){
        this.stampShow= false;
        this.stampAreaShow= false;
        this.emojiShow= false;
        this.marker_center = {lat: 35.681236,lng: 139.767125}
        this.mapShow = false;
        this.uploadedImage = "";
        this.contents = "";
        this.$refs.chatting.innerHTML = "";
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
      reactionDelete(id){
        if (confirm("このメッセージを削除しますか。")==true){
          axios.delete('/api/reactions/'+id)
          .then((res)=>{
            this.fetchReactions();
          },(error)=>{
            console.log(error)
          })
        } else {
          return;
        }
      },
      getImgUrl(para) {
        var images = require.context('../images/', false, /\.png$/)
        return images('./' + para + ".png")
      },
      detailImage(url){
        let imageHTML = '<img class="fullSizeImage" src='+url+' style="width: 21em;height: 26em;">'
        this.fullContents = imageHTML;
        this.showDetail = true;
      },
      welcomeToggle(){
        this.welcome_bool = !this.welcome_bool
        axios.post('api/update_option_bool',{
          bool: this.welcome_bool
        }).then((res)=>{
          if(res.data.option.bool){
            alert("友達登録時、メッセージが配信されます。")
          }else{
            alert("友達登録時、メッセージが配信されません。")
          }
        },(error)=>{
          console.log(error)
        })
      },
      remindToggle(){
        this.remind_bool = !this.remind_bool
        axios.post('api/update_option_remind',{
          remind_after: this.remind_bool
        }).then((res)=>{
          if(res.data.option.remind_after=='1'){
            alert("友達再登録時、メッセージが配信されます。")
          } else {
            alert("友達再登録時、メッセージが配信されません。")
          }
        },(error)=>{
          console.log(error)
        })
      },
      addBubble(){
        var bubble = {header: 'header', hero: null, body: 'body', footer: 'footer'}
        this.bubble_array.push(bubble)
      },
      removeBubble(id){
        var start = id
        for(var i=start; i<this.bubble_array.length-1; i++){
          this.bubble_array[i] = this.bubble_array[i+1]
          this.headers[i] = this.headers[i+1]
          this.bodies[i] = this.bodies[i+1]
          this.footers[i] = this.footers[i+1]
        }
        this.bubble_array.pop();
        this.headers.pop();
        this.bodies.pop();
        this.footers.pop();
      },
      syncHeader(index){
        this.headers[index] = this.$refs.body[index].innerHTML
      },
      syncBody(index){
        this.bodies[index] = this.$refs.body[index].innerHTML
      },
      syncFooter(index){
        this.footers[index] = this.$refs.footer[index].innerHTML
      },
    }
  }
</script>
<style scoped src="../components/page11/page11.css"/>
