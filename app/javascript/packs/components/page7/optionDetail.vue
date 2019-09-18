<template>
  <div class="optionDetail">
    <i class="material-icons open-file">flash_on</i>
    <div>
      <p class="settingMenu">条件名</p>
      <input type="text" v-model="optName" id="new-folder" class="new-folder">
      <!-- <button v-if="newOption.name" class="addFolderBtn" @click="createOptions">追加</button> -->
    </div>
    <!-- <div class="edit-panel" id="edit-panel">-->
      <div>
        <div>
          <p class="settingMenu" style="margin-top: 55px;">キーワード設定</p>
          <input type="text" name="option[target_keyword]" v-model="keyword" class="keywordInput" @keydown.enter="createKeyword">
          <a @click="clearKeyInput" v-if="keyword">
            <i class="material-icons keyword_cancel">cancel</i>
          </a>
        </div>
        <hr style="margin-top: 60px;" />
        <div>
          <span style="font-size: 14px;">キーワード : </span>
          <span v-for="(key,index) in keywords" v-model="keywords" style="margin-top: 10px;">
            <button class="keywordsTag" @click="removeKeyword(index)">{{key}}</button>
          </span>
        </div>
      </div>
      <div>
        <p class="settingMenu" style="margin-top: 4px;">送信対象設定</p>
        <input type="radio" class="settingRadio" id="unsetReceiver" value="unsetReceiver" v-model="setReceiver">
        <label class="setting" for="unsetCount">全ユーザー</label>
        <input type="radio" class="settingRadio" id="setReceiver" value="setReceiver" v-model="setReceiver">
        <label class="setting" for="setCount">送信対象選択</label>
      </div>
      <div style="margin-top: 60px;">
        <p class="settingMenu">曜日設定</p>
        <input type="radio" class="settingRadio" id="unsetDay" value="unsetDay" v-model="setDay"@click="clearDay">
        <label class="setting" for="two">毎日</label>
        <input type="radio" class="settingRadio" id="setDay" value="setDay" v-model="setDay">
        <label class="setting" for="one">曜日選択</label>
        <div v-if="setDay=='setDay'">
          <p class="timeSet">
            <label>
              <input class="with-gap" type="checkbox" name="option[target_day]" value="1" v-model="targetDay"/>
              <span class="optCheck">月</span>
            </label>
            <label>
              <input class="with-gap" type="checkbox" name="option[target_day]" value="2" v-model="targetDay"/>
              <span class="optCheck">火</span>
            </label>
            <label>
              <input class="with-gap" type="checkbox" name="option[target_day]" value="3" v-model="targetDay"/>
              <span class="optCheck">水</span>
            </label>
            <label>
              <input class="with-gap" type="checkbox" name="option[target_day]" value="4" v-model="targetDay"/>
              <span class="optCheck">木</span>
            </label>
            <label>
              <input class="with-gap" type="checkbox" name="option[target_day]" value="5" v-model="targetDay"/>
              <span class="optCheck">金</span>
            </label>
            <label>
              <input class="with-gap" type="checkbox" name="option[target_day]" value="6" v-model="targetDay"/>
              <span class="optCheck">土</span>
            </label>
            <label>
              <input class="with-gap" type="checkbox" name="option[target_day]" value="0" v-model="targetDay"/>
              <span class="optCheck">日</span>
            </label>
          </p>
        </div>
      </div>
      <div>
        <p class="settingMenu">時間設定</p>
        <input type="radio" class="settingRadio" id="unsetTime" value="unsetTime" v-model="setTime" @click="clearTime">
        <label class="setting" for="unsetTime">未指定</label>
        <input type="radio" class="settingRadio" id="setTime" value="setTime" v-model="setTime">
        <label class="setting" for="setTime">時間選択</label>
        <div v-if="setTime=='setTime'">
          <p class="timeSet">
            <input type="time" class="timeRange" v-model="startTime">
            ~
            <input type="time" class="timeRange" v-model="endTime">
          </p>
        </div>
      </div>
      <div>
        <p class="settingMenu">回数設定</p>
        <input type="radio" class="settingRadio" id="unsetTime" value="unsetCount" v-model="setCount">
        <label class="setting" for="unsetCount">未指定</label>
        <input type="radio" class="settingRadio" id="setTime" value="setCount" v-model="setCount">
        <label class="setting" for="setCount">回数選択</label>
        <div v-if="setCount=='setCount'">
          <p class="timeSet">
            <input class="countSet" type="number" name="option[action_count]" v-model="actionCount">回
          </p>
        </div>
      </div>
      <div>
        <button class="allSend-button">キャンセル</button>
        <button class="allSend-button" @click="createOption">設定</button>
      </div>
    </div>
</template>
<script>
  export default {
    name: 'optionDetail',
    props: {
      newOption: Object,
      createOptions: Function
    },
    data: function(){
      return {
        optName: '',
        keyword: '',
        keywords: [],
        setReceiver: 'unsetReceiver',
        targetDay: [0,1,2,3,4,5,6],
        setDay: 'unsetDay',
        setTime: 'unsetTime',
        setCount: 'unsetCount',
        startTime: '00:00',
        endTime: '00:00',
        actionCount: null,
      }
    },
    mounted: function(){

    },
    methods: {
      createKeyword(){
        if(!this.keyword) return;
        if(this.keyword.search(",")>-1||this.keyword.search("、")>-1) {
          alert("コンマはキーワードになれません。")
          return;
        }
        this.keywords.push(this.keyword)
        this.keyword = '';
      },
      clearKeyInput(){
        this.keyword = '';
      },
      removeKeyword(index){
        var start = index;
        if (index != this.keywords.length-1){
          for(var i=start;i<this.keywords.length-1;i++){
            this.keywords[i] = this.keywords[i+1]
          }
        }
        this.keywords.pop();
      },
      clearDay(){
        this.targetDay = [0,1,2,3,4,5,6]
      },
      clearTime(){
        this.startTime = '00:00'
        this.endTime = '00:00'
      },
      createOption(){
        if(!this.optName){
          alert("条件名を入力してください。")
          return;
        } else if(this.keywords.length<1){
          alert("キーワードを入力してください。")
          return;
        }
        var targetTime = [this.startTime,this.endTime]
        this.newOption.name = this.optName
        this.newOption.target_keyword = this.keywords.toString()
        this.newOption.action_count = this.actionCount
        this.newOption.target_day = this.targetDay.toString()
        this.newOption.target_time = targetTime.toString()
        this.createOptions();
      }
    }
  }
</script>
<style scoped src="./page7.css"/>
<style scoped>
  .optionDetail{
    margin-bottom: 32px;
  }
  .open-file {
    margin-top: 30px;
  }
</style>