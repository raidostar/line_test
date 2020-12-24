<template>
  <div class="page" id="page0">
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
    <div v-show="!loading">
      <div class="channel_buttons">
        <button class="button" @click="changeMode('create')">チャネル追加</button>
      </div>
      <div class="setting">
        <select class="page-setting" v-model="parPage" @change="resetPage">
          <option value=5>5個表示</option>
          <option value=10>10個表示</option>
          <option value=50>50個表示</option>
          <option value=100>100個表示</option>
          <option :value="channels.length">全体表示</option>
        </select>
      </div>
      <table class="channel_info">
        <thead>
          <tr>
            <th></th>
            <th>チャネル名</th>
            <th>チャネルID</th>
            <th>チャネルSECRET</th>
            <th>チャネルTOKEN</th>
            <th>チャネルユーザID</th>
            <th>連動</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(channel,index) in channels">
            <td class="channel">{{index+1}}</td>
            <td class="channel">
              <span class="channel-name" @click="selectToChange(index)">{{channel.channel_name}}</span>
            </td>

            <td class="channel channel_ok">
              <span v-if="channel.channel_id">登録完了</span>
              <span v-else>未登録</span>
            </td>

            <td class="channel channel_ok">
              <span v-if="channel.channel_secret">登録完了</span>
              <span v-else>未登録</span>
            </td>

            <td class="channel channel_ok">
              <span v-if="channel.channel_token">登録完了</span>
              <span v-else>未登録</span>
            </td>

            <td class="channel channel_ok">
              <span v-if="channel.channel_user_id">登録完了</span>
              <span v-else>未登録</span>
            </td>

            <td class="channel channel_ok" style="width: 6em;">
              <span v-if="channel.channel_destination">連動完了</span>
              <span v-else style="color: red;" title="公式アカウントでこのチャネルにLINEを配信してください。">未連動</span>
            </td>
          </tr>
        </tbody>
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
    <!-- member list -->
    <transition name="fadeInOut">
      <div class="window" v-if="mode=='update'">
        <div class="save" v-if="saveShow" @click="updateChannel">update</div>
        <div class="close" @click="closeChannelDetail">close</div>
        <div class="channel-detail">
          <div>
            <label class="profile-pic">
              <i class="material-icons profile" v-if="!uploadedImage">account_circle</i>
              <img v-else class="profile-image" :src="uploadedImage">
              <input type="file" @change="onFileChange" class="imageBtn" ref="fileInput" accept="img/*">
            </label>
          </div>
          <div class="channel-value">
            <div class="values">チャネル名</div>
            <input type="text" v-model="channelName" @keyup="hasChange" style="margin: 0 auto;width: 65%;height: 2em;text-align: center;"/>
          </div>
          <div class="channel-value">
            <div class="values">チャネルID</div>
            <input type="text" v-model="channelId" @keyup="hasChange" style="margin: 0 auto;width: 65%;height: 2em;text-align: center;"/>
          </div>
          <div class="channel-value">
            <div class="values">チャネルSECRET</div>
            <input type="text" v-model="channelSecret" @keyup="hasChange" style="margin: 0 auto;width: 65%;height: 2em;text-align: center;"/>
          </div>
          <div class="channel-value">
            <div style="width: fit-content;">チャネルTOKEN</div>
            <textarea class="channel-token" @keyup="hasChange" v-model="channelToken" style="resize: none;"></textarea>
          </div>
          <div class="channel-value">
            <div class="values">チャネルユーザーID</div>
            <input type="text" v-model="channelUserId" @keyup="hasChange" style="margin: 0 auto;width: 65%;height: 2em;text-align: center;"/>
          </div>
        </div>
      </div>
    </transition>

    <transition name="fadeInOut">
      <div class="window" v-if="mode=='create'">
        <div class="save" v-if="saveShow" @click="createChannel">save</div>
        <div class="close" @click="closeChannelDetail">close</div>
        <div class="channel-detail">
          <div>
            <label v-if="!uploadedImage" class="profile-pic">
              <i class="material-icons profile">
                account_circle
              </i>
              <input type="file" @change="onFileChange" class="imageBtn" ref="fileInput" accept="img/*">
            </label>
            <img v-else class="profile-image" :src="uploadedImage">
          </div>
          <div class="channel-value">
            <div class="values">チャネル名</div>
            <input type="text" v-model="channelName" @change="checkEmpty" style="margin: 0 auto;width: 65%;height: 2em;text-align: center;" placeholder="チャネル名入力"/>
          </div>
          <div class="channel-value">
            <div class="values">チャネルID</div>
            <input type="text" v-model="channelId" @change="checkEmpty" style="margin: 0 auto;width: 65%;height: 2em;text-align: center;" placeholder="チャネルアイディー入力"/>
          </div>
          <div class="channel-value">
            <div class="values">チャネルSECRET</div>
            <input type="text" v-model="channelSecret" @change="checkEmpty" style="margin: 0 auto;width: 65%;height: 2em;text-align: center;" placeholder="チャネルシークレット入力"/>
          </div>
          <div class="channel-value">
            <div style="width: fit-content;">チャネルTOKEN</div>
            <textarea class="channel-token" placeholder="チャネルトークン入力" @change="checkEmpty" v-model="channelToken" style="resize: none;"></textarea>
          </div>
          <div class="channel-value">
            <div class="values">チャネルユーザーID</div>
            <input type="text" v-model="channelUserId" @change="checkEmpty" style="margin: 0 auto;width: 65%;height: 2em;text-align: center;" placeholder="チャネルユーザーアイディー入力"/>
          </div>
        </div>
      </div>
    </transition>
  </div>
