<template>
  <div class="page" id="page2">
    <div>
      <div>
        <h2 class="title">友達リスト<hr/></h2>
        <div class="setting">
          <select v-model="parPage" @change="resetPage">
            <option value=5>5ライン別表示</option>
            <option value=10>10ライン別表示</option>
            <option value=50>50ライン別表示</option>
            <option value=100>100ライン別表示</option>
            <option value=500>500ライン別表示</option>
            <option :value="friendsList.length">全体表示</option>
          </select>
        </div>
      </div>
    </div>
    <table class="fList">
      <thead>
        <tr>
          <th><input type="checkbox" name="allUser" value="1" class="checkbox"/></th>
          <th>状況</th>
          <th>名前</th>
          <th>ブロック状態</th>
          <th>最新のメッセージ</th>
          <th>タグ・友だち情報</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="fr in getFriend" >
          <td><input type="checkbox" value="1" class="checkbox"/></td>
          <td><span>確認済み</span></td>
          <td style="text-align: left; padding-left: 100px;">
            <img :src="fr.profile_pic" class="profile_img">
            <router-link class="personalPage" :to="'/personalPage/'+fr.id">{{fr.fr_name}}</router-link>
          </td>
          <td v-if="fr.block==false" style="color: green;">受信中</td>
          <td v-else style="color: red;">ブロック</td>
          <td v-if="fr.last_message!=null&&fr.last_message.search('https://cdn.lineml.jp/api/media')>=0">
            <a @click="detailImage(fr.last_message)">
              <img class="stampBtnImg" :src="fr.last_message"/>
            </a>
          </td>
          <td v-else>
            <a v-if="fr.last_message!=null&&fr.last_message.search('<img src=')>=0"
              @click="showFullContents(fr.last_message)"
              v-html="fr.last_message.substr(0,100)"
              >
            </a>
            <a v-else @click="showFullContents(fr.last_message)">
              <span v-if="fr.last_message!=null&&fr.last_message.length>10" v-html="fr.last_message.substr(0,10)+'...'"></span>
              <span v-else-if="fr.last_message!=null&&fr.last_message.length<=10" v-html="fr.last_message.substr(0,20)"></span>
            </a>
          </td>
          <td>{{fr.tags}}</td>
        </tr>
      </tbody>
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
      }
    },
    mounted: function(){
      this.fetchFriends();
    },
    methods: {
      fetchFriends(){
        axios.get('/api/friends').then((res) => {
          this.friendsList = res.data.friends
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
        let imageHTML = '<img src='+url+' style="width: 21em;height: 26em;">'
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
        const tempLength = tempArr[1].length
        tempArr = tempArr[1].substring(6,tempLength-2).split(",")
        tempArr[0] = tempArr[0]*1
        tempArr[1] = tempArr[1]*1
        return {lat: tempArr[0], lng: tempArr[1]}
      },
    },
    computed: {
      getFriend(){
        let current = this.currentPage * this.parPage;
        let start = current - this.parPage;
        return this.friendsList.slice(start, current);
      },
      getPageCount(){
        return Math.ceil(this.friendsList.length / this.parPage)
      },
    }
  }
</script>

<style scoped src="../components/page2/page2.css"/>