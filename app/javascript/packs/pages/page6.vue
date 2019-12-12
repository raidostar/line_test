<!-- 전체송신 -->
<template>
  <div class="page" id="page6">
    <div v-show="loading" class="waiting-screen">
      <div class="spinner">
        <div class="bounce1"></div>
        <div class="bounce2"></div>
        <div class="bounce3"></div>
      </div>
    </div>
    <div v-show="!loading">
      <div>
        <button class="allSend-button" @click="formToggle" v-show="!formShow">新規配信</button>
        <button class="allSend-button" @click="formToggle" v-show="formShow">リスト見る</button>
      </div>
      <transition name="slideInOut">
        <div class="col col-left" v-show="formShow">
          <div class="left-panel">
            <div class="top-panel">
            <!-- <button class="allSend-button innerBtn innerBtnLeft"></button>
              <button class="allSend-button innerBtn innerBtnRight"></button> -->
            </div>
            <div class="bottom-panel">
              <p class="folder-title">配信する友達グループ</p>
              <div v-for="(tag,index) in tags" class="added-folder">
                <button class="added-folderBtn" id="added-folderBtn" v-if="tag==selectedTag" :style="selectedCSS" @click="selectTag(index)">
                  <i class="material-icons open-file-added" style="margin-left: 1em;">people</i>
                  <span>
                    {{tag}}
                  </span>
                </button>
                <button class="added-folderBtn" id="added-folderBtn" v-else @click="selectTag(index)">
                  <i class="material-icons open-file-added" style="margin-left: 1em;">people</i>
                  <span>
                    {{tag}}
                  </span>
                </button>
              </div>

            </div>
          </div>

          <div class="right-panel">

            <!-- side buttons -->
            <div class="contentBtns">
              <button class="stampBtn" @click="toggleStamp"><i class="material-icons stamp">child_care</i></button>
              <button class="stampBtn" @click="toggleEmoji">
                <i class="material-icons stamp">sentiment_satisfied_alt</i>
              </button>
              <label class="stampBtn">
                <i class="material-icons stamp">gif</i>
                <input type="file" @change="onFileChange" class="imageBtn" ref="fileInput" accept="img/*">
              </label>
              <button class="stampBtn" @click="toggleCarousel" title="キャルセル追加">
                <i class="material-icons stamp">border_color</i>
              </button>
              <button class="stampBtn" @click="toggleMap">
                <i class="material-icons stamp">location_on</i>
              </button>
            </div>

            <div class="chattingArea">
              <div v-show="uploadedImage"  class="attachedImgPanel">
                <a class="closeStamp" @click="closeImage">X</a>
                <p>[イメージ]</p>
                <img class="attachedImg" :src="uploadedImage">
              </div>

              <div id="chattingContents" class="chattingContents" contenteditable="true" :style="flexablePadding" @input="sync" v-html="innerContent" v-model="innerContent" ref="chatting"></div>
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
              <a class="closeStamp" @click="closeStamp" style="float: right;">X</a>
              <p>[スタンプ]</p>
              <img class="selectStamp" :src="selectStampUrl">
            </div>

            <!-- carousel area -->
            <transition name="showInOut">
              <div class="carouselArea" v-show="carouselAreaShow" :style="carouselAreaWidth">
                <!-- left-side menu -->
                <div class="control-box">
                  <div class="bubble-setting setting-gravity" v-if="selectedComponent!='hero'&&(selectedComponent!='footer'||footer_type!='button')">
                    <span>垂直配置</span>
                    <select class="css-option" v-model="gravity" @change="syncGravity">
                      <option value="top">上</option>
                      <option value="center">中</option>
                      <option value="bottom">下</option>
                    </select>
                  </div>
                  <div class="bubble-setting setting-align" v-if="selectedComponent!='hero'&&(selectedComponent!='footer'||footer_type!='button')">
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
                  <div class="bubble-setting color setting-color" style="height: 5.8em;" v-if="selectedComponent=='footer'&&footer_type=='button'">
                    <p style="margin-bottom: 0">文字色</p>
                    <select class="css-option" v-model="color" @change="syncColor" style="margin-bottom: .3em;">
                      <option value="#ffffff">白</option>
                      <option value="#111111">黒</option>
                    </select>
                    <div class="color-sample" :style="fontColor" v-model="color"></div>
                  </div>
                  <div v-else style="height: 5.2em;">
                    <div class="bubble-setting color setting-color" v-if="selectedComponent!='hero'">
                      <p style="margin-bottom: 0">文字色</p>
                      <input class="color-text color-input" type="text" v-model="color" @keyup="syncColor" style="height: 2em; color: white;">
                      <div class="color-sample" :style="fontColor" v-model="color"></div>
                    </div>
                  </div>
                  <button class="colorExchange" @click="exchangeColor" v-if="selectedComponent!='hero'&&(selectedComponent!='footer'||footer_type!='button')">↑ 色逆に ↓</button>
                  <div class="bubble-setting color setting-background" style="height: 6em;">
                    <p style="margin-bottom: 0">背景色</p>
                    <input class="color-text color-input" type="text" v-model="background" @keyup="syncBackground" style="height: 2em; color: white;">
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
                  <div class="design-buttons">
                    <button class="copyChu copy" @click="copyCSS(selectedBubble)">デザインコピー</button>
                    <button class="copyChu paste" v-if="copiedType" @click="pasteCSS">デザイン適用</button>
                  </div>
                  <label class="image-change" title="イメージ変更" v-if="selectedComponent=='hero'&&heros[selectedBubble]!=null">
                    イメージ変更
                    <input type="file" @change="onImageChange" class="imageBtn" ref="hero" accept="img/*">
                  </label>
                  <button class="image-remove" v-if="selectedComponent=='hero'&&heros[selectedBubble]!=null" @click="removeImage">
                    イメージ削除
                  </button>
                </div>

                <!-- main bubble -->
                <div class="carousel-box" :style="carouselBoxWidth">
                  <div class="bubble-box" ref="carousel" v-model="bubble_array">
                    <div class="bubble" v-for="(bubble,index) in bubble_array" :key="bubble.id">
                      <!-- header -->
                      <div class="blocks header-block" v-if="selectedComponent=='header'&&selectedBubble==index" style="border: 5px solid red" :style="headerBackground[index]">
                        <div class="component header-text" ref="header" contenteditable="true" v-html="header[index]" @input="syncHeader(index)" :style="headerCSS[index]">
                        </div>
                      </div>
                      <div class="blocks header-block" @click="selectComponent('header', index)" v-else
                      :style="headerBackground[index]">
                      <div class="component header-text" ref="header" contenteditable="true" v-html="header[index]" @input="syncHeader(index)" :style="headerCSS[index]">
                      </div>
                    </div>
                    <input type="text" v-model="bubble.header" style="display: none;">

                    <!-- hero(image) -->
                    <div class="blocks hero-block" v-if="selectedComponent=='hero'&&selectedBubble==index" style="border: 5px solid red">
                      <label class="add-label" title="イメージ追加">
                        <i class="material-icons add-bubble-image" v-if="!heros[index]">add</i>
                        <input type="file" @change="onImageChange" class="imageBtn" ref="hero" accept="img/*">
                      </label>
                      <div class="carousel-img-area" v-show="bubble.hero" :style="heroCSS[index]">
                        <img class="carousel-img" :src="bubble.hero" :style="imageCSS[index]">
                      </div>
                    </div>
                    <div class="blocks hero-block" @click="selectComponent('hero', index)" v-else>
                      <label class="add-label" title="イメージ追加">
                        <i class="material-icons add-bubble-image" v-if="!heros[index]">add</i>
                        <input type="file" @change="onImageChange" class="imageBtn" ref="hero" accept="img/*">
                      </label>
                      <div class="carousel-img-area" v-show="bubble.hero" :style="heroCSS[index]">
                        <img class="carousel-img" :src="bubble.hero" :style="imageCSS[index]">
                      </div>
                    </div>

                    <!-- body -->
                    <div class="blocks body-block" v-if="selectedComponent=='body'&&selectedBubble==index" style="border: 5px solid red" :style="bodyBackground[index]">
                      <div class="component body-text" ref="body" contenteditable="true" v-html="body[index]" @input="syncBody(index)" :style="bodyCSS[index]">
                      </div>
                    </div>
                    <div class="blocks body-block" @click="selectComponent('body', index)" v-else :style="bodyBackground[index]">
                      <div class="component body-text" ref="body" contenteditable="true" v-html="body[index]" @input="syncBody(index)" :style="bodyCSS[index]">
                      </div>
                    </div>
                    <input type="text" v-model="bubble.body" style="display: none;">

                    <!-- footer -->
                    <div class="blocks footer-block" v-if="selectedComponent=='footer'&&selectedBubble==index" style="border: 5px solid red" :style="footerBackground[index]">
                      <div class="component footer-text" ref="footer" contenteditable="true" v-html="footer[index]" @input="syncFooter(index)" :style="footerCSS[index]">
                      </div>
                    </div>
                    <div class="blocks footer-block" @click="selectComponent('footer', index)" v-else :style="footerBackground[index]">
                      <div class="component footer-text" ref="footer" contenteditable="true" v-html="footer[index]" @input="syncFooter(index)" :style="footerCSS[index]">
                      </div>
                    </div>
                    <input type="text" v-model="bubble.footer" style="display: none;">
                    <div>
                      <button v-if="index==0" class="copy-bubble" @click="copyBubble(index)" style="width: 100%;">
                        複　製
                      </button>
                      <button v-if="index>0" class="copy-bubble" @click="copyBubble(index)">
                        複　製
                      </button>
                      <button v-if="index>0" class="remove-bubble" @click="removeBubble(index)">
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
                  keyboard_arrow_left
                </i>
                <i class="material-icons open-circle" @click="stretchCarouselToggle" v-if="carouselOpen">
                  keyboard_arrow_right
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
            <GmapMap
            :center="default_center"
            :zoom="16"
            map-type-id="terrain"
            style="width: 100%; height: 95%;"
            @center_changed="onCenterChanged"
            >
            <GmapMarker
            :position="info.center"
            :clickable="true"
            :draggable="false"
            />
          </GmapMap>
        </div>
        <!-- submit button -->
        <button class="sendBtn" @click="createNotify">SEND</button>
      </div>

    </div>
  </transition>
  <transition name="slideInOut">
    <div v-show="!formShow">
      <select v-model="parPage" @change="resetPage">
        <option value=5>5ラインで表示</option>
        <option value=10>10ラインで表示</option>
        <option value=50>50ラインで表示</option>
        <option value=100>100ラインで表示</option>
        <option value=500>500ラインで表示</option>
        <option :value="notifies.length">全体表示</option>
      </select>
      <table class="sc-list">
        <tr>
          <th>再送信</th>
          <th>配信先</th>
          <th>内容</th>

          <th>日時</th>
          <th>配信数</th>
          <th>タイプ</th>
        </tr>
        <tr class="notiShow" v-for="notify in getNotify" style="height: 80px;">
          <td>
            <button class="sendAgainBtn" @click="sendAgain(notify.id)">送信</button>
          </td>

          <td v-if="notify.target_tag==null">
            {{notify.receiver}}
          </td>
          <td v-else>
            {{notify.target_tag}}
          </td>

          <td v-if="notify.notify_type=='stamp'">
            <a @click="detailImage(getImgUrl(notify.contents))">
              <img class="stampBtnImg" :src="getImgUrl(notify.contents)"/>
            </a>
          </td>
          <td v-else-if="notify.notify_type=='image'">
            <a @click="detailImage(notify.image.url)">
              <img class="imageResult" :src="notify.image.url"/>
            </a>
          </td>
          <td v-else-if="notify.notify_type=='carousel'">
            <a @click="detailCarousel(notify.contents)">
              <span>キャルセル</span>
            </a>
          </td>
          <td v-else>
            <a v-if="notify.contents.search('<img src=')>=0"
              @click="showFullContents(notify.contents)"
              v-html="notify.contents.substr(0,100)"
              >
            </a>
            <a v-else @click="showFullContents(notify.contents)" >
              <span v-if="notify.contents.length>19" v-html="notify.contents.substr(0,20)+'...'"></span>
              <span v-else v-html="notify.contents.substr(0,20)"></span>
            </a>
          </td>
          <td>{{notify.created_at}}</td>
          <td>{{notify.target_number}}</td>
          <td>{{notify.notify_type}}</td>
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
<transition name="tadaInOut">
  <div class="detailWindow" v-show="showDetail" @click="closeDetail">
    <div class="detailPanel">
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

