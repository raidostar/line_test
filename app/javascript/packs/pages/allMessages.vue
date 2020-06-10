<template>
  <div class="page" id="page3">
    <div v-show="loading" class="waiting-screen">
      <div class="spinner">
        <div class="bounce1"></div>
        <div class="bounce2"></div>
        <div class="bounce3"></div>
      </div>
    </div>
    <!-- <div class="tips" v-show="tipsPage!=tips.length">
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
    </div> -->
    <transition name="fadeInOut">
      <div v-show="!replyShow">
        <div>
          <div>
            <i @click="fetchMessage" class="material-icons loop">loop</i><br/>
            <div class="search-keyword">
              <input class="searchBar" @keydown.enter="searchByKeyword" placeholder="検索" v-model="searchKey" style="width: 75%;" />
              <button class="searchBtn" @click="searchByKeyword"><i class="material-icons" style="color: grey;">search</i></button>
            </div>
            <div class="setting">
              <select v-model="searchStatus" @change="searchByStatus">
                <option value='all'>全体</option>
                <option value='unchecked'>未確認</option>
                <option value='unreplied'>未返事</option>
                <option value='checked'>確認完了</option>
                <option value='autoReplied'>自動返事</option>
                <option value='replied'>直接返事</option>
              </select>
            </div>
            <div class="setting">
              <select v-model="parPage" @change="resetPage">
                <option value=5>5個表示</option>
                <option value=10>10個表示</option>
                <option value=50>50個表示</option>
                <option value=100>100個表示</option>
                <option value=500>500個表示</option>
                <option :value="messageList.length">全体表示</option>
              </select>
            </div>
          </div>
        </div>
        <table class="msgList">
          <tr>
            <th>送信日時</th>
            <th>ユーザー名</th>
            <th>メッセージ内容</th>
            <th>メッセージタイプ</th>
            <th>状態</th>
            <th>返事</th>
          </tr>
          <transition-group name="flipInOut" tag="tbody">
            <tr v-for="msg in getMessage" v-bind:key="msg.id" v-model="messageList">
              <td><span>{{ msg.created_at }}</span></td>
              <td>{{ msg.sender }}</td>
              <td v-if="msg.message_type=='stamp'">
                <a @click="detailImage(getImgUrl(msg.contents))">
                  <img class="stampBtnImg" :src="getImgUrl(msg.contents)"/>
                </a>
              </td>
              <td v-else-if="msg.message_type=='image'">
                <a @click="detailImage(msg.image.url)">
                  <img class="stampBtnImg" :src="msg.image.url"/>
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

              <td>
                <span v-if="msg.message_type=='text'">テキスト</span>
                <span v-else-if="msg.message_type=='carousel'">カルーセル</span>
                <span v-else-if="msg.message_type=='stamp'">スタンプ</span>
                <span v-else-if="msg.message_type=='image'">イメージ</span>
                <span v-else-if="msg.message_type=='map'">マップ</span>
              </td>

              <td v-if="msg.check_status=='autoReplied'">自動返事</td>
              <td v-else-if="msg.check_status=='replied'">直接返事</td>
              <td v-else-if="msg.check_status=='urgent'" style="color: red;">要対応</td>
              <td v-else-if="msg.check_status=='checked'">確認完了</td>
              <td v-else-if="msg.check_status=='unreplied'" style="color: blue;">未返事</td>
              <td v-else style="color: grey;">未確認</td>
              <td>
                <button class="replyBtn" @click="replyMessage(msg)" style="color: green;">
                  返事
                </button>
              </td>
            </tr>
          </transition-group>
        </table>
        <paginate
        :page-count="getPageCount"
        :page-range="3"
        :margin-pages="2"
        :click-handler="clickCallback"
        :prev-text="'戻る'"
        :next-text="'次へ'"
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
        <button v-show="replyShow" @click="messageToggle" class="allSend-button">戻る</button>
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
            <i class="material-icons stamp">collections</i>
            <input type="file" @change="onFileChange" @click="onFileChange" class="imageBtn" ref="fileInput" accept="img/*">
          </label>
          <button class="stampBtn" @click="toggleCarousel" title="カルーセル追加">
            <i class="material-icons stamp">border_color</i>
          </button>
          <button class="stampBtn" @click="toggleMap" title="マップ追加">
            <i class="material-icons stamp">location_on</i>
          </button>
        </div>
        <div class="chattingArea">
          <div v-show="uploadedImage" class="attachedImgPanel">
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

          <div class="buttons">
            <!-- submit button -->
            <button class="sendBtn okBtn" @click="createReply">送る</button>
            <button class="sendBtn cancelBtn" @click="resetReply">再作成</button>
          </div>
        </div>
        <div class="resultArea" id="resultArea" ref="result">
          <div class="oneLine" v-for="msg in reverseMessageList">
            <div v-if="msg.check_status!='answered'">
              <img v-if="selectedFriend.profile_pic" :src="selectedFriend.profile_pic" class="profile_img" ref="profile_image">
              <i class="material-icons profile" v-else>account_circle</i>
              <div class="balloon-left" v-if="msg.message_type=='text'">
                <span v-html="msg.contents">{{msg.contents}}</span>
              </div>
              <div class="balloon-leftimage" v-else-if="msg.message_type=='stamp'">
                <img class="attachedStamp" :src="getImgUrl(msg.contents)" style="width: 10em;" />
              </div>
              <span class="left-time">{{msg.created_at}}</span>
            </div>
            <div v-else-if="msg.check_status=='answered'">
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
                <div class="carousel-box" style="margin-bottom: 1em; width: 21em;">
                  <div class="bubble-box" style="height: 100%; display: inline-flex;">
                    <div v-for="(bubble,index) in bubbles">
                      <div class="bubble" style="height: 100%;" :style="bubbleChecker(bubble,msg.contents)">
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

      <!-- stamp image area -->
      <div class="stampArea" v-show="stampAreaShow">
        <a class="closeStamp" @click="closeStamp">X</a>
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
            <button class="colorExchange" @click="exchangeColor" v-if="selectedComponent!='hero'&&(selectedComponent!='footer'||footer_type!='button')">↑ 色逆に ↓</button>
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
                <option value="postback">ポストバック</option>
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
            <div class="bubble-setting color setting-message" v-if="selectedComponent=='footer'&&footer_type=='button'&&footer_button=='postback'">
              <p style="margin-bottom: 0">配信データ</p>
              <input class="uri-text" type="text" v-model="footer_data" @keyup="syncFooterData">
            </div>
            <div class="design-buttons">
              <button class="copyChu copy" @click="copyCSS">デザインコピー</button>
              <button class="copyChu paste" v-if="copiedType" @click="pasteCSS">デザイン適用</button>
            </div>
            <label class="image-change" title="イメージ変更" v-if="selectedComponent=='hero'&&heros[selectedBubble]!=null">
              イメージ変更
              <input type="file" @change="onImageChange" @click="onImageChange" class="imageBtn" ref="hero" accept="img/*">
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
                <div class="blocks header-block" :style="headerBackground[index]" @click="selectComponent('header', index)" ref="headerArea" tabindex="0" @keydown.shift="keyNumberCheck">
                  <div class="component header-text" ref="header" contenteditable="true" v-html="header[index]" @input="syncHeader(index)" :style="headerCSS[index]">
                  </div>
                </div>
                <input type="text" v-model="bubble.header" style="display: none;">

                <!-- hero(image) -->
                <div class="blocks hero-block" :style="heroBackground[index]" ref="heroArea" @click="selectComponent('hero',index)" tabindex="0" @keydown.shift="keyNumberCheck">
                  <label class="add-label" title="イメージ追加">
                    <i class="material-icons add-bubble-image" v-if="!heros[index]">add</i>
                    <input type="file" @change="onImageChange" @click="onImageChange" class="imageBtn" ref="hero" accept="img/*">
                  </label>
                  <div class="carousel-img-area" v-show="bubble.hero" :style="heroCSS[index]">
                    <img class="carousel-img" :src="bubble.hero" :style="imageCSS[index]">
                  </div>
                </div>

                <!-- body -->
                <div class="blocks body-block" :style="bodyBackground[index]" @click="selectComponent('body', index)" ref="bodyArea" tabindex="0" @keydown.shift="keyNumberCheck">
                  <div class="component body-text" ref="body" contenteditable="true" v-html="body[index]" @input="syncBody(index)" :style="bodyCSS[index]">
                  </div>
                </div>
                <input type="text" v-model="bubble.body" style="display: none;">

                <!-- footer -->
                <div class="blocks footer-block" :style="footerBackground[index]" ref="footerArea" @click="selectComponent('footer', index)" tabindex="0" @keydown.shift="keyNumberCheck">
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
          <div class="add-button" @click="stretchCarouselToggle">
            <i class="material-icons open-circle" v-if="!carouselOpen">
              keyboard_arrow_right
            </i>
            <i class="material-icons open-circle" v-if="carouselOpen">
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
  </div>
