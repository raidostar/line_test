<template>
  <div id="app">
    <nav id="topbar" :class="{sticky: (position > 0)}">
      <div style="line-height: 3.5em;">
        <span style="font-size: 25px; font-style: italic; font-weight: 600;">LINE MANAGER</span>
        <a class="loginOut" rel="nofollow" data-method="delete" href="/users/sign_out">
          {{userid}}
        </a>
      </div>
    </nav>
    <nav id="sidebar">
      <div class="side left nav-wrapper container">
        <ul class="hide-on-med-and-down">
          <li class="category"><i class="material-icons">language</i>チャンネル</li>
          <li v-if="mode=='channelManage'&&status!='client'" @click="reloadPage">
            <router-link class="pageLink selected-mode" to="/channelManage"">チャンネル管理</router-link>
          </li>
          <li v-else-if="mode!='channelManage'&&status!='client'" @click="changeMode('channelManage')">
            <router-link class="pageLink home" to="/channelManage">チャンネル管理</router-link>
          </li>
          <select v-model="selectedChannel" @change="selectChannel" style="display: flex;height: 2.8em;">
            <option value="">チャンネルを選択してください</option>
            <option v-for="channel in channels" :value="channel.channel_id">
              {{channel.channel_name}}
            </option>
          </select>
          <li v-if="mode==''" @click="reloadPage">
            <router-link class="pageLink selected-mode" to="/"">チャンネル情報</router-link>
          </li>
          <li v-else @click="changeMode('')">
            <router-link class="pageLink home" to="/">チャンネル情報</router-link>
          </li>

          <li class="category">
            <i class="material-icons">format_align_justify</i>1対1のトーク
          </li>
          <li v-if="mode=='friendsList'" @click="reloadPage">
            <router-link class="pageLink selected-mode" to="/friendsList">友達リスト</router-link>
          </li>
          <li v-else @click="changeMode('friendsList')">
            <router-link class="pageLink" to="/friendsList">友達リスト</router-link>
          </li>

          <li v-if="mode=='allMessages'" @click="reloadPage">
            <router-link class="pageLink selected-mode" to="/allMessages/all">トーク一覧</router-link>
          </li>
          <li v-else @click="changeMode('allMessages')">
            <router-link class="pageLink" to="/allMessages/all">トーク一覧</router-link>
          </li>

          <li v-if="mode=='personalMessages'" @click="reloadPage">
            <router-link class="pageLink selected-mode" to="/personalMessages">個別トーク</router-link>
          </li>
          <li v-else @click="changeMode('personalMessages')">
            <router-link class="pageLink" to="/personalMessages">個別トーク</router-link>
          </li>

          <li class="category"><i class="material-icons">email</i>メッセージ</li>
          <li v-if="mode=='dataAnalysis'" @click="reloadPage">
            <router-link class="pageLink selected-mode" to="/dataAnalysis">データ分析</router-link>
          </li>
          <li v-else @click="changeMode('dataAnalysis')">
            <router-link class="pageLink" to="/dataAnalysis">データ分析</router-link>
          </li>

          <li v-if="mode=='sendAll'" @click="reloadPage">
            <router-link class="pageLink selected-mode" to="/sendAll">全配信</router-link>
          </li>
          <li v-else @click="changeMode('sendAll')">
            <router-link class="pageLink" to="/sendAll">全配信</router-link>
          </li>

          <li v-if="mode=='autoReply'" @click="reloadPage">
            <router-link class="pageLink selected-mode" to="/autoReply">自動応答</router-link>
          </li>
          <li v-else @click="changeMode('autoReply')">
            <router-link class="pageLink" to="/autoReply">自動応答</router-link>
          </li>

          <li v-if="mode=='actionTemplate'" @click="reloadPage">
            <router-link class="pageLink selected-mode" to="/actionTemplate">テンプレート</router-link>
          </li>
          <li v-else @click="changeMode('actionTemplate')">
            <router-link class="pageLink" to="/actionTemplate">テンプレート</router-link>
          </li>

          <li v-if="mode=='tagManagement'" @click="reloadPage">
            <router-link class="pageLink selected-mode" to="/tagManagement">タグ管理</router-link>
          </li>
          <li v-else @click="changeMode('tagManagement')">
            <router-link class="pageLink" to="/tagManagement">タグ管理</router-link>
          </li>

          <li v-if="mode=='remindReply'" @click="reloadPage">
            <!-- <router-link class="pageLink selected-mode" to="/remindReply">リマインダ配信</router-link> -->
            <a class="pageLink" @click="readyAlert">リマインダ配信</a>
          </li>
          <li v-else @click="changeMode('remindReply')">
            <!-- <router-link class="pageLink" to="/remindReply">リマインダ配信</router-link> -->
            <a class="pageLink" @click="readyAlert">リマインダ配信</a>
          </li>

          <li v-if="mode=='welcomeMessage'" @click="reloadPage">
            <router-link class="pageLink selected-mode" to="/welcomeMessage">友だち追加時設定</router-link>
          </li>
          <li v-else @click="changeMode('welcomeMessage')">
            <router-link class="pageLink" to="/welcomeMessage">友だち追加時設定</router-link>
          </li>

          <li v-if="mode=='richMenu'" @click="reloadPage">
            <router-link class="pageLink selected-mode" to="/richMenu">
              リッチメニュー
            </router-link>
          </li>
          <li v-else @click="changeMode('richMenu')">
            <router-link class="pageLink" to="/richMenu">
              リッチメニュー
            </router-link>
          </li>

          <li class="category"><i class="material-icons">person</i>マイページ</li>
          <li v-if="mode=='membersManage'&&status=='master'" @click="reloadPage">
            <router-link class="pageLink selected-mode" to="/membersManage">メンバー管理</router-link>
          </li>
          <li v-else-if="mode!='membersManage'&&status=='master'" @click="changeMode('membersManage')">
            <router-link class="pageLink" to="/membersManage">メンバー管理</router-link>
          </li>

          <li v-if="mode=='adminPage'&&status=='admin'" @click="reloadPage">
            <router-link class="pageLink selected-mode" to="/adminPage">グループ管理</router-link>
          </li>
          <li v-else-if="mode!='adminPage'&&status=='admin'" @click="changeMode('adminPage')">
            <router-link class="pageLink" to="/adminPage">グループ管理</router-link>
          </li>

          <li><a class="pageLink" href="users/edit">個人情報設定</a></li>
          <li><a class="pageLink" rel="nofollow" data-method="delete" href="/users/sign_out">ログアウト</a></li>
        </ul>
      </div>
    </nav>
    <div id="page">
      <router-view/>
    </div>
    <Footer msg="This is common footer rendered by vue's single file components"/>
  </div>
