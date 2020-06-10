<template>
  <div class="page" id="page2">
    <div>
      <div>
        <div class="setting">
          <select class="page-setting" v-model="parPage" @change="resetPage">
            <option value=5>5個表示</option>
            <option value=10>10個表示</option>
            <option value=50>50個表示</option>
            <option value=100>100個表示</option>
            <option value=500>500個表示</option>
            <option :value="friendsList.length">全体表示</option>
          </select>
        </div>
      </div>
    </div>
    <table class="fList">
      <thead>
        <tr>
          <th><input type="checkbox" name="allUser" value="1" class="checkbox"/></th>
          <th>状態</th>
          <th style="width: 19em;">名前</th>
          <th>ブロック状態</th>
          <th>直近のメッセージ</th>
          <th>タグ・友だち情報</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(friend,i) in getFriend" >
          <td><input type="checkbox" value="1" class="checkbox"/></td>
          <td><span>確認済み</span></td>
          <td>
            <div class="personal">
              <img v-if="friend.profile_pic" :src="friend.profile_pic" class="profile_img" ref="profile_image">
              <i class="material-icons profile" v-else>account_circle</i>
              <router-link class="personalPage" :to="'/personalPage/'+((currentPage-1)*parPage+i)">
                <span v-if="friend.fr_name.length>7">{{friend.fr_name.substr(0,7)+'...'}}</span>
                <span v-else>{{friend.fr_name}}</span>
              </router-link>
            </div>
          </td>
          <td v-if="friend.block==false" style="color: green;">受信中</td>
          <td v-else style="color: red;">ブロック</td>
          <td>
            <a v-if="friend.last_message!=null&&friend.last_message.search('<img src=')>=0"
              @click="showFullContents(friend.last_message)"
              v-html="friend.last_message.substr(0,100)"
              >
            </a>
            <a v-else @click="showFullContents(friend.last_message)">
              <span v-if="friend.last_message!=null&&friend.last_message.length>10" v-html="friend.last_message.substr(0,10)+'...'"></span>
              <span v-else-if="friend.last_message!=null&&friend.last_message.length<=10" v-html="friend.last_message.substr(0,20)"></span>
            </a>
          </td>
          <td>{{friend.tags}}</td>
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
  <transition name="tadaInOut">
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
<div v-show="loading" class="waiting-screen">
  <div class="spinner">
    <div class="bounce1"></div>
    <div class="bounce2"></div>
    <div class="bounce3"></div>
  </div>
</div>
<!-- <div>
  <div class="tips" v-show="tipsPage!=tips.length">
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
  </div>
</div> -->
</div>
</template>

