<template>
  <div class="page" id="page8">
    <div class="title area">
      <h2 class="title">テンプレート<hr/></h2>
    </div>
    <div class="col col-left">
      <div class="label">
        <i class="material-icons folder">folder_open</i>
        アクションタグ
        <button v-show="deleteShow" class="button" @click="deleteTag">
          <i class="material-icons btnMark">remove_circle_outline</i>
        </button>
      </div>

      <div v-for="(tag,index) in tags" class="added-folder">
        <button v-if="index==selected" :style="selectedCSS" class="added-folderBtn" id="added-folderBtn" @click="firstGate(index,tag.id)">
          <i class="material-icons open-file-added">insert_drive_file</i>
          <span>
            {{tag.name}}
          </span>
        </button>
        <button v-else style="width: 100%;" class="added-folderBtn" id="added-folderBtn" @click="firstGate(index,tag.id)">
          <i class="material-icons open-file-added">insert_drive_file</i>
          <span>
            {{tag.name}}
          </span>
        </button>
        <!-- <button class="delete" v-if="(selected%tags.length)==index" @click="panelToggle">
          <i class="material-icons down">keyboard_arrow_down</i>
        </button>
        <div class="edit-panel" id="edit-panel" v-if="panelShow&&(selected%tags.length)==index">
          <button class="folderEdit">rename</button>
          <button class="folderEdit">remove</button>
        </div> -->
      </div>
    </div>
    <div class="col col-right">
      <transition name="fadeInOut" mode="out-in">
        <div v-show="!reactionShow">
          <div>
            <button @click="reactionToggle" class="allSend-button">新規アクション作成</button>
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
                  <th>削除</th>
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
                    <button class="edit-button" v-show="reaction.bool" @click="reactionDelete(reaction.id)">
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

            <!--tag input area-->
            <div class="tags">
              <div class="tags-top">
                <span style="margin-left: 10px; float: left;">タグ</span>
                <input type="text" name="option[target_keyword]" v-model="tag" class="tagInput" @keydown.enter="createTag">
                <a @click="clearTagInput" v-if="tag" style="line-height: 0px; float: left;">
                  <i class="material-icons keyword_cancel">cancel</i>
                </a>
              </div>
              <br>
              <div class="tags-bottom">
                <span style="font-size: 14px;">タグリスト</span>
                <span v-for="(tag,index) in tagtext" v-model="tagtext" style="margin-top: 10px; line-height: 0px;">
                  <button class="tagList" @click="removeTag(index)">{{tag}}</button>
                </span>
              </div>
            </div>

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

