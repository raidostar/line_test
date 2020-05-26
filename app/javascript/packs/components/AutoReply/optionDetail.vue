<template>
  <div class="optionDetail">
    <i class="material-icons open-file">flash_on</i>
    <div style="height: 92px">
      <p class="settingMenu">条件名</p>
      <input type="text" v-model="optName" id="new-folder" class="new-folder">
    </div>
    <div style="width: 49.5%; float: left; margin-bottom: 2em;">
      <!-- 조건어 설정 -->
      <div class="option-setting" v-if="autoReply" style="height: 10.7em;">
        <div>
          <p class="settingMenu">条件語設定</p>
          <input type="text" name="option[target_keyword]" v-model="keyword" class="keywordInput" @keydown.enter="createKeyword">
          <a @click="clearKeyInput" v-if="keyword">
            <i class="material-icons keyword_cancel">cancel</i>
          </a>
        </div>
        <hr style="margin-top: 15px;"/>
        <div>
          <span style="font-size: 14px;">条件語</span>
          <span v-for="(key,index) in keywords" v-model="keywords" style="margin-top: 10px;">
            <button class="keywordsTag" @click="removeKeyword(index)">{{key}}</button>
          </span>
        </div>
      </div>

      <!-- 요일 설정 -->
      <div class="option-setting" v-if="autoReply"> <!-- style="margin-top: 60px;"> -->
        <p class="settingMenu">曜日設定</p>
        <input type="radio" class="settingRadio" id="unsetDay" value="unsetDay" v-model="setDay" @click="clearDay">
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

      <!-- 횟수 설정 -->
      <div class="option-setting">
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
      <!-- 리마인드 설정 -->
      <div class="option-setting" v-if="remindReply" style="margin-top: 58px;">
        <p class="settingMenu">リマインド条件設定</p>
        最後のメッセージから
        <input type="number" name="option[target_keyword]" v-model="days" class="daysInput">
        日後
      </div>
    </div>

    <div style="width: 49.5%; float: left; margin-bottom: 2em;">
      <!-- 송신대상 설정 -->
      <div class="option-setting" style="height: 10.7em;">
        <p class="settingMenu">送信対象設定</p>
        <input type="radio" class="settingRadio" id="unsetReceiver" value="unsetTarget" v-model="setTarget" @click="clearTargetTag">
        <label class="setting" >全ユーザー</label>
        <input type="radio" class="settingRadio" @click="callTarget" id="setReceiver" value="setTarget" v-model="setTarget">
        <label class="setting" >送信対象選択</label>
        <hr :style="targetMargin" />
        <div v-if="setTarget=='setTarget'">
          <span style="font-size: 14px;">送信対象タグ</span>
          <span v-for="(target,index) in targets" style="margin-top: 10px;">
            <button  v-model="selectedTargets" v-if="selectedTargets.includes(target)==true" class="keywordsTag" :style="targetCSS" @click="cancelTarget(target)">
              {{target}}
            </button>
            <button v-else class="keywordsTag" @click="selectTarget(index)">{{target}}</button>
          </span>
        </div>
      </div>

      <!-- 시간 설정 -->
      <div class="option-setting" v-if="autoReply">
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

      <!-- 태그 설정 -->
      <div class="option-setting">
        <div>
          <p class="settingMenu">
            タグ設定
          </p>
          <input type="text" name="option[target_keyword]" v-model="tag" class="keywordInput" @keydown.enter="createTag">
          <a @click="clearTag" v-if="tag">
            <i class="material-icons keyword_cancel">cancel</i>
          </a>
        </div>
        <hr style="margin-top: 33px;" />
        <div>
          <span style="font-size: 14px;">タグリスト</span>
          <span v-for="(tag,index) in tagtext" v-model="tagtext" style="margin-top: 10px;">
            <button class="keywordsTag" @click="removeTag(index)">{{tag}}</button>
          </span>
        </div>
      </div>


    </div>
    <hr style="margin-top: 2px; display: flow-root;" />
    <div class="option-buttons">
      <button class="allSend-button">キャンセル</button>
      <button class="allSend-button" @click="createOption">設定</button>
    </div>
  </div>
</template>
<script>
  import axios from 'axios'
  export default {
    name: 'optionDetail',
    props: {
      newOption: Object,
      targets: Array,
      autoReply: Boolean,
      remindReply: Boolean,
      createOptions: Function,
      fetchTargets: Function,
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
        setTarget: 'unsetTarget',
        startTime: '00:00',
        endTime: '00:00',
        actionCount: null,
        tags: [],
        tagtext:['ALL'],
        tag: '',
        days: 0,
        selectedTargets: [],
        targetCSS: {'background-color': '#007FFF', 'color': 'white'},
        targetMargin: {'margin-top':'28px', 'margin-bottom':'26px'},
      }
    },
    mounted: function(){

    },
    methods: {
      createKeyword(){
        if(!this.keyword) return;
        if(this.keyword.search(",")>-1||this.keyword.search("、")>-1) {
          alert("コンマは条件語になれません。")
          return;
        }
        this.keywords.push(this.keyword)
        this.keyword = '';
      },
      clearKeyInput(){
        this.keyword = '';
      },
      clearTag(){
        this.tag = '';
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
      clearTargetTag(){
        this.targetMargin['margin-bottom'] = '26px'
        this.selectedTargets = []
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
        } else if(this.keywords.length<1&&this.autoReply){
          alert("条件語を入力してください。")
          return;
        } else if(this.remindReply&&(this.days==0)){
          alert("リマインドは１日後からできます。")
          return;
        }

        var targetTime = [this.startTime,this.endTime]
        if(this.keywords.toString().length!=0){
          this.newOption.target_keyword = this.keywords.toString()
        }
        this.newOption.action_count = this.actionCount
        this.newOption.target_day = this.targetDay.toString()
        this.newOption.target_time = targetTime.toString()

        if(this.remindReply){
          this.newOption.remind_after = this.days
        }
        this.newOption.name = this.optName
        this.newOption.tag = this.tagtext.toString()
        this.newOption.target_friend = this.selectedTargets.toString()
        this.createOptions();
      },
      createTag(){
        if(!this.tag) return;
        if(this.tag.search(",")>-1||this.tag.search("、")>-1) {
          alert("コンマはキーワードになれません。")
          return;
        }
        for(var t of this.tagtext){
          if(t==this.tag){
            alert("もうあるタグです。");
            return;
          }
        }
        this.tagtext.push(this.tag)
        this.tag = '';
      },
      removeTag(index){
        if(this.tagtext[index]=='ALL'){
          alert('ALLタグはデフォルトタグです。');
          return;
        }
        var start = index;
        if (index != this.tagtext.length-1){
          for(var i=start;i<this.tagtext.length-1;i++){
            this.tagtext[i] = this.tagtext[i+1]
          }
        }
        this.tagtext.pop();
      },
      selectTarget(index){
        this.selectedTargets.push(this.targets[index])
      },
      cancelTarget(target){
        for(var i=0;i<this.selectedTargets.length;i++){
          if(this.selectedTargets[i]==target){
            var start = i
            for(var i=start;i<this.selectedTargets.length-1;i++){
              this.selectedTargets[i] = this.selectedTargets[i+1]
            }
            break;
          }
        }
        this.selectedTargets.pop();
      },
      callTarget(){
        this.targetMargin['margin-bottom'] = '0px'
        this.fetchTargets();
      }
    }
  }
</script>
<style scoped src="./autoReply.css"/>
<style scoped>
.optionDetail{
  margin-bottom: 32px;
}
.open-file {
  margin-top: 30px;
}
</style>