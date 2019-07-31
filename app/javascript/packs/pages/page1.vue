<template>
  <div class="page">
    <div class="col-left">
      <h2 class="title">{{ title }}<hr/></h2>

      <table class="status">
        <tr>
          <th>有効友だち数</th>
          <th>ブロック/友だち解除数</th>
        </tr>
        <tr>
          <td class="text-center">
            <b>56789</b>
            <small>名</small>
          </td>
          <td class="text-center">
            <b>12345</b>
            <small>名</small>
          </td>
        </tr>
      </table>

      <table class="status message">
        <tr>
          <td class="text-center">7月のメッセージ送信数</td>
          <td class="text-center">
            <b>113170</b>
            <small>通</small>
          </td>
        </tr>
      </table>
    </div>
    <div>
      <table>

      </table>
    </div>
    <div>
      <table>

      </table>
    </div>
    <div>
      <table>

      </table>
    </div>
    <div>
      <table>

      </table>
    </div>
    <div>
      <table>

      </table>
    </div>
    <router-link to="/page2">次のページへ</router-link>
  </div>
</template>

<script>

  export default {
    name: 'global_footer',
    data: function(){
      return{
        title: "ホーム"
      }
    }
  }
</script>

<style scoped>
.title {
  float: left;
}
hr {
  margin: 10px;
}
.status {
  border: 1px grey;
  border-top: 2px solid grey;
  margin-bottom: 3em;
  background-color: #EFF2FB;
}
.status th {
  padding: 5px;
  margin: 0;
  height: 10px;
  width: 50%;
  background-color: #E0E0F8;
}
td {
  border: 2px  grey;
  width: 50%;
}
.message td {
  padding: 5px;
  margin: 0;
  height: 10px;
}
b {
  font-size: 30px;
}
.col-left {
  width: 65%;
  margin-left: 10px;
  margin-right: 10px;
}
</style>
