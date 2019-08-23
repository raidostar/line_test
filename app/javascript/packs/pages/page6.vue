<template>
  <div class="page" id="page6">
    <div>
      <div class="title area">
        <h2 class="title">一斉配信<hr/></h2>
      </div>
      <div class="buttons">
        <button class="allSend-button">詳細登録</button>
      </div>
    </div>
    <table class="sc-list">
      <tr>
        <th>編集</th>
        <th>配信先</th>
        <th>内容</th>
        <th>日時</th>
        <th>配信数</th>
        <th></th>
      </tr>
    </table>
  </div>
</template>
<script>

</script>
<style scoped>
.title {
  float: left;
  padding-left: 10px;
  width: 100%;
  text-align: left;
}
hr {
  margin: 5px;
  width: 95%
}
.allSend-button {
  background-color: #C0C0C0;
  color: #2C3250;
  padding: 5px 5px;
  border-radius: 10px;
  border: 1px solid #C0C0C0;
  box-shadow: 0 0 2px #666;
}
.allSend-button:hover {
  text-decoration: none;
  background-color: #2C3250;
  color: white;
}
.allSend-button:focus {
  outline: none;
}
.allSend-button:active {
  -webkit-transform: translateY(2px);
  transform: translateY(2px);
  box-shadow: 0 0 1px rgba(0, 0, 0, 0.15);
}
.buttons {
    padding-bottom: 10px;
    padding-left: 40px;
    text-align: left;
  }
</style>