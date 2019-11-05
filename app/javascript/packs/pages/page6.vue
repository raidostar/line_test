<template>
  <div class="page" id="page6">
    <div>
      <div class="title area">
        <h2 class="title">
          <span>一斉配信</span>
          <button class="allSend-button" @click="formToggle" v-show="!formShow">新規配信</button>
          <button class="allSend-button" @click="formToggle" v-show="formShow">リスト見る</button>
          <hr/>
        </h2>
      </div>
    </div>
    <transition name="slideInOut">
      <div class="col col-left" v-show="formShow">
        <div class="left-panel">
          <div class="top-panel">
            <!-- <button class="allSend-button innerBtn innerBtnLeft"></button>
            <button class="allSend-button innerBtn innerBtnRight"></button> -->
          </div>
          <div class="bottom-panel">

            <div v-for="(tag,index) in tags" class="added-folder">
              <button class="added-folderBtn" id="added-folderBtn" v-if="tag==selectedTag" :style="selectedCSS" @click="selectTag(index)">
                <i class="material-icons open-file-added">people</i>
                <span>
                  {{tag}}
                </span>
              </button>
              <button class="added-folderBtn" id="added-folderBtn" v-else @click="selectTag(index)">
                <i class="material-icons open-file-added">people</i>
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
            <button class="stampBtn"><i class="material-icons stamp">border_color</i></button>
            <button class="stampBtn" @click="mapToggle"><i class="material-icons stamp">location_on</i></button>
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
        info: {
          center: {lat: 35.681236,lng: 139.767125},
          lat: {min: null, max: null},
          lng: {min: null, max: null}
        },
        text_address: '',
        google: gmapApi,
        selectedTag: '',
        selectedCSS: {'background-color': '#444','color': 'white'}
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
        axios.get('api/notifies').then((res)=>{
          for(let notify of res.data.notifies){
            notify.created_at = notify.created_at.substr(0,16).replace('T',' ');
          }
          //console.log(res.data.notifies)
          this.notifies = res.data.notifies
        },(error)=>{
          console.log(error)
        })
      },
      createNotify(){
        if(!this.stampAreaShow&&!this.contents&&!this.uploadedImage&&!this.mapShow){//empty
          alert("empty")
          alert("一応メッセージを作成してください。")
          return;
        }
        else if(this.contents&&!this.uploadedImage&&!this.stampAreaShow&&!this.mapShow){//text only
          axios.post('/create_notify', {notify_type: 'text',contents: this.contents}).then((res)=>{
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
          axios.post('/create_notify',{notify_type: 'stamp',contents: target.substr(26,10)})
          .then((res)=>{
            alert("メッセージ送信完了！")
          },(error)=>{
            console.log(error)
          })
        } else if(this.stampAreaShow&&this.contents){//text+stamp
          axios.post('/create_notify',{notify_type: 'text', contents: this.contents}).then((res)=>{
            let arr = this.selectStampUrl.split('-')
            let target = arr[0]
            axios.post('/create_notify',{notify_type: 'stamp',contents: target.substr(26,10)}).then((res)=>{
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
        } else if(!this.contents&&this.mapShow){//only map
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