<transition name="tadaInOut">
  <div class="detailWindow" v-show="showCarousel" @click="closeDetail">
    <div class="result-carousel-box">
      <div class="bubble-box" style="height: 100%; display: inline-flex;">
        <div v-for="(bubble,index) in bubbles">
          <div class="bubble" style="height: 100%;">
            <div style="height: 100%;">
              <div class="result-blocks header-block rounder1">
                <div class="header-text rounder1" v-html="bubble.header" :style="resultHeaderCSS[index]">
                </div>
              </div>
              <div class="result-blocks hero-block">
                <div class="carousel-img-area" v-show="bubble.image.url" style="bottom: -1%; display: grid; align-items: center;justify-content: center;">
                  <img class="carousel-img" :src="bubble.image.url" style="width: 100%;">
                </div>
              </div>
              <div class="result-blocks body-block">
                <div class="body-text" v-html="bubble.body" :style="resultBodyCSS[index]">
                </div>
              </div>
              <div class="result-blocks footer-block" style="line-height: 4.5vh">
                <div class="footer-text rounder2" v-html="bubble.footer" :style="resultFooterCSS[index]">
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</transition>
</div>
</div>
</template>
<script>
  import axios from 'axios'
  import {gmapApi} from 'vue2-google-maps'
  export default {
    name: 'SendAll',
    data: function(){
      return {
        formShow: false,
        tags: ['ALL'],
        contents: '',
        innerContent:'',
        notifies: [],
        stampNums: [],
        sampleAdd: '',
        stampShow: false,
        stampAreaShow: false,
        carouselAreaShow: false,
        selectStampUrl: null,
        flexablePadding: {},
        parPage: 5,
        currentPage: 1,
        showDetail: false,
        showCarousel: false,
        fullContents: '',
        emojis:[],
        emojiShow: false,
        image: null,
        uploadedImage: '',
        imageFile: null,
        mapShow: false,
        default_center: {lat: 35.681236,lng: 139.767125},
        info: {
          center: {lat: 35.681236,lng: 139.767125},
          lat: {min: null, max: null},
          lng: {min: null, max: null}
        },
        text_address: '',
        google: gmapApi,
        selectedTag: '',
        selectedCSS: {'background-color': '#444','color': 'white'},
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
        header: ['header'],
        heros: [],
        body: ['body'],
        footer: ['footer'],
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
        carouselAreaWidth: {'width': '67.7%'},
        carouselBoxWidth: {'width': '76%'},
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
        resultHeaderCSS: [],
        resultHeroCSS: [],
        resultBodyCSS: [],
        resultFooterCSS: [],
        copied: {},
        copiedType: '',
        loading: true,
      }
    },
    mounted: function(){
      this.fetchNotifies();
      this.setStampNum();
      this.fetchEmojis();
      this.fetchTags();
      this.innerContent = this.contents
    },
    methods: {
      fetchTags(){
        axios.get('api/tags?tag_group=friend').then((res)=>{
          for(var t of res.data.tags){
            this.tags.push(t.name)
          }
        },(error)=>{
          console.log(error)
        })
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
      },
      formToggle(){
        this.stampShow= false;
        this.stampAreaShow= false;
        this.emojiShow= false;
        this.info.center = {lat: 35.681236,lng: 139.767125}
        this.mapShow = false
        this.contents = "";
        this.$refs.chatting.innerHTML = ""
        this.formShow = !this.formShow;
      },
      fetchNotifies(){
        this.loading = true
        axios.get('api/notifies').then((res)=>{
          for(let notify of res.data.notifies){
            notify.created_at = notify.created_at.substr(0,16).replace('T',' ');
          }
          //console.log(res.data.notifies)
          this.notifies = res.data.notifies
          this.loading = false
        },(error)=>{
          console.log(error)
        })
      },
      createNotify(){
        if(!this.stampAreaShow&&!this.contents&&!this.uploadedImage&&!this.mapShow&&!this.carouselAreaShow){//empty
          alert("empty")
          alert("一応メッセージを作成してください。")
          return;
        }
        else if(this.contents&&!this.uploadedImage&&!this.stampAreaShow&&!this.mapShow&&!this.carouselAreaShow){//text only
          axios.post('/create_notify', {
            notify_type: 'text',
            contents: this.contents
          }).then((res)=>{
            if (res.data != null){
              alert("メッセージ送信完了！")
              this.formToggle();
              this.fetchNotifies();
            }
          }, (error) =>{
            console.log(error)
          })
        } else if(this.stampAreaShow&&!this.contents){//stamp only
          let arr = this.selectStampUrl.split('-')
          let target = arr[0]
          axios.post('/create_notify',{
            notify_type: 'stamp',
            contents: target.substr(26,10)
          }).then((res)=>{
            alert("メッセージ送信完了！")
          },(error)=>{
            console.log(error)
          })
        } else if(this.stampAreaShow&&this.contents){//text+stamp
          axios.post('/create_notify',{
            notify_type: 'text',
            contents: this.contents
          }).then((res)=>{
            let arr = this.selectStampUrl.split('-')
            let target = arr[0]
            axios.post('/create_notify',{
              notify_type: 'stamp',
              contents: target.substr(26,10)
            }).then((res)=>{
              alert("メッセージ送信完了！")
              this.formToggle();
              this.fetchNotifies();
            },(error)=>{
              console.log(error)
            })
          },(error)=>{
            console.log(error)
          })
        } else if(!this.contents&&this.uploadedImage){//only image
          var data = new FormData();
          var file = this.$refs.fileInput.files[0];
          data.append('notify_type','image');
          data.append('contents','[ NO TEXT ]');
          data.append('image',file);
          axios.post('/create_notify',data)
          .then((res)=>{
            alert("メッセージ送信完了！")
            this.formToggle();
            this.fetchNotifies();
          },(error)=>{
            console.log(error)
          })
        } else if(this.contents&&this.uploadedImage){//text+image
          let data = new FormData();
          let file = this.$refs.fileInput.files[0];
          data.append('notify_type','text+image');
          data.append('contents',this.contents);
          data.append('image',file);
          axios.post('/create_notify',data)
          .then((res)=>{
            alert("メッセージ送信完了！")
            this.formToggle();
            this.fetchNotifies();
          },(error)=>{
            console.log(error)
          })
        } else if(this.carouselAreaShow){//only carousel
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
          axios.post('api/bubbles_archives',data)
          .then((res)=>{
            console.log(res.data)
            const data = res.data.toString()
            axios.post('create_notify',{
              notify_type: 'carousel',
              contents: data
            }).then((res)=>{
              alert("メッセージ送信完了！")
              this.formToggle();
              this.fetchNotifies();
            },(error)=>{
              console.log(error)
            })
          },(error)=>{
            console.log(error)
          })
        } else if(!this.contents&&this.mapShow){//only map
          let geocoder = new google.maps.Geocoder();
          const latlng = this.info.center
          geocoder.geocode({'location':this.info.center,'language': 'ja'},(results,status)=>{
            if(status == 'OK'){
              //console.log(results)
              let data = '['+results[5].formatted_address+']+[@map('+latlng.lat+','+latlng.lng+')]'
              axios.post('/create_notify',{
                notify_type: 'map',
                contents: data
              }).then((res)=>{
                alert("メッセージ送信完了！")
                this.formToggle();
                this.fetchNotifies();
              },(error)=>{
                console.log(error)
              })
            }
          })
        } else {//text+map
          axios.post('/create_notify',{notify_type: 'text',contents: this.contents}).then((res)=>{
            let geocoder = new google.maps.Geocoder();
            const latlng = this.info.center
            geocoder.geocode({'location':this.info.center,'language': 'ja'},(results,status)=>{
              if(status == 'OK'){
                //console.log(results)
                let data = '['+results[5].formatted_address+']+[@map('+latlng.lat+','+latlng.lng+')]'
                axios.post('/create_notify',{notify_type: 'map', contents: data}).then((res)=>{
                  alert("メッセージ送信完了！")
                  this.formToggle();
                  this.fetchNotifies();
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
      getImgUrl(para) {
        var images = require.context('../images/', false, /\.png$/)
        return images('./' + para + ".png")
      },
      setStampNum(){
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
      toggleStamp(){
        this.emojiShow = false;
        this.mapShow = false;
        this.stampShow = !this.stampShow
      },
      selectStamp(num){
        this.uploadedImage = "";
        this.stampAreaShow = true
        var images = require.context('../images/', false, /\.png$/)
        this.selectStampUrl = images('./' + num + ".png")
        this.flexablePadding = {"padding-right": "300px"}
      },
      closeStamp(){
        this.stampAreaShow = false;
        this.flexablePadding = {"padding-right": "30px"}
      },
      resetPage(){
        this.currentPage = 1;
      },
      clickCallback(pageNum){
        this.currentPage = Number(pageNum);
      },
      showFullContents(contents){
        this.showDetail = true;
        this.fullContents = contents;
      },
      closeDetail(){
        this.showDetail = false
        this.showCarousel = false
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
        if(!files[0].type.match(/image.*/)){
          alert("イメージファイルをアップロードしてください。")
          return;
        }
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
      onImageChange(e){
        this.uploadedImage = ""
        this.stampShow = false;
        this.stampAreaShow = false;
        this.mapShow = false;
        this.contents = ""
        this.innerContent = ""

        let files = e.target.files || e.dataTransfer.files;
        var index = this.selectedBubble
        if(!files[0].type.match(/image.*/)){
          alert("イメージファイルをアップロードしてください。")
          return;
        }
        this.heros[index] = files[0]
        this.createCarouselImage(index,files[0]);
      },
      createCarouselImage(index,file){
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
        this.emptyAll();
        this.bubble_array = [{
          header: 'header', hero: null, body: 'body', footer: 'footer',
          header_gravity: 'top', header_align: 'start', header_size: 'md', header_bold: 'regular', header_color: '#111111',
          header_background: '#ffffff', hero_size: 'full', hero_align: 'center', hero_background: '#ffffff', hero_ratio: '1:1'
          ,body_gravity: 'top', body_align: 'start', body_size: 'md', body_bold: 'regular', body_color: '#111111',
          body_background: '#ffffff', footer_gravity: 'top', footer_align: 'center', footer_size: 'md', footer_bold: 'regular'
          ,footer_color: '#111111', footer_background: '#ffffff', footer_type: 'text', footer_button: 'uri',footer_uri: '',
          footer_message: ''
        }]
        this.header = ['header']
        this.body = ['body']
        this.footer = ['footer']
        this.heros = []
        this.carouselAreaShow = !this.carouselAreaShow
      },
      toggleMap(){
        this.uploadedImage = ""
        this.stampShow = false
        this.stampAreaShow = false
        this.emojiShow = false
        this.mapShow = !this.mapShow
        if (this.mapShow==true){
          this.flexablePadding = {"padding-right": "430px"}
        } else {
          this.flexablePadding = {"padding-right": "30px"}
        }
      },
      onCenterChanged(center){
        this.info.center = {lat: center.lat(),lng: center.lng()}
      },
      getAddress(){
        var geocoder = new google.maps.Geocoder();
        geocoder.geocode({ 'location':this.info.center},(results, status)=>{
          if (status == google.maps.GeocoderStatus.OK){
            let address = results[5].formatted_address
            this.innerContent = this.contents + ' ['+address.substr(3,address.length)+'] '
            this.contents += this.innerContent
          }
        });
      },
      setPlace(place){
        this.info.center = place.geometry.location
      },
      detailImage(url){
        let imageHTML = '<img class="fullSizeImage" src='+url+' style="width: 21em;height: 26em;">'
        this.fullContents = imageHTML;
        this.showDetail = true;
      },
      detailCarousel(ids){
        this.fetchBubbles(ids);
        this.showCarousel = true;
      },
      selectTag(index){
        this.selectedTag = this.tags[index]
      },
      sendAgain(id){
        axios.post('api/notify_again',{
          id: id
        }).then((res)=>{
          console.log(res.data)
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
        this.header.push('header')
        this.body.push('body')
        this.footer.push('footer')

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
          this.gravity = 'center'
          this.align = 'center'
          this.color = '#ffffff'
          this.background = '#007bff'
          this.syncGravity();
          this.syncAlign();
          this.syncColor();
          this.syncBackground();
          this.footerCSS[i]['height'] = '6vh'
          this.footerCSS[i]['width'] = '100%'
          this.footerCSS[i]['font-size'] = '25px'
          this.footerCSS[i]['line-height'] = '6vh'
          this.footerCSS[i]['cursor'] = 'pointer'
          this.footerCSS[i]['margin-top'] = '0px'
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
          this.carouselBoxWidth.width = "83%"
          this.carouselAreaWidth.width = "99%"
        } else {
          this.carouselBoxWidth.width = "76%"
          this.carouselAreaWidth.width = "67.7%"
        }
      },
      fetchBubbles(ids){
        axios.post('api/fetch_bubbles_archives',{
          ids: ids
        }).then((res)=>{
          // console.log("bubble수집")
          console.log(res.data)
          this.bubbles = []
          this.bubbles = res.data
          for(var bubble of res.data){
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
          this.selectComponent('header',0)
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
      moveToSync(index,bubble,component){
        this.selectedBubble = index
        this.selectedComponent = component
        switch(component){
          case "header":
          this.gravity = bubble['header_gravity']
          this.align = bubble['header_align']
          this.size = bubble['header_size']
          this.bold = bubble['header_bold']
          this.color = bubble['header_color']
          this.background = bubble['header_background']
          break
          case "body":
          this.gravity = bubble['body_gravity']
          this.align = bubble['body_align']
          this.size = bubble['body_size']
          this.bold = bubble['body_bold']
          this.color = bubble['body_color']
          this.background = bubble['body_background']
          break
          case "footer":
          this.gravity = bubble['footer_gravity']
          this.align = bubble['footer_align']
          this.size = bubble['footer_size']
          this.bold = bubble['footer_bold']
          this.color = bubble['footer_color']
          this.background = bubble['footer_background']
          this.footer_type = bubble['footer_type']
          this.footer_button = bubble['footer_button']
          this.footer_uri = bubble['footer_uri']
          this.footer_message = bubble['footer_message']
          break
          default:
          console.log("moveToSync error!")
        }
        // this.heroWidth = bubble['heroWidth']
        // this.heroHeight = bubble['heroHeight']

        this.syncGravity();
        this.syncAlign();
        this.syncSize();
        this.syncBold();
        this.syncColor();
        this.syncBackground();
        if(component=='footer'){
          this.syncFooterType();
          this.syncFooterButton();
          this.syncFooterUri();
          this.syncFooterMessage();
        }
      },
      exchangeColor(){
        var temp = this.color
        this.color = this.background
        this.background = temp
        this.syncColor();
        this.syncBackground();
      },
      copyCSS(){
        var i = this.selectedBubble
        this.copiedType = this.selectedComponent

        this.copied['gravity'] = this.gravity
        this.copied['align'] = this.align
        this.copied['size'] = this.size
        this.copied['bold'] = this.bold
        this.copied['color'] = this.color
        this.copied['background'] = this.background
        this.copied['heroWidth']= this.heroWidth
        this.copied['heroHeight']= this.heroHeight
        this.copied['footer_type']= this.footer_type
        this.copied['footer_button']= this.footer_button
        this.copied['footer_uri']= this.footer_uri
        this.copied['footer_message']= this.footer_message
      },
      pasteCSS(){
        // var design = this.copiedCSS
        if(this.copiedType == this.selectedComponent){
          this.syncCSS()
        } else {
          if(this.copiedType=='hero'||this.selectedComponent=='hero'){
            alert("イメージのデザインはイメージ間だけ適用できます。")
          }else{
            if(this.selectedComponent!='footer'){
              this.syncCSS()
            } else {
              if(this.footer_type=='button'){
                alert("テキストのデザインはボタンに適用できません。")
              }else{
                this.syncCSS()
              }
            }
          }
        }
      },
      syncCSS(){
        if(this.copiedType=='hero'){
          this.align = this.copied['align']
          this.size = this.copied['size']
          this.background = this.copied['background']
          this.heroHeight = this.copied['heroHeight']
          this.heroWidth = this.copied['heroWidth']

          this.syncAlign();
          this.syncSize();
          this.syncBackground();
          this.syncRatio();
        } else {
          this.gravity = this.copied['gravity']
          this.align = this.copied['align']
          this.size = this.copied['size']
          this.bold = this.copied['bold']
          this.color = this.copied['color']
          this.background = this.copied['background']

          this.syncGravity();
          this.syncAlign();
          this.syncSize();
          this.syncBold();
          this.syncColor();
          this.syncBackground();
          if(this.copiedType=='footer'&&this.selectedComponent=='footer'){
            this.footer_type = this.copied['footer_type']
            this.footer_button = this.copied['footer_button']
            this.footer_uri = this.copied['footer_uri']
            this.footer_message = this.copied['footer_message']

            this.syncFooterType();
            this.syncFooterButton();
            this.syncFooterUri();
            this.syncFooterMessage();
          }
        }
      },
      copyBubble(index){
        this.addBubble();

        var header = this.bubble_array[index].header
        var body = this.bubble_array[index].body
        var file = this.heros[index]
        var hero = this.bubble_array[index].hero
        var footer = this.bubble_array[index].footer

        var end = this.bubble_array.length - 1
        this.heros[end] = file
        this.bubble_array[end]['header'] = header
        this.bubble_array[end]['body'] = body
        this.bubble_array[end]['footer'] = footer
        this.bubble_array[end].hero = hero

        this.header[end] = header
        this.body[end] = body
        this.footer[end] = footer

        var comp = ['header','hero','body','footer']
        for(var i in comp){
          this.selectComponent(comp[i],index)
          this.copyCSS();
          var target = this.bubble_array.length - 1
          this.selectComponent(comp[i],target)
          this.pasteCSS();
        }
        this.selectedBubble = null
        this.selectedComponent = null
        this.copied = {}
        this.copiedType = ''
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
      removeImage(){
        var i = this.selectedBubble
        this.heros[i] = null
        this.bubble_array[i].hero = null
      },
      onImageChange(e){
        this.uploadedImage = ""
        this.stampShow = false;
        this.stampAreaShow = false;
        this.mapShow = false;
        this.contents = ""
        this.innerContent = ""

        let files = e.target.files || e.dataTransfer.files;
        var index = this.selectedBubble
        this.heros[index] = files[0]
        this.createCarouselImage(index,files[0]);
      },
      emptyAll(){
        this.stampShow= false;
        this.stampAreaShow= false;
        this.emojiShow= false;
        this.default_center = {lat: 35.681236,lng: 139.767125}
        this.marker_center = {lat: 35.681236,lng: 139.767125}
        this.mapShow = false
        this.uploadedImage = ""
        this.contents = "";
        this.$refs.chatting.innerHTML = "";
        this.tag = ''
      },
      closeByKey(e){
        alert(e.target)
      }
    },
    computed: {
      getNotify(){
        let current = this.currentPage * this.parPage;
        let start = current - this.parPage;
        return this.notifies.slice(start, current);
      },
      getPageCount(){
        return Math.ceil(this.notifies.length / this.parPage)
      },
    }
  }
</script>
<style scoped src="../components/common/common1.css"/>
<style scoped src="../components/page6/page6.css"/>
