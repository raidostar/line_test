<template>
  <div class="page" id="page5">
    <div>
      <div class="title area">
        <h2 class="title">シナリオ配信<hr/></h2>
      </div>
      <div class="buttons">
        <button class="svc-button" @click="formToggle">サービス登録</button>
      </div>
    </div>
    <div class="service-add pannel" v-if="formShow">
      <table class="service-add-form">
        <tr>
          <th>
            <input type="text" name="service-name" placeholder="サービス名" class="sc-name">
          </th>
          <th>
            <select class="sc-type">
              <option>-------------------------サービス状態-------------------------</option>
              <option value="running">リリース中</option>
              <option value="stop">停止中</option>
            </select>
          </th>
        </tr>
        <tr>
          <th></th>
          <th>
            <select class="sc-type">
              <option>-------------------------サービスタイプ-------------------------</option>
              <option value="chatBot">CHAT_BOT</option>
              <option value="message">MESSAGE</option>
            </select>
          </th>
        </tr>
        <tr>
          <th></th>
          <th>
            <select class="sc-type">
              <option>-----------------------新規登録メッセージ-----------------------</option>
              <option>必要</option>
              <option>不要</option>
            </select>
          </th>
        </tr>
        <tr>
          <th></th>
          <th>
            <select class="sc-type">
              <option>----------------------------Richメニュー----------------------------</option>
              <option>必要</option>
              <option>不要</option>
            </select>
          </th>
        </tr>
      </table>
      </div>
    </div>
  </template>

  <script>
    import axios from 'axios'
    export default {
      name: 'servicePage',
      data: function(){
        return {
          formShow: false
        }
      },
      mounted: function(){

      },
      methods: {
        formToggle(){
          this.formShow = !this.formShow
        }
      }
    }
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
  .svc-button {
    background-color: #C0C0C0;
    color: #2C3250;
    padding: 5px 5px;
    border-radius: 10px;
    border: 1px solid #C0C0C0;
    box-shadow: 0 0 2px #666;
  }
  .svc-button:hover {
    text-decoration: none;
    background-color: #2C3250;
    color: white;
  }
  .svc-button:focus {
    outline: none;
  }
  .svc-button:active {
    -webkit-transform: translateY(2px);
    transform: translateY(2px);
    box-shadow: 0 0 1px rgba(0, 0, 0, 0.15);
  }
  .buttons {
    padding-bottom: 10px;
    padding-left: 40px;
    text-align: left;
  }
  .service-add-form {
    width: 90%;
    padding-left: 30px;
  }
  .sc-type {
    display: -webkit-box;
    width: 80%;
    margin: 10px auto;
  }
  table {
    width: 80%;
    margin-left: 30px;
    border-collapse: inherit;
  }
  table th {
    width: 50%;
    text-align: center;
    padding: 0px 10px;
  }
</style>