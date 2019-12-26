<template>
  <div class="page" id="page0">
    <div class="channel_buttons">
      <button class="button" v-if="mode!='create'" @click="changeMode('create')">チャンネル追加</button>
      <button class="button" v-if="mode!='read'" @click="changeMode('read')">キャンセル</button>
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
          <th v-if="mode=='create'"></th>
          <th style="width: 6em;"></th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(channel,index) in channels">
          <td class="channel">{{index+1}}</td>
          <td class="channel">
            <input v-if="selectedChannel==index&&mode=='update'" type="text" v-model="channelName" style="margin: 0 auto;width: 90%;height: 2em;"/>
            <span v-else>{{channel.channel_name}}</span>
          </td>

          <td class="channel channel_ok">
            <input v-if="selectedChannel==index&&mode=='update'" type="text" v-model="channelId" style="margin: 0 auto;width: 90%;height: 2em;" />
            <div v-else>
              <span v-if="channel.channel_id">登録完了</span>
              <span v-else>未登録</span>
            </div>
          </td>

          <td class="channel channel_ok">
            <input v-if="selectedChannel==index&&mode=='update'" type="text" v-model="channelSecret" style="margin: 0 auto;width: 90%;height: 2em;" />
            <div v-else>
              <span v-if="channel.channel_secret">登録完了</span>
              <span v-else>未登録</span>
            </div>
          </td>

          <td class="channel channel_ok">
            <input v-if="selectedChannel==index&&mode=='update'" type="text" v-model="channelToken" style="margin: 0 auto;width: 90%;height: 2em;" />
            <div v-else>
              <span v-if="channel.channel_token">登録完了</span>
              <span v-else>未登録</span>
            </div>
          </td>

          <td class="channel channel_ok">
            <input v-if="selectedChannel==index&&mode=='update'" type="text" v-model="channelUserId" style="margin: 0 auto;width: 90%;height: 2em;" />
            <div v-else>
              <span v-if="channel.channel_user_id">登録完了</span>
              <span v-else>未登録</span>
            </div>
          </td>

          <td class="channel channel_ok" style="width: 6em;">
            <span v-if="channel.channel_destination">連動完了</span>
            <span v-else>未連動</span>
          </td>

          <td style="width: 12em;">
            <div class="buttons" v-if="selectedChannel==index&&mode=='update'">
              <button class="button delete" @click="deleteChannel">
                削除
              </button>
              <button class="button update" @click="updateChannel">
                修正
              </button>
            </div>
            <button v-else class="button" @click="selectToChange(index)">選択</button>
          </td>
        </tr>
        <tr v-if="mode=='create'">
          <td class="channel">{{channels.length+1}}</td>
          <td class="channel">
            <input type="text" v-model="channelName" placeholder="チャンネル名前入力" style="height: 2em;margin-bottom: 0px;" />
          </td>
          <td class="channel">
            <input type="text" v-model="channelId" placeholder="チャンネル名前入力" style="height: 2em;margin-bottom: 0px;" />
          </td>
          <td class="channel">
            <input type="text" v-model="channelSecret" placeholder="チャンネル名前入力" style="height: 2em;margin-bottom: 0px;" />
          </td>
          <td class="channel">
            <input type="text" v-model="channelToken" placeholder="チャンネル名前入力" style="height: 2em;margin-bottom: 0px;" />
          </td>
          <td class="channel">
            <input type="text" v-model="channelUserId" placeholder="チャンネル名前入力" style="height: 2em;margin-bottom: 0px;" />
          </td>
          <td></td>
          <td class="channel">
            <button class="button" @click="createChannel">セーブ</button>
          </td>
        </tr>
      </tbody>
    </table>
    <div class="channel-detail" v-if="showDetail">
      detail
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
      }
    },
    mounted: function(){
      this.fetchChannelsLimit();
      this.fetchChannels();
    },
    methods: {
      fetchChannelsLimit(){
        axios.post('api/check_channel_limit').then((res)=>{
          //console.log(res.data)
          this.channelLimit = res.data
        },(error)=>{
          console.log(res.data)
        })
      },
      fetchChannels(){
        axios.post('api/fetch_channels').then((res)=>{
          //console.log(res.data.channels)
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

        var channel = {}
        channel['channel_name'] = this.channelName
        channel['channel_id'] = this.channelId
        channel['channel_secret'] = this.channelSecret
        channel['channel_token'] = this.channelToken
        channel['channel_user_id'] = this.channelUserId

        axios.post('api/channels',{
          channel: channel
        }).then((res)=>{
          console.log(res.data)
          alert("新規チャンネル登録完了！");
          this.fetchChannels();
          this.mode = 'read'
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
        this.channelId = channel.channel_id
        this.channelSecret = channel.channel_secret
        this.channelToken = channel.channel_token
        this.channelUserId = channel.channel_user_id
        this.changeMode('update');
      },
      updateChannel(){
        var i = this.selectedChannel
        var id = this.channels[i].id
        var channel = {}
        channel['channel_name'] = this.channelName;
        channel['channel_id'] = this.channelId;
        channel['channel_secret'] = this.channelSecret;
        channel['channel_token'] = this.channelToken;
        channel['channel_user_id'] = this.channelUserId;
        axios.put('api/channels/'+id, {
          channel: channel
        }).then((res)=>{
          console.log(res.data)
          alert("アップデート完了！");
          this.mode = 'read';
          this.clearChannelValues();
          this.fetchChannels();
        },(error)=>{
          console.log(res.data)
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
