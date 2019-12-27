<template>
  <div class="page" id="page13">
    <div class="channel_buttons">
      <button class="button" v-if="mode=='read'" @click="changeMode('create')">グループ追加</button>
      <button class="button" v-else @click="changeMode('read')">キャンセル</button>
    </div>
    <div class="setting">
      <select class="page-setting" v-model="parPage" @change="resetPage">
        <option value=5>5ライン別表示</option>
        <option value=10>10ライン別表示</option>
        <option value=50>50ライン別表示</option>
        <option value=100>100ライン別表示</option>
        <option value=500>500ライン別表示</option>
        <option :value="groups.length">全体表示</option>
      </select>
    </div>
    <table class="group_info">
      <thead>
        <tr>
          <th></th>
          <th>グループ名前</th>
          <th>グループキー</th>
          <th>グループ承認</th>
          <th>グループ等級</th>
          <th>チャンネル数</th>
          <th>チャンネル可能</th>
          <th>メンバー可能</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <!-- group list -->
        <tr v-for="(group,index) in groups">
          <td class="group_value">
            {{ index+1 }}
          </td>
          <td class="group_value">
            <input v-if="selectedGroup==index&&mode=='update'" type="text" v-model="groupName" placeholder="チャンネル名前入力" style="height: 2em;margin-bottom: 0px;text-align: center;"/>
            <span class="group-name" v-else @click="fetchMembers(index)">{{ group.group }}</span>
          </td>
          <td class="group_value">
            <div v-if="selectedGroup==index&&mode=='update'">
              <span v-if="groupKey.length>0" v-model="groupKey">
                {{ groupKey }}
              </span>
              <button class="button" v-if="groupKey.length==0" @click="makeGroupKey(index)" style="float: none;margin:0 auto;">
                新規発行
              </button>
            </div>
            <div v-else>
              <span v-if="group.group_key">発行完了</span>
              <span v-else>未発行</span>
            </div>
          </td>
          <td class="group_value">
            <select v-if="selectedGroup==index&&mode=='update'" v-model="groupAdmit" style="display: flex; width: 90%; margin: 0 auto;">
              <option value=true>承認完了</option>
              <option value=false>未承認</option>
            </select>
            <div v-else>
              <span v-if="group.admit" style="color: green;">承認完了</span>
              <span v-else style="color: red;">未承認</span>
            </div>
          </td>
          <td class="group_value">
            <select v-if="selectedGroup==index&&mode=='update'" v-model="groupStatus" @change="changeStatus" style="display: flex; width: 95%; margin: 0 auto;">
              <option value="normal">普通</option>
              <option value="silver">シルバー</option>
              <option value="gold">ゴルド</option>
              <option value="premium">プレミアム</option>
            </select>
            <div v-else>
              <span v-if="group.status=='normal'">普通</span>
              <span v-else-if="group.status=='silver'">シルバー</span>
              <span v-else-if="group.status=='gold'">ゴルド</span>
              <span v-else-if="group.status=='premium'">プレミアム</span>
              <span v-else>未登録</span>
            </div>
          </td>
          <td class="group_value">{{ channelNum[index] }}</td>
          <td class="group_value">
            <input v-if="selectedGroup==index&&mode=='update'" type="number" v-model="groupChannelLimit" @change="checkLimit" placeholder="可能チャンネル数設定" style="height: 2em;margin-bottom: 0px;width: 50%;text-align: center;"/>
            <span v-else>{{ group.channels_limit }}</span>
          </td>
          <td class="group_value">
            <input v-if="selectedGroup==index&&mode=='update'" type="number" v-model="groupMemberLimit" @change="checkLimit" placeholder="可能チャンネル数設定" style="height: 2em;margin-bottom: 0px;width: 50%;text-align: center;"/>
            <span v-else>{{ group.member_limit }}</span>
          </td>
          <td class="group_value">
            <button v-if="selectedGroup==index&&mode=='update'" class="button" @click="updateGroup" style="background: #00b900;">
              修正
            </button>
            <button v-else class="button" @click="selectToChange(index)">選択</button>
          </td>
        </tr>

        <!-- make a new group -->
        <tr v-if="mode=='create'">
          <td class="group_value">{{groups.length+1}}</td>
          <td class="group_value">
            <input type="text" v-model="groupName" placeholder="チャンネル名前入力" style="height: 2em;margin-bottom: 0px;text-align: center;"/>
          </td>
          <td class="group_value">
            <span v-if="groupKey" v-model="groupKey">
              {{ groupKey }}
            </span>
            <button class="button" v-else-if="!groupKey" @click="makeGroupKey(index)" style="float: none; margin: 0 auto;">
              新規発行
            </button>
          </td>
          <td class="group_value">
            <select v-model="groupAdmit" style="display: flex; width: 90%; margin: 0 auto;">
              <option value=true>承認完了</option>
              <option value=false>未承認</option>
            </select>
          </td>
          <td class="group_value">
            <select v-model="groupStatus" @change="changeStatus" style="display: flex; width: 95%; margin: 0 auto;">
              <option value="normal">普通</option>
              <option value="silver">シルバー</option>
              <option value="gold">ゴルド</option>
              <option value="premium">プレミアム</option>
            </select>
          </td>
          <td class="group_value">
          </td>
          <td class="group_value">
            <input type="number" v-model="groupChannelLimit" @change="checkLimit" placeholder="可能チャンネル数設定" style="height: 2em;margin-bottom: 0px;width: 50%;text-align: center;"/>
          </td>
          <td class="group_value">
            <input type="number" v-model="groupMemberLimit" @change="checkLimit" placeholder="可能チャンネル数設定" style="height: 2em;margin-bottom: 0px;width: 50%;text-align: center;"/>
          </td>
          <td>
            <button class="button" @click="createGroup">セーブ</button>
          </td>
        </tr>
      </tbody>
    </table>
    <!-- member list -->
    <transition name="fadeInOut">
      <div class="window" v-if="memberShow">
        <div class="save" v-if="saveShow" @click="updateMember">save</div>
        <div class="close" @click="closeMemberDetail">close</div>
        <div class="member-detail">
          <table>
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
        </div>
      </div>
    </transition>
  </div>