</div>
</template>
<script type="text/javascript">
  import axios from 'axios'
  export default {
    name: 'channelManage',
    comoponents: {
    },
    data: function(){
      return {
        mode: 'read',
        channels: [],
        channelName: '',
        channelId: '',
        channelSecret: '',
        channelToken: '',
        channelUserId: '',
        showDetail: false,
        parPage: 5,
        currentPage: 1,
        selectedChannel: null,
        channelLimit: 0,
        saveShow: false,
        imageFile: null,
        uploadedImage: '',
        loading: true,
        topCover: {'height':'14%'},
        bottomCover: {'height':'80%'},
        leftCover: {'width':'18%'},
        rightCover: {'width':'4%'},
        focusLineCSS: {'width':'78%','height':'6%','left':'18%','top':'14%'},
        explanationCSS: {'right':'8%','top':'22%','width': '30%','height': '18%'},
        tips: [
          '<p>チャンネルの各要素が</p><p>登録されているかを表示します。</p>',
          '<p>このボタン押すと</p><p>チャネルを登録することができます。</p>',
          '<p>LINE_Developersで登録された</p><p>チャネル名を入力します。</p>',
          '<p>LINE_Developersで登録された</p><p>チャネルIDを入力します。</p>',
          '<p>LINE_Developersで登録された</p><p>チャネルSECRETを入力します。</p>',
          '<p>LINE_Developersで登録された</p><p>チャネルTOKENを入力します。</p>',
          '<p>LINE_Developersで登録された</p><p>チャネルユーザーIDを入力します。</p>',
          '<p>LINEチャネルとこのサイトを連動するため</p><p>自分のアカウントで自分のチャネルにメッセージを送信してください。</p>',
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
          if(status=='client'||(status=='master'&&!admit)){
            alert("このページの接続権限がありません。\nCSD事業部に問い合わせてください。")
            axios.delete('users/sign_out').then((res)=>{
              location.href = '/';
            },(error)=>{
              console.log(error)
            })
          } else {
            this.fetchChannelsLimit();
            this.fetchChannels();
          }
        },(error)=>{
          console.log(error)
        })
      },
      onFileChange(e){
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
        let vm = this
        reader.onload = (e) => {
          this.uploadedImage = e.target.result;
        }
        reader.readAsDataURL(file);
        this.hasChange();
      },
      fetchChannelsLimit(){
        axios.post('/api/check_channel_limit').then((res)=>{
          this.channelLimit = res.data
        },(error)=>{
          console.log(error)
        })
      },
      fetchChannels(){
        axios.post('/api/fetch_channels').then((res)=>{
          if(res.data != null){
            this.channels = res.data.channels
          }
          this.loading = false
        },(error)=>{
          console.log(error)
        })
      },
      changeMode(type){
        this.mode = type
      },
      createChannel(){
        if(this.channelName.length==0){
          alert("チャネル名を作成してください。");
          return;
        } else if(this.channelId.length==0){
          alert("チャネルIDを作成してください。");
          return;
        } else if(this.channelSecret.length==0){
          alert("チャネルSECRETを作成してください。");
          return;
        } else if(this.channelToken.length==0){
          alert("チャネルTOKENを作成してください。");
          return;
        } else if(this.channelUserId.length==0){
          alert("チャネルユーザーIDを作成してください。");
          return;
        } else if(this.channels.length>=this.channelLimit){
          alert("登録できる最大のチャネルをオーバーしました。\nもっと登録したい場合、フルアウトのCSD事業部にお問い合せてください。");
          this.clearChannelValues();
          this.mode = 'read'
          return;
        }

        var data = new FormData();
        var file = this.imageFile

        data.append('channel_name', this.channelName)
        data.append('image', file)
        data.append('channel_id',this.channelId)
        data.append('channel_secret',this.channelSecret)
        data.append('channel_token',this.channelToken)
        data.append('channel_user_id',this.channelUserId)

        axios.post('/api/channels',data)
        .then((res)=>{
          if(res.data=='unlinked'){
            alert("連動されないチャネルがあります。新しいチャネルを登録するために既存の全チャネルを連動してください。")
          }else {
            alert("新規チャネル登録完了！");
          }
          this.closeChannelDetail();
          this.clearChannelValues();
          this.fetchChannels();
        },(error)=>{
          console.log(error)
        })
      },
      resetPage(){
        this.currentPage = 1;
      },
      changeMode(type){
        this.mode = type
        if(type=='read'){
          this.clearChannelValues();
        }
      },
      clearChannelValues(){
        this.channelName = ''
        this.channelId = ''
        this.channelSecret = ''
        this.channelToken = ''
        this.channelUserId = ''
        this.imageFile = null
        this.uploadedImage = ''
      },
      selectToChange(index){
        this.selectedChannel = index
        var channel = this.channels[index]
        this.channelName = channel.channel_name
        if(channel.image!=null){
          this.uploadedImage = channel.image.url
        }
        this.channelId = channel.channel_id
        this.channelSecret = channel.channel_secret
        this.channelToken = channel.channel_token
        this.channelUserId = channel.channel_user_id
        //this.channelShow = true
        this.changeMode('update');
      },
      updateChannel(){
        var i = this.selectedChannel
        var id = this.channels[i].id
        var data = new FormData();
        var file = this.imageFile

        data.append('channel_name', this.channelName)
        data.append('image', file)
        data.append('channel_id',this.channelId)
        data.append('channel_secret',this.channelSecret)
        data.append('channel_token',this.channelToken)
        data.append('channel_user_id',this.channelUserId)
        axios.put('/api/channels/' + id, data)
        .then((res)=>{
          alert("アップデート完了！");
          this.closeChannelDetail();
          this.clearChannelValues();
          this.fetchChannels();
        },(error)=>{
          console.log(error)
        })
      },
      deleteChannel(){
        if (confirm("このファイルを削除しますか。")==true){
          var i = this.selectedChannel
          var id = this.channels[i].id
          axios.delete('/api/channels/'+id).then((res)=>{
            this.mode = 'read'
            this.fetchChannels();
          },(error)=>{
            console.log(error)
          })
        }
      },
      closeChannelDetail(){
        this.changeMode('read')
        this.saveShow = false
        this.clearChannelValues();
      },
      hasChange(){
        this.saveShow = true;
      },
      checkEmpty(){
        if(this.channelName!=''&&this.channelId!=''&&this.channelSecret!=''&&this.channelToken!=''&&this.channelUserId!=''){
          this.hasChange();
        }
      },
      clickCallback(pageNum){
        this.currentPage = Number(pageNum);
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
          this.topCover = {'height':'14%'}
          this.bottomCover = {'height':'80%'}
          this.leftCover = {'width':'18%'}
          this.rightCover = {'width':'4%'}
          this.focusLineCSS = {'width':'78%','height':'6%','left':'18%','top':'14%'}
          this.explanationCSS = {'right':'8%','top':'22%','width': '30%','height': '18%'}
          break;
          case 1:
          this.topCover = {'height':'8%'}
          this.bottomCover = {'height':'86%'}
          this.leftCover = {'width':'88%'}
          this.rightCover = {'width':'4%'}
          this.focusLineCSS = {'width':'8.2%','height':'6%','left':'87.7%','top':'7.7%'}
          this.explanationCSS = {'right':'4%','top':'15%','width': '30%','height': '18%'}
          break;
          case 2:
          this.topCover = {'height':'15%'}
          this.bottomCover = {'height':'80%'}
          this.leftCover = {'width':'20%'}
          this.rightCover = {'width':'3%'}
          this.focusLineCSS = {'width':'8%','height':'6%','left':'88%','top':'8%'}
          this.explanationCSS = {'right':'4%','top':'15%','width': '30%','height': '18%'}
          break;
          case 3:
          this.topCover = {'height':'15%'}
          this.bottomCover = {'height':'80%'}
          this.leftCover = {'width':'20%'}
          this.rightCover = {'width':'3%'}
          this.focusLineCSS = {'width':'8%','height':'6%','left':'88%','top':'8%'}
          this.explanationCSS = {'right':'4%','top':'15%','width': '30%','height': '18%'}
          break;
          case 4:
          this.topCover = {'height':'15%'}
          this.bottomCover = {'height':'80%'}
          this.leftCover = {'width':'20%'}
          this.rightCover = {'width':'3%'}
          this.focusLineCSS = {'width':'8%','height':'6%','left':'88%','top':'8%'}
          this.explanationCSS = {'right':'4%','top':'15%','width': '30%','height': '18%'}
          break;
          case 5:
          this.topCover = {'height':'15%'}
          this.bottomCover = {'height':'80%'}
          this.leftCover = {'width':'20%'}
          this.rightCover = {'width':'3%'}
          this.focusLineCSS = {'width':'8%','height':'6%','left':'88%','top':'8%'}
          this.explanationCSS = {'right':'4%','top':'15%','width': '30%','height': '18%'}
          break;
          case 6:
          this.topCover = {'height':'15%'}
          this.bottomCover = {'height':'80%'}
          this.leftCover = {'width':'20%'}
          this.rightCover = {'width':'3%'}
          this.focusLineCSS = {'width':'8%','height':'6%','left':'88%','top':'8%'}
          this.explanationCSS = {'right':'4%','top':'15%','width': '30%','height': '18%'}
          break;
          case 7:
          this.topCover = {'height':'15%'}
          this.bottomCover = {'height':'80%'}
          this.leftCover = {'width':'20%'}
          this.rightCover = {'width':'3%'}
          this.focusLineCSS = {'width':'8%','height':'6%','left':'88%','top':'8%'}
          this.explanationCSS = {'right':'4%','top':'15%','width': '30%','height': '18%'}
          break;
          case 8:
          this.topCover = {'height':'15%'}
          this.bottomCover = {'height':'80%'}
          this.leftCover = {'width':'20%'}
          this.rightCover = {'width':'3%'}
          this.focusLineCSS = {'width':'8%','height':'6%','left':'88%','top':'8%'}
          this.explanationCSS = {'right':'4%','top':'15%','width': '30%','height': '18%'}
          break;
        }
        if(page>1&&page<8){
          this.changeMode('create')
        }else {
          this.changeMode('read')
        }
        if(page==this.tips.length-1){
          this.nextWord = '完了'
        }
      },
    },
    computed: {
      getGroup(){
        let current = this.currentPage * this.parPage;
        let start = current - this.parPage;
        return this.channels.slice(start, current);
      },
      getPageCount(){
        return Math.ceil(this.channels.length / this.parPage)
      },
    }
  }
</script>
<style scoped src="../components/ChannelManage/channelManage.css"/>
