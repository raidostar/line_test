<template>
  <div class="page" id="page2">

    <table class="fList">
      <tr>
        <th><input type="checkbox" name="allUser" value="1" id="check-all"></th>
        <th>状況</th>
        <th>名前</th>
        <th>シナリオ</th>
        <th>受信メッセージ</th>
        <th>タグ・友だち情報</th>
      </tr>
      <tr>
        <td><input type="checkbox" name="allUser" value="1" id="check-all"/></td>
        <td><span></span></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
      </tr>
    </table>
  </div>
</template>

<script>
  import axios from 'axios'
  export default {
    name: 'friendslist',

  }
</script>

<style scoped>
[type="checkbox"]:not(:checked), [type="checkbox"]:checked {
    position: absolute;
    opacity: 1;
    pointer-events: none;
}
.fList {
  width: 98%;
  padding: 15px;
  margin: 15px;
  float: inherit;
}
.fList th{
  padding: 5px;
  margin: 0;
  height: 10px;
  width: auto;
  background-color: #E0E0F8;
  border-top: 2px solid grey;
}
</style>