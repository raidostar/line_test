<template>
  <div class="page" id="page7">
    <div class="title area">
      <h2 class="title">一斉配信<hr/></h2>
    </div>
    <div class="col col-left">
      <div class="label">
        <i class="material-icons folder">folder_open</i>
        フォルダ
        <button class="button" @click="addToggle">
          <i class="material-icons btnMark">add_circle_outline</i>
        </button>
        <button class="button" @click="addToggle">
          <i class="material-icons btnMark">add_circle_outline</i>
        </button>
      </div>
      <div v-if="addShow">
        <i class="material-icons open-file">insert_drive_file</i>
        <span>
          <input type="text" v-model="newFolder" id="new-folder" class="new-folder" @keydown.enter="createFolder">
        </span>
      </div>
      <div v-for="(item,index) in folders" class="added-folder">
        <button style="width: 80%;" class="added-folderBtn" id="added-folderBtn" @click="firstGate(index)">
          <i class="material-icons open-file-added">insert_drive_file</i>
          <span>
            {{item}}
          </span>
        </button>
        <button class="delete" v-if="(selected%folders.length)==index" @click="panelToggle">
          <i class="material-icons down">keyboard_arrow_down</i>
        </button>
        <div class="edit-panel" id="edit-panel" v-if="panelShow&&(selected%folders.length)==index">
          <button class="folderEdit">rename</button>
          <button class="folderEdit">remove</button>
        </div>
      </div>
    </div>
    <div class="col col-right">
      <table>
        <tr>
          <th>自動応答名</th>
          <th>アクション</th>
          <th>操作</th>
          <th>ヒット数</th>
          <th>フォルダ</th>
        </tr>
      </table>
    </div>
  </div>
</template>
<script>
  import axios from 'axios'
  export default {
    name: 'sendAll',
    data: function(){
      return {
        addShow: false,
        folders: [],
        newFolder: '',
        selected: null,
        panelShow: false,
      }
    },
    mounted: function(){

    },
    methods: {
      addToggle(){
        this.addShow = !this.addShow;
        this.$nextTick(() => document.getElementById('new-folder').focus());
      },
      createFolder(){
        this.folders.push(this.newFolder);
        this.newFolder = '';
        this.addShow = !this.addShow;
      },
      firstGate(index){
        this.selected = index
        this.panelShow = false;
      },
      panelToggle(){
        this.panelShow = !this.panelShow
      }
    }
  }
</script>
<style scoped>
#page7 {
  height: 91vh;
}
.label{
  border-bottom: 2px solid grey;
  padding: 0;
  margin: 0;
  line-height: 40px;
  font-size: 20px;
  font-weight: 700;
}
.label button {
  margin-left: 30px;
}
.col {
  float: left;
  padding: 2px 5px;
  margin: 10px 2px;
  text-align: left;
}
.col-left {
  width: 25%;
}
.folder {
  font-size: 40px;
  color: #00B900;
  margin-right: 30px;
}
.open-file{
  font-size: 20px;
  color: #00B900;
  line-height: 42px;
  padding-left: 60px;
}
.title {
  float: left;
  padding-left: 10px;
  width: 100%;
  text-align: left;
}
ul li {
  height: 30px;
  line-height: 30px;
  border: unset;
  margin: 10px 0px;
}
ul li span{
  height: 30px;
  line-height: 30px;
  border: unset;
  margin: 10px 0px;
  align-items: center;
  font-size: 20px;
}
.category {
  border: inherit;
}
hr {
  margin: 5px;
  width: 95%
}
.button {
  font-size: 10px;
  background-color: #fff;
  color: #2C3250;
  padding: 0px 0px;
  border-radius: 100%;
}
.button:hover {
  text-decoration: none;
  color: white;
}
.button:focus {
  outline: none;
}
.button:active {
  -webkit-transform: translateY(2px);
  transform: translateY(2px);
  box-shadow: 0 0 1px rgba(0, 0, 0, 0.15);
}
.folder {
  padding-left: 15px;
}
.btnMark {
  font-size: 20px;
}
input[type=text] {
  width: 50%;
  padding: 0px 0px;
  margin: 0px 40px;
}
.open-file-added {
  font-size: 20px;
  line-height: 39px;
  padding-left: 40px;
}
.added-folder {
  height: 40px;
  line-height: 40px;
  text-align: center;
}
.added-folder span {
  font-size: 20px;
}
.added-folderBtn {
  background-color: white;
  color: black;
  width: 100%;
}
.added-folderBtn:hover {
  cursor: pointer;
}
.added-folderBtn span{
  padding-right: 70px;

}
.added-folderBtn button{
  line-height: 30px;
}
.added-folderBtn:focus {
  outline: none;
  background-color: #CCFFFF;
}
.delete {
  color: #333;
  background-color: #fff;
  border-color: #ccc;
  padding: 1px 5px;
  font-size: 20px;
  line-height: 40px;
  border-radius: 3px;
  height: 20px;
}
.down{
  font-size: 15px;
}
.edit-panel {
  position: relative;
  background-color: #17a2b8;
  padding: 0px;
  left: 230px;
  top: 0px;
  width: 130px;
  height: 80px;
  z-index: 100;
}
.folderEdit {
  width: 100%;
  height: 50%;
  line-height: 50%;
  padding: 0px;
  margin: 0px;
}
.col-right {
  float: right;
  width: 70%;

}
</style>
