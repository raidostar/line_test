<template>
  <div class="page" id="page11">
    <div class="title area">
      <h2 class="title">友達追加メッセージ設定<hr/></h2>
    </div>
    <div class="col col-left">
      <table class="table">
        <tr>
          <th colspan="2">新規友達</th>
        </tr>
        <tr>
          <td class="center">シナリオ</td>
          <td>
            <select class="type">
              <option>購読しない</option>
              <option>購読中</option>
            </select>
          </td>
        </tr>
        <tr>
          <td class="center">タグ</td>
          <td>
            <div class="divBtn" @click="leftDivClick">
              button
              <i class="material-icons updownMark" v-if="leftPanelShow">keyboard_arrow_up</i>
              <i class="material-icons updownMark" v-if="!leftPanelShow">keyboard_arrow_down</i>
            </div>
          </td>
        </tr>
        <tr>
          <td colspan="2">
            <button class="setting">詳細設定</button>
            <button class="setting">設定解除</button>
          </td>
        </tr>
      </table>
      <div class="edit-panel" id="left-panel" v-if="leftPanelShow">
        <div class="inner-panel inner-left">
          <div class="tag" v-for="(item,index) in category" @click="showUnderTag(index)">
            {{item}}
          </div>
        </div>
        <div class="inner-panel inner-right">
          <div class="tag" v-for="(item,index) in underTag" @click="showIndex(index)">
            {{item}}
          </div>
        </div>
      </div>
    </div>
    <div class="col col-right">
      <table class="table">
        <tr>
          <th colspan="2">既存友達</th>
        </tr>
        <tr>
          <td class="center">シナリオ</td>
          <td>
            <select class="type">
              <option>購読しない</option>
              <option>購読中</option>
            </select>
          </td>
        </tr>
        <tr>
          <td class="center">タグ</td>
          <td>
            <div class="divBtn" @click="rightDivClick">
              button
              <i class="material-icons updownMark" v-if="rightPanelShow">keyboard_arrow_up</i>
              <i class="material-icons updownMark" v-if="!rightPanelShow">keyboard_arrow_down</i>
            </div>
          </td>
        </tr>
        <tr>
          <td colspan="2">
            <button class="setting">詳細設定</button>
            <button class="setting">設定解除</button>
          </td>
        </tr>
      </table>
      <div class="edit-panel" id="right-panel" v-if="rightPanelShow">
        <div class="inner-panel inner-left">
          <div class="tag" v-for="(item,index) in category" @click="showUnderTag(index)">
            {{item}}
          </div>
        </div>
        <div class="inner-panel inner-right">
          <div class="tag" v-for="(item,index) in underTag" @click="showIndex(index)">
            {{item}}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
  import axios from 'axios'
  export default {
    name: 'followEvent',
    data: function(){
      return {
        leftPanelShow: false,
        rightPanelShow: false,
        category: [
        "cate1","cate2","cate3",
        ],
        underTag: [],
        allTag: [
          ["aaaa","aaaa","aaaa",],
          ["bbbb","bbbb","bbbb",],
          ["cccc","cccc","cccc",]
        ]
      }
    },
    mounted: function(){

    },
    methods: {
      leftDivClick(){
        this.leftPanelShow = !this.leftPanelShow;
        this.rightPanelShow = false;
      },
      rightDivClick(){
        this.rightPanelShow = !this.rightPanelShow;
        this.leftPanelShow = false;
      },
      showUnderTag(index){
        this.underTag = null;
        this.underTag = this.allTag[index]
      },
      showIndex(index){
        alert(index);
      }
    }
  }
</script>
<style scoped>
.page {
  height: 91vh;
}
.title {
  float: left;
  padding-left: 10px;
  width: 100%;
  text-align: left;
}
.col {
  width: 50%;
}
.col-left {
  float: left;
  padding-left: 3%;
}
.col-right {
  float: right;
  padding-right: 3%;
}
.table th {
  padding: 5px;
  margin: 0;
  height: 10px;
  width: auto;
  background-color: #E0E0F8;
}
.type {
  display: -webkit-box;
  width: 80%;
  margin: 10px auto;
}
.center{
  text-align: center;
  line-height: 63px;
}
.edit-panel {
  position: absolute;
  background-color: white;
  padding: 0px;
  margin: 0px;
  top: 184px;
  width: 600px;
  height: 280px;
  z-index: 100;
  border-radius: 5px;
}
#left-panel {
  left: 20px;
}
#right-panel {
  left: -10px;
}
.inner-panel {
  height: 100%;
  background-color: white;
  border-radius: 5px;
}
.inner-left {
  width: 30%;
  float: left;
  border:1px solid;
}
.inner-right {
  width: 70%;
  float: right;
  border:1px solid;
}
.divBtn {
  width: 81%;
  height: 40px;
  border: 1px solid;
  border-radius: 3px;
  line-height: 40px;
  padding-left: 10px;
  margin-left: 30px;
  margin-top: 10px;
}
.divBtn:hover {
  cursor: pointer;
}
.updownMark {
  float: right;
  font-size: 30px;
  color: black;
  font-weight: 300;
  line-height: 40px;
}
.setting {
  width: 45%;
}
.tag {
  width: 100%;
  height: 40px;
  line-height: 40px;

}
.tag:hover {
  cursor: pointer;
  background-color: #E0E0F8;
}
</style>