</div>
</transition>
<!-- preview area -->
<transition name="fadeInOut">
  <div class="detailWindow" v-show="showDetail" @click="closeDetail">
    <div class="detailPanel">
      <div class="detailContents">
        <div class="detail" readonly="readonly">
          <div v-html="fullContents" v-if="fullContents.search('@map')<0" style="margin: 5px 10px;"></div>
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
    props: {
      searchKeyword: String
    },
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
        bubble_num: 0,
        bubble_array: [
        {
          header: '', hero: null, body: '', footer: '',
          header_gravity: 'top', header_align: 'start', header_size: 'md', header_bold: 'regular', header_color: '#111111',
          header_background: '#ffffff', hero_size: 'full', hero_align: 'center', hero_background: '#ffffff', hero_ratio: '1:1'
          ,body_gravity: 'top', body_align: 'start', body_size: 'md', body_bold: 'regular', body_color: '#111111',
          body_background: '#ffffff', footer_gravity: 'top', footer_align: 'center', footer_size: 'md', footer_bold: 'regular'
          ,footer_color: '#111111', footer_background: '#ffffff', footer_type: 'text', footer_button: 'uri',footer_uri: '',
          footer_message: '', footer_data: ''
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
        footer_data: '',
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
        headerBackground: [{'background-color':'#ffffff', 'border': '3px dotted #111'}],
        heroBackground: [{'background-color':'#ffffff', 'border': '3px dotted #111'}],
        bodyBackground: [{'background-color':'#ffffff', 'border': '3px dotted #111'}],
        footerBackground: [{'background-color':'#ffffff', 'border': '3px dotted #111'}],
        resultHeaderCSS: [],
        resultHeroCSS: [],
        resultBodyCSS: [],
        resultFooterCSS: [],
        copied: {},
        copiedType: '',
        baseTop: 0,
        loading: true,
        searchStatus: 'all',
        topCover: {'height':'18.5%'},
        bottomCover: {'height':'76%'},
        leftCover: {'width':'19.5%'},
        rightCover: {'width':'66.8%'},
        focusLineCSS: {'width':'13.6%','height':'5.5%','left':'19.5%','top':'18.5%'},
        explanationCSS: {'right':'54%','top':'26%','width': '30%','height': '18%'},
        tips: [
        '<p>友だちから送信された各メッセージが</p><p>届いた時間が表示されます。</p>',//0
        '<p>メッセージを送信したユーザー名が</p><p>表示されます。</p>',//1
        '<p>メッセージの内容が表示されます。</p>',//2
        '<p>メッセージの内容をクリックすると</p><p>全文を確認することができます。</p>',//3
        '<p>各友だちから送信された最後のメッセージの内容が表示されます。</p>',//4
        '<p>メッセージの現在の状態が表示されます。</p>',//5
        '<p>メッセージの状態は未確認・未返事・</p><p>確認完了・自動返事・直接返事で分類されます。</p>',//6
        '<p>ここにあるボタンを押すと返事することができるページに移動します。</p>',//7
        '<p>このボタンを押すと</p>',//8
        '<p>スタンプのリストが見えます。</p><p>ここでスタンプを追加することができます。</p>',//9
        '<p>このボタンを押すと</p>',//10
        '<p>絵文字のリストが見えます。</p><p>ここで絵文字を追加することができます。</p>',//11
        '<p>このボタンを押すと</p><p>イメージを添付して送信することができます。</p>',//12
        '<p>このボタンを押すと</p><p>カルーセルを配信することができます。</p>',//13
        '<p>カルーセルのヘッダーをクリックしてから</p>',//14
        '<p>ここでカルーセルのデザインを編集することができます。</p>',//15
        '<p>ここをクリックすると</p><p>新しいカルーセルが追加されます。</p>',//16
        '<p>複製ボタンを押すと</p><p>同じカルーセルが追加されます。</p>',//17
        '<p>このボタンを押すと</p><p>マップを添付して送信することができます。</p>',//18
        '<p>ここで地域名を検索することができます。</p>',//19
        '<p>ここにメッセージのヒストリーが</p><p>表示されます。</p>',//20
        '<p>返事が不必要なメッセージは単純に確認処理ができます。</p>',//21
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
            alert("このページの接続権限がありません。\nCSD事業部に問い合わせてください。")
            axios.delete('users/sign_out').then((res)=>{
              location.href = '/';
            },(error)=>{
              console.log(error)
            })
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
            this.fetchMessage();
            this.fetchEmojis();
            this.fetchStamps();
          }
        },(error)=>{
          console.log(error)
        })
      },
      fetchMessage(){
        axios.get('/api/messages').then((res) => {
          this.messageList = []
          this.reverseMessageList = []

          for(let message of res.data.messages){
            let time = message.created_at+""
            message.created_at = time.substr(0,19).replace('T'," ")
            if(message.check_status == 'answered'){
              this.replyList.push(message)
            }
            // else {
            //   this.messageList.push(message)
            // }
          }
          var last = res.data.messages.length - 1
          for(var i=last; i>=0; i--){
            let message = res.data.messages[i]
            this.reverseMessageList.push(message)
          }
          this.allMessageList = res.data.messages
          this.$nextTick(function(){
            let height = this.$refs.result.clientHeight
            let scrollTop = this.$refs.result.scrollTop
            let scrollHeight = this.$refs.result.scrollHeight
            scrollTop = scrollHeight - height
            this.$refs.result.scrollTop = scrollTop
            if(this.searchKeyword!=null){
              this.searchStatus = this.searchKeyword
              this.searchByStatus();
            } else {
              this.searchStatus = 'all'
              this.searchByStatus();
            }
            this.loading = false
          })
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
        this.clearCarousel();
        this.carouselAreaShow = false
        this.replyShow = !this.replyShow
        if(this.replyShow==false){
          this.emptyAll();
          this.fetchMessage();
        }
      },
      emptyAll(){
        this.stampShow= false;
        this.stampAreaShow= false;
        this.emojiShow= false;
        this.marker_center = {lat: 35.681236,lng: 139.767125}
        this.mapShow = false;
        this.uploadedImage = "";
        this.imageFile = null;

        this.contents = "";
        this.$refs.chatting.innerHTML = "";
        this.editMode = false;
        this.reactionListShow = false;
        this.flexablePadding = {"padding-right": "30px"}
      },
      closeAll(except){
        if(except != 'stamp'){
          this.closeStamp();
        }
        if(except != 'emoji'){
          this.closeEmoji();
        }
        if(except != 'image'){
          this.closeImage();
        }
        if(except != 'carousel'){
          this.closeCarousel();
        }
        if(except != 'map'){
          this.closeMap();
        }
      },
      toggleStamp(){
        this.closeAll('stamp');
        this.stampShow = !this.stampShow
      },
      toggleEmoji(){
        this.closeAll('emoji');
        this.emojiShow = !this.emojiShow
      },
      onFileChange(e){
        this.closeAll('all')
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
        this.closeAll("carousel")
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
        this.imageFile =null
        this.uploadedImage = ''
        this.flexablePadding = {"padding-right": "30px"}
      },
      toggleCarousel(){
        this.emptyAll();
        this.clearCarousel();
        this.carouselAreaShow = !this.carouselAreaShow
        if(this.carouselAreaShow){
          this.$nextTick(function(){
            this.selectComponent('header',0)
          })
        }
      },
      clearCarousel(){
        this.bubble_array = [{
          header: 'header', hero: null, body: 'body', footer: 'footer',
          header_gravity: 'top', header_align: 'start', header_size: 'md', header_bold: 'regular', header_color: '#111111',
          header_background: '#ffffff', hero_size: 'full', hero_align: 'center', hero_background: '#ffffff', hero_ratio: '1:1'
          ,body_gravity: 'top', body_align: 'start', body_size: 'md', body_bold: 'regular', body_color: '#111111',
          body_background: '#ffffff', footer_gravity: 'top', footer_align: 'center', footer_size: 'md', footer_bold: 'regular'
          ,footer_color: '#111111', footer_background: '#ffffff', footer_type: 'text', footer_button: 'uri',footer_uri: '',
          footer_message: '', footer_data: ''
        }]
        this.header = ['header']
        this.body = ['body']
        this.footer = ['footer']
        this.heros = []

        this.headerCSS = [{'margin-left':'0', 'margin-right':'auto', 'font-size':'15px', 'font-weight':'normal', 'margin-top':'0px', 'color':'#111111', 'background':'#ffffff'}]
        this.heroCSS = [{'text-align':'center','background-color':'#ffffff'}]
        this.imageCSS = [{'width':'100%', 'height': 'auto'}]
        this.imageSize = ['100%']
        this.bodyCSS = [{'margin-left':'0', 'margin-right':'auto', 'font-size':'15px', 'font-weight':'normal', 'margin-top':'0px', 'color':'#111111', 'background':'#ffffff'}]
        this.footerCSS = [{'margin-left':'auto', 'margin-right':'auto', 'font-size':'15px', 'font-weight':'normal', 'margin-top':'0px', 'color':'#111111', 'background':'#ffffff'}]
        this.headerBackground = [{'background-color':'#ffffff', 'border': '3px dotted #111'}]
        this.heroBackground = [{'background-color':'#ffffff', 'border': '3px dotted #111'}]
        this.bodyBackground = [{'background-color':'#ffffff', 'border': '3px dotted #111'}]
        this.footerBackground = [{'background-color':'#ffffff', 'border': '3px dotted #111'}]

        this.gravity = 'top'
        this.align = 'start'
        this.color = '#111111'
        this.background = '#ffffff'
        this.size = 'md'
        this.bold = 'regular'
        this.heroWidth = 1
        this.heroHeight = 1
        this.footer_type = 'text'
        this.footer_button = 'uri'
        this.footer_uri = ''
        this.footer_message = ''
        this.footer_data = ''
        this.selectedBubble = null
        this.selectedComponent = null
        this.carouselOpen = false
      },
      toggleMap(){
        this.uploadedImage = ""
        this.closeAll('map')
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
        axios.get('/api/emojis').then((res)=>{
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
        this.stampShow = false;
        this.stampAreaShow = false;
        this.flexablePadding = {"padding-right": "30px"}
      },
      closeCarousel(){
        this.carouselAreaShow = false;
        this.clearCarousel();
      },
      closeEmoji(){
        this.emojiShow = false;
        this.flexablePadding = {"padding-right": "30px"}
      },
      closeMap(){
        this.mapShow = false;
        this.flexablePadding = {"padding-right": "30px"}
      },
      createReply(){
        if (this.reactions.length>=5){
          alert("最大アクション値は５つです。");
          return;
        }
        if(!this.stampAreaShow&&!this.contents&&!this.uploadedImage&&!this.mapShow&&!this.carouselAreaShow){//empty
          alert("一応アクションを作成してください。")
          return;
        }
        else if(this.contents&&!this.uploadedImage&&!this.stampAreaShow&&!this.mapShow&&!this.carouselAreaShow){//text only
          axios.post('/api/direct_reply', {
            message_id: this.selectedMessage.id,
            message_type: 'text',
            contents: this.contents,
          })
          .then((res)=>{
            var reply_token = res.data.reply_token
            this.fetchReply(reply_token)
            this.emptyAll();
          }, (error) =>{
            console.log(error)
          })
        } else if(this.stampAreaShow&&!this.contents){//stamp only
          let arr = this.selectStampUrl.split('-')
          let target = arr[0]
          axios.post('/api/direct_reply',{
            message_id: this.selectedMessage.id,
            message_type: 'stamp',
            contents: target.substr(40,target.length),
          })
          .then((res)=>{
            var reply_token = res.data.reply_token
            this.fetchReply(reply_token)
            this.emptyAll();
          },(error)=>{
            console.log(error)
          })
        } else if(this.stampAreaShow&&this.contents){//text+stamp
          if(this.reactions.length>=4){
            alert("最大アクション値は５つです。");
            return;
          }
          axios.post('/api/direct_reply',{
            message_id: this.selectedMessage.id,
            message_type: 'text',
            contents: this.contents,
          }).then((res)=>{
            let arr = this.selectStampUrl.split('-')
            let target = arr[0]
            axios.post('/api/reactions',{
              message_id: this.selectedMessage.id,
              message_type: 'stamp',
              contents: target.substr(40,target.length),
            }).then((res)=>{
              var reply_token = res.data.reply_token
              this.fetchReply(reply_token)
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
          this.loading = true
          axios.post('/api/direct_reply',data)
          .then((res)=>{
            var reply_token = res.data.reply_token
            this.fetchReply(reply_token)
            this.emptyAll();
            this.loading = false
          },(error)=>{
            console.log(error)
          })
        } else if(this.contents&&this.uploadedImage){//text+image
          if(this.reactions.length>=4){
            alert("最大アクションは五つです。");
            return;
          }
          this.loading = true
          axios.post('/api/direct_reply',{
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
            axios.post('/api/direct_reply',data)
            .then((res)=>{
              var reply_token = res.data.reply_token
              this.fetchReply(reply_token)
              this.emptyAll();
              this.loading = false
            },(error)=>{
              console.log(error)
            })
          },(error)=>{
            console.log(error)
          })
        } else if(this.carouselAreaShow){//only carousel
          for(var bubble of this.bubble_array){
            let bubbleLength = bubble.header.length+bubble.body.length+bubble.footer.length
            if(bubbleLength==0){
              alert("作成されないカルーセルがあります。");
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
              } else if(bubble.footer_button=='postback'&&bubble.footer_data.length==0){
                alert("ボタンのデータを入力してください。");
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
            data.append('footer_data[]', this.bubble_array[i].footer_data)
          }
          data.append('bubble_num',this.bubble_array.length)
          axios.post('/api/bubbles_archives',data)
          .then((res)=>{
            const data = res.data.toString()
            axios.post('/api/direct_reply',{
              message_id: this.selectedMessage.id,
              message_type: 'carousel',
              contents: data,
            }).then((res)=>{
              var reply_token = res.data.reply_token
              this.fetchReply(reply_token)
              this.toggleCarousel();
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
              let data = '['+results[5].formatted_address+']+[@map('+latlng.lat+','+latlng.lng+')]'
              axios.post('/api/direct_reply',{
                message_id: this.selectedMessage.id,
                message_type: 'map',
                contents: data,
              }).then((res)=>{
                var reply_token = res.data.reply_token
                this.fetchReply(reply_token)
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
          axios.post('/api/direct_reply',{
            message_id: this.selectedMessage.id,
            message_type: 'text',
            contents: this.contents,
          }).then((res)=>{
            let geocoder = new google.maps.Geocoder();
            const latlng = this.marker_center
            geocoder.geocode({'location':this.marker_center,'language': 'ja'},(results,status)=>{
              if(status == 'OK'){
                let data = '['+results[5].formatted_address+']+[@map('+latlng.lat+','+latlng.lng+')]'
                axios.post('/api/direct_reply',{
                  message_id: this.selectedMessage.id,
                  message_type: 'map',
                  contents: data,
                }).then((res)=>{
                  var reply_token = res.data.reply_token
                  this.fetchReply(reply_token)
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
        // var images = require.context('../images/', false, /\.png$/)
        var images = 'https://cdn.lineml.jp/api/media/sticker/'+para
        return images
      },
      detailImage(url){
        let imageHTML = '<img src='+url+' style="width: 21em;">'
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
        this.bubbles = []
        this.resultHeaderCSS = []
        this.resultBodyCSS = []
        this.resultFooterCSS = []
        axios.post('/api/read_message',{
          id: msg.id
        }).then((res)=>{
          var data = res.data
          this.fetchReply(data.reply_token)
        },(error)=>{
          console.log(error)
        })
      },
      fetchReply(data){
        axios.post('/api/fetch_reply',{
          reply_token: data
        }).then((res)=>{
          this.reverseMessageList = res.data.messages
          this.bubbles = []
          for(var msg of this.reverseMessageList){
            let time = msg.created_at+""
            msg.created_at = time.substr(0,19).replace('T'," ")
            if(msg.message_type=='carousel'){
              this.fetchBubbles(msg.contents)
            }
          }
        },(error)=>{
          console.log(error)
        })
      },
      fetchStamps(){
        for(let i=34; i<74;i++){
          let add = '11537_520027'+i
          this.stampNums.push(add)
        }
        for(let i=494; i<534;i++){
          let add = '11538_51626'+i
          this.stampNums.push(add)
        }
        for(let i=10; i<50;i++){
          let add = '11539_521141'+i
          this.stampNums.push(add)
        }
      },
      selectStamp(num){
        this.uploadedImage = "";
        this.stampAreaShow = true
        //let images = require.context('../images/', false, /\.png$/)
        this.selectStampUrl = 'https://cdn.lineml.jp/api/media/sticker/' + num
        this.flexablePadding = {"padding-right": "300px"}
      },
      loadProfile(fr_account){
        axios.post('/api/by_fr_account',{
          fr_account: fr_account
        }).then((res)=>{
          this.selectedFriend = res.data
        },(error)=>{
          console.log(error)
        })
      },
      searchByKeyword(){
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
        axios.post('/api/check_message',{
          id: this.selectedMessage.id
        }).then((res)=>{
          this.messageToggle();
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
          footer_message: '', footer_data: ''
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

        this.headerBackground.push({'background-color':'#ffffff','border': '3px dotted #111'})
        this.heroBackground.push({'background-color':'#ffffff','border': '3px dotted #111'})
        this.bodyBackground.push({'background-color':'#ffffff','border': '3px dotted #111'})
        this.footerBackground.push({'background-color':'#ffffff','border': '3px dotted #111'})
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
          this.heroBackground[i]['background-color'] = this.background
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
      syncFooterData(){
        var i = this.selectedBubble
        this.bubble_array[i].footer_data = this.footer_data
      },
      syncHeroRatio(){
        var i = this.selectedBubble
        this.bubble_array[i].hero_ratio = this.heroWidth + ':' + this.heroHeight
      },
      selectComponent(type,index){
        this.selectedComponent = type
        this.selectedBubble = index
        this.clearHeaderCSS();
        this.clearHeroCSS();
        this.clearBodyCSS();
        this.clearFooterCSS();
        switch(type){
          case 'header':
          this.gravity = this.bubble_array[index].header_gravity
          this.align = this.bubble_array[index].header_align
          this.size = this.bubble_array[index].header_size
          this.color = this.bubble_array[index].header_color
          this.background = this.bubble_array[index].header_background
          this.bold = this.bubble_array[index].header_bold
          this.headerBackground[index].border = '5px solid red'
          this.$nextTick(function(){
            this.$refs.headerArea[index].focus();
          })
          break
          case 'hero':
          var ratio = this.bubble_array[index].hero_ratio.split(":")
          this.heroWidth = ratio[0]*1
          this.heroHeight = ratio[1]*1
          this.align = this.bubble_array[index].hero_align
          this.size = this.bubble_array[index].hero_size
          this.background = this.bubble_array[index].hero_background
          this.heroBackground[index].border = '5px solid red'
          this.$nextTick(function(){
            this.$refs.heroArea[index].focus();
          })
          break
          case 'body':
          this.gravity = this.bubble_array[index].body_gravity
          this.align = this.bubble_array[index].body_align
          this.size = this.bubble_array[index].body_size
          this.color = this.bubble_array[index].body_color
          this.background = this.bubble_array[index].body_background
          this.bold = this.bubble_array[index].body_bold
          this.bodyBackground[index].border = '5px solid red'
          this.$nextTick(function(){
            this.$refs.bodyArea[index].focus();
          })
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
          this.footer_data = this.bubble_array[index].footer_data
          this.footerBackground[index].border = '5px solid red'
          this.$nextTick(function(){
            this.$refs.footerArea[index].focus();
          })
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
        },(error)=>{
          console.log(error)
        })
      },
      clearHeaderCSS(){
        for(var i in this.headerBackground){
          this.headerBackground[i].border = '3px dotted #111'
        }
      },
      clearHeroCSS(){
        for(var i in this.heroBackground){
          this.heroBackground[i].border = '3px dotted #111'
        }
      },
      clearBodyCSS(){
        for(var i in this.bodyBackground){
          this.bodyBackground[i].border = '3px dotted #111'
        }
      },
      clearFooterCSS(){
        for(var i in this.footerBackground){
          this.footerBackground[i].border = '3px dotted #111'
        }
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
        this.copied['footer_data'] = this.footer_data
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
            this.footer_message = this.copied['footer_data']

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
      searchByStatus(){
        let searchResult = []
        for(let msg of this.allMessageList){
          if(this.searchStatus!='all'){
            if(msg.check_status==this.searchStatus){
              searchResult.push(msg)
            }
          } else{
            if(msg.check_status!='answered'){
              searchResult.push(msg)
            }
          }
          this.messageList = searchResult
        }
      },
      keyNumberCheck(e){
        switch(e.keyCode){
          case 13:
          this.stretchCarouselToggle();
          break;

          case 37:
          this.previousBubble();
          break;
          case 38:
          this.previousComponent();
          break;
          case 39:
          this.nextBubble();
          break;
          case 40:
          this.nextComponent();
          break;

          case 48:
          this.size = "5xl"
          this.syncSize();
          break;
          case 49:
          this.size = "xxs"
          this.syncSize();
          break;
          case 50:
          this.size = "xs"
          this.syncSize();
          break;
          case 51:
          this.size = "sm"
          this.syncSize();
          break;
          case 52:
          this.size = "md"
          this.syncSize();
          break;
          case 53:
          this.size = "lg"
          this.syncSize();
          break;
          case 54:
          this.size = "xl"
          this.syncSize();
          break;
          case 55:
          this.size = "xxl"
          this.syncSize();
          break;
          case 56:
          this.size = "3xl"
          this.syncSize();
          break;
          case 57:
          this.size = "4xl"
          this.syncSize();
          break;

          case 66:
          this.switchBold();
          break;
          case 67:
          this.copyCSS();
          break;
          case 86:
          this.pasteCSS();
          break;

          case 73:
          this.gravityUp();
          break;
          case 74:
          this.alignLeft();
          break;
          case 75:
          this.gravityDown();
          break;
          case 76:
          this.alignRight();
          break;

          case 78:
          this.addBubble();
          break;
        }
      },
      alignRight(){
        if(this.align=='start'){
          this.align = 'center'
        } else if(this.align=='center'){
          this.align = 'end'
        }
        this.syncAlign();
      },
      alignLeft(){
        if(this.align=='center'){
          this.align = 'start'
        } else if(this.align=='end'){
          this.align = 'center'
        }
        this.syncAlign();
      },
      gravityUp(){
        if(this.gravity=='center'){
          this.gravity = 'top'
        } else if(this.gravity=='bottom'){
          this.gravity = 'center'
        }
        this.syncGravity();
      },
      gravityDown(){
        if(this.gravity=='top'){
          this.gravity = 'center'
        } else if(this.gravity=='center'){
          this.gravity = 'bottom'
        }
        this.syncGravity();
      },
      switchBold(){
        if(this.bold == 'bold'){
          this.bold = 'regular'
        } else {
          this.bold = 'bold'
        }
        this.syncBold();
      },
      nextComponent(){
        var index = this.selectedBubble
        switch(this.selectedComponent){
          case 'header':
          this.selectComponent('hero',index)
          this.$nextTick(function(){
            var i = this.selectedBubble
            if(this.heros[i] == null){

            }
          })
          break;
          case 'hero':
          this.selectComponent('body',index)
          break;
          case 'body':
          this.selectComponent('footer',index)
          break;
        }
      },
      previousComponent(){
        var index = this.selectedBubble
        switch(this.selectedComponent){
          case 'hero':
          this.selectComponent('header',index)
          break;
          case 'body':
          this.selectComponent('hero',index)
          this.$nextTick(function(){
            var i = this.selectedBubble
            if(this.heros[i] == null){

            }
          })
          break;
          case 'footer':
          this.selectComponent('body',index)
          break;
        }
      },
      nextBubble(){
        var comp = this.selectedComponent
        var index = 0
        if(this.selectedBubble < this.bubble_array.length-1){
          index = this.selectedBubble + 1
        }
        this.selectComponent(comp, index)
      },
      previousBubble(){
        var comp = this.selectedComponent
        var index = 0
        if(this.selectedBubble >0){
          index = this.selectedBubble - 1
        }
        this.selectComponent(comp, index)
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
          this.topCover = {'height':'18.5%'}
          this.bottomCover = {'height':'76%'}
          this.leftCover = {'width':'19.5%'}
          this.rightCover = {'width':'66.8%'}
          this.focusLineCSS = {'width':'13.6%','height':'5.5%','left':'19.5%','top':'18.5%'}
          this.explanationCSS = {'right':'54%','top':'26%','width': '30%','height': '18%'}
          break;
          case 1:
          this.topCover = {'height':'18.5%'}
          this.bottomCover = {'height':'76%'}
          this.leftCover = {'width':'36%'}
          this.rightCover = {'width':'50.3%'}
          this.focusLineCSS = {'width':'13.6%','height':'5.5%','left':'36%','top':'18.5%'}
          this.explanationCSS = {'right':'38%','top':'26%','width': '30%','height': '18%'}
          break;
          case 2:
          this.topCover = {'height':'18.5%'}
          this.bottomCover = {'height':'76%'}
          this.leftCover = {'width':'50.5%'}
          this.rightCover = {'width':'36%'}
          this.focusLineCSS = {'width':'13.6%','height':'5.5%','left':'50.5%','top':'18.5%'}
          this.explanationCSS = {'right':'24%','top':'26%','width': '30%','height': '18%'}
          break;
          case 3:
          this.topCover = {'height':'18.5%'}
          this.bottomCover = {'height':'76%'}
          this.leftCover = {'width':'50.5%'}
          this.rightCover = {'width':'36%'}
          this.focusLineCSS = {'width':'13.6%','height':'5.5%','left':'50.5%','top':'18.5%'}
          this.explanationCSS = {'right':'24%','top':'26%','width': '30%','height': '18%'}
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
    computed: {
      getMessage(){
        let current = this.currentPage * this.parPage;
        let start = current - this.parPage;
        return this.messageList.slice(start, current);
      },
      getPageCount(){
        return Math.ceil(this.messageList.length / this.parPage)
      },
    },
    updated(){
      this.$nextTick(function(){
        var profile = this.$refs.profile_image
        if(profile != null){
          if( profile.src != '' && profile.complete == true && profile.naturalWidth == 0 ){
            this.selectedFriend.profile_pic = null
          }
        }
      })
    }
  }
</script>

<style scoped src="../components/AllMessages/allMessages.css"/>