</template>
<script>
  import axios from 'axios'
  export default {
    name: 'adminPage',
    components: {
    },
    data: function(){
      return {
        groups: [],
        mode: 'read',
        groupKeyShow: false,
        groupKey: '',
        selectedGroup: 0,
        groupName: '',
        groupAdmit: false,
        groupStatus: 'normal',
        groupChannelLimit: 1,
        groupMemberLimit: 1,
        parPage: 5,
        currentPage: 1,
        channelNum: [],
        members: [],
        memberShow: false,
        statusList: [],
        admitList: [],
        saveShow: false,
      }
    },
    mounted: function(){
      this.fetchGroups();
    },
    methods: {
      fetchGroups(){
        axios.post('api/fetch_groups').then((res)=>{
          this.groups = res.data
          for(var group of this.groups){
            if(group.channels!=null){
              var channels = group.channels.split(",")
              this.channelNum.push(channels.length)
            } else {
              this.channelNum.push(0)
            }
          }
        },(error)=>{
          console.log(error)
        })
      },
      makeGroupKey(index){
        this.selectedGroup = index
        axios.post('api/make_group_key').then((res)=>{
          this.groupKeyShow = true
          this.groupKey = res.data
        },(error)=>{
          console.log(error)
        })
      },
      clickCallback(pageNum){
        this.currentPage = Number(pageNum);
      },
      resetPage(){
        this.currentPage = 1;
      },
      changeMode(type){
        this.mode = type
        if(type=='read'){
          this.clearGroupValues();
        }
      },
      selectToChange(index){
        this.selectedGroup = index
        this.groupName = this.groups[index].group
        this.groupAdmit = this.groups[index].admit
        this.groupStatus = this.groups[index].status
        this.groupChannelLimit = this.groups[index].channels_limit
        this.groupMemberLimit = this.groups[index].member_limit
        this.changeMode('update');
      },
      updateGroup(){
        var i = this.selectedGroup
        var id = this.groups[i].id
        axios.put('api/groups/'+id, {
          group: this.groupName,
          group_key: this.groupKey,
          admit: this.groupAdmit,
          status: this.groupStatus,
          channels_limit: this.groupChannelLimit,
          member_limit: this.groupMemberLimit,
        }).then((res)=>{
          alert("アップデート完了！");
          this.mode = 'read';
          this.clearGroupValues();
          this.fetchGroups();
        },(error)=>{
          console.log(error)
        })
      },
      createGroup(){
        if(this.groupName.length==0){
          alert("グループ名前を入力してください。");
          return
        } else if(this.groupKey.length==0){
          alert("グループ名前を入力してください。");
          return
        }
        for(var group of this.groups){
          if(group.group==this.groupName){
            alert("もうあるグループ名ですので、登録できません。");
            return
            break;
          }
        }
        axios.post('api/groups', {
          group: this.groupName,
          group_key: this.groupKey,
          admit: this.groupAdmit,
          status: this.groupStatus,
          channels_limit: this.groupChannelLimit,
          member_limit: this.groupMemberLimit,
        }).then((res)=>{
          alert("新規グループ登録完了！");
          this.mode='read'
          this.clearGroupValues();
          this.fetchGroups();
        },(error)=>{
          console.log(error)
        })
      },
      clearGroupValues(){
        this.groupKey = ''
        this.groupName = ''
        this.groupAdmit = false
        this.groupStatus = 'normal'
        this.groupChannelLimit = 1
        this.groupMemberLimit = 1
      },
      checkLimit(){
        var i = this.groupChannelLimit
        var j = this.groupMemberLimit
        if(i<1){
          alert("デフォルトのチャンネル可能数は１です。")
          this.groupChannelLimit = 1;
        } else if(this.groupStatus=='silver'){
          if(i<10){
            alert("シルバーのチャンネル可能数は１０以上です。")
            this.groupChannelLimit = 10;
          }
        } else if(this.groupStatus=='gold'){
          if(i<20){
            alert("ゴルドのチャンネル可能数は５０以上です。")
            this.groupChannelLimit = 50;
          }
        } else if(this.groupStatus=='premium'){
          if(i<100){
            alert("プレミアムのチャンネル可能数は１００です。")
            this.groupChannelLimit = 100;
          }
        }
        if(j<1){
          alert("デフォルトのメンバー可能数は１です。")
          this.groupMemberLimit = 1;
        } else if(this.groupStatus=='silver'){
          if(j<10){
            alert("シルバーのメンバー可能数は１０以上です。")
            this.groupMemberLimit = 10;
          }
        } else if(this.groupStatus=='gold'){
          if(j<20){
            alert("ゴルドのメンバー可能数は５０以上です。")
            this.groupMemberLimit = 50;
          }
        } else if(this.groupStatus=='premium'){
          if(j<100){
            alert("プレミアムのメンバー可能数は１００です。")
            this.groupMemberLimit = 100;
          }
        }
      },
      changeStatus(){
        var status = this.groupStatus
        switch(status){
          case 'normal':
          this.groupChannelLimit = 1
          this.groupMemberLimit = 1
          break;
          case 'silver':
          this.groupChannelLimit = 10
          this.groupMemberLimit = 10
          break;
          case 'gold':
          this.groupChannelLimit = 50
          this.groupMemberLimit = 50
          break;
          case 'premium':
          this.groupChannelLimit = 100
          this.groupMemberLimit = 100
          break;
          default:
          console.log("changeStatus error!")
        }
      },
      fetchMembers(index){
        this.memberShow = true
        this.statusList = []
        this.admitList = []
        var group = this.groups[index].group
        axios.post('api/fetch_members',{
          group: group
        }).then((res)=>{
          this.members = res.data.users
          for(var member of this.members){
            this.statusList.push(member.status)
            this.admitList.push(member.admit)
          }
        },(error)=>{
          console.log(error)
        })
      },
      closeMemberDetail(){
        this.saveShow = false
        this.memberShow = false
      },
      hasChange(){
        this.saveShow = true
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
        axios.post('api/users_update',{
          users: users
        }).then((res)=>{
          alert("アップデート完了！");
          this.closeMemberDetail();
        },(error)=>{
          console.log(error)
        })
      },
    },
    computed: {
      getGroup(){
        let current = this.currentPage * this.parPage;
        let start = current - this.parPage;
        return this.groups.slice(start, current);
      },
      getPageCount(){
        return Math.ceil(this.groups.length / this.parPage)
      },
    }
  }
</script>
<style scoped src="../components/AdminPage/adminPage.css"/>
