<template>
  <div class="page" id="page9">
    <div v-show="loading" class="waiting-screen">
      <div class="spinner">
        <div class="bounce1"></div>
        <div class="bounce2"></div>
        <div class="bounce3"></div>
      </div>
    </div>
    <!-- 친구 태그 -->
    <div class="friend-tag col">
      <div class="label">
        <i class="material-icons folder">folder_open</i>
        友達タグ
        <i class="material-icons add-tag" v-if="addTo!='friend'" @click="addMode('friend')">add_to_photos</i>
        <i class="material-icons close-tag" v-if="addTo=='friend'" @click="addMode('')">cancel_presentation</i>
      </div>
      <div>
        <div v-for="(tag,index) in friendTags" class="added-folder">
          <span v-if="tag.id==selectedFriend">
            <div class="added-folderBtn" id="added-folderBtn" :style="selectedCSS">
              <i style="float: left;" class="material-icons open-file-added">insert_drive_file</i>
              <span v-if="editTo!='friend'" class="selected-tag" @click="editMode('friend',tag.name)">
                {{tag.name}}
              </span>
              <span v-if="editTo=='friend'" class="selected-tag">
                <input type="text" ref="friend" v-model="tag.name"
                style="width: 50%;text-align:center;color: white;height:2em;"
                @keyup.esc="closeEdit" @keyup.enter="updateTag(tag.id,tag.name)"/>
              </span>
              <i class="material-icons trashcan" v-if="tag.name!='ALL'&&editTo==''" @click="deleteTag(tag.name,tag.id)">
                delete_outline
              </i>
            </div>
          </span>
          <span v-else>
            <button class="added-folderBtn" id="added-folderBtn" @click="clickTag(index,'friend',tag.id)">
              <i style="float: left;" class="material-icons open-file-added">insert_drive_file</i>
              <span style="padding-right: 28px;">
                {{tag.name}}
              </span>
            </button>
          </span>
        </div>
        <div class="add-tag-area" v-if="addTo!='friend'">
          <button class="add-tag-button" @click="addMode('friend')">
            <i class="material-icons add-button">add</i>
          </button>
        </div>
        <div class="tag-input-area" v-if="addTo=='friend'">
          <i style="float: left; line-height: 3em;" class="material-icons open-file-added">insert_drive_file</i>
          <input class="tag-input" type="text" v-model="friendTag" placeholder="タグ入力" style="width: 70%; text-align: center;" @keyup.enter="createTag('friend')" @keyup.esc="addMode('')"/>
          <i v-if="friendTag" class="material-icons clear-tag" @click="clearTag('friend')">cancel</i>
        </div>
      </div>
    </div>

    <!-- 옵션 태그 -->
    <div class="option-tag col">
      <div class="label">
        <i class="material-icons folder">folder_open</i>
        条件タグ
        <i class="material-icons add-tag" v-if="addTo!='option'" @click="addMode('option')">add_to_photos</i>
        <i class="material-icons close-tag" v-if="addTo=='option'" @click="addMode('')">cancel_presentation</i>
      </div>
      <div>
        <div v-for="(tag,index) in optionTags" class="added-folder">
          <span v-if="tag.id==selectedOption">
            <div class="added-folderBtn" id="added-folderBtn" :style="selectedCSS">
              <i style="float: left;" class="material-icons open-file-added">insert_drive_file</i>
              <span v-if="editTo!='option'" class="selected-tag" @click="editMode('option',tag.name)">
                {{tag.name}}
              </span>
              <span v-if="editTo=='option'" class="selected-tag">
                <input type="text" ref="option" v-model="tag.name"
                style="width: 50%;text-align:center;color: white;height:2em;"
                @keyup.esc="closeEdit" @keyup.enter="updateTag(tag.id,tag.name)"/>
              </span>
              <i class="material-icons trashcan" v-if="tag.name!='ALL'&&tag.name==''" @click="deleteTag(tag.name,tag.id)">
                delete_outline
              </i>
            </div>
          </span>
          <span v-else>
            <button class="added-folderBtn" id="added-folderBtn" @click="clickTag(index,'option',tag.id)">
              <i style="float: left;" class="material-icons open-file-added">insert_drive_file</i>
              <span style="padding-right: 28px;">
                {{tag.name}}
              </span>
            </button>
          </span>
        </div>
        <div class="add-tag-area" v-if="addTo!='option'">
          <button class="add-tag-button" @click="addMode('option')">
            <i class="material-icons add-button">add</i>
          </button>
        </div>
        <div class="tag-input-area" v-if="addTo=='option'">
          <i style="float: left; line-height: 3em;" class="material-icons open-file-added">insert_drive_file</i>
          <input class="tag-input" type="text" v-model="optionTag" placeholder="タグ入力" style="width: 70%; text-align: center;"
          @keyup.enter="createTag('option')" @keyup.esc="addMode('')"/>
          <i v-if="optionTag" class="material-icons clear-tag" @click="clearTag('option')">cancel</i>
        </div>
      </div>
    </div>

    <!-- 리액션 태그 -->
    <div class="reaction-tag col">
      <div class="label">
        <i class="material-icons folder">folder_open</i>
        アクションタグ
        <i class="material-icons add-tag" v-if="addTo!='reaction'" @click="addMode('reaction')">add_to_photos</i>
        <i class="material-icons close-tag" v-if="addTo=='reaction'" @click="addMode('')">cancel_presentation</i>
      </div>
      <div>
        <div v-for="(tag,index) in reactionTags" class="added-folder">
          <span v-if="tag.id==selectedReaction">
            <div class="added-folderBtn" id="added-folderBtn" @click="clickTag(index,'reaction',tag.id)" :style="selectedCSS">
              <i style="float: left;" class="material-icons open-file-added">insert_drive_file</i>
              <span v-if="editTo!='reaction'" class="selected-tag" @click="editMode('reaction',tag.name)">
                {{tag.name}}
              </span>
              <span v-if="editTo=='reaction'" class="selected-tag">
                <input type="text" ref="reaction" v-model="tag.name"
                style="width: 50%;text-align:center;color: white;height:2em;"
                @keyup.esc="closeEdit" @keyup.enter="updateTag(tag.id,tag.name)"/>
              </span>
              <i class="material-icons trashcan" v-if="tag.name!='ALL'&&editTo==''" @click="deleteTag(tag.name,tag.id)">
                delete_outline
              </i>
            </div>
          </span>
          <span v-else>
            <button class="added-folderBtn" id="added-folderBtn" @click="clickTag(index,'reaction',tag.id)">
              <i style="float: left;" class="material-icons open-file-added">insert_drive_file</i>
              <span style="padding-right: 28px;">
                {{tag.name}}
              </span>
            </button>
          </span>
        </div>
        <div class="add-tag-area" v-if="addTo!='reaction'">
          <button class="add-tag-button" @click="addMode('reaction')">
            <i class="material-icons add-button">add</i>
          </button>
        </div>
        <div class="tag-input-area" v-if="addTo=='reaction'">
          <i style="float: left; line-height: 3em;" class="material-icons open-file-added">insert_drive_file</i>
          <input class="tag-input" type="text" v-model="reactionTag" placeholder="タグ入力" style="width: 70%; text-align: center;"
          @keyup.enter="createTag('reaction')" @keyup.esc="addMode('')"/>
          <i v-if="reactionTag" class="material-icons clear-tag" @click="clearTag('reaction')">cancel</i>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
  import axios from 'axios'
  export default {
    name: 'tagManagement',
    data: function(){
      return {
        friendTags: [],
        optionTags: [],
        reactionTags: [],
        selectedFriend: '',
        selectedOption: '',
        selectedReaction: '',
        selectedFriendTag: '',
        selectedOptionTag: '',
        selectedReactionTag: '',
        selectedCSS: {'background-color': '#444444', 'color': 'white'},
        addTo: '',
        editTo: '',
        friendTag: '',
        optionTag: '',
        reactionTag: '',
        friendEditTag: '',
        optionEditTag: '',
        reactionEditTag: '',
        loading: true,
      }
    },
    mounted: function(){
      this.fetchChannels();
    },
    methods: {
      fetchChannels(){
        axios.post('api/fetch_channels').then((res)=>{
          if(res.data==null){
            alert("まず、チャンネルを登録してご利用ください。");
            location.href = "/#/channelManage"
          } else {
            this.fetchFriendTags();
            this.fetchOptionTags();
            this.fetchReactionTags();
          }
        },(error)=>{
          console.log(error)
        })
      },
      clickTag(index,type,id){
        this.editTo = ''
        switch(type){
          case 'friend':
          this.selectedFriend = id
          this.selectedFriendTag = this.friendTags[index]
          break;
          case 'option':
          this.selectedOption = id
          this.selectedOptionTag = this.optionTags[index]
          break;
          case 'reaction':
          this.selectedReaction = id
          this.selectedReactionTag = this.reactionTags[index]
          break;
          default:
        }
      },
      fetchFriendTags(){
        this.loading = true
        axios.get('/api/tags?tag_group=friend').then((res)=>{
          this.friendTags = res.data.tags
          this.loading = false
        },(error)=>{
          console.log(error)
        })
      },
      fetchOptionTags(){
        this.loading = true
        axios.get('/api/tags?tag_group=option').then((res)=>{
          this.optionTags = res.data.tags
          this.loading = false
        },(error)=>{
          console.log(error)
        })
      },
      fetchReactionTags(){
        this.loading = true
        axios.get('/api/tags?tag_group=reaction').then((res)=>{
          this.reactionTags = res.data.tags
          this.loading = false
        },(error)=>{
          console.log(error)
        })
      },
      createTag(mode){
        let name = ""
        let tag_group = mode
        switch(tag_group){
          case 'friend':
          name = this.friendTag
          for(var tag of this.friendTags){
            if(tag.name==name){
              alert("もうあるタグです。");
              return;
            }
          }
          break
          case 'option':
          name = this.optionTag
          for(var tag of this.optionTags){
            if(tag.name==name){
              alert("もうあるタグです。");
              return;
            }
          }
          break
          case 'reaction':
          name = this.reactionTag
          for(var tag of this.reactionTags){
            if(tag.name==name){
              alert("もうあるタグです。");
              return;
            }
          }
          break
          default:
          console.log("createTag error")
        }
        if(name.length==0) return;
        if(name.search(",")>-1||name.search("、")>-1) {
          alert("コンマはキーワードになれません。")
          return;
        }

        axios.post('api/tags',{
          name: name,
          tag_group: tag_group
        }).then((res)=>{
          const tag = res.data.tag
          switch(tag.tag_group){
            case 'friend':
            this.friendTag = ''
            this.selectedFriend = ''
            this.fetchFriendTags();
            break
            case 'option':
            this.optionTag = ''
            this.selectedOption = ''
            this.fetchOptionTags();
            break
            case 'reaction':
            this.reactionTag = ''
            this.selectedReaction = ''
            this.fetchReactionTags();
            break
            default:
            console.log("createTag error")
          }
          this.addTo = '';
        },(error)=>{
          console.log(error)
        })
      },
      clearTag(mode){
        switch(mode){
          case 'friend':
          this.friendTag = ''
          break
          case 'option':
          this.optionTag = ''
          break
          case 'reaction':
          this.reactionTag = ''
          break
          default:
          console.log("clearTag error")
        }
      },
      deleteTag(name,id){
        if(name=="ALL"){
          alert("ALLタグはデフォルトタグなので、削除できません。")
          return;
        }
        if (confirm("このタグを削除しますか。")==true){
          axios.delete('api/tags/'+id).then((res)=>{
            this.fetchFriendTags();
            this.fetchOptionTags();
            this.fetchReactionTags();
          },(error)=>{
            console.log(error)
          })
        } else {
          return;
        }
      },
      addMode(mode){
        switch(mode){
          case 'friend':
          this.selectedFriend = ''
          break;
          case 'option':
          this.selectedOption = ''
          break;
          case 'reaction':
          this.selectedReaction = ''
          break;
          default:
        }
        this.addTo = mode
      },
      editMode(mode,name){
        if(name!='ALL'){
          this.editTo = mode
        }
      },
      closeEdit(){
        this.editTo = ''
      },
      updateTag(id,name){
        axios.put('api/tags/'+id,{
          name: name
        }).then((res)=>{
          this.editTo = ''
          this.addTo = ''
          var tag = res.data.tag

          switch(tag.tag_group){
            case 'friend':
            this.fetchFriendTags();
            break;
            case 'option':
            this.fetchOptionTags();
            break;
            case 'reaction':
            this.fetchReactionTags();
            break;
          }
        },(error)=>{
          console.log(error)
        })
      },
    }
  }
</script>
<style scoped src="../components/TagManagement/tagManagement.css"/>