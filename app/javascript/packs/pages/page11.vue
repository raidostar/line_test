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
        <div class="chattingArea">
          <div v-show="uploadedImage"  class="attachedImgPanel">
            <a class="closeStamp" @click="closeImage" style="margin-right: 1em;">X</a>
            <p>[イメージ]</p>
            <img class="attachedImg" :src="uploadedImage">
          </div>
          <!-- chatting area -->
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

          <!-- submit button -->
          <div class="buttons">
            <button class="sendBtn okBtn" @click="createOption">追加</button>
            <button class="sendBtn okBtn" @click="resetReply">再作成</button>
          </div>
        </div>

        <div class="resultArea">
          <div class="oneLine" v-for="reaction in reactions">
            <div v-if="reaction.reaction_type=='text'" style="margin-bottom: 1em;">
              <img src="" class="profile_img">
              <div class="balloon-left">
                <span v-html="reaction.contents">{{reaction.contents}}</span>
              </div>
              <a class="cancelBtn" @click="reactionDelete(reaction.id)">X</a>
            </div>
            <div v-if="reaction.reaction_type=='carousel'">
              <img src="" class="profile_img">
              <div class="carousel-box" style="margin-bottom: 1em;">
                <div class="bubble-box" style="height: 26em;">
                  <div class="bubble" v-for="(bubble,index) in bubbles" style="height: inherit;">
                    <div style="height: inherit;">
                      <div class="result-blocks header-block">
                        <div class="header-text" v-html="bubble.header">
                        </div>
                      </div>
                      <div class="result-blocks hero-block">
                        <div class="carousel-img-area" v-show="bubble.image.url" style="bottom: -1%;">
                          <img class="carousel-img" :src="bubble.image.url">
                        </div>
                      </div>
                      <div class="result-blocks body-block">
                        <div class="body-text" v-html="bubble.body">
                        </div>
                      </div>
                      <div class="result-blocks footer-block">
                        <div class="footer-text" v-html="bubble.footer">
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <a class="cancelBtn" @click="reactionDelete(reaction.id)">X</a>
            </div>
            <div v-else-if="reaction.reaction_type=='stamp'" style="margin-bottom: 1em;">
              <img src="" class="profile_img">
              <div>
                <span>
                  <img class="attachedStamp" :src="getImgUrl(reaction.contents)" style="width: 4em;"/>
                </span>
                <a class="cancelBtn" @click="reactionDelete(reaction.id)" style="margin-left: 10px;">X</a>
              </div>
            </div>
            <div v-else-if="reaction.reaction_type=='image'" style="margin-bottom: 1em;">
              <img src="" class="profile_img">
              <div>
                <span>
                  <img class="attachedStamp" :src="reaction.image.url" style="width: 20em; height: 15em;" />
                </span>
                <a class="cancelBtn" @click="reactionDelete(reaction.id)" style="margin-left: 10px;">X</a>
              </div>
            </div>
            <div v-else-if="reaction.reaction_type=='map'" style="margin-bottom: 1em;">
              <span>
                <GmapMap :center="mapConvert(reaction.contents)" :zoom="12" map-type-id="terrain" style="width: 16em; height: 16em; float: left;">
                  <GmapMarker :position="mapConvert(reaction.contents)" :clickable="true" :draggable="false"/>
                </GmapMap>
                <a class="cancelBtn" @click="reactionDelete(reaction.id)" style="margin-left: 10px;">X</a>
              </span>
            </div>
          </div>
          <div style="display: none;">
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

      <!-- stamp image area -->
      <div class="stampArea" v-show="stampAreaShow">
        <a class="closeStamp" @click="closeStamp">X</a>
        <p>[スタンプ]</p>
        <img class="selectStamp" :src="selectStampUrl">
      </div>
      <!----------------------------------------------------------------------->
      <!----------------------------------------------------------------------->
      <!----------------------------------------------------------------------->
      <!----------------------------------------------------------------------->
      <!-- carousel area -->
      <transition name="showInOut">
        <div class="carouselArea" v-show="carouselAreaShow" :style="carouselAreaWidth">
          <!-- left-side menu -->
          <div class="control-box">
            <div class="bubble-setting setting-gravity" v-if="selectedComponent!='hero'">
              <span>垂直配置</span>
              <select class="css-option" v-model="gravity" @change="syncGravity">
                <option value="top">上</option>
                <option value="center">中</option>
                <option value="bottom">下</option>
              </select>
            </div>
            <div class="bubble-setting setting-align" v-if="selectedComponent!='footer'||footer_type!='button'">
              <span>水平配置</span>
              <select class="css-option" v-model="align" @change="syncAlign">
                <option value="start">左</option>
                <option value="center">中</option>
                <option value="end">右</option>
              </select>
            </div>
            <div class="bubble-setting setting-size" v-if="selectedComponent!='footer'||footer_type!='button'">
              <span v-if="selectedComponent!='hero'">文字サイズ</span>
              <span v-else>イメージ幅</span>
              <select class="css-option" v-model="size" @change="syncSize">
                <option value="xxs">1</option>
                <option value="xs">2</option>
                <option value="sm">3</option>
                <option value="md">4</option>
                <option value="lg">5</option>
                <option value="xl">6</option>
                <option value="xxl">7</option>
                <option value="3xl">8</option>
                <option value="4xl">9</option>
                <option value="5xl">10</option>
                <option v-if="selectedComponent=='hero'" value="full">full</option>
              </select>
            </div>
            <div class="bubble-setting setting-bold" v-if="selectedComponent!='hero'&&(selectedComponent!='footer'||footer_type!='button')">
              <span>濃さ</span>
              <select class="css-option" v-model="bold" @change="syncBold">
                <option value="regular">普通</option>
                <option value="bold">濃い</option>
              </select>
            </div>
            <div class="bubble-setting color setting-color" v-if="selectedComponent=='hero'">
              <p style="margin-bottom: 0">横:縦</p>
              <input class="color-text" type="number" v-model="heroWidth" style="width: 4em;color: white;text-align: center;" @change="syncRatio">
              :
              <input class="color-text" type="number" v-model="heroHeight" style="width: 4em;color: white;text-align: center;" @change="syncRatio">
            </div>
            <div class="bubble-setting color setting-color" v-if="selectedComponent=='footer'&&footer_type=='button'">
              <p style="margin-bottom: 0">文字色</p>
              <select class="css-option" v-model="color" @change="syncColor" style="margin-bottom: .3em;">
                <option value="#ffffff">白</option>
                <option value="#111111">黒</option>
              </select>
              <div class="color-sample" :style="fontColor" v-model="color"></div>
            </div>
            <div v-else>
              <div class="bubble-setting color setting-color" v-if="selectedComponent!='hero'">
                <p style="margin-bottom: 0">文字色</p>
                <input class="color-text" type="text" v-model="color" @keyup="syncColor">
                <div class="color-sample" :style="fontColor" v-model="color"></div>
              </div>
            </div>
            <div class="bubble-setting color setting-background">
              <p style="margin-bottom: 0">背景色</p>
              <input class="color-text" type="text" v-model="background" @keyup="syncBackground">
              <div class="color-sample" :style="backgroundColor" v-model="backgroundColor"></div>
            </div>
            <div class="bubble-setting setting-footerType" v-if="selectedComponent=='footer'">
              <span>フッタータイプ</span>
              <select class="css-option" v-model="footer_type" @change="syncFooterType">
                <option value="text">テキスト</option>
                <option value="button">ボタン</option>
              </select>
            </div>
            <div class="bubble-setting setting-footerType" v-if="selectedComponent=='footer'&&footer_type=='button'">
              <span>ボタンタイプ</span>
              <select class="css-option" v-model="footer_button" @change="syncFooterButton">
                <option value="uri">リンク</option>
                <option value="message">メッセージ</option>
              </select>
            </div>
            <div class="bubble-setting color setting-url" v-if="selectedComponent=='footer'&&footer_type=='button'&&footer_button=='uri'">
              <p style="margin-bottom: 0">リンクURL</p>
              <input class="uri-text" type="text" v-model="footer_uri" @keyup="syncFooterUri">
            </div>
            <div class="bubble-setting color setting-message" v-if="selectedComponent=='footer'&&footer_type=='button'&&footer_button=='message'">
              <p style="margin-bottom: 0">配信メッセージ</p>
              <input class="uri-text" type="text" v-model="footer_message" @keyup="syncFooterMessage">
            </div>
          </div>
          <!-- main bubble -->
          <div class="carousel-box" :style="carouselBoxWidth">
            <div class="bubble-box" ref="carousel" v-model="bubble_array">
              <div class="bubble" v-for="(bubble,index) in bubble_array" :key="bubble.id">
                <!-- header -->
                <div class="blocks header-block" v-if="selectedComponent=='header'&&selectedBubble==index" style="border: 5px solid red" :style="headerBackground[index]">
                  <div class="component header-text" ref="header" contenteditable="true" v-html="header" @input="syncHeader(index)" :style="headerCSS[index]">
                  </div>
                </div>
                <div class="blocks header-block" @click="selectComponent('header', index)" v-else
                :style="headerBackground[index]">
                <div class="component header-text" ref="header" contenteditable="true" v-html="header" @input="syncHeader(index)" :style="headerCSS[index]">
                </div>
              </div>
              <input type="text" v-model="bubble.header" style="display: none;">

              <!-- hero(image) -->
              <div class="blocks hero-block" v-if="selectedComponent=='hero'&&selectedBubble==index" style="border: 5px solid red">
                <label class="add-label" title="イメージ追加">
                  <i class="material-icons add-bubble-image" v-if="!heros[index]">add</i>
                  <input type="file" @change="onImageChange(index)" class="imageBtn" ref="hero" accept="img/*">
                </label>
                <div class="carousel-img-area" v-show="bubble.hero" :style="heroCSS[index]">
                  <img class="carousel-img" :src="bubble.hero" :style="imageCSS[index]">
                </div>
              </div>
              <div class="blocks hero-block" @click="selectComponent('hero', index)" v-else>
                <label class="add-label" title="イメージ追加">
                  <i class="material-icons add-bubble-image" v-if="!heros[index]">add</i>
                  <input type="file" @change="onImageChange(index)" class="imageBtn" ref="hero" accept="img/*">
                </label>
                <div class="carousel-img-area" v-show="bubble.hero" :style="heroCSS[index]">
                  <img class="carousel-img" :src="bubble.hero" :style="imageCSS[index]">
                </div>
              </div>

              <!-- body -->
              <div class="blocks body-block" v-if="selectedComponent=='body'&&selectedBubble==index" style="border: 5px solid red" :style="bodyBackground[index]">
                <div class="component body-text" ref="body" contenteditable="true" v-html="body" @input="syncBody(index)" :style="bodyCSS[index]">
                </div>
              </div>
              <div class="blocks body-block" @click="selectComponent('body', index)" v-else :style="bodyBackground[index]">
                <div class="component body-text" ref="body" contenteditable="true" v-html="body" @input="syncBody(index)" :style="bodyCSS[index]">
                </div>
              </div>
              <input type="text" v-model="bubble.body" style="display: none;">

              <!-- footer -->
              <div class="blocks footer-block" v-if="selectedComponent=='footer'&&selectedBubble==index" style="border: 5px solid red" :style="footerBackground[index]">
                <div class="component footer-text" ref="footer" contenteditable="true" v-html="footer" @input="syncFooter(index)" :style="footerCSS[index]">
                </div>
              </div>
              <div class="blocks footer-block" @click="selectComponent('footer', index)" v-else :style="footerBackground[index]">
                <div class="component footer-text" ref="footer" contenteditable="true" v-html="footer" @input="syncFooter(index)" :style="footerCSS[index]">
                </div>
              </div>
              <input type="text" v-model="bubble.footer" style="display: none;">
              <div v-if="index>0">
                <button class="remove-bubble" @click="removeBubble(index)">
                  削　除
                </button>
              </div>
            </div>
            <div class="bubble">
              <div class="empty-bubble">
                <div class="add-button" @click="addBubble">
                  <i class="material-icons add-circle">
                    add_circle_outline
                  </i>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="add-button">
          <i class="material-icons open-circle" @click="stretchCarouselToggle" v-if="!carouselOpen">
            keyboard_arrow_right
          </i>
          <i class="material-icons open-circle" @click="stretchCarouselToggle" v-if="carouselOpen">
            keyboard_arrow_left
          </i>
        </div>
      </div>
    </transition>
    <!--GoogleMap-->
    <div class="googleMap" v-show="mapShow">
      <div class="placeSearch">
        <GmapAutocomplete @place_changed="setPlace"/>
      </div>
      <button style="width: 100%; height: 5%;" id="location" @click="getAddress">
        住所取得
      </button>
      <GmapMap :center="default_center" :zoom="12" map-type-id="terrain" style="width: 100%; height: 95%;" @center_changed="onCenterChanged">
        <GmapMarker :position="marker_center" :clickable="true" :draggable="false"/>
      </GmapMap>
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
          header: '', hero: null, body: '', footer: '',
          header_gravity: 'top', header_align: 'start', header_size: 'md', header_bold: 'regular', header_color: '#111111',
          header_background: '#ffffff', hero_size: 'full', hero_align: 'center', hero_background: '#ffffff', hero_ratio: '1:1'
          ,body_gravity: 'top', body_align: 'start', body_size: 'md', body_bold: 'regular', body_color: '#111111',
          body_background: '#ffffff', footer_gravity: 'top', footer_align: 'center', footer_size: 'md', footer_bold: 'regular'
          ,footer_color: '#111111', footer_background: '#ffffff', footer_type: 'text', footer_button: 'uri',footer_uri: '',
          footer_message: ''
        }
        ],
        header: 'header',
        heros: [],
        body: 'body',
        footer: 'footer',
        gravity: 'top',
        align: 'start',
        color: '#111111',
        background: '#ffffff',
        size: 'md',
        bold: 'regular',
        heroWidth: 1,
        heroHeight: 1,
        footer_type: 'text',
        footer_button: 'uri',
        footer_uri: '',
        footer_message: '',
        selectedBubble: null,
        selectedComponent: null,
        carouselOpen: false,
        carouselAreaWidth: {'width': '40.4%'},
        carouselBoxWidth: {'width': '65%'},
        bubbles: [],
        fontColor: {'background-color': '#111111'},
        backgroundColor: {'background-color': '#ffffff'},
        headerCSS: [{'margin-left':'0', 'margin-right':'auto', 'font-size':'15px', 'font-weight':'normal', 'margin-top':'0px', 'color':'#111111', 'background':'#ffffff'}],
        heroCSS: [{'text-align':'center','background-color':'#ffffff'}],
        imageCSS: [{'width':'100%', 'height': 'auto'}],
        imageSize: ['100%'],
        bodyCSS: [{'margin-left':'0', 'margin-right':'auto', 'font-size':'15px', 'font-weight':'normal', 'margin-top':'0px', 'color':'#111111', 'background':'#ffffff'}],
        footerCSS: [{'margin-left':'auto', 'margin-right':'auto', 'font-size':'15px', 'font-weight':'normal', 'margin-top':'0px', 'color':'#111111', 'background':'#ffffff'}],
        headerBackground: [{'background-color':'#ffffff'}],
        bodyBackground: [{'background-color':'#ffffff'}],
        footerBackground: [{'background-color':'#ffffff'}],
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
          if(res.data.length>0){
            this.welcome_bool = res.data.options[0].bool
            if(res.data.options[0].remind_after=='1'){
              this.remind_bool = true
            } else{
              this.remind_bool = false
            }
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
            if(reaction.reaction_type=="carousel"){
              this.fetchBubbles(reaction.contents)
            }
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
      onImageChange(index){
        this.uploadedImage = ""
        this.stampShow = false;
        this.stampAreaShow = false;
        this.mapShow = false;
        this.contents = ""
        this.innerContent = ""

        let files = this.$refs.hero[index].files || this.$refs.hero[index].dataTransfer.files;
        this.heros[index] = files[0]
        this.createCarouselImage(index, files[0]);
      },
      createCarouselImage(index, file){
        let reader = new FileReader();
        let vm = this
        reader.onload = (e) => {
          this.bubble_array[index].hero = e.target.result
        }
        reader.readAsDataURL(file);
      },
      closeImage(){
        this.uploadedImage = ''
        this.flexablePadding = {"padding-right": "30px"}
      },
      toggleCarousel(){
        this.reactionClear();
        this.bubble_array = [{
          header: 'header', hero: null, body: 'body', footer: 'footer',
          header_gravity: 'top', header_align: 'start', header_size: 'md', header_bold: 'regular', header_color: '#111111',
          header_background: '#ffffff', hero_size: 'full', hero_align: 'center', hero_background: '#ffffff', hero_ratio: '1:1'
          ,body_gravity: 'top', body_align: 'start', body_size: 'md', body_bold: 'regular', body_color: '#111111',
          body_background: '#ffffff', footer_gravity: 'top', footer_align: 'center', footer_size: 'md', footer_bold: 'regular'
          ,footer_color: '#111111', footer_background: '#ffffff', footer_type: 'text', footer_button: 'uri',footer_uri: '',
          footer_message: ''
        }]
        // this.headers = []
        // this.heros = []
        // this.bodies = []
        // this.footers = []
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
        this.innerContent = this.contents
        //this.$refs.chatting.innerHTML
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
        if(!this.stampAreaShow&&!this.contents&&!this.uploadedImage&&!this.mapShow&&!this.carouselAreaShow){//empty
          alert("一応アクションを作成してください。")
          return;
        }
        else if(this.contents&&!this.uploadedImage&&!this.stampAreaShow&&!this.mapShow&&!this.carouselAreaShow){//text only
          if(this.reactions.length>4){
            alert("最大メッセージは５つです。");
            return;
          }
          alert(this.contents)
          axios.post('/api/reactions', {
            name: "text_welcome_message",
            reaction_type: 'text',
            contents: this.contents,
            match_option: this.selectedId,
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
            match_option: this.selectedId,
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
            match_option: this.selectedId,
            tag: 'ALL',
          }).then((res)=>{
            let arr = this.selectStampUrl.split('-')
            let target = arr[0]
            axios.post('/api/reactions',{
              name: "text_welcome_message",
              reaction_type: 'stamp',
              contents: target.substr(26,10),
              match_option: this.selectedId,
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
        } else if(!this.contents&&this.uploadedImage&&!this.carouselAreaShow){//only image
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
          data.append('match_option', this.selectedId)
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
            match_option: this.selectedId,
            tag: 'ALL',
          }).then((res)=>{
            var data = new FormData();
            var file = this.$refs.fileInput.files[0];
            data.append('name', 'text_welcome_message');
            data.append('reaction_type','image');
            data.append('contents','[ IMAGE ]');
            data.append('image',file);
            data.append('tag','ALL');
            data.append('match_option', this.selectedId)
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
        } else if(this.carouselAreaShow){//only carousel
          if(this.reactions.length>4){
            alert("最大メッセージは５つです。");
            return;
          }
          for(var bubble of this.bubble_array){
            let bubbleLength = bubble.header.length+bubble.body.length+bubble.footer.length
            if(bubbleLength==0){
              alert("作成されないキャルセルがあります。");
              return;
            }
            if(bubble.header_color.substr(0,1)!='#'&&bubble.header_color.length!=7){
              alert("色の形式が間違います。\n例) #00b900");
              return;
            }else if(bubble.header_background.substr(0,1)!='#'&&bubble.header_background.length!=7){
              alert("色の形式が間違います。\n例) #00b900");
              return;
            }else if(bubble.body_color.substr(0,1)!='#'&&bubble.body_color.length!=7){
              alert("色の形式が間違います。\n例) #00b900");
              return;
            }else if(bubble.body_background.substr(0,1)!='#'&&bubble.body_background.length!=7){
              alert("色の形式が間違います。\n例) #00b900");
              return;
            }else if(bubble.footer_color.substr(0,1)!='#'&&bubble.footer_color.length!=7){
              alert("色の形式が間違います。\n例) #00b900");
              return;
            }else if(bubble.footer_background.substr(0,1)!='#'&&bubble.footer_background.length!=7){
              alert("色の形式が間違います。\n例) #00b900");
              return;
            }else if(bubble.hero_background.substr(0,1)!='#'&&bubble.hero_background.length!=7){
              alert("色の形式が間違います。\n例) #00b900");
              return;
            }
            if(bubble.footer_type=='button'){
              if(bubble.footer_button=='uri'&&bubble.footer_uri.length==0){
                alert("ボタンのURLを入力してください。");
                return;
              } else if(bubble.footer_button=='message'&&bubble.footer_message.length==0){
                alert("ボタンのメッセージを入力してください。");
                return;
              }
            }
          }
          var data = new FormData();
          for(var i=0; i<this.bubble_array.length; i++){
            data.append('headers[]', this.bubble_array[i].header)
            data.append('images[]', this.heros[i])
            data.append('bodies[]', this.bubble_array[i].body)
            data.append('footers[]', this.bubble_array[i].footer)

            data.append('header_gravity[]', this.bubble_array[i].header_gravity)
            data.append('header_align[]', this.bubble_array[i].header_align)
            data.append('header_size[]', this.bubble_array[i].header_size)
            data.append('header_bold[]', this.bubble_array[i].header_bold)
            data.append('header_color[]', this.bubble_array[i].header_color)
            data.append('header_background[]', this.bubble_array[i].header_background)

            data.append('hero_size[]', this.bubble_array[i].hero_size)
            data.append('hero_align[]', this.bubble_array[i].hero_align)
            data.append('hero_background[]', this.bubble_array[i].hero_background)
            data.append('hero_ratio[]', this.bubble_array[i].hero_ratio)

            data.append('body_gravity[]', this.bubble_array[i].body_gravity)
            data.append('body_align[]', this.bubble_array[i].body_align)
            data.append('body_size[]', this.bubble_array[i].body_size)
            data.append('body_bold[]', this.bubble_array[i].body_bold)
            data.append('body_color[]', this.bubble_array[i].body_color)
            data.append('body_background[]', this.bubble_array[i].body_background)

            data.append('footer_gravity[]', this.bubble_array[i].footer_gravity)
            data.append('footer_align[]', this.bubble_array[i].footer_align)
            data.append('footer_size[]', this.bubble_array[i].footer_size)
            data.append('footer_bold[]', this.bubble_array[i].footer_bold)
            data.append('footer_color[]', this.bubble_array[i].footer_color)
            data.append('footer_background[]', this.bubble_array[i].footer_background)
            data.append('footer_type[]', this.bubble_array[i].footer_type)
            data.append('footer_button[]', this.bubble_array[i].footer_button)
            data.append('footer_uri[]', this.bubble_array[i].footer_uri)
            data.append('footer_message[]', this.bubble_array[i].footer_message)
          }
          data.append('bubble_num',this.bubble_array.length)
          axios.post('api/bubbles',data)
          .then((res)=>{
            console.log(res.data)
            const data = res.data.toString()
            axios.post('/api/reactions',{
              name: "text_welcome_message",
              reaction_type: 'carousel',
              contents: data,
              match_option: this.selectedId,
              tag: 'ALL',
            }).then((res)=>{
              //console.log(res.data)
              alert("メッセージセーブ完了")
              this.toggleCarousel();
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
                match_option: this.selectedId,
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
            match_option: this.selectedId,
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
                  match_option: this.selectedId,
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
        var bubble = {
          header: 'header', hero: null, body: 'body', footer: 'footer',
          header_gravity: 'top', header_align: 'start', header_size: 'md', header_bold: 'regular', header_color: '#111111',
          header_background: '#ffffff', hero_size: 'full', hero_align: 'center', hero_background: '#ffffff', hero_ratio: '1:1'
          ,body_gravity: 'top', body_align: 'start', body_size: 'md', body_bold: 'regular', body_color: '#111111',
          body_background: '#ffffff', footer_gravity: 'top', footer_align: 'center', footer_size: 'md', footer_bold: 'regular'
          ,footer_color: '#111111', footer_background: '#ffffff', footer_type: 'text', footer_button: 'uri',footer_uri: '',
          footer_message: ''
        }
        var headerStyle = {
          'margin-left':'0', 'margin-right':'auto', 'font-size':'15px', 'font-weight':'normal', 'margin-top':'0px',
          'color':'#111111','background':'#ffffff'
        }
        var bodyStyle = {
          'margin-left':'0', 'margin-right':'auto', 'font-size':'15px', 'font-weight':'normal', 'margin-top':'0px',
          'color':'#111111', 'background':'#ffffff'
        }
        var footerStyle = {
          'margin-left':'auto', 'margin-right':'auto', 'font-size':'15px', 'font-weight':'normal', 'margin-top':'0px',
          'color':'#111111', 'background':'#ffffff'
        }

        this.bubble_array.push(bubble)

        this.headerCSS.push(headerStyle)
        this.heroCSS.push({'text-align':'center','background-color':'#ffffff'})
        this.imageCSS.push({'width':'100%', 'height': 'auto'})
        this.imageSize.push('100%')
        this.bodyCSS.push(bodyStyle)
        this.footerCSS.push(footerStyle)

        this.headerBackground.push({'background-color':'#ffffff'})
        this.bodyBackground.push({'background-color':'#ffffff'})
        this.footerBackground.push({'background-color':'#ffffff'})
      },
      removeBubble(id){
        var start = id
        for(var i=start; i<this.bubble_array.length-1; i++){
          this.bubble_array[i] = this.bubble_array[i+1]
        }
        this.bubble_array.pop();
      },
      syncHeader(index){
        this.bubble_array[index].header = this.$refs.header[index].innerHTML
      },
      syncBody(index){
        this.bubble_array[index].body = this.$refs.body[index].innerHTML
      },
      syncFooter(index){
        this.bubble_array[index].footer = this.$refs.footer[index].innerHTML
      },
      syncGravity(){
        var i = this.selectedBubble
        switch(this.selectedComponent){
          case 'header':
          this.bubble_array[i].header_gravity = this.gravity
          this.headerCSS[i]['margin-top'] = this.gravityConverter('header', this.size, this.gravity)
          break
          case 'hero':
          break
          case 'body':
          this.bubble_array[i].body_gravity = this.gravity
          this.bodyCSS[i]['margin-top'] = this.gravityConverter('body', this.size, this.gravity)
          break
          case 'footer':
          this.bubble_array[i].footer_gravity = this.gravity
          this.footerCSS[i]['margin-top'] = this.gravityConverter('footer', this.size, this.gravity)
          break
          default:
          console.log("syncGravity error")
        }
      },
      gravityConverter(component,size,gravity){
        let slice = 0
        switch(size){
          case 'xxs':
          case 'xs':
          case 'sm':
          slice = 3
          break
          case 'md':
          slice = 4
          break
          case 'lg':
          slice = 5
          break
          case 'xl':
          slice = 6
          break
          case 'xxl':
          slice = 7
          break
          case '3xl':
          slice = 8
          break
          case '4xl':
          slice = 9
          break
          case '5xl':
          slice = 10
          break
          default:
          console.log("gravityConverter error!")
        }
        let result = 0
        if(component=='header'||component=='body'){
          result = 8.5-(0.55*slice)
        } else {
          result = 6.2-(0.55*slice)
        }
        switch(gravity){
          case 'top':
          return '0'
          break
          case 'center':
          result = result/2
          return result+'vh'
          break
          case 'bottom':
          return result+'vh'
          break
          default:
          console.log('gravityConverter error!')
        }
      },
      syncAlign(){
        var i = this.selectedBubble
        switch(this.selectedComponent){
          case 'header':
          this.bubble_array[i].header_align = this.align
          this.headerCSS[i]['margin-left'] = this.alignConverter(this.align)[0]
          this.headerCSS[i]['margin-right'] = this.alignConverter(this.align)[1]
          break
          case 'hero':
          this.bubble_array[i].hero_align = this.align
          this.heroCSS[i]['text-align'] = this.align
          break
          case 'body':
          this.bubble_array[i].body_align = this.align
          this.bodyCSS[i]['margin-left'] = this.alignConverter(this.align)[0]
          this.bodyCSS[i]['margin-right'] = this.alignConverter(this.align)[1]
          break
          case 'footer':
          this.bubble_array[i].footer_align = this.align
          this.footerCSS[i]['margin-left'] = this.alignConverter(this.align)[0]
          this.footerCSS[i]['margin-right'] = this.alignConverter(this.align)[1]
          break
          default:
          console.log("syncAlign error!")
        }
      },
      alignConverter(align){
        var leftRight = []
        switch(align){
          case 'start':
          leftRight.push('0')
          leftRight.push('auto')
          break
          case 'center':
          leftRight.push('auto')
          leftRight.push('auto')
          break
          case 'end':
          leftRight.push('auto')
          leftRight.push('0')
          break
        }
        return leftRight
      },
      syncSize(){
        var i = this.selectedBubble
        switch(this.selectedComponent){
          case 'header':
          this.bubble_array[i].header_size = this.size
          this.headerCSS[i]['font-size'] = this.sizeConverter('header',this.size)
          break
          case 'hero':
          this.bubble_array[i].hero_size = this.size
          this.imageCSS[i]['width'] = this.sizeConverter('hero',this.size)
          this.imageSize[i] = this.sizeConverter('hero',this.size)
          break
          case 'body':
          this.bubble_array[i].body_size = this.size
          this.bodyCSS[i]['font-size'] = this.sizeConverter('body',this.size)
          break
          case 'footer':
          this.bubble_array[i].footer_size = this.size
          this.footerCSS[i]['font-size'] = this.sizeConverter('footer',this.size)
          break
          default:
          console.log("syncSize error!")
        }
        this.syncGravity()
        this.syncAlign()
      },
      sizeConverter(component,size){
        console.log("size")
        console.log(size)
        switch(size){
          case 'xxs':
          if(component=='hero'){
            return '10%'
          }else {
            return '11px'
          }
          break
          case 'xs':
          if(component=='hero'){
            return '15%'
          }else {
            return '12px'
          }
          break
          case 'sm':
          if(component=='hero'){
            return '20%'
          }else {
            return '13px'
          }
          break
          case 'md':
          if(component=='hero'){
            return '30%'
          }else {
            return '15px'
          }
          break
          case 'lg':
          if(component=='hero'){
            return '40%'
          }else {
            return '20px'
          }
          break
          case 'xl':
          if(component=='hero'){
            return '50%'
          }else {
            return '25px'
          }
          break
          case 'xxl':
          if(component=='hero'){
            return '60%'
          }else {
            return '30px'
          }
          break
          case '3xl':
          if(component=='hero'){
            return '70%'
          }else {
            return '35px'
          }
          break
          case '4xl':
          if(component=='hero'){
            return '80%'
          }else {
            return '40px'
          }
          break
          case '5xl':
          if(component=='hero'){
            return '90%'
          }else {
            return '45px'
          }
          break
          case 'full':
          return '100%'
          break
          default:
          console.log('sizeConverter error!')
        }
      },
      syncRatio(){
        var i = this.selectedBubble
        this.bubble_array[i].hero_ratio = this.heroWidth + ':' + this.heroHeight
        var ratio = this.heroHeight / this.heroWidth
        var reverseRatio = this.heroWidth / this.heroHeight
        var imageWidth = this.imageSize[i]
        if(ratio > 1){
          this.imageCSS[i]['height'] = imageWidth
          var ratioWidth = imageWidth.substring(0,imageWidth.length-1)*reverseRatio
          this.imageCSS[i]['width'] = ratioWidth + '%'
        } else if(ratio==1){
          this.imageCSS[i]['width'] = imageWidth
          this.imageCSS[i]['height'] = 'auto'
        } else{
          var ratioHeight = imageWidth.substring(0,imageWidth.length-1)*ratio
          this.imageCSS[i]['height'] = ratioHeight + '%'
        }
      },
      syncBold(){
        var i = this.selectedBubble
        switch(this.selectedComponent){
          case 'header':
          this.bubble_array[i].header_bold = this.bold
          this.headerCSS[i]['font-weight'] = this.boldConverter(this.bold)
          break
          case 'body':
          this.bubble_array[i].body_bold = this.bold
          this.bodyCSS[i]['font-weight'] = this.boldConverter(this.bold)
          break
          case 'footer':
          this.bubble_array[i].footer_bold = this.bold
          this.footerCSS[i]['font-weight'] = this.boldConverter(this.bold)
          break
          default:
          console.log("syncBold error!")
        }
      },
      boldConverter(bold){
        switch(bold){
          case 'regular':
          return 'normal'
          break
          case 'bold':
          return 'bold'
          break
          default:
          console.log('error!')
        }
      },
      syncColor(){
        this.fontColor = {'background-color': this.color}
        var i = this.selectedBubble
        switch(this.selectedComponent){
          case 'header':
          this.bubble_array[i].header_color = this.color
          this.headerCSS[i]['color'] = this.color
          break
          case 'body':
          this.bubble_array[i].body_color = this.color
          this.bodyCSS[i]['color'] = this.color
          break
          case 'footer':
          this.bubble_array[i].footer_color = this.color
          this.footerCSS[i]['color'] = this.color
          break
          default:
          console.log("error!")
        }
      },
      syncBackground(){
        this.backgroundColor = {'background-color': this.background}
        var i = this.selectedBubble
        switch(this.selectedComponent){
          case 'header':
          this.bubble_array[i].header_background = this.background
          this.headerBackground[i]['background-color'] = this.background
          this.headerCSS[i]['background'] = this.background
          break
          case 'hero':
          this.bubble_array[i].hero_background = this.background
          this.heroCSS[i]['background-color'] = this.background
          break
          case 'body':
          this.bubble_array[i].body_background = this.background
          this.bodyBackground[i]['background'] = this.background
          this.bodyCSS[i]['background'] = this.background
          break
          case 'footer':
          this.bubble_array[i].footer_background = this.background
          this.footerBackground[i]['background'] = this.background
          this.footerCSS[i]['background'] = this.background
          break
          default:
          console.log("error!")
        }
      },
      syncFooterType(){
        var i = this.selectedBubble
        this.bubble_array[i].footer_type = this.footer_type
        if(this.footer_type=='button'){
          this.footerCSS[i]['height'] = '6vh'
          this.footerCSS[i]['width'] = '100%'
          this.footerCSS[i]['font-size'] = '25px'
          this.footerCSS[i]['line-height'] = '6vh'
          this.footerCSS[i]['cursor'] = 'pointer'
          this.color = '#ffffff'
          this.background = '#007bff'
          this.syncColor();
          this.syncBackground();
        } else{
          this.footerCSS[i]['height'] = ''
          this.footerCSS[i]['width'] = ''
          this.footerCSS[i]['font-size'] = '15px'
          this.footerCSS[i]['line-height'] = '100%'
          this.footerCSS[i]['cursor'] = ''
          this.color = '#111111'
          this.background = '#ffffff'
          this.syncColor();
          this.syncBackground();
        }
      },
      syncFooterButton(){
        var i = this.selectedBubble
        this.bubble_array[i].footer_button = this.footer_button
      },
      syncFooterUri(){
        var i = this.selectedBubble
        this.bubble_array[i].footer_uri = this.footer_uri
      },
      syncFooterMessage(){
        var i = this.selectedBubble
        this.bubble_array[i].footer_message = this.footer_message
      },
      syncHeroRatio(){
        var i = this.selectedBubble
        this.bubble_array[i].hero_ratio = this.heroWidth + ':' + this.heroHeight
      },
      selectComponent(type,index){
        this.selectedComponent = type
        this.selectedBubble = index
        switch(type){
          case 'header':
          this.gravity = this.bubble_array[index].header_gravity
          this.align = this.bubble_array[index].header_align
          this.size = this.bubble_array[index].header_size
          this.color = this.bubble_array[index].header_color
          this.background = this.bubble_array[index].header_background
          this.bold = this.bubble_array[index].header_bold
          break
          case 'hero':
          var ratio = this.bubble_array[index].hero_ratio.split(":")
          this.heroWidth = ratio[0]*1
          this.heroHeight = ratio[1]*1
          this.align = this.bubble_array[index].hero_align
          this.size = this.bubble_array[index].hero_size
          this.background = this.bubble_array[index].hero_background
          break
          case 'body':
          this.gravity = this.bubble_array[index].body_gravity
          this.align = this.bubble_array[index].body_align
          this.size = this.bubble_array[index].body_size
          this.color = this.bubble_array[index].body_color
          this.background = this.bubble_array[index].body_background
          this.bold = this.bubble_array[index].body_bold
          break
          case 'footer':
          this.gravity = this.bubble_array[index].footer_gravity
          this.align = this.bubble_array[index].footer_align
          this.size = this.bubble_array[index].footer_size
          this.color = this.bubble_array[index].footer_color
          this.background = this.bubble_array[index].footer_background
          this.bold = this.bubble_array[index].footer_bold
          this.footer_type = this.bubble_array[index].footer_type
          this.footer_button = this.bubble_array[index].footer_button
          this.footer_uri = this.bubble_array[index].footer_uri
          this.footer_message = this.bubble_array[index].footer_message
          break
          default:
          console.log("error")
        }
        this.fontColor = {'background-color': this.color}
        this.backgroundColor = {'background-color': this.background}
      },
      stretchCarouselToggle(){
        this.carouselOpen = !this.carouselOpen
        if(this.carouselOpen){
          this.carouselBoxWidth.width = "82%"
          this.carouselAreaWidth.width = "80%"
        } else {
          this.carouselBoxWidth.width = "65%"
          this.carouselAreaWidth.width = "40.4%"
        }
      },
      fetchBubbles(ids){
        axios.post('api/fetch_bubbles',{
          ids: ids
        }).then((res)=>{
          this.bubbles = [];
          for(var bubble of res.data){
            this.bubbles.push(bubble)
          }
          //console.log(this.bubbles)
        },(error)=>{
          console.log(error)
        })

      }
    }
  }
</script>
<style scoped src="../components/page11/page11.css"/>
