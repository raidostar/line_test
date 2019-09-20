<template>
  <div class="page" id="page7">
    <div class="title area">
      <h2 class="title">
        <span>自動応答</span>
        <button class="allSend-button" @click="formToggle" v-show="!formShow">新規配信</button>
        <button class="allSend-button" @click="formToggle" v-show="formShow">リスト見る</button>
        <hr/>
      </h2>
    </div>
    <transition name="slideInOut">
      <div v-show="formShow" :style="flexableHeight">
        <div class="col col-left">
          <div class="label">
            <i class="material-icons folder">sms</i>
            条件リスト
            <button class="button" @click="addToggle">
              <i class="material-icons btnMark">add_circle_outline</i>
            </button>
            <button class="button" v-if="deleteShow" @click="deleteOption" rel="nofollow" data-method="delete">
              <i class="material-icons btnMark">remove_circle_outline</i>
            </button>
          </div>
          <transition name="slideUpDown">
            <div v-if="addShow">
              <!--components--><option-detail
              :newOption="newOption"
              :createOptions="createOptions"
              />
            </div>
          </transition>
          <div class="options-panel">
            <div v-for="(item,index) in options" class="added-folder">
              <span v-if="index==selected">
                <button class="added-folderBtn" id="added-folderBtn" @click="firstGate(index,item.id)" :style="selectedCSS">
                  <i style="float: left;" class="material-icons open-file-added">flash_on</i>
                  <span>
                    {{item.name}}
                  </span>
                </button>
                <button class="detail-panel" @click="panelToggle">
                  <i class="material-icons down" v-if="!panelShow">keyboard_arrow_down</i>
                  <i class="material-icons down" v-if="panelShow">keyboard_arrow_up</i>
                </button>
                <transition name="slideUpDown">
                  <div class="edit-panel" id="edit-panel" v-if="panelShow">
                    <div>
                      <div>
                        <p class="settingMenu">キーワード設定</p>
                        <input type="text" name="option[target_keyword]" v-model="keyword" class="keywordInput" @keydown.enter="createKeyword">
                        <a @click="clearKeyInput" v-if="keyword">
                          <i class="material-icons keyword_cancel">cancel</i>
                        </a>
                      </div>
                      <hr style="margin-top: 60px;" />
                      <div>
                        <span style="font-size: 14px;">キーワード : </span>
                        <span v-for="(key,index) in keywords" v-model="keywords" style="margin-top: 10px;">
                          <button class="keywordsTag" @click="removeKeyword(index)">{{key}}</button>
                        </span>
                      </div>
                    </div>
                    <div>
                      <p class="settingMenu" style="margin-top: 4px;">送信対象設定</p>
                      <input type="radio" class="settingRadio" id="unsetReceiver" value="unsetReceiver" v-model="setReceiver">
                      <label class="setting" >全ユーザー</label>
                      <input type="radio" class="settingRadio" id="setReceiver" value="setReceiver" v-model="setReceiver">
                      <label class="setting" >送信対象選択</label>
                    </div>
                    <div>
                      <p class="settingMenu">曜日設定</p>
                      <input type="radio" class="settingRadio" id="unsetDay" value="unsetDay" v-model="setDay"@click="clearDay">
                      <label class="setting" for="two">毎日</label>
                      <input type="radio" class="settingRadio" id="setDay" value="setDay" v-model="setDay">
                      <label class="setting" for="one">曜日選択</label>
                      <div v-if="setDay=='setDay'">
                        <p class="timeSet">
                          <label>
                            <input class="with-gap" type="checkbox" name="option[target_day]" value="1" v-model="targetDay"/>
                            <span class="optCheck">月</span>
                          </label>
                          <label>
                            <input class="with-gap" type="checkbox" name="option[target_day]" value="2" v-model="targetDay"/>
                            <span class="optCheck">火</span>
                          </label>
                          <label>
                            <input class="with-gap" type="checkbox" name="option[target_day]" value="3" v-model="targetDay"/>
                            <span class="optCheck">水</span>
                          </label>
                          <label>
                            <input class="with-gap" type="checkbox" name="option[target_day]" value="4" v-model="targetDay"/>
                            <span class="optCheck">木</span>
                          </label>
                          <label>
                            <input class="with-gap" type="checkbox" name="option[target_day]" value="5" v-model="targetDay"/>
                            <span class="optCheck">金</span>
                          </label>
                          <label>
                            <input class="with-gap" type="checkbox" name="option[target_day]" value="6" v-model="targetDay"/>
                            <span class="optCheck">土</span>
                          </label>
                          <label>
                            <input class="with-gap" type="checkbox" name="option[target_day]" value="0" v-model="targetDay"/>
                            <span class="optCheck">日</span>
                          </label>
                        </p>
                      </div>
                    </div>
                    <div>
                      <p class="settingMenu">時間設定</p>
                      <input type="radio" class="settingRadio" id="unsetTime" value="unsetTime" v-model="setTime" @click="clearTime">
                      <label class="setting" for="unsetTime">未指定</label>
                      <input type="radio" class="settingRadio" id="setTime" value="setTime" v-model="setTime">
                      <label class="setting" for="setTime">時間選択</label>
                      <div v-if="setTime=='setTime'">
                        <p class="timeSet">
                          <input type="time" class="timeRange" v-model="startTime">
                          ~
                          <input type="time" class="timeRange" v-model="endTime">
                        </p>
                      </div>
                    </div>
                    <div>
                      <p class="settingMenu">回数設定</p>
                      <input type="radio" class="settingRadio" id="unsetTime" value="unsetCount" v-model="setCount">
                      <label class="setting" for="unsetCount">未指定</label>
                      <input type="radio" class="settingRadio" id="setTime" value="setCount" v-model="setCount">
                      <label class="setting" for="setCount">回数選択</label>
                      <div v-if="setCount=='setCount'">
                        <p class="timeSet">
                          <input class="countSet" type="number" name="option[action_count]" v-model="actionCount">回
                        </p>
                      </div>
                    </div>
                    <div>
                      <button class="allSend-button">キャンセル</button>
                      <button class="allSend-button" @click="updateOption">設定</button>
                    </div>
                  </div>
                </transition>
              </span>
              <span v-if="index!=selected&&!reactionShow">
                <button class="added-folderBtn" id="added-folderBtn" @click="firstGate(index,item.id)">
                  <i style="float: left;" class="material-icons open-file-added">flash_on</i>
                  <span>
                    {{item.name}}
                  </span>
                </button>
              </span>
            </div>
          </div>
        </div>

        <!--Action部分-->

        <div class="col col-right">
          <transition name="fadeInOut">
            <div v-show="!reactionShow">
              <div>
                <button v-show="selectedId" @click="reactionToggle" class="allSend-button">新規アクション作成</button>
                <button v-show="selectedId" @click="reactionListToggle" class="allSend-button">既存アクション中選択</button>
              </div>
              <div class="right-panel" style="border: none;" v-show="!reactionListShow">
                <table class="actionList">
                  <thead>
                    <tr>
                      <th>
                        <input type="checkbox" class="checkbox" v-model="reactionAllCheck" @click="reactionAllChecker">
                      </th>
                      <th>アクション名</th>
                      <th>アクション内容</th>
                      <th>操作</th>
                      <th>ヒット数</th>
                      <th>タイプ</th>
                      <th>連動</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(reaction,index) in reactions" v-model="reactions">
                      <td class="check">
                        <input type="checkbox" class="checkbox" :checked="reaction.bool" @click="reactionChecker(index)">
                      </td>
                      <td>
                        {{reaction.name}}
                      </td>

                      <td v-if="reaction.reaction_type=='stamp'">
                        <a @click="detailImage(getImgUrl(reaction.contents))">
                          <img class="stampBtnImg" :src="getImgUrl(reaction.contents)"/>
                        </a>
                      </td>
                      <td v-else-if="reaction.reaction_type=='image'">
                        <a @click="detailImage(reaction.image.url)">
                          <img class="imageResult" :src="reaction.image.url"/>
                        </a>
                      </td>
                      <td v-else>
                        <a v-if="reaction.contents.search('<img src=')>=0"
                          @click="showFullContents(reaction.contents)"
                          v-html="reaction.contents.substr(0,100)"
                          >
                        </a>
                        <a v-else @click="showFullContents(reaction.contents)" >
                          <span v-if="reaction.contents.length>19" v-html="reaction.contents.substr(0,20)+'...'"></span>
                          <span v-else v-html="reaction.contents.substr(0,20)"></span>
                        </a>
                      </td>
                      <td>
                        <button class="edit-button" @click="editAction(reaction.id)">
                          編集
                        </button>
                      </td>
                      <td class="hitcount">{{reaction.target_number}}</td>
                      <td>{{reaction.reaction_type}}</td>
                      <td>
                        <button class="edit-button" v-show="reaction.bool" @click="reactionCancel(reaction.id)">
                          解除
                        </button>
                      </td>
                    </tr>
                  </tbody>
                </table>
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
        <transition name="fadeInOut">
          <div v-show="reactionShow">
            <div>
              <input type="text" ref="reactionName" v-model="reactionName" placeholder="アクション名を入力してください。">
              <button v-show="reactionShow" @click="reactionToggle" class="allSend-button">戻り</button>
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

              <div class="chattingArea">
                <div v-show="uploadedImage"  class="attachedImgPanel">
                  <a class="closeStamp" @click="closeImage">X</a>
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
            <!-- submit button -->
            <button class="sendBtn okBtn" @click="createReaction" v-if="!editMode">セーブ</button>
            <button class="sendBtn okBtn" @click="updateReaction" v-else>修正</button>
            <button class="sendBtn cancelBtn" @click="resetReaction" style="float: right;">再作成</button>
          </div>
        </div>
      </transition>

      <!-- 여기는 전체 액션을 보여주는 곳 -->
      <transition name="slideUpDown">
        <div class="reactionAll" v-if="reactionListShow">
          <div class="right-panel-small" style="border: none;">
            <table class="actionList">
              <thead>
                <tr>
                  <th>
                    <input type="checkbox" class="checkbox" v-model="reactionAllCheck" @click="reactionAllChecker">
                  </th>
                  <th>アクション名</th>
                  <th>アクション内容</th>
                  <th>ヒット数</th>
                  <th>タイプ</th>
                  <th>連動</th>
                </tr>
              </thead>
              <tbody style="overflow:scroll;">
                <tr v-for="(reaction,index) in reactions" v-model="reactions">
                  <td class="check">
                    <input type="checkbox" class="checkbox" :checked="reaction.bool" @click="reactionChecker(index)">
                  </td>
                  <td>
                    {{reaction.name}}
                  </td>
                  <td v-if="reaction.reaction_type=='stamp'">
                    <a @click="detailImage(getImgUrl(reaction.contents))">
                      <img class="stampBtnImg" :src="getImgUrl(reaction.contents)"/>
                    </a>
                  </td>
                  <td v-else-if="reaction.reaction_type=='image'">
                    <a @click="detailImage(reaction.image.url)">
                      <img class="imageResult" :src="reaction.image.url"/>
                    </a>
                  </td>
                  <td v-else>
                    <a v-if="reaction.contents.search('<img src=')>=0"
                      @click="showFullContents(reaction.contents)"
                      v-html="reaction.contents.substr(0,100)"
                      >
                    </a>
                    <a v-else @click="showFullContents(reaction.contents)" >
                      <span v-if="reaction.contents.length>19" v-html="reaction.contents.substr(0,20)+'...'"></span>
                      <span v-else v-html="reaction.contents.substr(0,20)"></span>
                    </a>
                  </td>
                  <td class="hitcount">{{reaction.target_number}}</td>
                  <td>{{reaction.reaction_type}}</td>
                  <td>
                    <button class="edit-button" v-if="reaction.bool" @click="linkOptionReaction(reaction.id)">
                      選択
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </transition>


    </div>
  </div>
