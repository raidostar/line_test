<template>
  <div class="page" id="page0">
    <div class="channel_buttons">
      <button class="button" @click="changeMode('create')">チャンネル追加</button>
    </div>
    <div class="setting">
      <select class="page-setting" v-model="parPage" @change="resetPage">
        <option value=5>5ライン別表示</option>
        <option value=10>10ライン別表示</option>
        <option value=50>50ライン別表示</option>
        <option value=100>100ライン別表示</option>
        <option :value="channels.length">全体表示</option>
      </select>
    </div>
    <table class="channel_info">
      <thead>
        <tr>
          <th></th>
          <th>チャンネル名前</th>
          <th>チャンネルID</th>
          <th>チャンネルSECRET</th>
          <th>チャンネルTOKEN</th>
          <th>チャンネルユーザID</th>
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
            <span v-else>未連動</span>
          </td>
        </tr>
      </tbody>
    </table>
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
            <div class="values">チャンネル名前</div>
            <input type="text" v-model="channelName" @keyup="hasChange" style="margin: 0 auto;width: 65%;height: 2em;text-align: center;"/>
          </div>
          <div class="channel-value">
            <div class="values">チャンネルID</div>
            <input type="text" v-model="channelId" @keyup="hasChange" style="margin: 0 auto;width: 65%;height: 2em;text-align: center;"/>
          </div>
          <div class="channel-value">
            <div class="values">チャンネルSECRET</div>
            <input type="text" v-model="channelSecret" @keyup="hasChange" style="margin: 0 auto;width: 65%;height: 2em;text-align: center;"/>
          </div>
          <div class="channel-value">
            <div style="width: fit-content;">チャンネルTOKEN</div>
            <textarea class="channel-token" @keyup="hasChange" v-model="channelToken" style="resize: none;"></textarea>
          </div>
          <div class="channel-value">
            <div class="values">チャンネルユーザーID</div>
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
            <div class="values">チャンネル名前</div>
            <input type="text" v-model="channelName" @change="checkEmpty" style="margin: 0 auto;width: 65%;height: 2em;text-align: center;" placeholder="チャンネル名前入力"/>
          </div>
          <div class="channel-value">
            <div class="values">チャンネルID</div>
            <input type="text" v-model="channelId" @change="checkEmpty" style="margin: 0 auto;width: 65%;height: 2em;text-align: center;" placeholder="チャンネルアイディー入力"/>
          </div>
          <div class="channel-value">
            <div class="values">チャンネルSECRET</div>
            <input type="text" v-model="channelSecret" @change="checkEmpty" style="margin: 0 auto;width: 65%;height: 2em;text-align: center;" placeholder="チャンネルシークレット入力"/>
          </div>
          <div class="channel-value">
            <div style="width: fit-content;">チャンネルTOKEN</div>
            <textarea class="channel-token" placeholder="チャンネルトークン入力" @change="checkEmpty" v-model="channelToken" style="resize: none;"></textarea>
          </div>
          <div class="channel-value">
            <div class="values">チャンネルユーザーID</div>
            <input type="text" v-model="channelUserId" @change="checkEmpty" style="margin: 0 auto;width: 65%;height: 2em;text-align: center;" placeholder="チャンネルユーザーアイディー入力"/>
          </div>
        </div>
      </div>
    </transition>
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
      }
    },
    mounted: function(){
      this.fetchChannelsLimit();
      this.fetchChannels();
    },
    methods: {
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
        axios.post('api/check_channel_limit').then((res)=>{
          this.channelLimit = res.data
        },(error)=>{
          console.log(error)
        })
      },
      fetchChannels(){
        axios.post('api/fetch_channels').then((res)=>{
          if(res.data != null){
            this.channels = res.data.channels
          }
        },(error)=>{
          console.log(error)
        })
      },
      changeMode(type){
        this.mode = type
      },
      createChannel(){
        if(this.channelName.length==0){
          alert("チャンネル名前を作成してください。");
          return;
        } else if(this.channelId.length==0){
          alert("チャンネルIDを作成してください。");
          return;
        } else if(this.channelSecret.length==0){
          alert("チャンネルSECRETを作成してください。");
          return;
        } else if(this.channelToken.length==0){
          alert("チャンネルTOKENを作成してください。");
          return;
        } else if(this.channelUserId.length==0){
          alert("チャンネルユーザーIDを作成してください。");
          return;
        } else if(this.channels.length>=this.channelLimit){
          alert("登録できる最大のチャンネルをオーバーしました。\nもっと登録したい場合、フルアウトのCSD事業部にお問い合せてください。");
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

        axios.post('api/channels',data)
        .then((res)=>{
          alert("新規チャンネル登録完了！");
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
        axios.put('api/channels/' + id, data)
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
          axios.delete('api/channels/'+id).then((res)=>{
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
      }
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