</div>
</div>
</template>
<script>
  import axios from 'axios'
  import {gmapApi} from 'vue2-google-maps'
  export default {
    name: 'autoReply',
    data: function(){
      return {
        formShow: false,

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
        flexableMarginBottom: {'margin-bottom': '0px'},
        startTime: '00:00',
        endTime: '00:00',
        actionCount: null,
        reactionListShow: false,
        insiteMode: false,
        selectedOption: null,
        tags: [],
        tagtext:['ALL'],
        tag: '',
      }
    },
    mounted: function(){
      this.fetchTags();
      this.setStampNum();
      this.fetchEmojis();
      this.innerContent = this.contents
    },
    methods: {
      fetchTags(){
        axios.get('/api/tags?tag_group=reaction').then((res)=>{
          this.tags = res.data.tags
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
        //this.selectedId = null
        this.reactionListShow = false;
        this.reactions = []
      },
      firstGate(index,id){
        this.deleteShow = true;
        this.selected = index
        this.selectedId = id
        this.panelShow = false;
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
      deleteTag(){
        if(this.tags[this.selected].name=='ALL'){
          alert("ALLタグはデフォルトタグです。");
          return
        }
        if (confirm("このタグを削除しますか。")==true){
          axios.delete('/api/tags/'+this.selectedId).then((res)=>{
            this.selected = null
            this.selectedId = null
            this.panelShow = false
            this.fetchTags();
          },(error)=>{
            console.log(error)
          })
        } else {
          return;
        }
      },
      fetchReactions(){
        axios.post('api/reactions_by_tag',{tag_id:this.selectedId}).then((res)=>{
          for(let reaction of res.data){
            reaction.created_at = reaction.created_at.substr(0,16).replace('T',' ');
          }
          this.reactions = res.data
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
            tag: this.tagtext.toString(),
          })
          .then((res)=>{
            this.afterAxios();
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
            tag: this.tagtext.toString(),
          })
          .then((res)=>{
            this.afterAxios();
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
            tag: this.tagtext.toString(),
          }).then((res)=>{
            let arr = this.selectStampUrl.split('-')
            let target = arr[0]
            axios.post('/api/reactions',{
              name: this.reactionName,
              reaction_type: 'stamp',
              contents: target.substr(26,10),
              tag: this.tagtext.toString(),
            }).then((res)=>{
              this.afterAxios();
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
          data.append('tag',this.tagtext.toString());
          data.append('image',this.imageFile);
          axios.post('/api/reactions',data)
          .then((res)=>{
            this.afterAxios();
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
            tag: this.tagtext.toString(),
          }).then((res)=>{
            var data = new FormData();
            var file = this.$refs.fileInput.files[0];
            data.append('name', this.reactionName);
            data.append('reaction_type','image');
            data.append('contents','[ IMAGE ]');
            data.append('tag',this.tagtext.toString());
            data.append('image',file);
            axios.post('/api/reactions',data)
            .then((res)=>{
              this.afterAxios();
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
                tag: this.tagtext.toString(),
              }).then((res)=>{
                this.afterAxios();
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
            tag: this.tagtext.toString(),
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
                  tag: this.tagtext.toString(),
                }).then((res)=>{
                  this.afterAxios();
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
      afterAxios(){
        alert("アクションセーブ完了");
        this.reactionToggle();
        this.fetchTags();
        this.fetchReactions();
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
        this.tagtext = ['ALL']
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
      editAction(id){
        axios.get('/api/reactions/'+id).then((res)=>{
          this.selectedReaction = res.data.reaction
          this.reactionShow = true

          this.reactionName = this.selectedReaction.name
          switch(this.selectedReaction.reaction_type){
            case "text":
            this.innerContent = this.selectedReaction.contents
            this.contents = this.innerContent
            this.tagtext = this.selectedReaction.tag.split(",")
            break
            case "image":
            this.uploadedImage  = this.selectedReaction.image.url
            this.tagtext = this.selectedReaction.tag.split(",")
            break
            case "stamp":
            let images = require.context('../images/', false, /\.png$/)
            this.selectStampUrl = images('./' + this.selectedReaction.contents + ".png")
            this.stampAreaShow = true;
            this.tagtext = this.selectedReaction.tag.split(",")
            break
            case "map":
            var tempArr = this.mapConvert(this.selectedReaction.contents);
            tempArr[0] = tempArr[0]*1
            tempArr[1] = tempArr[1]*1
            this.default_center = {lat: tempArr[0], lng: tempArr[1]}
            this.marker_center = {lat: tempArr[0], lng: tempArr[1]}
            this.mapShow  = true;
            this.tagtext = this.selectedReaction.tag.split(",")
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
            tag: this.tagtext.toString(),
          })
          .then((res)=>{
            this.afterAxios();
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
            tag: this.tagtext.toString(),
          })
          .then((res)=>{
            this.afterAxios();
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
          data.append('tag',this.tagtext.toString());
          axios.put('/api/reactions/'+this.selectedReaction.id,data)
          .then((res)=>{
            this.afterAxios();
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
              let data = '['+results[5].formatted_address+']+[@map('+latlng.lat+','+latlng.lng+')]'
              axios.put('/api/reactions/'+this.selectedReaction.id,{
                name: this.reactionName,
                reaction_type: 'map',
                contents: data,
                image: null,
                tag: this.tagtext.toString(),
              }).then((res)=>{
                this.afterAxios();
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
      clearTagInput(){
        this.tag = ''
      },
      createTag(){
        if(!this.tag) return;
        if(this.tag.search(",")>-1||this.tag.search("、")>-1) {
          alert("コンマはキーワードになれません。")
          return;
        }
        for(var t of this.tagtext){
          if(t==this.tag){
            alert("もうあるタグです。");
            return;
          }
        }
        this.tagtext.push(this.tag)
        this.tag = '';
      },
      removeTag(index){
        if(this.tagtext[index]=='ALL'){
          alert('ALLタグはデフォルトタグです。');
          return;
        }
        var start = index;
        if (index != this.tagtext.length-1){
          for(var i=start;i<this.tagtext.length-1;i++){
            this.tagtext[i] = this.tagtext[i+1]
          }
        }
        this.tagtext.pop();
      },
      reactionDelete(id){
        if (confirm("このアクションを削除しますか。")==true){
          axios.delete('/api/reactions/'+id)
          .then((res)=>{
            alert("削除完了");
            this.fetchTags();
            this.fetchReactions();
          },(error)=>{
            console.log(error)
          })
        } else {
          return;
        }
      },
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
<style scoped src="../components/common/common1.css"/>