</transition>
<transition name="slideInOut">
  <div v-show="!formShow" :style="flexableHeight">
    <div class="col col-left">
      <div class="label">
        <i class="material-icons folder">folder_open</i>
        フォルダ
        <button class="button" @click="addToggle">
          <i class="material-icons btnMark">add_circle_outline</i>
        </button>
        <button class="button" v-if="deleteShow" @click="deleteFolder" rel="nofollow" data-method="delete">
          <i class="material-icons btnMark">remove_circle_outline</i>
        </button>
      </div>
      <div v-if="addShow">
        <i class="material-icons open-file">insert_drive_file</i>
        <div>
          <input type="text" v-model="newFolder" id="new-folder" class="new-folder">
          <button v-if="newFolder" class="addFolderBtn" @click="createFolder">追加</button>
        </div>
      </div>
      <div :style="flexableMargin">
        <div v-for="(item,index) in folders" class="added-folder">
          <span v-if="index==selected">
            <button
            class="added-folderBtn"
            id="added-folderBtn"
            @click="firstGate(index,item.id)"
            :style="selectedCSS"
            >
            <i style="float: left;" class="material-icons open-file-added">insert_drive_file</i>
            <span>
              {{item.name}}
            </span>
          </button>
        </span>
        <span v-else>
          <button class="added-folderBtn" id="added-folderBtn" @click="firstGate(index,item.id)">
            <i style="float: left;" class="material-icons open-file-added">insert_drive_file</i>
            <span>
              {{item.name}}
            </span>
          </button>
        </span>

        <button class="detail-panel" v-if="(selected%folders.length)==index" @click="panelToggle">
          <i class="material-icons down" v-if="!panelShow">keyboard_arrow_down</i>
          <i class="material-icons down" v-if="panelShow">keyboard_arrow_up</i>
        </button>
        <transition name="fadeUpDown">
          <div class="edit-panel" id="edit-panel" v-if="panelShow&&(selected%folders.length)==index">

          </div>
        </transition>
      </div>
    </div>
  </div>

  <div class="col col-right">
    <table>
      <tr>
        <th>
          <input type="checkbox" class="checkbox" v-model="allCheck" @click="allChecker">
        </th>
        <th>自動応答名</th>
        <th>アクション</th>
        <th>操作</th>
        <th>ヒット数</th>
        <th>フォルダ</th>
        <th>
          <button class="button">
            <i class="material-icons btnMark">add_circle_outline</i>
          </button>
        </th>
      </tr>
      <tr v-for="(check,index) in replyArray">
        <td class="check">
          <input type="checkbox" class="checkbox" :checked="check.bool" @click="oneChecker(index)">
        </td>
        <td class="title">
          {{check.name}}
        </td>
        <td class="action">{{check.bool}}</td>
        <td>샘플</td>
        <td class="hitcount">샘플</td>
        <td class="category-in">샘플</td>
        <td></td>
      </tr>
    </table>
  </div>