</template>
<script type="text/javascript">
  import Header from './components/main/header.vue'
  import Footer from './components/main/footer.vue'
  import axios from 'axios'

  export default {
    name: 'MyApp',
    props: {
      msg: String
    },
    components: {
      Header,Footer
    },
    data: function(){
      return {
        position: undefined,
        show: false,
        userid: '',
        loading: true,
        mode: '',
        status: '',
        channels: [],
        selectedChannel: '',
      }
    },
    mounted: function(){
      this.showCurrent();
      this.sendMode();
      this.fetchChannels();
    },
    methods: {
      showCurrent(){
        axios.post('api/show_current').then((res)=>{
          // console.log(res.data)
          if(res.data!=null){
            // console.log(res.data)
            this.userid = res.data.user.email
            this.selectedChannel = res.data.user.target_channel
            this.status = res.data.user.status
          } else {
            alert("権限がありません。フルアウトのCSD事業部にお問い合せてください。")
            axios.delete('users/sign_out').then((res)=>{
              location.href= '/users/sign_in'
            },(error)=>{
              console.log(error)
            })
          }
        },(error)=>{
          console.log(error)
        })
      },
      fetchChannels(){
        axios.post('api/fetch_channels').then((res)=>{
          if(res.data!=null){
            this.channels = res.data.channels
            this.$nextTick(function(){
              if(this.selectedChannel==null){
                if(this.channels.length > 0){
                  alert("チャンネルと連動します。")
                  this.selectedChannel = this.channels[0].channel_id
                  this.selectChannel();
                } else {
                  alert("まず、チャンネルを登録してご利用ください。");
                  location.href = "/#/channelManage"
                }
              }
            })
          }
        },(error)=>{
          console.log(error)
        })
      },
      sendMode(){
        var url = window.location.href
        var mode = url.substr(24,url.length)
        this.changeMode(mode);
      },
      changeMode(mode){
        this.mode = mode
      },
      selectChannel(){
        if(this.selectedChannel==''){
          alert("チャンネルを選択してください。")
          return;
        }
        axios.post('api/save_target_channel', {
          target_channel: this.selectedChannel
        }).then((res)=>{
          console.log(res.data.user.target_channel)
          this.selectedChannel = res.data.user.target_channel
          window.location.reload();
        },(error)=>{
          console.log(error)
        })
      },
      reloadPage(){
        window.location.reload();
      },
      readyAlert(){
        alert("リマインダ配信はまだ準備中でございます。")
        return;
      }
    }
  }
</script>
<!-- <script src="./app.js"/> -->
<style src="./app.css"/>
