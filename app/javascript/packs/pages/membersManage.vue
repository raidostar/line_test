<template>
  <div class="page" id="page14">
    <div class="channel_buttons">
      <div class="search-keyword">
        <input class="searchBar" @keydown.enter="searchByKeyword" placeholder="検索" v-model="searchKey" style="width: 18em;" />
        <i class="material-icons search" @click="searchByKeyword">
          search
        </i>
      </div>
    </div>
    <div class="setting">
      <select class="page-setting" v-model="parPage" @change="resetPage">
        <option value=5>5ライン別表示</option>
        <option value=10>10ライン別表示</option>
        <option value=50>50ライン別表示</option>
        <option value=100>100ライン別表示</option>
        <option :value="members.length">全体表示</option>
      </select>
    </div>
    <table class="member-info">
      <thead>
        <tr>
          <th></th>
          <th>メール</th>
          <th>状態</th>
          <th>承認</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(member,index) in members">
          <td class="member-value">{{ index+1 }}</td>
          <td class="member-value">{{member.email}}</td>
          <td class="member-value">
            <select  v-model="statusList[index]" @change="hasChange" style="width: 70%;">
              <option value="master">マスター</option>
              <option value="client">メンバー</option>
            </select>
          </td>
          <td class="member-value">
            <select  v-model="admitList[index]" @change="hasChange" style="width: 70%;">
              <option value=true>承認</option>
              <option value=false>未承認</option>
            </select>
          </td>
        </tr>
      </tbody>
    </table>
    <div class="save-button" v-if="saveShow">
      <button class="button" @click="updateMember">セーブ</button>
    </div>
  </div>
</template>
<script type="text/javascript">
  import axios from 'axios'
  export default {
    name: 'membersManage',
    data: function(){
      return {
        members: [],
        parPage: 5,
        currentPage: 1,
        statusList: [],
        admitList: [],
        saveShow: false,
        searchKey: '',
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
          if(status!='master'||!admit){
            alert("このページの接続権限がありません。")
            location.href = '/';
          } else {
            this.fetchMembers();
          }
        },(error)=>{
          console.log(error)
        })
      },
      fetchMembers(index){
        axios.post('api/fetch_members').then((res)=>{
          //console.log(res.data.users)
          this.members = res.data.users
          for(var member of this.members){
            this.statusList.push(member.status)
            this.admitList.push(member.admit)
          }
        },(error)=>{
          console.log(error)
        })
      },
      updateMember(){
        var users = []
        for(var i in this.members){
          if(this.members[i].status != this.statusList[i]||this.members[i].admit != this.admitList[i]){
            var user = {}
            user['id'] = this.members[i].id
            user['status'] = this.statusList[i]
            user['admit'] = this.admitList[i]
            users.push(user)
          }
        }
        // console.log(users)
        axios.post('api/users_update',{
          users: users
        }).then((res)=>{
          console.log(res.data)
          alert("アップデート完了！");
        },(error)=>{
          console.log(error)
        })
      },
      resetPage(){
        this.currentPage = 1;
      },
      hasChange(){
        this.saveShow = true
      },
      searchByKeyword(){
        if(this.searchKey.length==0) {
          this.fetchMembers();
        } else {
          let searchResult = []
          for(let member of this.members){
            if(member.email.search(this.searchKey)>-1){
              searchResult.push(member)
            }
          }
          this.members = searchResult
        }
      },
    },
    computed: {
      getGroup(){
        let current = this.currentPage * this.parPage;
        let start = current - this.parPage;
        return this.members.slice(start, current);
      },
      getPageCount(){
        return Math.ceil(this.members.length / this.parPage)
      },
    }
  }
</script>
<style scoped src="../components/MembersManage/membersManage.css"/>