</div>
</transition>
</div>
</template>
<script>
  import axios from 'axios'
  import {gmapApi} from 'vue2-google-maps'
  import optionDetail from '../components/page7/optionDetail.vue'
  export default {
    name: 'autoReply',
    components: {
      optionDetail
    },
    data: function(){
      return {
        formShow: false,
        addShow: false,
        folders: [],
        newFolder: '',
        selected: null,
        selectedId: null,
        panelShow: false,
        allCheck: false,
        reactionAllCheck: false,
        replyArray: [{name: 'kakasi', bool: false}, {name: 'obito', bool: false}],
        deleteShow: false,
        options: [],
        newOption: {name: '', match_reaction: '', action_count: '', target_keyword: '', target_day: '', target_time: ''},
        flexableMargin: {'margin-top': '0px'},
        flexableHeight: {'height': '0vh'},

        contents: '',
        innerContent:'',
        reactions: [],
        stampNums: [],
        sampleAdd: '',
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
        reactionShow: false,
        reactionName: '',
        selectedCSS: {'background-color': '#AAA', 'color': 'white'},
        mapDisplay: {'display': 'block;'},
        selected_center: null,
        selectedReaction: null,
        editMode: false,
        setDay: 'unsetDay',
        setTime: 'unsetTime',
        setCount: 'unsetCount',
        setReceiver: 'unsetReceiver',
        targetDay: [0,1,2,3,4,5,6],
        keyword: '',
        keywords: [],
        flexableMarginBottom: {'margin-bottom': '0px'},
        startTime: '00:00',
        endTime: '00:00',
        actionCount: null,
        reactionListShow: false,
        insiteMode: false,
        selectedOption: null,
      }
    },
    mounted: function(){
      this.fetchFolders();
      this.fetchOptions();
      this.setStampNum();
      this.fetchEmojis();
      this.innerContent = this.contents
    },
    methods: {
      fetchFolders(){
        axios.get('/api/tags?tag_group=autoreply').then((res)=>{
          this.folders = res.data.tags
        },(error)=>{
          console.log(error)
        })
      },
      fetchOptions(){
        axios.get('/api/options').then((res)=>{
          this.options = res.data.options
          this.fetchOption();
        },(error)=>{
          console.log(error)
        })
      },
      formToggle(){
        this.stampShow= false;
        this.stampAreaShow= false;
        this.emojiShow= false;
        this.default_center = {lat: 35.681236,lng: 139.767125}
        this.marker_center = {lat: 35.681236,lng: 139.767125}
        this.mapShow = false
        this.uploadedImage = ""
        this.contents = "";
        this.$refs.chatting.innerHTML = "";
        this.reactionShow = false;
        this.selectedReaction = null
        this.formShow = !this.formShow;
        this.selected = null
        this.selectedId = null
        this.reactionListShow = false;
        this.reactions = []
      },
      addToggle(){
        this.selectedId = null
        this.deleteShow = false;
        this.addShow = !this.addShow;
        this.selected = null
        if(this.addShow){
          this.flexableMargin = {'margin-top': '50px'}

        } else {
          this.flexableMargin = {'margin-top': '0px'}
          this.newOption = {name: '', match_reaction: '', action_count: '', target_keyword: '', target_day: '', target_time: ''}
        }
        //this.$nextTick(() => document.getElementById('new-folder').focus());
      },
      createFolder(){
        if (!this.newFolder) return;
        axios.post('/api/tags',{name: this.newFolder, tag_group: 'autoreply'}).then((res)=>{
          alert("新しいファイルが追加されました。")
          this.newFolder = '';
          this.addShow = !this.addShow;
          this.flexableMargin = {'margin-top': '0px'}
          this.fetchFolders();
        },(error)=>{
          console.log(error);
        })
      },
      createOptions(){
        if (!this.newOption) return;
        axios.post('/api/options',{ option: this.newOption, }).then((res)=>{
          alert("新しい条件が追加されました。")
          this.newOption = {name: '', match_reaction: '', action_count: '', target_keyword: '', target_day: '', target_time: ''}
          this.addShow = !this.addShow;
          this.flexableMargin = {'margin-top': '0px'}
          this.fetchOptions();
        },(error)=>{
          console.log(error)
        })
      },
      firstGate(index,id){
        this.addShow = true;
        this.addToggle();
        this.deleteShow = true;
        this.selected = index
        this.selectedId = id
        this.panelShow = false;
        this.fetchOption();
        this.fetchReactions();
      },
      panelToggle(){
        this.panelShow = !this.panelShow;
      },
      allChecker(){
        for(let obj of this.replyArray){
          obj.bool = !this.allCheck
        }
      },
      oneChecker(index){
        this.replyArray[index].bool = !this.replyArray[index].bool
      },
      reactionAllChecker(){
        for(let obj of this.reactions){
          obj.bool = !this.reactionAllCheck
        }
      },
      reactionChecker(index){
        this.reactions[index].bool = !this.reactions[index].bool
      },
      deleteFolder(){
        if (confirm("このファイルを削除しますか。")==true){
          axios.delete('/api/tags/'+this.selectedId).then((res)=>{
            this.selected = null
            this.selectedId = null
            this.panelShow = false
            this.fetchFolders();
          },(error)=>{
            console.log(error)
          })
        } else {
          return;
        }
      },
      deleteOption(){
        if (confirm("この条件を削除しますか。")==true){
          var option = this.options[this.selected]
          if(option.match_reaction != null){
            var tempArr = option.match_reaction.split(",")
            for(var id of tempArr){
              if(id*1>0){
                axios.get('/api/cancel_reaction?id='+id+'&match_option='+this.selectedId)
                .then((res)=>{
                },(error)=>{
                  console.log(error)
                })
              }
            }
            this.removeOption();
          } else {
            this.removeOption();
          }
        } else {
          return;
        }
      },
      removeOption(){
        axios.delete('/api/options/'+this.selectedId).then((res)=>{
          alert("条件削除完了")
          this.selected = null
          this.selectedId = null
          this.panelShow = false
          this.reactions = []
          this.fetchOptions();
        },(error)=>{
          console.log(error)
        })
      },
      fetchReactions(){
        axios.get('api/reactions?option_id='+this.selectedId).then((res)=>{
          for(let reaction of res.data.reactions){
            reaction.created_at = reaction.created_at.substr(0,16).replace('T',' ');
          }
          //console.log(res.data.reactions)
          this.reactions = res.data.reactions
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
        this.$refs.chatting.innerHTML = this.contents
        this.$refs.chatting.focus();
      },
      createReaction(){
        if (this.reactions.length>=5){
          alert("最大アクション値は５つです。");
          return;
        }
        if(!this.reactionName){
          alert("アクションタイトルを作成してください。");
          return;
        }
        if(!this.stampAreaShow&&!this.contents&&!this.uploadedImage&&!this.mapShow){//empty
          alert("一応アクションを作成してください。")
          return;
        }
        else if(this.contents&&!this.uploadedImage&&!this.stampAreaShow&&!this.mapShow){//text only
          axios.post('/api/reactions', {
            name: this.reactionName,
            reaction_type: 'text',
            contents: this.contents,
            match_option: this.selectedId
          })
          .then((res)=>{
            alert("アクションセーブ完了")
            this.reactionToggle();
            this.fetchOptions();
            this.fetchReactions();
          }, (error) =>{
            console.log(error)
          })
        } else if(this.stampAreaShow&&!this.contents){//stamp only
          let arr = this.selectStampUrl.split('-')
          let target = arr[0]
          axios.post('/api/reactions',{
            name: this.reactionName,
            reaction_type: 'stamp',
            contents: target.substr(26,10),
            match_option: this.selectedId
          })
          .then((res)=>{
            alert("アクションセーブ完了");
            this.reactionToggle();
            this.fetchOptions();
            this.fetchReactions();
          },(error)=>{
            console.log(error)
          })
        } else if(this.stampAreaShow&&this.contents){//text+stamp
          if(this.reactions.length>=4){
            alert("最大アクション値は５つです。");
            return;
          }
          axios.post('/api/reactions',{
            name: this.reactionName,
            reaction_type: 'text',
            contents: this.contents,
            match_option: this.selectedId
          }).then((res)=>{
            let arr = this.selectStampUrl.split('-')
            let target = arr[0]
            axios.post('/api/reactions',{
              name: this.reactionName,
              reaction_type: 'stamp',
              contents: target.substr(26,10),
              match_option: this.selectedId
            }).then((res)=>{
              alert("アクションセーブ完了");
              this.reactionToggle();
              this.fetchOptions();
              this.fetchReactions();
            },(error)=>{
              console.log(error)
            })
          },(error)=>{
            console.log(error)
          })
        } else if(!this.contents&&this.uploadedImage){//only image
          var data = new FormData();
          //var file = this.$refs.fileInput.files[0];

          data.append('name', this.reactionName);
          data.append('reaction_type','image');
          data.append('contents','[ NO TEXT ]');
          data.append('image',this.imageFile);
          data.append('match_option', this.selectedId)
          axios.post('/api/reactions',data)
          .then((res)=>{
            alert("アクションセーブ完了");
            this.reactionToggle();
            this.fetchOptions();
            this.fetchReactions();
          },(error)=>{
            console.log(error)
          })
        } else if(this.contents&&this.uploadedImage){//text+image
          if(this.reactions.length>=4){
            alert("最大アクションは五つです。");
            return;
          }
          axios.post('/api/reactions',{
            name: this.reactionName,
            reaction_type: 'text',
            contents: this.contents,
            match_option: this.selectedId
          }).then((res)=>{
            var data = new FormData();
            var file = this.$refs.fileInput.files[0];
            data.append('name', this.reactionName);
            data.append('reaction_type','image');
            data.append('contents','[ IMAGE ]');
            data.append('image',file);
            data.append('match_option', this.selectedId)
            axios.post('/api/reactions',data)
            .then((res)=>{
              alert("アクションセーブ完了");
              this.reactionToggle();
              this.fetchOptions();
              this.fetchReactions();
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
              axios.post('/api/reactions',{
                name: this.reactionName,
                reaction_type: 'map',
                contents: data,
                match_option: this.selectedId
              }).then((res)=>{
                alert("アクションセーブ完了");
                this.reactionToggle();
                this.fetchOptions();
                this.fetchReactions();
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
          axios.post('/api/reactions',{
            name: this.reactionName,
            reaction_type: 'text',
            contents: this.contents,
            match_option: this.selectedId
          }).then((res)=>{
            let geocoder = new google.maps.Geocoder();
            const latlng = this.marker_center
            geocoder.geocode({'location':this.marker_center,'language': 'ja'},(results,status)=>{
              if(status == 'OK'){
                console.log(results)
                let data = '['+results[5].formatted_address+']+[@map('+latlng.lat+','+latlng.lng+')]'
                axios.post('/api/reactions',{
                  name: this.reactionName,
                  reaction_type: 'map',
                  contents: data,
                  match_option: this.selectedId
                }).then((res)=>{
                  alert("アクションセーブ完了");
                  this.reactionToggle();
                  this.fetchOptions();
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
        let images = require.context('../images/', false, /\.png$/)
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
        if (contents.search("@map")>=0){
          var tempArr = this.mapConvert(contents)
          tempArr[0] = tempArr[0]*1
          tempArr[1] = tempArr[1]*1
          this.selected_center = {lat: tempArr[0], lng: tempArr[1]}
          //{lat: 35.681236,lng: 139.767125}
        }

        this.fullContents = contents;
        this.showDetail = true;
      },
      closeDetail(){
        this.showDetail = false
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
        // console.log("그래서 파일이 뭔데????")
        // console.log((files[0]))
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
          this.flexablePadding = {"padding-right": "430px"}
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
      resetReaction(){
        this.stampShow= false;
        this.stampAreaShow= false;
        this.emojiShow= false;
        this.marker_center = {lat: 35.681236,lng: 139.767125}
        this.mapShow = false;
        this.uploadedImage = "";
        this.contents = "";
        this.$refs.chatting.innerHTML = "";
      },
      reactionToggle(){
        this.stampShow= false;
        this.stampAreaShow= false;
        this.emojiShow= false;
        this.marker_center = {lat: 35.681236,lng: 139.767125}
        this.mapShow = false;
        this.uploadedImage = "";
        this.contents = "";
        this.$refs.chatting.innerHTML = "";
        this.reactionName = "";
        this.selectedReaction = null
        this.editMode = false;
        this.reactionListShow = false;
        this.reactionShow = !this.reactionShow
        if(this.reactionShow!=true){
          this.fetchReactions();
        }
      },
      detailImage(url){
        let imageHTML = '<img class="fullSizeImage" src='+url+' style="width: 21em;height: 26em;">'
        this.fullContents = imageHTML;
        this.showDetail = true;
      },
      reactionCancel(id){
        if (confirm("このアクションを解除しますか。")==true){
          axios.get('/api/cancel_reaction?id='+id+'&match_option='+this.selectedId)
          .then((res)=>{
            alert("解除完了");
            this.fetchOptions();
            this.fetchReactions();
          },(error)=>{
            console.log(error)
          })
        } else {
          return;
        }
      },
      editAction(id){
        axios.get('/api/reactions/'+id).then((res)=>{
          this.selectedReaction = res.data.reaction
          this.reactionShow = true

          this.reactionName = this.selectedReaction.name
          switch(this.selectedReaction.reaction_type){
            case "text":
            this.innerContent = this.selectedReaction.contents
            this.contents = this.innerContent
            break
            case "image":
            this.uploadedImage  = this.selectedReaction.image.url
            break
            case "stamp":
            let images = require.context('../images/', false, /\.png$/)
            this.selectStampUrl = images('./' + this.selectedReaction.contents + ".png")
            this.stampAreaShow = true;
            break
            case "map":
            var tempArr = this.mapConvert(this.selectedReaction.contents);
            tempArr[0] = tempArr[0]*1
            tempArr[1] = tempArr[1]*1
            this.default_center = {lat: tempArr[0], lng: tempArr[1]}
            this.marker_center = {lat: tempArr[0], lng: tempArr[1]}
            this.mapShow  = true;
            break
            default:
            console.log(this.selectedReaction.reaction_type);
          }
          if(this.reactionListShow == true){
            this.reactionListShow = false
            this.editMode = false;
            this.insiteMode = true;
            this.reactions = []
          } else {
            this.insiteMode = false;
            this.editMode = true;
          }
        },(error)=>{
          console.log(error)
        })
      },
      mapConvert(contents){
        let tempArr = contents.split("+")
        const tempLength = tempArr[1].length
        tempArr = tempArr[1].substring(6,tempLength-2).split(",")
        return tempArr
      },
      updateReaction(){
        if(!this.reactionName){
          alert("アクションタイトルを作成してください。");
          return;
        }
        if(!this.stampAreaShow&&!this.contents&&!this.uploadedImage&&!this.mapShow){//empty
          alert("一応アクションを作成してください。")
          return;
        }
        else if(this.contents&&!this.uploadedImage&&!this.stampAreaShow&&!this.mapShow){//text only
          axios.put('/api/reactions/'+this.selectedReaction.id, {
            name: this.reactionName,
            reaction_type: 'text',
            contents: this.contents,
            image: null,
            match_option: this.selectedId
          })
          .then((res)=>{
            alert("アクションセーブ完了")
            this.reactionToggle();
            this.fetchReactions();
          }, (error) =>{
            console.log(error)
          })
        } else if(this.stampAreaShow&&!this.contents){//stamp only
          let arr = this.selectStampUrl.split('-')
          let target = arr[0]
          axios.put('/api/reactions/'+this.selectedReaction.id,{
            name: this.reactionName,
            reaction_type: 'stamp',
            contents: target.substr(26,10),
            image: null,
            match_option: this.selectedId
          })
          .then((res)=>{
            alert("アクションセーブ完了");
            this.reactionToggle();
            this.fetchReactions();
          },(error)=>{
            console.log(error)
          })
        } else if(this.stampAreaShow&&this.contents){//text+stamp
          alert("一つのアクションは一つのアクションでだけ修正できます。");
          return;
        } else if(!this.contents&&this.uploadedImage){//only image
          var data = new FormData();
          //var file = this.$refs.fileInput.files[0];
          data.append('name', this.reactionName);
          data.append('reaction_type','image');
          data.append('contents','[ NO TEXT ]');
          data.append('image',this.imageFile);
          data.append('match_option', this.selectedId)
          axios.put('/api/reactions/'+this.selectedReaction.id,data)
          .then((res)=>{
            alert("アクションセーブ完了");
            this.reactionToggle();
            this.fetchReactions();
          },(error)=>{
            console.log(error)
          })
        } else if(this.contents&&this.uploadedImage){//text+image
          alert("一つのアクションは一つのアクションでだけ修正できます。");
          return;
        } else if(!this.contents&&this.mapShow){//only map
          let geocoder = new google.maps.Geocoder();
          const latlng = this.marker_center
          geocoder.geocode({'location':this.marker_center,'language': 'ja'},(results,status)=>{
            if(status == 'OK'){
              console.log(results)
              let data = '['+results[5].formatted_address+']+[@map('+latlng.lat+','+latlng.lng+')]'
              axios.put('/api/reactions/'+this.selectedReaction.id,{
                name: this.reactionName,
                reaction_type: 'map',
                contents: data,
                image: null,
                match_option: this.selectedId
              }).then((res)=>{
                alert("アクションセーブ完了");
                this.reactionToggle();
                this.fetchReactions();
              },(error)=>{
                console.log(error)
              })
            }
          })
        } else {//text+map
          alert("一つのアクションは一つのアクションでだけ修正できます。");
          return;
        }
      },
      clearDay(){
        this.targetDay = [0,1,2,3,4,5,6]
      },
      clearTime(){
        this.startTime = '00:00'
        this.endTime = '00:00'
      },
      updateOption(){
        if(this.setDay=='setDay'&&this.targetDay.length==0){
          alert("日を設定してください。")
          return;
        }
        if(this.setTime=='setTime'&&(this.startTime.length==0||this.endTime.legnth==0)){
          alert("時間を設定してください。")
          return;
        }
        var targetTime = [this.startTime,this.endTime]
        axios.put('api/options/'+this.selectedId,{
          target_keyword: this.keywords.toString(),
          target_day: this.targetDay.toString(),
          target_time: targetTime.toString(),
          action_count: this.actionCount,
        }).then((res)=>{
          alert("条件セーブ完了！");
          console.log(res.data)
          this.fetchOptions();
        },(error)=>{
          console.log(error)
        })
      },
      clearKeyInput(){
        this.keyword = ''
      },
      createKeyword(){
        if(!this.keyword) return;
        if(this.keyword.search(",")>-1||this.keyword.search("、")>-1) {
          alert("コンマはキーワードになれません。")
          return;
        }
        this.keywords.push(this.keyword)
        this.keyword = '';
      },
      removeKeyword(index){
        var start = index;
        if (index != this.keywords.length-1){
          for(var i=start;i<this.keywords.length-1;i++){
            this.keywords[i] = this.keywords[i+1]
          }
        }
        this.keywords.pop();
      },
      fetchOption(){
        if(this.selected != null){
          this.selectedOption = this.options[this.selected]
          if(this.selectedOption.target_keyword != null){
            if(this.selectedOption.target_keyword.length != 0){
              this.keywords = []
              this.keywords = this.selectedOption.target_keyword.split(",");
            }
          }
          this.targetDay = []
          this.targetDay = this.selectedOption.target_day.split(",")
          if(this.targetDay.length==7){
            this.setDay = 'unsetDay'
          } else {
            this.setDay = 'setDay'
          }

          var targetTime = this.selectedOption.target_time.split(",")
          this.startTime = targetTime[0]
          this.endTime = targetTime[1]
          if(this.startTime==this.endTime){
            this.setTime = 'unsetTime'
          } else {
            this.setTime = 'setTime'
          }
          if(this.selectedOption.action_count != null){
            this.actionCount = this.selectedOption.action_count
            this.setCount = 'setCount'
          } else {
            this.setCount = 'unsetCount'
          }
        }
      },
      reactionListToggle(){
        if(this.reactionListShow!=true){
          this.fetchAllReactions();
        } else {
          this.fetchReactions();
        }
        this.reactionListShow = !this.reactionListShow
      },
      fetchAllReactions(){
        axios.post('api/reactions_all',{
          option_id: this.selectedId
        }).then((res)=>{
          this.reactions = res.data
          if(this.reactions.length==0){
            alert("登録できるアクションがありません。")
            this.fetchReactions();
            this.reactionListShow = false;
          }
        },(error)=>{
          console.log(error)
        })
      },
      linkOptionReaction(id){
        this.fetchOptions();
        var reactions = this.selectedOption.match_reaction.split(",")
        console.log(reactions)
        console.log(reactions.length)
        if(reactions.length>=5){
          alert("最大アクション値は５つです。")
          this.fetchReactions();
          this.reactionListShow = false;
          return;
        }
        axios.post('api/link_option_reaction',{
          reaction_id: id,
          option_id: this.selectedId
        }).then((res)=>{
          this.fetchAllReactions();
        },(error)=>{
          console.log(error)
        })
      }
    },
    computed: {
      getOption(){
        let current = this.currentPage * this.parPage;
        let start = current - this.parPage;
        return this.options.slice(start, current);
      },
      getPageCount(){
        return Math.ceil(this.options.length / this.parPage)
      },
    }
  }
</script>
<style scoped src="../components/page7/page7.css"/>
