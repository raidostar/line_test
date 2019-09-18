<template>
  <div class="page" id="page9">
    <div class="title area">
      <h2 class="title">回答フォーム<hr/></h2>
    </div>
    <div class="col col-left">
      <div class="label">
        <i class="material-icons folder">folder_open</i>
        フォルダ
        <button class="button" @click="addToggle">
          <i class="material-icons btnMark">add_circle_outline</i>
        </button>
        <button class="button" @click="addToggle">
          <i class="material-icons btnMark">remove_circle_outline</i>
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
          <th>
            <input type="checkbox" class="checkbox" v-model="allCheck" @click="allChecker">
          </th>
          <th>フォオーム名</th>
          <th></th>
          <th>フォルダ</th>
          <th></th>
          <th></th>
          <th></th>
          <th>
            <button>
              追加
            </button>
          </th>
        </tr>
        <tr v-for="(check,index) in templateArray">
          <td class="check">
            <input type="checkbox" class="checkbox" :checked="check.bool" @click="oneChecker(index)">
          </td>
          <td class="title">
            {{check.name}}
          </td>
          <td class="action">{{check.bool}}</td>
          <td class="edit">샘플</td>
          <td class="hitcount">샘플</td>
          <td class="category-in">샘플</td>
          <td></td>
          <td></td>
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
        allCheck: false,
        templateArray: [{name: 'kakasi', bool: false}, {name: 'obito', bool: false}]
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
      },
      allChecker(){
        for(let obj of this.templateArray){
          obj.bool = !this.allCheck
        }
      },
      oneChecker(index){
        this.templateArray[index].bool = !this.templateArray[index].bool
      }
    }
  }
</script>
<style scoped src="../components/common/common1.css"/>