<script>
  import axios from 'axios'
  export default {
    name: 'friendsList',
    data: function(){
      return {
        friendsList: [],
        message: [],
        showDetail: false,
        fullContents: '',
        parPage: 5,
        currentPage: 1,
        selected_center: null,
        lastMessage: '',
        loading: true,
        topCover: {'height':'16.5%'},
        bottomCover: {'height':'77%'},
        leftCover: {'width':'15.5%'},
        rightCover: {'width':'71%'},
        focusLineCSS: {'width':'13.6%','height':'6.5%','left':'15.5%','top':'16.5%'},
        explanationCSS: {'right':'54%','top':'26%','width': '30%','height': '18%'},
        tips: [
          '<p>各友だちから来た</p><p>最後のメッセージの状態が表示されます。</p>',
          '<p>LINEで設定したユーザー名が表示されます。</p>',
          '<p>各友だちの受信状態が表示されます。</p>',
          '<p>各友だちから送信された最後のメッセージの内容が表示されます。</p>',
          '<p>各友だちのタグが表示されます。</p>',
          '<p>友だちのタグは個人ページやタグ管理ページで</p><p>設定することができます。</p>',
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
            this.fetchFriends();
          }
        },(error)=>{
          console.log(error)
        })
      },
      fetchFriends(){
        this.loading = true
        axios.get('/api/friends').then((res) => {
          this.friendsList = res.data.friends
          this.loading = false
        }, (error) => {
          console.log(error)
        })
      },
      closeDetail(){
        this.showDetail = false
      },
      clickCallback(pageNum){
        this.currentPage = Number(pageNum);
      },
      resetPage(){
        this.currentPage = 1;
      },
      detailImage(url){
        alert(url)
        let imageHTML = '<img src="'+url+'" style="width: 100%; height: 26em;">'
        this.fullContents = imageHTML;
        this.showDetail = true;
      },
      showFullContents(contents){
        if (contents.search("@map")>=0){
          var tempArr = this.mapConvert(contents)
          this.selected_center = tempArr
        }
        this.fullContents = contents;
        this.showDetail = true;
      },
      mapConvert(contents){
        let tempArr = contents.split("+")
        const tempLength = tempArr[1].length;
        tempArr = tempArr[1].substring(6,tempLength-2).split(",");
        tempArr[0] = tempArr[0]*1;
        tempArr[1] = tempArr[1]*1;
        return {lat: tempArr[0], lng: tempArr[1]}
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
          this.topCover = {'height':'16.5%'}
          this.bottomCover = {'height':'77%'}
          this.leftCover = {'width':'15.5%'}
          this.rightCover = {'width':'71%'}
          this.focusLineCSS = {'width':'13.6%','height':'6.5%','left':'15.5%','top':'16.5%'}
          this.explanationCSS = {'right':'54%','top':'26%','width': '30%','height': '18%'}
          break;
          case 1:
          this.topCover = {'height':'16.5%'}
          this.bottomCover = {'height':'77%'}
          this.leftCover = {'width':'29.5%'}
          this.rightCover = {'width':'53.8%'}
          this.focusLineCSS = {'width':'16.6%','height':'6.5%','left':'29.5%','top':'16.5%'}
          this.explanationCSS = {'right':'41%','top':'26%','width': '30%','height': '18%'}
          break;
          case 2:
          this.topCover = {'height':'16.5%'}
          this.bottomCover = {'height':'77%'}
          this.leftCover = {'width':'46.5%'}
          this.rightCover = {'width':'36.8%'}
          this.focusLineCSS = {'width':'16.6%','height':'6.5%','left':'46.5%','top':'16.5%'}
          this.explanationCSS = {'right':'24%','top':'26%','width': '30%','height': '18%'}
          break;
          case 3:
          this.topCover = {'height':'16.5%'}
          this.bottomCover = {'height':'77%'}
          this.leftCover = {'width':'62.5%'}
          this.rightCover = {'width':'20.8%'}
          this.focusLineCSS = {'width':'16.6%','height':'6.5%','left':'62.5%','top':'16.5%'}
          this.explanationCSS = {'right':'9%','top':'26%','width': '30%','height': '18%'}
          break;
          case 4:
          this.topCover = {'height':'16.5%'}
          this.bottomCover = {'height':'77%'}
          this.leftCover = {'width':'81.2%'}
          this.rightCover = {'width':'2%'}
          this.focusLineCSS = {'width':'16.6%','height':'6.5%','left':'81.3%','top':'16.5%'}
          this.explanationCSS = {'right':'1%','top':'26%','width': '30%','height': '18%'}
          break;
          case 5:
          this.topCover = {'height':'16.5%'}
          this.bottomCover = {'height':'77%'}
          this.leftCover = {'width':'81.2%'}
          this.rightCover = {'width':'2%'}
          this.focusLineCSS = {'width':'16.6%','height':'6.5%','left':'81.3%','top':'16.5%'}
          this.explanationCSS = {'right':'1%','top':'26%','width': '30%','height': '18%'}
          break;
        }
        if(page==this.tips.length-1){
          this.nextWord = '完了'
        }
      },
    },
    computed: {
      getFriend(){
        let current = this.currentPage * this.parPage;
        let start = current - this.parPage;
        return this.friendsList.slice(start, current);
      },
      testMethod(){
        alert("test")
      },
      getPageCount(){
        return Math.ceil(this.friendsList.length / this.parPage)
      },
    },
    updated(){
      this.$nextTick(function(){
        var profile = this.$refs.profile_image
        if(profile != null){
          if( profile.src != '' && profile.complete == true && profile.naturalWidth == 0 ){
            this.friend.profile_pic = null
          }
        }
      })
    }
  }
</script>

<style scoped src="../components/FriendsList/friendsList.css"/>