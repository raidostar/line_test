<template>
  <div class="page" id="page12">
    <div v-show="loading" class="waiting-screen">
      <div class="spinner">
        <div class="bounce1"></div>
        <div class="bounce2"></div>
        <div class="bounce3"></div>
      </div>
    </div>
    <div class="col-left" ref="result" @scroll="mouseScroll">
      <div class="inner-col-left">
        <div class="richmenu-list-area">
          <div class="label">
            <i class="material-icons folder">folder_special</i>
            リッチメニュー
            <button class="load-rich" @click="loadRichmenu">アップデート</button>
          </div>
          <div class="richmenu-list" v-model="richmenuList" v-for="(richmenu,index) in richmenuList">
            <div class="richmenu-one" ref="richmenulist" tabindex="0" @keyup.down="nextMenu(index)" @keyup.up="previousMenu(index)" @click="selectRichmenu(index)" @keyup.right="goRight" @keyup.left="goLeft" @keyup.enter="openRichDetail(index)" @keyup.esc="closeDetail" @keyup.delete="deleteRichmenu" :style="richmenuCSS[index]">
              <span class="richmenu-name">{{richmenu.name}}</span>
              <!-- <span class="richmenu-id">{{richmenu.richmenu_id}}</span> -->
              <i class="material-icons open-detail" tabindex="0" @click="openRichDetail(index)" @keyup.esc="closeDetail" @keyup.down="nextMenu(index)" @keyup.up="previousMenu(index)" @keyup.right="goRight" @keyup.left="goLeft">
                info
              </i>
            </div>
          </div>
        </div>
        <div>
          <button class="scroll-button scroll-right" @click="goRight" v-if="endPoint<1">
            <i class="material-icons move-scroll">
              keyboard_arrow_right
            </i>
          </button>
          <button class="scroll-button scroll-left" @click="goLeft" v-if="endPoint>0">
            <i class="material-icons move-scroll">
              keyboard_arrow_left
            </i>
          </button>
        </div>
        <div class="richmenu-list-area action-list">
          <div class="label">
            <i class="material-icons folder">devices</i>
            新規作成
            <i class="material-icons add-tag" v-if="addTo!='richmenu'" @click="addMode('richmenu')">add_to_photos</i>
            <i class="material-icons close-tag" v-if="addTo=='richmenu'" @click="richClear('')">cancel_presentation</i>
          </div>
          <div class="add-richmenu-area" v-if="addTo!='richmenu'">
            <button class="add-richmenu-button" @click="addMode('richmenu')">
              <i class="material-icons add-button">add</i>
            </button>
          </div>
          <div class="rich-input-area" v-if="addTo=='richmenu'">
            <div class="richname-input-area">
              <p class="rich-area">
                <span class="rich-name" title="必須項目">
                  <span style="font-size: 15px; color: red;">*</span>
                  名前
                </span>
                <input class="richmenu-input" ref="richname" type="text" v-model="richmenuName" placeholder="リッチメニューの名前" style="width: 70%; text-align: center;" @keyup.esc="clearRichmenu" @keyup="allSetChecker"/>
                <i v-if="richmenuName" class="material-icons clear-richmenu" @click="clearRichmenu">cancel</i>
              </p>
            </div>

            <div class="richimage-input-area">
              <p class="rich-area">
                <span style="float: left;" title="必須項目">
                  <span style="font-size: 15px; color: red;">*</span>
                  イメージ
                </span>
                <label class="add-label" title="イメージ追加">
                  <span class="image-name" v-if="uploadedImage">{{imageName}}</span>
                  <i class="material-icons add-rich-image">folder_open</i>
                  <input type="file" @change="onFileChange" class="imageBtn" ref="richImage" accept="img/*">
                </label>
              </p>
            </div>

            <div class="richsize-input-area">
              <p class="rich-area">
                <span style="float: left;">イメージサイズ</span>
                <span v-show="uploadedImage">{{baseWidth}} x {{baseHeight}}</span>
              </p>
            </div>

            <div class="richdefault-input-area">
              <p class="rich-area">
                <span style="float: left;margin-bottom: .5em;">リッチメニュー自動ON設定</span>
                <select v-model="selected" style="display: flex;">
                  <option value=false>NO</option>
                  <option value=true>YES</option>
                </select>
              </p>
            </div>

            <div class="richbartext-input-area">
              <p class="rich-area">
                <span class="rich-bartext" title="必須項目">
                  <span style="font-size: 15px; color: red;">*</span>
                  メニューバーテキスト
                </span>
                <input class="richmenu-input" type="text" v-model="richBarText" placeholder="メニューバーテキスト" style="width: 82%; text-align: left;" @keyup.esc="clearRichBarText" @keyup="allSetChecker"/>
                <i v-if="richBarText" class="material-icons clear-richmenu" @click="clearRichBarText">cancel</i>
              </p>
            </div>

            <div class="richaction-input-area" v-model="richActions" v-for="(action,index) in richActions">
              <p class="rich-area">
                <div class="richaction" :style="selectedActionColor[index]">
                  <span class="action-number" @click="selectAction(index)" @keyup="checkNum" tabindex="0">
                    アクション{{index+1}}
                  </span>
                  <span class="action-delete" @click="deleteAction(index)">削除</span>
                </div>
                <div class="richaction-sizemenu">
                  <span class="richaction-menu">範囲</span>
                  <span class="richaction-menu" style="float: right;">
                    x={{action.x}}, y= {{action.y}}, width= {{action.width}}, height= {{action.height}}
                  </span>
                </div>
                <div class="richaction-sizemenu">
                  <div class="richaction-sizemenu">
                    <span class="richaction-menu">タイプ</span>
                  </div>
                  <select v-model="action.type" @change="typeDefault(index)">
                    <option value="message">メッセージ</option>
                    <option value="uri">URI</option>
                    <option value="postback">ポストバック</option>
                  </select>
                </div>
                <div v-if="action.type=='message'||action.type=='postback'">
                  <span class="action-type">
                    <span style="font-size: 15px; color: red;" v-if="action.type=='message'">*</span>
                    テキスト
                  </span>
                  <input v-model="action.text" @keyup="allSetChecker" type="text" placeholder="テキスト入力" style="height: 2em; width: 67%;">
                </div>
                <div v-if="action.type=='uri'">
                  <span class="action-type">
                    <span style="font-size: 15px; color: red;">*</span>
                    URI
                  </span>
                  <input v-model="action.uri" @keyup="allSetChecker" type="text" placeholder="URI入力" style="height: 2em; width: 67%;">
                </div>
                <div v-if="action.type=='postback'">
                  <span class="action-type">
                    <span style="font-size: 15px; color: red;">*</span>
                    データ
                  </span>
                  <input v-model="action.data" @keyup="allSetChecker" type="text" placeholder="データ入力" style="height: 2em; width: 67%;">
                </div>
              </p>
            </div>
          </div>
          <div class="richmenus" v-if="allSet">
            <div class="richmenu-setting">
              <button class="richmenu-setting-button" @click="createRichmenu">セーブ</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="col-right">
      <div class="richmenu-image" ondragstart="return false" @click="closeDetail">
        <div class="rich-image" ref="richmenu">
          <div v-show="uploadedImage" ref="richmenuImage" @mousedown="mouseDown" @mousemove="mouseTrack" @mouseup="mouseUp">
            <div class="richmenu-img-area">
              <img class="richmenu-img" :src="uploadedImage" ref="uploaded" ondragstart="return false">
            </div>
            <div>
              <div v-show="dragStart" class="selected-range" ref="selectedRange"></div>
            </div>
          </div>
          <div v-if="richActions.length>0&&uploadedImage">
            <div class="richmenu-actions" v-model="richActions" v-for="(style,index) in richStyles">
              <div class="selected-range" ref="richAction" :style="style" @click="selectAction(index)" @keyup.delete="deleteAction(index)" @keyup.esc="pressEsc" @keyup="checkNum" tabindex="0">
                <span class="delete-action" @click="deleteAction(index)">X</span>
                <span class="select-number">{{index+1}}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="mouse-location">
        <div v-if="uploadedImage">
          <span v-model="richX">X: {{richX}}</span>
          <span v-model="richY">Y: {{richY}}</span>
          <span v-model="richActions" v-for="action in richActions">
            <p style="font-size: 12px;">{{action}}</p>
          </span>
        </div>
      </div>
    </div>
    <transition name="tadaInOut">
      <div class="detailWindow" v-if="showRichDetail">
        <div class="detailPanel">
          <div class="details">
            <span class="detail-title">
              名前
            </span>
            <span class="detail-content">
              {{richmenuList[selectedRichmenu].name}}
            </span>
          </div>
          <div class="details">
            <span class="detail-title">
              サイズ
            </span>
            <span class="detail-content">
              {{richmenuList[selectedRichmenu].width}} x {{richmenuList[selectedRichmenu].height}}
            </span>
          </div>
          <div class="details">
            <span class="detail-title">
              自動ON
            </span>
            <span class="detail-content" v-if="richmenuList[selectedRichmenu].selected" style="color: #28a745;">
              ON
            </span>
            <span class="detail-content" v-if="!richmenuList[selectedRichmenu].selected" style="color: #dc3545;">
              OFF
            </span>
          </div>
          <div class="details">
            <span class="detail-title">
              バーテキスト
            </span>
            <span class="detail-content">
              {{richmenuList[selectedRichmenu].chat_bar_text}}
            </span>
          </div>
          <div class="details">
            <div class="detail-title richmenu-id-title">
              リッチメニューID
            </div>
            <span class="detail-content richmenu-id">
              {{richmenuList[selectedRichmenu].richmenu_id}}
            </span>
          </div>
          <div class="details">
            <span class="detail-title">
              デフォルト
            </span>
            <span class="detail-content" v-if="richmenuList[selectedRichmenu].default_richmenu" style="color: #28a745;">
              YES
            </span>
            <span class="detail-content" v-if="!richmenuList[selectedRichmenu].default_richmenu" style="color: #dc3545;">
              NO
            </span>
          </div>
          <div class="details">
            <button class="default-setting cancel" v-if="richmenuList[selectedRichmenu].default_richmenu" @click="cancelDefault">
              デフォルト解除
            </button>
            <button class="default-setting default" v-if="!richmenuList[selectedRichmenu].default_richmenu" @click="setDefault">
              デフォルト設定
            </button>
            <button class="default-setting delete-rich" @click="deleteRichmenu">リッチメニュー削除</button>
          </div>
          <div class="close-detail" @click="closeDetail">
            X
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>
<script>
  import axios from 'axios'
  export default {
    name: 'Richmenu',
    data: function(){
      return {
        richX: 0,
        richY: 0,
        xSpot: '',
        ySpot: '',
        areaWidth: '',
        areaHeight: '',
        dragStart: false,
        dragEnd: false,
        imageFile: null,
        uploadedImage: '',
        richmenuList: [],
        richActions: [],
        richStyles: [],
        addTo: '',
        richmenuName: '',
        richBarText: '',
        imageName: '',
        baseWidth: '',
        baseHeight: '',
        allSet: false,
        selectedAction: 0,
        selectedActionColor: [],
        selected: false,
        richmenuCSS: [],
        endPoint: 0,
        baseScroll: 0,
        showRichDetail: false,
        selectedRichmenu: 0,
        loading: true,
      }
    },
    mounted: function(){
      this.fetchRichmenu();
    },
    methods: {
      fetchRichmenu(){
        this.loading = true
        axios.get('api/richmenus').then((res)=>{
          this.richmenuList = res.data.richmenus
          for(var i in this.richmenuList){
            var richCSS = {"background-color": "#ffffff", "color": "#000000"}
            this.richmenuCSS.push(richCSS)
          }
          this.richmenuCSS[0] = {"background-color": "#2C3250", "color": "#ffffff"}
          this.$nextTick(function(){
            this.$refs.richmenulist[0].focus();
          })
          this.loading = false
        },(error)=>{
          console.log(error)
        })
      },
      mouseDown(e){
        this.xSpot = e.clientX
        this.ySpot = e.clientY
        this.dragStart = true
        this.dragEnd = false
        this.$refs.richmenu.style.cursor = "crosshair"
      },
      mouseTrack(e){
        let xRound = ((e.clientX - 716)/72)*250
        let yRound = ((e.clientY - 53)/486)*1686
        this.richX = Math.round(xRound)
        this.richY = Math.round(yRound)

        if(this.dragStart != true||this.dragEnd != false){
          return;
        }
        if(e.clientX<716){
          e.clientX = 716
          this.mouseUp(e);
        }
        if(e.clientX>1436){
          e.clientX = 1436
          this.mouseUp(e);
        }
        if(e.clientY<53){
          e.clientY = 53
          this.mouseUp(e);
        }
        if(e.clientY>539){
          e.clientY = 539
          this.mouseUp(e);
        }

        var baseX = this.xSpot
        var baseY = this.ySpot
        var xAfter = e.clientX
        var yAfter = e.clientY
        var width = xAfter - this.xSpot
        var height = yAfter - this.ySpot
        if(this.dragStart&&!this.dragEnd){
          if(width<0){
            baseX = xAfter
            width = width*(-1)
          }
          if(height<0){
            baseY = yAfter
            height = height*(-1)
          }
          this.$refs.selectedRange.style.left = baseX+"px"
          this.$refs.selectedRange.style.top = baseY+"px"
          this.$refs.selectedRange.style.width = (width+8)+"px"
          this.$refs.selectedRange.style.height = (height+8)+"px"
        }
        if(this.richActions.length>0){

        }
      },
      mouseUp(e){
        if(this.dragStart != true||this.dragEnd != false){
          return;
        }
        if(e.clientX<=716){
          e.clientX = 716
        }
        if(e.clientX>=1436){
          e.clientX = 1436
        }
        if(e.clientY<=53){
          e.clientY = 53
        }
        if(e.clientY>=539){
          e.clientY = 539
        }
        this.dragStart = false
        this.dragEnd = true
        this.$refs.richmenu.style.cursor = "default"
        var xBefore = ((this.xSpot - 716)/72)*250
        var yBefore = ((this.ySpot - 53)/486)*1686
        var xAfter = ((e.clientX - 716)/72)*250
        var yAfter = ((e.clientY - 53)/486)*1686

        var areaWidth = xAfter - xBefore
        var areaHeight = yAfter - yBefore
        var actualWidth = e.clientX - this.xSpot
        var actualHeight = e.clientY - this.ySpot

        areaWidth = Math.round(areaWidth)
        areaHeight = Math.round(areaHeight)

        if(areaWidth>=0){
          this.areaWidth = areaWidth
        } else {
          this.xSpot = e.clientX
          this.areaWidth = areaWidth*(-1)
          actualWidth = actualWidth*(-1)
        }
        if(areaHeight>=0){
          this.areaHeight = areaHeight
        } else {
          this.ySpot = e.clientY
          this.areaHeight = areaHeight*(-1)
          actualHeight = actualHeight*(-1)
        }
        let xRound = ((this.xSpot - 716)/72)*250
        let yRound = ((this.ySpot - 53)/486)*1686

        var width = this.areaWidth
        var height = this.areaHeight

        xRound = Math.round(xRound)
        yRound = Math.round(yRound)

        // console.log("x:"+xRound)
        // console.log("y:"+yRound)
        // console.log("width:"+this.areaWidth)
        // console.log("height:"+this.areaHeight)
        // console.log("actualWidth:"+actualWidth)
        // console.log("actualHeight:"+actualHeight)

        if(this.richActions.length>0){
          for(var action of this.richActions){
            var x = action.x
            var y = action.y
            var w = action.width
            var h = action.height
            if(xRound<=x&&x<=(xRound+width)&&yRound<=y&&y<=(yRound+height)){
              alert("アクション範囲は重ねられません。");
              return;
            } else if(xRound<=(x+w)&&(x+w)<=(xRound+width)&&yRound<=y&&y<=(yRound+height)){
              alert("アクション範囲は重ねられません。");
              return;
            } else if(xRound<=x&&x<=(xRound+width)&&yRound<=(y+h)&&(y+h)<=(yRound+height)){
              alert("アクション範囲は重ねられません。");
              return;
            } else if(xRound<=(x+w)&&(x+w)<=(xRound+width)&&yRound<=(y+h)&&(y+h)<=(yRound+height)){
              alert("アクション範囲は重ねられません。");
              return;
            }
          }
        }

        var action = {
          "x": xRound,
          "y": yRound,
          "width": width,
          "height": height,
          "type": "message",
          "text": "",
          "uri": "",
          "data": ""
        }
        this.richActions.push(action)
        var style = {
          "top": this.ySpot+"px",
          "left":this.xSpot+"px",
          "width": (actualWidth+8)+"px",
          "height": (actualHeight+8)+"px",
          "border": "3px dotted #999999"
        }
        this.richStyles.push(style)
        this.selectedActionColor.push({"color": "#211", "border-bottom": "1.5px solid #211"})
        this.allSet = false;
        this.$nextTick(function(){
          var index = this.richActions.length - 1
          this.selectAction(index)
        })
      },
      onFileChange(e){
        this.richClear("image")
        let files = e.target.files || e.dataTransfer.files;
        if(!files[0].type.match(/image.png/)&&!files[0].type.match(/image.jpeg/)){
          alert("pngやjpegファイルだけアップロード可能です。");
          return;
        }
        if(files[0].size>1048576){
          alert("最大ファイルのサイズは1MBです。")
          return;
        }
        this.imageFile = files[0]
        console.log(this.imageFile)
        this.createImage(files[0]);
      },
      createImage(file){
        let reader = new FileReader();
        var image = document.createElement("img");
        var canvas = document.createElement("canvas")
        reader.onload = (e) => {
          image.src = e.target.result;
          this.$nextTick(function(){

            this.baseWidth = image.width
            this.baseHeight = image.height
            if(image.width!=2500||image.height!=1686){
              alert("イメージのサイズは「2500x1686」です。")
              this,imageFile = null
            } else {
              this.uploadedImage = e.target.result;
            }
            var imageFile = this.$refs.richImage.value
            var start = imageFile.lastIndexOf("\\") + 1
            var end = imageFile.length
            this.imageName = imageFile.substring(start,end)
          })
        }
        reader.readAsDataURL(file);
      },
      deleteAction(index){
        for(var i=index;i<this.richActions.length-1;i++){
          this.richActions[i] = this.richActions[i+1]
        }
        this.richActions.pop();
        for(var i=index;i<this.richStyles.length-1;i++){
          this.richStyles[i] = this.richStyles[i+1]
        }
        this.richStyles.pop();
        this.allSetChecker();
      },
      selectAction(index){
        this.selectedAction = index
        var rich = this.$refs.richAction[index]
        if(rich != null){
          this.$refs.richAction[index].focus();
        }
        for(var style of this.richStyles){
          style.border = "3px dotted #999999"
        }
        var richStyle = this.richStyles[index]
        if(richStyle!=null){
          richStyle["border"] = "5px solid #00b900"
        }
        for(var action of this.selectedActionColor){
          action.color = "#211"
          action["border-bottom"] = "1.5px solid #211"
        }
        var selectedActionColor = this.selectedActionColor[index]
        if(selectedActionColor!=null){
          selectedActionColor["color"] = "#00b900"
          selectedActionColor["border-bottom"] = "1.8px solid #00b900"
        }
      },
      pressEsc(){
        this.selectedAction = ''
        for(var style of this.richStyles){
          style.border = "3px dotted #999999"
        }
        for(var action of this.selectedActionColor){
          action.color = "#211"
        }
      },
      checkNum(e){
        //console.log(typeof(e.keyCode))
        var index = 0
        if(48<e.keyCode&&e.keyCode<58){
          index = e.keyCode - 49
          if(index<=this.richActions.length){
            this.selectAction(index);
          }
        }
      },
      addMode(mode){
        this.addTo = mode
        if(mode=='richmenu'){
          this.$nextTick(function(){
            this.$refs.richname.focus();
          })
        }
      },
      createRichmenu(){
        this.loading = true
        axios.post('api/richactions',{
          richactions: this.richActions
        }).then((res)=>{
          var ids = res.data
          var data = new FormData();
          var file = this.imageFile;
          data.append('name', this.richmenuName);
          data.append('contents',ids.toString());
          data.append('image',file);
          data.append('width',this.baseWidth);
          data.append('height',this.baseHeight);
          data.append('selected',this.selected);
          data.append('chat_bar_text',this.richBarText);

          axios.post('api/set_richmenu', data).then((res)=>{
            alert("リッチメニューが登録されました。");
            this.richClear('ALL');
            this.fetchRichmenu();
          },(error)=>{
            console.log(error)
          })
        },(error)=>{
          console.log(error)
        })
      },
      clearRichmenu(){
        this.richmenuName = '';
      },
      clearRichBarText(){
        this.richBarText = '';
      },
      richClear(mode){
        if(mode!='image'){
          if(mode=='ALL'){
            this.richmenuName = ''
            this.allSet = false
            this.addTo = ''
            this.selected = false
            this.richBarText = ''
          } else {
            if (confirm("このリッチメニューが初期化されます。")==true){
              this.richmenuName = ''
              this.allSet = false
              this.addTo = ''
              this.$nextTick(function(){
                var i = this.selectedRichmenu
                this.$refs.richmenulist[i].focus();
              })
            } else {
              return;
            }
          }
        }
        this.selectedAction = 0
        this.richX = 0
        this.richY = 0
        this.xSpot = ''
        this.ySpot = ''
        this.areaWidth = ''
        this.areaHeight = ''
        this.dragStart = false
        this.dragEnd = false
        this.imageName = ''
        this.baseWidth = ''
        this.baseHeight = ''
        this.imageFile = null
        this.uploadedImage = ''
        this.richActions = []
        this.richStyles = []
      },
      typeDefault(index){
        var action = this.richActions[index]
        switch(action.type){
          case 'message':
          action.uri = ""
          action.data = ""
          break;
          case 'uri':
          action.uri = "https://"
          action.text = ""
          action.data = ""
          break;
          case 'postback':
          action.uri = ""
          break;
          default:
          console.log("typeDefault error")
        }
        this.selectAction(index);
      },
      allSetChecker(){
        if(this.richmenuName!=''&&this.richBarText!=''&&this.imageFile!=null&&this.uploadedImage!=''&&this.richActions.length>0){
          this.allSet = true
          for(var action of this.richActions){
            switch(action.type){
              case 'message':
              if(action.text.length==0){
                this.allSet = false
              } else {
                action.uri = ''
                action.data = ''
              }
              break;
              case 'uri':
              if(action.uri.search('https://')<0){
                action.uri = 'https://'
                this.allSet = false
              } else if(action.uri.length<9){
                action.uri = 'https://'
                this.allSet = false
              } else {
                action.text = ''
                action.data = ''
              }
              break;
              case 'postback':
              if(action.data.length==0){
                this.allSet = false
              } else {
                action.uri = ''
              }
              break;
              default:
              console.log("allSetChecker error!")
            }
          }
        } else {
          this.allSet = false
        }
      },
      selectRichmenu(index){
        if(this.selectedRichmenu!=index){
          this.closeDetail();
        }
        this.selectedRichmenu = index
        for(var richcss of this.$refs.richmenulist){
          richcss.style.background = "#ffffff"
          richcss.style.color = "#000000"
        }
        this.$refs.richmenulist[index].style.background = "#2C3250"
        this.$refs.richmenulist[index].style.color = "#ffffff"
      },
      nextMenu(index){
        var i = 0
        if(index<this.richmenuList.length-1){
          i = index + 1
          this.selectRichmenu(i)
          this.$refs.richmenulist[i].focus();
        }
      },
      previousMenu(index){
        var i = 0
        if(0<index){
          i = index - 1
          this.selectRichmenu(i)
          this.$refs.richmenulist[i].focus();
        }
      },
      goRight(){
        var width = this.$refs.result.clientWidth
        var scrollLeft = this.$refs.result.scrollLeft
        var scrollWidth = this.$refs.result.scrollWidth
        var moveWidth = (scrollWidth - width)

        this.$refs.result.scrollLeft = scrollLeft + moveWidth
        this.baseScroll = scrollLeft
        this.endPoint = this.endPoint+1
        this.closeDetail();
        this.$nextTick(function(){
          var i = this.selectedRichmenu
          this.$refs.richmenulist[i].focus();
        })
      },
      goLeft(){
        var width = this.$refs.result.clientWidth
        var scrollLeft = this.$refs.result.scrollLeft
        var scrollWidth = this.$refs.result.scrollWidth
        var moveWidth = (scrollWidth - width)

        this.$refs.result.scrollLeft = scrollLeft - moveWidth
        this.baseScroll = scrollLeft
        this.endPoint = this.endPoint-1
        this.$nextTick(function(){
          var i = this.selectedRichmenu
          this.$refs.richmenulist[i].focus();
        })
      },
      mouseScroll(){
        var width = this.$refs.result.clientWidth
        var scrollLeft = this.$refs.result.scrollLeft
        var scrollWidth = this.$refs.result.scrollWidth
        if(scrollLeft==0){
          this.endPoint = 0
        } else if(scrollLeft==scrollWidth-width){
          this.endPoint = 1
        } else {
          this.closeDetail();
          this.endPoint = 0.5
        }
      },
      openRichDetail(index){
        this.showRichDetail = true
      },
      closeDetail(){
        this.showRichDetail = false
      },
      setDefault(){
        if (confirm("このリッチメニューをデフォルトで設定しますか。")==true){
          this.closeDetail();
          var i = this.selectedRichmenu
          var richmenu = this.richmenuList[i]
          this.loading = true
          axios.post('api/set_default_richmenu',{
            richmenu_id: richmenu.richmenu_id
          }).then((res)=>{
            var i = this.selectedRichmenu
            var richmenu = this.richmenuList[i]
            if(res.data=="BadRequest"){
              alert(richmenu.richmenu_id+"はデフォルトで設定できません！")
            } else{
              alert(richmenu.richmenu_id+"がデフォルトで設定されました。")
            }
            this.fetchRichmenu();
          },(error)=>{
            console.log(error)
          })
        }
      },
      deleteRichmenu(){
        if (confirm("このリッチメニューを削除しますか。")==true){
          this.closeDetail();
          var i = this.selectedRichmenu
          var richmenu = this.richmenuList[i]
          this.loading = true
          axios.post('api/delete_richmenu',{
            richmenu_id: richmenu.richmenu_id
          }).then((res)=>{
            var i = this.selectedRichmenu
            var richmenu = this.richmenuList[i]
            alert(richmenu.richmenu_id+"が削除されました。")
            this.fetchRichmenu();
          },(error)=>{
            console.log(error)
          })
        }
      },
      cancelDefault(){
        if (confirm("このリッチメニューをデフォルト解除しますか。")==true){
          this.closeDetail();
          var i = this.selectedRichmenu
          var richmenu = this.richmenuList[i]
          this.loading = true
          axios.post('api/unset_default_richmenu',{
            richmenu_id: richmenu.richmenu_id
          }).then((res)=>{
            var i = this.selectedRichmenu
            var richmenu = this.richmenuList[i]
            alert(richmenu.richmenu_id+"がデフォルト解除されました。")
            this.fetchRichmenu();
          },(error)=>{
            console.log(error)
          })
        }
      },
      loadRichmenu(){
        this.loading = true
        axios.post('api/load_all_richmenus').then((res)=>{
          this.loading = false
          alert("リッチメニュが最新のリストです。")
          this.fetchRichmenu();
        },(error)=>{
          console.log(error)
        })
      }
    }
  }
</script>
<style scoped src="../components/page12/page12.css"/>