<template>
  <div class="page" id="page7" @scroll="mouseScroll" ref="result">
    <div class="inner-area" style="width: 200%">
      <div v-show="!formShow" :style="flexableHeight">
        <div class="col col-left">
          <div class="label">
            <i class="material-icons folder">folder_open</i>
            条件タグ
          </div>
          <div :style="flexableMargin">
            <div v-for="(tag,index) in tags" class="added-folder">
              <span v-if="tag.id==selectedTagId">
                <button
                class="added-folderBtn"
                id="added-folderBtn"
                @click="clickTag(index,tag.id)"
                :style="selectedCSS"
                >
                <i style="float: left;" class="material-icons open-file-added">insert_drive_file</i>
                <span>
                  {{tag.name}}
                </span>
              </button>
            </span>
            <span v-else>
              <button class="added-folderBtn" id="added-folderBtn" @click="clickTag(index,tag.id)">
                <i style="float: left;" class="material-icons open-file-added">insert_drive_file</i>
                <span>
                  {{tag.name}}
                </span>
              </button>
            </span>
          </div>
        </div>
      </div>

      <div class="col col-left">
        <div class="label">
          <i class="material-icons folder">event_note</i>
          条件リスト
          <button class="button" @click="addToggle">
            <i class="material-icons btnMark">add_circle_outline</i>
          </button>
          <button class="button" v-if="deleteShow" @click="deleteOption" rel="nofollow" data-method="delete">
            <i class="material-icons btnMark">remove_circle_outline</i>
          </button>
        </div>
        <transition name="slideUpDown">
          <div v-if="addShow">
            <option-detail
            :newOption="newOption"
            :createOptions="createOptions"
            :autoReply="autoReply"
            :remindReply="remindReply"
            :fetchTargets="fetchTargets"
            :targets="targets"
            :targetMargin="targetMargin"
            />
          </div>
        </transition>
        <div class="options-panel">
          <div v-for="(item,index) in options" class="added-folder">
            <span v-if="selectedOption==item">
              <button class="added-folderBtn" id="added-folderBtn" @click="clickOption(index,item.id)" :style="selectedCSS">
                <i style="float: left;" class="material-icons open-file-added">flash_on</i>
                <span>
                  {{item.name}}
                </span>
              </button>
              <button class="detail-panel" @click="panelToggle">
                <i class="material-icons down" v-if="!panelShow">keyboard_arrow_down</i>
                <i class="material-icons down" v-if="panelShow">keyboard_arrow_up</i>
              </button>
              <transition name="slideUpDown">
                <div class="edit-panel" id="edit-panel" v-if="panelShow">
                  <div style="width: 49.5%; float: left; margin-bottom: 2em;">
                    <!-- 조건어 설정 -->
                    <div class="option-setting">
                      <div>
                        <p class="settingMenu">条件語設定</p>
                        <input type="text" name="option[target_keyword]" v-model="keyword" class="keywordInput" @keydown.enter="createKeyword">
                        <a @click="clearKeyInput" v-if="keyword">
                          <i class="material-icons keyword_cancel">cancel</i>
                        </a>
                      </div>
                      <hr style="margin-top: 60px;" />
                      <div>
                        <span style="font-size: 14px;">条件語(クリックすると削除)</span>
                        <span v-for="(key,index) in keywords" v-model="keywords" style="margin-top: 10px;">
                          <button class="keywordsTag" @click="removeKeyword(index)">{{key}}</button>
                        </span>
                      </div>
                    </div>
                    <!-- 요일 설정 -->
                    <div class="option-setting">
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
                  </div>
                  <div style="width: 49.5%; float: right; margin-bottom: 2em;">
                    <!-- 송신대상 설정 -->
                    <div class="option-setting">
                      <p class="settingMenu" style="margin-top: 4px;">送信対象設定</p>
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
                    <div class="option-setting">
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
                    <!-- 옵션태그 설정 -->
                    <div class="option-setting">
                      <div>
                        <p class="settingMenu">タグ設定</p>
                        <input type="text" name="option[target_keyword]" v-model="tag" class="keywordInput" @keydown.enter="createTag">
                        <a @click="clearTag" v-if="tag">
                          <i class="material-icons keyword_cancel">cancel</i>
                        </a>
                      </div>
                      <hr style="margin-top: 60px;" />
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
                    <button class="allSend-button" @click="updateOption">設定</button>
                  </div>
                </div>
              </transition>
            </span>
            <span v-else>
              <button class="added-folderBtn" id="added-folderBtn" @click="clickOption(index,item.id)">
                <i style="float: left;" class="material-icons open-file-added">flash_on</i>
                <span>
                  {{item.name}}
                </span>
              </button>
            </span>
          </div>
        </div>
      </div>
      <!---->
      <div class="col col-left">
        <div class="label">
          <i class="material-icons folder">tap_and_play</i>
          アクションリスト
        </div>
        <div class="right-panel" style="border: none;" v-show="!reactionListShow">
          <table class="actionList">
            <thead>
              <tr>
                <th>
                  <input type="checkbox" class="checkbox" v-model="reactionAllCheck" @click="reactionAllChecker">
                </th>
                <th>アクション名</th>
                <th>アクション内容</th>
                <th>操作</th>
                <th>ヒット数</th>
                <th>タイプ</th>
                <th>連動</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(reaction,index) in reactions" v-model="reactions" ref="reaction">
                <td class="check">
                  <input type="checkbox" class="checkbox" :checked="reaction.bool" @click="reactionChecker(index)">
                </td>
                <td>
                  {{reaction.name}}
                </td>
                <td v-if="reaction.reaction_type=='stamp'">
                  <a @click="editAction(reaction.id,index,'read')">
                    <img class="stampBtnImg" :src="getImgUrl(reaction.contents)"/>
                  </a>
                </td>
                <td v-else-if="reaction.reaction_type=='image'">
                  <a @click="editAction(reaction.id,index,'read')">
                    <img class="imageResult" :src="reaction.image.url"/>
                  </a>
                </td>
                <td v-else-if="reaction.reaction_type=='carousel'">
                  <a @click="editAction(reaction.id,index,'read')">
                    <span>キャルセル</span>
                  </a>
                </td>
                <td v-else>
                  <a v-if="reaction.contents.search('<img src=')>=0"
                    @click="editAction(reaction.id,index,'read')"
                    v-html="reaction.contents.substr(0,100)"
                    >
                  </a>
                  <a v-else @click="editAction(reaction.id,index,'read')">
                    <span v-if="reaction.contents.length>19" v-html="reaction.contents.substr(0,20)+'...'"></span>
                    <span v-else v-html="reaction.contents.substr(0,20)"></span>
                  </a>
                </td>
                <td>
                  <button class="edit-button" @click="editAction(reaction.id,index,'edit')">
                    編集
                  </button>
                </td>
                <td class="hitcount" style="text-align: center;">{{reaction.target_number}}</td>
                <td style="text-align: center;">{{reaction.reaction_type}}</td>
                <td>
                  <button class="edit-button" v-show="reaction.bool" @click="reactionCancel(reaction.id)">
                    解除
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div class="col col-left">
        <div style="line-height: 2em;">
          <input v-if="editMode!='read'" type="text" ref="reactionName" v-model="reactionName" placeholder="アクション名を入力してください。" style="width: 50%;"/>
          <div class="read-title" v-else>
            <span class="reaction-title" v-html="reactionName"></span>
          </div>
          <span class="mode-show" v-model="editMode">
            MODE
            <button class="mode-button" @click="changeEditMode('new')" v-if="editMode=='read'">プレビュー</button>
            <button class="mode-button" @click="changeEditMode('read')" v-if="editMode=='new'">新規作成</button>
            <button class="mode-button" @click="changeEditMode('new')" v-if="editMode=='edit'">修正中</button>
          </span>
        </div>
        <div class="right-panel" >
          <!-- side buttons -->
          <div class="contentBtns">
            <button class="stampBtn" @click="toggleStamp" title="スタンプ追加">
              <i class="material-icons stamp">child_care</i>
            </button>
            <button class="stampBtn" @click="toggleEmoji" title="emoji追加">
              <i class="material-icons stamp">sentiment_satisfied_alt</i>
            </button>
            <label class="stampBtn" title="イメージ追加">
              <i class="material-icons stamp">gif</i>
              <input type="file" @change="onFileChange" class="imageBtn" ref="fileInput" accept="img/*">
            </label>
            <button class="stampBtn" @click="toggleCarousel" title="キャルセル追加">
              <i class="material-icons stamp">border_color</i>
            </button>
            <button class="stampBtn" @click="toggleMap" title="マップ追加">
              <i class="material-icons stamp">location_on</i>
            </button>
          </div>

          <div class="chattingArea">
            <div v-show="uploadedImage"  class="attachedImgPanel">
              <a class="closeStamp" @click="closeImage">X</a>
              <p>[イメージ]</p>
              <img class="attachedImg" :src="uploadedImage">
            </div>

            <div id="chattingContents" class="chattingContents" contenteditable="true" :style="flexablePadding" @input="sync" v-html="innerContent" v-model="innerContent" ref="chatting" autofocus="autofocus"></div>
            <input type="text" v-model="contents" style="display: none;">

            <!--tag input area-->
            <div class="tags">
              <div class="tags-top" style="width: 48%; float: left;">
                <span style="margin-left: 10px; float: left;">タグ</span>
                <input type="text" name="option[target_keyword]" v-model="tag" class="tagInput" @keydown.enter="createTag">
                <a @click="clearTag" v-if="tag" style="line-height: 0px; float: left;">
                  <i class="material-icons keyword_cancel">cancel</i>
                </a>
              </div>
              <div class="tags-bottom" style="width: 48%; float: left; overflow-x: scroll; height: 100%;">
                <div style="width: max-content;">
                  <span style="font-size: 14px;">タグリスト</span>
                  <span v-for="(tag,index) in tagtext" v-model="tagtext" style="margin-top: 10px; line-height: 0px;">
                    <button class="tagList" @click="removeTag(index)">{{tag}}</button>
                  </span>
                </div>
              </div>
            </div>

            <!-- stamp list bottom -->
            <div class="sticker-panel" v-show="stampShow">
              <button class="stampBtn" v-for="num in stampNums" @click="selectStamp(num)">
                <img class="stampBtnImg" :src="getImgUrl(num)"/>
              </button>
            </div>

            <!-- emoji list bottom -->
            <div class="sticker-panel" v-show="emojiShow">
              <button class="emojiBtn stampBtn" v-for="emoji in emojis" @click="addEmoji(emoji.img_url)">
                <img class="stampBtnImg" :src="emoji.img_url">
              </button>
            </div>
          </div>

          <!-- stamp image area -->
          <div class="stampArea" v-show="stampAreaShow">
            <a class="closeStamp" @click="closeStamp">X</a>
            <p>[スタンプ]</p>
            <img class="selectStamp" :src="selectStampUrl">
          </div>

          <!-- carousel area -->
          <transition name="showInOut">
            <div class="carouselArea" v-show="carouselAreaShow" :style="carouselAreaWidth">
              <!-- left-side menu -->
              <div class="control-box">
                <div class="bubble-setting setting-gravity" v-if="selectedComponent!='hero'&&(selectedComponent!='footer'||footer_type!='button')">
                  <span>垂直配置</span>
                  <select class="css-option" v-model="gravity" @change="syncGravity">
                    <option value="top">上</option>
                    <option value="center">中</option>
                    <option value="bottom">下</option>
                  </select>
                </div>
                <div class="bubble-setting setting-align" v-if="selectedComponent!='hero'&&(selectedComponent!='footer'||footer_type!='button')">
                  <span>水平配置</span>
                  <select class="css-option" v-model="align" @change="syncAlign">
                    <option value="start">左</option>
                    <option value="center">中</option>
                    <option value="end">右</option>
                  </select>
                </div>
                <div class="bubble-setting setting-size" v-if="selectedComponent!='footer'||footer_type!='button'">
                  <span v-if="selectedComponent!='hero'">文字サイズ</span>
                  <span v-else>イメージ幅</span>
                  <select class="css-option" v-model="size" @change="syncSize">
                    <option value="xxs">1</option>
                    <option value="xs">2</option>
                    <option value="sm">3</option>
                    <option value="md">4</option>
                    <option value="lg">5</option>
                    <option value="xl">6</option>
                    <option value="xxl">7</option>
                    <option value="3xl">8</option>
                    <option value="4xl">9</option>
                    <option value="5xl">10</option>
                    <option v-if="selectedComponent=='hero'" value="full">full</option>
                  </select>
                </div>
                <div class="bubble-setting setting-bold" v-if="selectedComponent!='hero'&&(selectedComponent!='footer'||footer_type!='button')">
                  <span>濃さ</span>
                  <select class="css-option" v-model="bold" @change="syncBold">
                    <option value="regular">普通</option>
                    <option value="bold">濃い</option>
                  </select>
                </div>
                <div class="bubble-setting color setting-color" v-if="selectedComponent=='hero'">
                  <p style="margin-bottom: 0">横:縦</p>
                  <input class="color-text" type="number" v-model="heroWidth" style="width: 4em;color: white;text-align: center;" @change="syncRatio">
                  :
                  <input class="color-text" type="number" v-model="heroHeight" style="width: 4em;color: white;text-align: center;" @change="syncRatio">
                </div>
                <div class="bubble-setting color setting-color" style="height: 5.8em;" v-if="selectedComponent=='footer'&&footer_type=='button'">
                  <p style="margin-bottom: 0">文字色</p>
                  <select class="css-option" v-model="color" @change="syncColor" style="margin-bottom: .3em;">
                    <option value="#ffffff">白</option>
                    <option value="#111111">黒</option>
                  </select>
                  <div class="color-sample" :style="fontColor" v-model="color"></div>
                </div>
                <div v-else style="height: 5.2em;">
                  <div class="bubble-setting color setting-color" v-if="selectedComponent!='hero'">
                    <p style="margin-bottom: 0">文字色</p>
                    <input class="color-text color-input" type="text" v-model="color" @keyup="syncColor" style="height: 2em; color: white;">
                    <div class="color-sample" :style="fontColor" v-model="color"></div>
                  </div>
                </div>
                <button class="colorExchange" @click="exchangeColor" v-if="selectedComponent!='hero'&&(selectedComponent!='footer'||footer_type!='button')">↑ 色逆に ↓</button>
                <div class="bubble-setting color setting-background" style="height: 6em;">
                  <p style="margin-bottom: 0">背景色</p>
                  <input class="color-text color-input" type="text" v-model="background" @keyup="syncBackground" style="height: 2em; color: white;">
                  <div class="color-sample" :style="backgroundColor" v-model="backgroundColor"></div>
                </div>
                <div class="bubble-setting setting-footerType" v-if="selectedComponent=='footer'">
                  <span>フッタータイプ</span>
                  <select class="css-option" v-model="footer_type" @change="syncFooterType">
                    <option value="text">テキスト</option>
                    <option value="button">ボタン</option>
                  </select>
                </div>
                <div class="bubble-setting setting-footerType" v-if="selectedComponent=='footer'&&footer_type=='button'">
                  <span>ボタンタイプ</span>
                  <select class="css-option" v-model="footer_button" @change="syncFooterButton">
                    <option value="uri">リンク</option>
                    <option value="message">メッセージ</option>
                  </select>
                </div>
                <div class="bubble-setting color setting-url" v-if="selectedComponent=='footer'&&footer_type=='button'&&footer_button=='uri'">
                  <p style="margin-bottom: 0">リンクURL</p>
                  <input class="uri-text" type="text" v-model="footer_uri" @keyup="syncFooterUri">
                </div>
                <div class="bubble-setting color setting-message" v-if="selectedComponent=='footer'&&footer_type=='button'&&footer_button=='message'">
                  <p style="margin-bottom: 0">配信メッセージ</p>
                  <input class="uri-text" type="text" v-model="footer_message" @keyup="syncFooterMessage">
                </div>
                <div class="design-buttons">
                  <button class="copyChu copy" @click="copyCSS(selectedBubble)">デザインコピー</button>
                  <button class="copyChu paste" v-if="copiedType" @click="pasteCSS">デザイン適用</button>
                </div>
                <label class="image-change" title="イメージ変更" v-if="selectedComponent=='hero'&&heros[selectedBubble]!=null">
                  イメージ変更
                  <input type="file" @change="onImageChange" class="imageBtn" ref="hero" accept="img/*">
                </label>
                <button class="image-remove" v-if="selectedComponent=='hero'&&heros[selectedBubble]!=null" @click="removeImage">
                  イメージ削除
                </button>
              </div>
              <!-- main bubble -->
              <!-- main bubble -->

              <!-- main bubble -->
              <!-- main bubble -->
              <!-- main bubble -->
              <!-- main bubble -->
              <!-- main bubble -->

              <!-- main bubble -->
              <div class="carousel-box" :style="carouselBoxWidth">
                <div class="bubble-box" ref="carousel" v-model="bubble_array">
                  <div class="bubble" v-for="(bubble,index) in bubble_array" :key="bubble.id">
                    <!-- header -->
                    <div class="blocks header-block" v-if="selectedComponent=='header'&&selectedBubble==index" style="border: 5px solid red" :style="headerBackground[index]">
                      <div class="component header-text" ref="header" contenteditable="true" v-html="header[index]" @input="syncHeader(index)" :style="headerCSS[index]">
                      </div>
                    </div>
                    <div class="blocks header-block" @click="selectComponent('header', index)" v-else
                    :style="headerBackground[index]">
                    <div class="component header-text" ref="header" contenteditable="true" v-html="header[index]" @input="syncHeader(index)" :style="headerCSS[index]">
                    </div>
                  </div>
                  <input type="text" v-model="bubble.header" style="display: none;">

                  <!-- hero(image) -->
                  <div class="blocks hero-block" v-if="selectedComponent=='hero'&&selectedBubble==index" style="border: 5px solid red">
                    <label class="add-label" title="イメージ追加">
                      <i class="material-icons add-bubble-image" v-if="!heros[index]">add</i>
                      <input type="file" @change="onImageChange" class="imageBtn" ref="hero" accept="img/*">
                    </label>
                    <div class="carousel-img-area" v-show="bubble.hero" :style="heroCSS[index]">
                      <img class="carousel-img" :src="bubble.hero" :style="imageCSS[index]">
                    </div>
                  </div>
                  <div class="blocks hero-block" @click="selectComponent('hero', index)" v-else>
                    <label class="add-label" title="イメージ追加">
                      <i class="material-icons add-bubble-image" v-if="!heros[index]">add</i>
                      <input type="file" @change="onImageChange" class="imageBtn" ref="hero" accept="img/*">
                    </label>
                    <div class="carousel-img-area" v-show="bubble.hero" :style="heroCSS[index]">
                      <img class="carousel-img" :src="bubble.hero" :style="imageCSS[index]">
                    </div>
                  </div>

                  <!-- body -->
                  <div class="blocks body-block" v-if="selectedComponent=='body'&&selectedBubble==index" style="border: 5px solid red" :style="bodyBackground[index]">
                    <div class="component body-text" ref="body" contenteditable="true" v-html="body[index]" @input="syncBody(index)" :style="bodyCSS[index]">
                    </div>
                  </div>
                  <div class="blocks body-block" @click="selectComponent('body', index)" v-else :style="bodyBackground[index]">
                    <div class="component body-text" ref="body" contenteditable="true" v-html="body[index]" @input="syncBody(index)" :style="bodyCSS[index]">
                    </div>
                  </div>
                  <input type="text" v-model="bubble.body" style="display: none;">

                  <!-- footer -->
                  <div class="blocks footer-block" v-if="selectedComponent=='footer'&&selectedBubble==index" style="border: 5px solid red" :style="footerBackground[index]">
                    <div class="component footer-text" ref="footer" contenteditable="true" v-html="footer[index]" @input="syncFooter(index)" :style="footerCSS[index]">
                    </div>
                  </div>
                  <div class="blocks footer-block" @click="selectComponent('footer', index)" v-else :style="footerBackground[index]">
                    <div class="component footer-text" ref="footer" contenteditable="true" v-html="footer[index]" @input="syncFooter(index)" :style="footerCSS[index]">
                    </div>
                  </div>
                  <input type="text" v-model="bubble.footer" style="display: none;">
                  <div>
                    <button v-if="index==0" class="copy-bubble" @click="copyBubble(index)" style="width: 100%;">
                      複　製
                    </button>
                    <button v-if="index>0" class="copy-bubble" @click="copyBubble(index)">
                      複　製
                    </button>
                    <button v-if="index>0" class="remove-bubble" @click="removeBubble(index)">
                      削　除
                    </button>
                  </div>
                </div>
                <div class="bubble">
                  <div class="empty-bubble">
                    <div class="add-button" @click="addBubble">
                      <i class="material-icons add-circle">
                        add_circle_outline
                      </i>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="add-button">
              <i class="material-icons open-circle" @click="stretchCarouselToggle" v-if="!carouselOpen">
                keyboard_arrow_left
              </i>
              <i class="material-icons open-circle" @click="stretchCarouselToggle" v-if="carouselOpen">
                keyboard_arrow_right
              </i>
            </div>
          </div>
        </transition>

        <!--GoogleMap-->
        <div class="googleMap" v-show="mapShow">
          <div class="placeSearch">
            <GmapAutocomplete @place_changed="setPlace"/>
          </div>
          <button style="width: 100%; height: 5%;" id="location" @click="getAddress">
            住所取得
          </button>
          <GmapMap
          :center="default_center"
          :zoom="12"
          map-type-id="terrain"
          style="width: 100%; height: 95%;"
          @center_changed="onCenterChanged"
          >
          <GmapMarker
          :position="marker_center"
          :clickable="true"
          :draggable="false"
          />
        </GmapMap>
      </div>
      <!-- submit button -->
      <button class="sendBtn okBtn" @click="createReaction" v-if="editMode=='new'">セーブ</button>
      <button class="sendBtn okBtn" @click="updateReaction" v-else-if="editMode=='edit'">修正</button>
      <button class="sendBtn cancelBtn" @click="reactionToggle"v-if="editMode!='read'" style="float: right;">再作成</button>
    </div>
  </div>

  <div>
    <button class="scroll-button scroll-right" @click="goRight" v-if="endPoint<2">
      <i class="material-icons move-scroll">
        keyboard_arrow_right
      </i>
    </button>
    <button class="scroll-button scroll-left" @click="goLeft" v-if="endPoint>0">
      <i class="material-icons move-scroll">
        keyboard_arrow_left
      </i>
    </button>
  </div>
</div>
</div>
</div>
</template>
<script>
  import axios from 'axios'
  import {gmapApi} from 'vue2-google-maps'
  import optionDetail from '../components/page7/optionDetail.vue'
  export default {
    name: 'autoReply',
    components: {
      optionDetail
    },
    data: function(){
      return {
        formShow: false,
        addShow: false,
        newFolder: '',
        selected: null,
        selectedId: null,
        panelShow: false,
        allCheck: false,
        reactionAllCheck: false,
        reactionLeftAllCheck: false,
        deleteShow: false,
        options: [],
        newOption: {
          name: '',
          match_reaction: '',
          action_count: '',
          tag: '',
          target_keyword: '',
          target_day: '',
          target_time: '',
          target_friend: '',
          option_type: 'autoReply'
        },
        flexableMargin: {'margin-top': '0px'},
        flexableHeight: {'height': '0vh'},
        contents: '',
        innerContent:'',
        reactions: [],
        stampNums: [],
        sampleAdd: '',
        stampShow: false,
        stampAreaShow: false,
        carouselAreaShow: false,
        selectStampUrl: null,
        flexablePadding: {},
        parPage: 5,
        currentPage: 1,
        showDetail: false,
        fullContents: '',
        emojis:[],
        emojiShow: false,
        image: null,
        uploadedImage: '',
        imageFile: null,
        mapShow: false,
        default_center: {lat: 35.681236,lng: 139.767125},
        marker_center: {lat: 35.681236,lng: 139.767125},
        text_address: '',
        google: gmapApi,
        reactionName: '',
        selectedCSS: {'background-color': '#444444', 'color': 'white'},
        mapDisplay: {'display': 'block;'},
        selected_center: null,
        selectedReaction: null,
        editMode: 'new',
        setDay: 'unsetDay',
        setTime: 'unsetTime',
        setCount: 'unsetCount',
        setTarget: 'unsetTarget',
        targetDay: [0,1,2,3,4,5,6],
        keyword: '',
        keywords: [],
        flexableMarginBottom: {'margin-bottom': '0px'},
        startTime: '00:00',
        endTime: '00:00',
        actionCount: null,
        reactionListShow: false,
        selectedOption: null,
        tags: [],
        tagtext:['ALL'],
        tag: '',
        targets: [],
        autoReply: true,
        remindReply: false,
        selectedTagId: '',
        selectedTargets: [],
        targetCSS: {'background-color': '#007FFF', 'color': 'white'},
        reactionsLeft: [],
        targetMargin: {'margin-top':'10px', 'margin-bottom': '46px'},
        baseScroll: 0,
        endPoint: 0,
        bubble_num: 0,
        bubble_array: [
        {
          header: '', hero: null, body: '', footer: '',
          header_gravity: 'top', header_align: 'start', header_size: 'md', header_bold: 'regular', header_color: '#111111',
          header_background: '#ffffff', hero_size: 'full', hero_align: 'center', hero_background: '#ffffff', hero_ratio: '1:1'
          ,body_gravity: 'top', body_align: 'start', body_size: 'md', body_bold: 'regular', body_color: '#111111',
          body_background: '#ffffff', footer_gravity: 'top', footer_align: 'center', footer_size: 'md', footer_bold: 'regular'
          ,footer_color: '#111111', footer_background: '#ffffff', footer_type: 'text', footer_button: 'uri',footer_uri: '',
          footer_message: ''
        }
        ],
        header: ['header'],
        heros: [],
        body: ['body'],
        footer: ['footer'],
        gravity: 'top',
        align: 'start',
        color: '#111111',
        background: '#ffffff',
        size: 'md',
        bold: 'regular',
        heroWidth: 1,
        heroHeight: 1,
        footer_type: 'text',
        footer_button: 'uri',
        footer_uri: '',
        footer_message: '',
        selectedBubble: null,
        selectedComponent: null,
        carouselOpen: false,
        carouselAreaWidth: {'width': '90%'},
        carouselBoxWidth: {'width': '65%'},
        bubbles: [],
        fontColor: {'background-color': '#111111'},
        backgroundColor: {'background-color': '#ffffff'},
        headerCSS: [{'margin-left':'0', 'margin-right':'auto', 'font-size':'15px', 'font-weight':'normal', 'margin-top':'0px', 'color':'#111111', 'background':'#ffffff'}],
        heroCSS: [{'text-align':'center','background-color':'#ffffff'}],
        imageCSS: [{'width':'100%', 'height': 'auto'}],
        imageSize: ['100%'],
        bodyCSS: [{'margin-left':'0', 'margin-right':'auto', 'font-size':'15px', 'font-weight':'normal', 'margin-top':'0px', 'color':'#111111', 'background':'#ffffff'}],
        footerCSS: [{'margin-left':'auto', 'margin-right':'auto', 'font-size':'15px', 'font-weight':'normal', 'margin-top':'0px', 'color':'#111111', 'background':'#ffffff'}],
        headerBackground: [{'background-color':'#ffffff'}],
        bodyBackground: [{'background-color':'#ffffff'}],
        footerBackground: [{'background-color':'#ffffff'}],
        resultHeaderCSS: [],
        resultHeroCSS: [],
        resultBodyCSS: [],
        resultFooterCSS: [],
        copied: {},
        copiedType: '',
        baseTop: 0,
      }
    },
    mounted: function(){
      this.fetchTags();
      this.fetchOptions();
      this.setStampNum();
      this.fetchEmojis();
      this.innerContent = this.contents
    },
    methods: {
      fetchTags(){
        axios.get('/api/tags?tag_group=option').then((res)=>{
          this.tags = res.data.tags
        },(error)=>{
          console.log(error)
        })
      },
      fetchTargets(){
        axios.post('/api/fetch_targets').then((res)=>{
          //console.log(res.data)
          this.targets = res.data
        },(error)=>{
          console.log(error)
        })
      },
      fetchOptions(){
        axios.post('api/options_by_tag',{option_type: 'autoReply',tag_id: this.selectedTagId}).then((res)=>{
          //console.log(res.data)
          this.options = res.data
          //this.fetchOption();
          this.fetchTargets();
        },(error)=>{
          console.log(error)
        })
      },
      emptyAll(){
        this.stampShow= false;
        this.stampAreaShow= false;
        this.emojiShow= false;
        this.default_center = {lat: 35.681236,lng: 139.767125}
        this.marker_center = {lat: 35.681236,lng: 139.767125}
        this.mapShow = false
        this.uploadedImage = ""
        this.contents = "";
        this.$refs.chatting.innerHTML = "";
        this.tag = ''
      },
      addToggle(){
        //this.selectedId = null
        this.deleteShow = false;
        this.addShow = !this.addShow;
        this.selected = null
        if(!this.addShow){
          this.flexableMargin = {'margin-top': '0px'}
          this.newOption = {
            name: '',
            match_reaction: '',
            action_count: '',
            tag: '',
            target_keyword: '',
            target_day: '',
            target_time: '',
            target_friend: '',
            option_type: 'autoReply'
          }
        }
        //this.$nextTick(() => document.getElementById('new-folder').focus());
      },
      createFolder(){
        if (!this.newFolder) return;
        axios.post('/api/tags',{name: this.newFolder, tag_group: 'option'}).then((res)=>{
          alert("新しいファイルが追加されました。")
          this.newFolder = '';
          this.addShow = !this.addShow;
          this.flexableMargin = {'margin-top': '0px'}
          this.fetchTags();
        },(error)=>{
          console.log(error);
        })
      },
      createOptions(){
        if (!this.newOption) return;
        axios.post('/api/options',{ option: this.newOption, }).then((res)=>{
          alert("新しい条件が追加されました。")
          this.newOption = {
            name: '',
            match_reaction: '',
            action_count: '',
            tag: '',
            target_keyword: '',
            target_day: '',
            target_time: '',
            target_friend: '',
            option_type: 'autoReply'
          }
          this.addShow = !this.addShow;
          this.flexableMargin = {'margin-top': '0px'}
          this.fetchOptions();
        },(error)=>{
          console.log(error)
        })
      },
      setToggles(){
        this.addShow = true;
        this.addToggle();
      },
      clickTag(index,id){
        //this.setToggles();
        this.panelShow = false;
        this.deleteShow = false;
        this.selected = index
        this.selectedTagId = id

        this.fetchOptions();
      },
      clickOption(index,id){
        //this.setToggles();
        this.deleteShow = true;
        this.panelShow = false;
        this.selected = index
        this.selectedId = id
        this.fetchOption();
        this.fetchReactions();
        this.goRight();
      },
      panelToggle(){
        this.panelShow = !this.panelShow;
      },
      allChecker(){
        for(let obj of this.options){
          obj.bool = !this.allCheck
        }
      },
      oneChecker(index){
        this.options[index].bool = !this.options[index].bool
      },
      reactionAllChecker(){
        for(let obj of this.reactions){
          obj.bool = !this.reactionAllCheck
        }
      },
      reactionLeftAllChecker(){
        for(let obj of this.reactionsLeft){
          obj.bool = !this.reactionLeftAllCheck
        }
      },
      reactionChecker(index){
        this.reactions[index].bool = !this.reactions[index].bool
      },
      reactionLeftChecker(index){
        this.reactionsLeft[index].bool = !this.reactionsLeft[index].bool
      },
      deleteTag(){
        if(this.tags[this.selected].name=='ALL'){
          alert("ALLタグはデフォルトタグです。");
          return
        }
        if (confirm("このファイルを削除しますか。")==true){
          axios.delete('/api/tags/'+this.selectedId).then((res)=>{
            this.selected = null
            this.selectedId = null
            this.panelShow = false
            this.fetchTags();
          },(error)=>{
            console.log(error)
          })
        } else {
          return;
        }
      },
      deleteOption(){
        if (confirm("この条件を削除しますか。")==true){
          var option = this.options[this.selected]
          if(option.match_reaction != null){
            var tempArr = option.match_reaction.split(",")
            for(var id of tempArr){
              if(id*1>0){
                axios.get('/api/cancel_reaction?id='+id+'&match_option='+this.selectedId)
                .then((res)=>{
                },(error)=>{
                  console.log(error)
                })
              }
            }
            this.removeOption();
          } else {
            this.removeOption();
          }
        } else {
          return;
        }
      },
      removeOption(){
        axios.delete('/api/options/'+this.selectedId).then((res)=>{
          alert("条件削除完了")
          this.selected = null
          this.selectedId = null
          this.panelShow = false
          this.reactions = []
          this.deleteShow = false;
          this.fetchOptions();
        },(error)=>{
          console.log(error)
        })
      },
      fetchReactions(){
        axios.get('api/reactions?option_id='+this.selectedId).then((res)=>{
          this.bubbles = []
          this.resultHeaderCSS = []
          this.resultBodyCSS = []
          this.resultFooterCSS = []
          this.reactions = []
          //console.log(res.data)
          for(let reaction of res.data.reactions){
            reaction.created_at = reaction.created_at.substr(0,16).replace('T',' ');
          }
          //console.log(res.data.reactions)
          this.reactions = res.data.reactions
        },(error)=>{
          console.log(error)
        })
      },
      fetchEmojis(){
        axios.get('api/emojis').then((res)=>{
          // console.log("emojis")
          // console.log(res.data.emojis)
          this.emojis = res.data.emojis
        },(error)=>{
          console.log(error)
        })
      },
      sync(e){
        this.contents = e.target.innerHTML
      },
      addEmoji(img_url){
        this.contents += '<img src="'+img_url+'" style="width: 30px;">'
        this.$refs.chatting.innerHTML = this.contents
        this.$refs.chatting.focus();
      },
      createReaction(){
        if(this.selectedOption==null){
          alert("一応条件を選択してください。")
          return;
        }
        if (this.reactions.length>=5){
          alert("最大アクション値は５つです。");
          return;
        }
        if(!this.reactionName){
          alert("アクションタイトルを作成してください。");
          return;
        }
        if(!this.stampAreaShow&&!this.contents&&!this.uploadedImage&&!this.mapShow&&!this.carouselAreaShow){//empty
          alert("一応アクションを作成してください。")
          return;
        }
        else if(this.contents&&!this.uploadedImage&&!this.stampAreaShow&&!this.mapShow&&!this.carouselAreaShow){//text only
          axios.post('/api/reactions', {
            name: this.reactionName,
            reaction_type: 'text',
            contents: this.contents,
            match_option: this.selectedId,
            tag: this.tagtext.toString(),
          })
          .then((res)=>{
            alert("アクションセーブ完了")
            this.reactionToggle();
            this.fetchOptions();
          }, (error) =>{
            console.log(error)
          })
        } else if(this.stampAreaShow&&!this.contents){//stamp only
          let arr = this.selectStampUrl.split('-')
          let target = arr[0]
          axios.post('/api/reactions',{
            name: this.reactionName,
            reaction_type: 'stamp',
            contents: target.substr(26,10),
            match_option: this.selectedId,
            tag: this.tagtext.toString(),
          })
          .then((res)=>{
            alert("アクションセーブ完了");
            this.reactionToggle();
            this.fetchOptions();
          },(error)=>{
            console.log(error)
          })
        } else if(this.stampAreaShow&&this.contents){//text+stamp
          if(this.reactions.length>=4){
            alert("最大アクション値は５つです。");
            return;
          }
          axios.post('/api/reactions',{
            name: this.reactionName,
            reaction_type: 'text',
            contents: this.contents,
            match_option: this.selectedId,
            tag: this.tagtext.toString(),
          }).then((res)=>{
            let arr = this.selectStampUrl.split('-')
            let target = arr[0]
            axios.post('/api/reactions',{
              name: this.reactionName,
              reaction_type: 'stamp',
              contents: target.substr(26,10),
              match_option: this.selectedId,
              tag: this.tagtext.toString(),
            }).then((res)=>{
              alert("アクションセーブ完了");
              this.reactionToggle();
              this.fetchOptions();
            },(error)=>{
              console.log(error)
            })
          },(error)=>{
            console.log(error)
          })
        } else if(!this.contents&&this.uploadedImage){//only image
          var data = new FormData();
          //var file = this.$refs.fileInput.files[0];

          data.append('name', this.reactionName);
          data.append('reaction_type','image');
          data.append('contents','[ NO TEXT ]');
          data.append('tag',this.tagtext.toString());
          data.append('image',this.imageFile);
          data.append('match_option', this.selectedId)
          axios.post('/api/reactions',data)
          .then((res)=>{
            alert("アクションセーブ完了");
            this.reactionToggle();
            this.fetchOptions();
          },(error)=>{
            console.log(error)
          })
        } else if(this.contents&&this.uploadedImage){//text+image
          if(this.reactions.length>=4){
            alert("最大アクションは五つです。");
            return;
          }
          axios.post('/api/reactions',{
            name: this.reactionName,
            reaction_type: 'text',
            contents: this.contents,
            match_option: this.selectedId,
            tag: this.tagtext.toString(),
          }).then((res)=>{
            var data = new FormData();
            var file = this.$refs.fileInput.files[0];
            data.append('name', this.reactionName);
            data.append('reaction_type','image');
            data.append('contents','[ IMAGE ]');
            data.append('tag',this.tagtext.toString());
            data.append('image',file);
            data.append('match_option', this.selectedId)
            axios.post('/api/reactions',data)
            .then((res)=>{
              alert("アクションセーブ完了");
              this.reactionToggle();
              this.fetchOptions();
            },(error)=>{
              console.log(error)
            })
          },(error)=>{
            console.log(error)
          })
        } else if(this.carouselAreaShow){//only carousel
          if(this.reactions.length>4){
            alert("最大メッセージは５つです。");
            return;
          }
          for(var bubble of this.bubble_array){
            let bubbleLength = bubble.header.length+bubble.body.length+bubble.footer.length
            if(bubbleLength==0){
              alert("作成されないキャルセルがあります。");
              return;
            }
            if(bubble.header_color.substr(0,1)!='#'&&bubble.header_color.length!=7){
              alert("色の形式が間違います。\n例) #00b900");
              return;
            }else if(bubble.header_background.substr(0,1)!='#'&&bubble.header_background.length!=7){
              alert("色の形式が間違います。\n例) #00b900");
              return;
            }else if(bubble.body_color.substr(0,1)!='#'&&bubble.body_color.length!=7){
              alert("色の形式が間違います。\n例) #00b900");
              return;
            }else if(bubble.body_background.substr(0,1)!='#'&&bubble.body_background.length!=7){
              alert("色の形式が間違います。\n例) #00b900");
              return;
            }else if(bubble.footer_color.substr(0,1)!='#'&&bubble.footer_color.length!=7){
              alert("色の形式が間違います。\n例) #00b900");
              return;
            }else if(bubble.footer_background.substr(0,1)!='#'&&bubble.footer_background.length!=7){
              alert("色の形式が間違います。\n例) #00b900");
              return;
            }else if(bubble.hero_background.substr(0,1)!='#'&&bubble.hero_background.length!=7){
              alert("色の形式が間違います。\n例) #00b900");
              return;
            }
            if(bubble.footer_type=='button'){
              if(bubble.footer_button=='uri'&&bubble.footer_uri.length==0){
                alert("ボタンのURLを入力してください。");
                return;
              } else if(bubble.footer_button=='message'&&bubble.footer_message.length==0){
                alert("ボタンのメッセージを入力してください。");
                return;
              }
            }
          }
          var data = new FormData();
          for(var i=0; i<this.bubble_array.length; i++){
            data.append('headers[]', this.bubble_array[i].header)
            data.append('images[]', this.heros[i])
            data.append('bodies[]', this.bubble_array[i].body)
            data.append('footers[]', this.bubble_array[i].footer)

            data.append('header_gravity[]', this.bubble_array[i].header_gravity)
            data.append('header_align[]', this.bubble_array[i].header_align)
            data.append('header_size[]', this.bubble_array[i].header_size)
            data.append('header_bold[]', this.bubble_array[i].header_bold)
            data.append('header_color[]', this.bubble_array[i].header_color)
            data.append('header_background[]', this.bubble_array[i].header_background)

            data.append('hero_size[]', this.bubble_array[i].hero_size)
            data.append('hero_align[]', this.bubble_array[i].hero_align)
            data.append('hero_background[]', this.bubble_array[i].hero_background)
            data.append('hero_ratio[]', this.bubble_array[i].hero_ratio)

            data.append('body_gravity[]', this.bubble_array[i].body_gravity)
            data.append('body_align[]', this.bubble_array[i].body_align)
            data.append('body_size[]', this.bubble_array[i].body_size)
            data.append('body_bold[]', this.bubble_array[i].body_bold)
            data.append('body_color[]', this.bubble_array[i].body_color)
            data.append('body_background[]', this.bubble_array[i].body_background)

            data.append('footer_gravity[]', this.bubble_array[i].footer_gravity)
            data.append('footer_align[]', this.bubble_array[i].footer_align)
            data.append('footer_size[]', this.bubble_array[i].footer_size)
            data.append('footer_bold[]', this.bubble_array[i].footer_bold)
            data.append('footer_color[]', this.bubble_array[i].footer_color)
            data.append('footer_background[]', this.bubble_array[i].footer_background)
            data.append('footer_type[]', this.bubble_array[i].footer_type)
            data.append('footer_button[]', this.bubble_array[i].footer_button)
            data.append('footer_uri[]', this.bubble_array[i].footer_uri)
            data.append('footer_message[]', this.bubble_array[i].footer_message)
          }
          data.append('bubble_num',this.bubble_array.length)
          axios.post('api/bubbles',data)
          .then((res)=>{
            console.log(res.data)
            const data = res.data.toString()
            axios.post('/api/reactions',{
              name: this.reactionName,
              reaction_type: 'carousel',
              contents: data,
              match_option: this.selectedId,
              tag: this.tagtext.toString(),
            }).then((res)=>{
              //console.log(res.data)
              alert("メッセージセーブ完了")
              this.toggleCarousel();
              this.fetchOptions();
            },(error)=>{
              console.log(error)
            })
          },(error)=>{
            console.log(error)
          })
        } else if(!this.contents&&this.mapShow){//only map
          let geocoder = new google.maps.Geocoder();
          const latlng = this.marker_center
          geocoder.geocode({'location':this.marker_center,'language': 'ja'},(results,status)=>{
            if(status == 'OK'){
              //console.log(results)
              let data = '['+results[5].formatted_address+']+[@map('+latlng.lat+','+latlng.lng+')]'
              axios.post('/api/reactions',{
                name: this.reactionName,
                reaction_type: 'map',
                contents: data,
                match_option: this.selectedId,
                tag: this.tagtext.toString(),
              }).then((res)=>{
                alert("アクションセーブ完了");
                this.reactionToggle();
                this.fetchOptions();
              },(error)=>{
                console.log(error)
              })
            }
          })
        } else {//text+map
          if(this.reactions.length>=4){
            alert("最大アクションは五つです。");
            return;
          }
          axios.post('/api/reactions',{
            name: this.reactionName,
            reaction_type: 'text',
            contents: this.contents,
            match_option: this.selectedId,
            tag: this.tagtext.toString(),
          }).then((res)=>{
            let geocoder = new google.maps.Geocoder();
            const latlng = this.marker_center
            geocoder.geocode({'location':this.marker_center,'language': 'ja'},(results,status)=>{
              if(status == 'OK'){
                //console.log(results)
                let data = '['+results[5].formatted_address+']+[@map('+latlng.lat+','+latlng.lng+')]'
                axios.post('/api/reactions',{
                  name: this.reactionName,
                  reaction_type: 'map',
                  contents: data,
                  match_option: this.selectedId,
                  tag: this.tagtext.toString(),
                }).then((res)=>{
                  alert("アクションセーブ完了");
                  this.reactionToggle();
                  this.fetchOptions();
                },(error)=>{
                  console.log(error)
                })
              }
            })
          },(error)=>{
            console.log(error)
          })
        }
      },
      getImgUrl(para) {
        var images = require.context('../images/', false, /\.png$/)
        return images('./' + para + ".png")
      },
      setStampNum(){
        for(let i=1; i<47;i++){
          let add = '1_'+i
          this.stampNums.push(add)
        }
        for(let i=100; i<180;i++){
          let add = '1_'+i
          this.stampNums.push(add)
        }
        for(let i=401; i<431;i++){
          let add = '1_'+i
          this.stampNums.push(add)
        }
        for(let i=501; i<528;i++){
          let add = '1_'+i
          this.stampNums.push(add)
        }
      },
      toggleStamp(){
        this.emojiShow = false;
        this.mapShow = false;
        this.stampShow = !this.stampShow
      },
      selectStamp(num){
        this.uploadedImage = "";
        this.stampAreaShow = true
        let images = require.context('../images/', false, /\.png$/)
        this.selectStampUrl = images('./' + num + ".png")
        this.flexablePadding = {"padding-right": "300px"}
      },
      closeStamp(){
        this.stampAreaShow = false;
        this.flexablePadding = {"padding-right": "30px"}
      },
      resetPage(){
        this.currentPage = 1;
      },
      clickCallback(pageNum){
        this.currentPage = Number(pageNum);
      },
      showFullContents(contents){
        if (contents.search("@map")>=0){
          var tempArr = this.mapConvert(contents)
          tempArr[0] = tempArr[0]*1
          tempArr[1] = tempArr[1]*1
          this.selected_center = {lat: tempArr[0], lng: tempArr[1]}
          //{lat: 35.681236,lng: 139.767125}
        }

        this.fullContents = contents;
        this.showDetail = true;
      },
      closeDetail(){
        this.showDetail = false
      },
      toggleEmoji(){
        this.stampShow = false;
        this.emojiShow = !this.emojiShow
      },
      onFileChange(e){
        this.stampShow = false;
        this.stampAreaShow = false;
        this.mapShow = false;
        let files = e.target.files || e.dataTransfer.files;
        // console.log("그래서 파일이 뭔데????")
        // console.log((files[0]))
        this.imageFile = files[0]
        this.createImage(files[0]);
      },
      createImage(file){
        let reader = new FileReader();
        this.flexablePadding = {"padding-right": "300px"}
        let vm = this
        reader.onload = (e) => {
          this.uploadedImage = e.target.result;
        }
        reader.readAsDataURL(file);
      },
      onImageChange(e){
        this.uploadedImage = ""
        this.stampShow = false;
        this.stampAreaShow = false;
        this.mapShow = false;
        this.contents = ""
        this.innerContent = ""

        let files = e.target.files || e.dataTransfer.files;
        var index = this.selectedBubble
        this.heros[index] = files[0]
        this.createCarouselImage(index,files[0]);
      },
      createCarouselImage(index,file){
        let reader = new FileReader();
        let vm = this
        reader.onload = (e) => {
          this.bubble_array[index].hero = e.target.result
        }
        reader.readAsDataURL(file);
      },
      closeImage(){
        this.uploadedImage = ''
        this.flexablePadding = {"padding-right": "30px"}
      },
      toggleCarousel(){
        this.emptyAll();
        this.bubble_array = [{
          header: 'header', hero: null, body: 'body', footer: 'footer',
          header_gravity: 'top', header_align: 'start', header_size: 'md', header_bold: 'regular', header_color: '#111111',
          header_background: '#ffffff', hero_size: 'full', hero_align: 'center', hero_background: '#ffffff', hero_ratio: '1:1'
          ,body_gravity: 'top', body_align: 'start', body_size: 'md', body_bold: 'regular', body_color: '#111111',
          body_background: '#ffffff', footer_gravity: 'top', footer_align: 'center', footer_size: 'md', footer_bold: 'regular'
          ,footer_color: '#111111', footer_background: '#ffffff', footer_type: 'text', footer_button: 'uri',footer_uri: '',
          footer_message: ''
        }]
        this.header = ['header']
        this.body = ['body']
        this.footer = ['footer']
        this.heros = []
        this.carouselAreaShow = !this.carouselAreaShow
      },
      toggleMap(){
        this.uploadedImage = ""
        this.stampShow = false
        this.stampAreaShow = false
        this.emojiShow = false
        this.mapShow = !this.mapShow
        if (this.mapShow==true){
          this.flexablePadding = {"padding-right": "315px"}
        } else {
          this.flexablePadding = {"padding-right": "30px"}
        }
      },
      onCenterChanged(center){
        this.marker_center = {lat: center.lat(),lng: center.lng()}
      },
      getAddress(){
        var geocoder = new google.maps.Geocoder();
        geocoder.geocode({ 'location':this.marker_center},(results, status)=>{
          if (status == google.maps.GeocoderStatus.OK){
            let address = results[5].formatted_address
            this.innerContent = this.contents + ' ['+address.substr(3,address.length)+'] '
            this.contents += this.innerContent
          }
        });
      },
      setPlace(place){
        this.default_center = place.geometry.location
        this.marker_center = place.geometry.location
      },
      reactionToggle(){
        this.stampShow= false;
        this.stampAreaShow= false;
        this.emojiShow= false;
        this.marker_center = {lat: 35.681236,lng: 139.767125}
        this.mapShow = false;
        this.uploadedImage = "";
        this.contents = "";
        this.$refs.chatting.innerHTML = "";
        this.reactionName = "";
        this.selectedReaction = null
        //this.editMode = 'new';
        this.reactionListShow = false;
        this.carouselAreaShow = false;
        this.fetchReactions();
      },
      detailImage(url){
        let imageHTML = '<img class="fullSizeImage" src='+url+' style="width: 21em;height: 26em;">'
        this.fullContents = imageHTML;
        this.showDetail = true;
      },
      reactionCancel(id){
        if (confirm("このアクションを解除しますか。")==true){
          axios.get('/api/cancel_reaction?id='+id+'&match_option='+this.selectedId)
          .then((res)=>{
            alert("解除完了");
            this.fetchOptions();
            this.fetchReactions();
          },(error)=>{
            console.log(error)
          })
        } else {
          return;
        }
      },
      clearReactionCSS(){
        for(var reaction of this.$refs.reaction){
          reaction.style.backgroundColor = ''
        }
        for(var reaction of this.reactions){
          reaction.bool = false
        }
      },
      editAction(id,index,mode){
        this.clearReactionCSS();
        this.reactionToggle();
        this.goRight();
        this.reactions[index].bool = true
        this.$refs.reaction[index].style.backgroundColor = '#cccdff'

        axios.get('/api/reactions/'+id).then((res)=>{
          this.selectedReaction = res.data.reaction
          this.reactionName = this.selectedReaction.name
          switch(this.selectedReaction.reaction_type){
            case "text":
            this.$refs.chatting.innerHTML = this.selectedReaction.contents;
            this.contents = this.$refs.chatting.innerHTML
            break
            case "image":
            this.uploadedImage  = this.selectedReaction.image.url
            break
            case "stamp":
            let images = require.context('../images/', false, /\.png$/)
            this.selectStampUrl = images('./' + this.selectedReaction.contents + ".png")
            this.stampAreaShow = true;
            break
            case "map":
            var tempArr = this.mapConvert(this.selectedReaction.contents);
            tempArr[0] = tempArr[0]*1
            tempArr[1] = tempArr[1]*1
            this.default_center = {lat: tempArr[0], lng: tempArr[1]}
            this.marker_center = {lat: tempArr[0], lng: tempArr[1]}
            this.mapShow  = true;
            break
            case "carousel":
            this.fetchBubbles(this.selectedReaction.contents)
            break
            default:
            console.log(this.selectedReaction.reaction_type);
          }
          this.editMode = mode
        },(error)=>{
          console.log(error)
        })
      },
      mapConvert(contents){
        let tempArr = contents.split("+")
        const tempLength = tempArr[1].length
        tempArr = tempArr[1].substring(6,tempLength-2).split(",")
        return tempArr
      },
      updateReaction(){
        if(!this.reactionName){
          alert("アクションタイトルを作成してください。");
          return;
        }
        if(!this.stampAreaShow&&!this.contents&&!this.uploadedImage&&!this.mapShow&&!this.carouselAreaShow){//empty
          alert("一応アクションを作成してください。")
          return;
        }
        else if(this.contents&&!this.uploadedImage&&!this.stampAreaShow&&!this.mapShow&&!this.carouselAreaShow){//text only
          axios.put('/api/reactions/'+this.selectedReaction.id, {
            name: this.reactionName,
            reaction_type: 'text',
            contents: this.contents,
            image: null,
            match_option: this.selectedId,
            tag: this.tagtext.toString(),
          })
          .then((res)=>{
            alert("アクション修正完了")
            this.reactionToggle();
            this.clearReactionCSS();
          }, (error) =>{
            console.log(error)
          })
        } else if(this.stampAreaShow&&!this.contents){//stamp only
          let arr = this.selectStampUrl.split('-')
          let target = arr[0]
          axios.put('/api/reactions/'+this.selectedReaction.id,{
            name: this.reactionName,
            reaction_type: 'stamp',
            contents: target.substr(26,10),
            image: null,
            match_option: this.selectedId,
            tag: this.tagtext.toString(),
          })
          .then((res)=>{
            alert("アクション修正完了");
            this.reactionToggle();
            this.clearReactionCSS();
          },(error)=>{
            console.log(error)
          })
        } else if(this.stampAreaShow&&this.contents){//text+stamp
          alert("一つのアクションは一つのアクションでだけ修正できます。");
          return;
        } else if(!this.contents&&this.uploadedImage){//only image
          var data = new FormData();
          //var file = this.$refs.fileInput.files[0];
          data.append('name', this.reactionName);
          data.append('reaction_type','image');
          data.append('contents','[ NO TEXT ]');
          data.append('tag',this.tagtext.toString());
          data.append('image',this.imageFile);
          data.append('match_option', this.selectedId)
          axios.put('/api/reactions/'+this.selectedReaction.id,data)
          .then((res)=>{
            alert("アクション修正完了");
            this.reactionToggle();
            this.clearReactionCSS();
          },(error)=>{
            console.log(error)
          })
        } else if(this.contents&&this.uploadedImage){//text+image
          alert("一つのアクションは一つのアクションでだけ修正できます。");
          return;
        } else if(this.carouselAreaShow){//only carousel
          var contents = this.selectedReaction.contents
          var contents_array = contents.split(",")
          var old_length = contents_array.length
          var new_length = this.bubble_array.length
          if(old_length<new_length){
            alert("carousel added")
          } else if(old_length==new_length){
            alert("carousel maintained")
          } else {
            alert("carousel deleted")
          }

        //   for(var bubble of this.bubble_array){
        //     let bubbleLength = bubble.header.length+bubble.body.length+bubble.footer.length
        //     if(bubbleLength==0){
        //       alert("作成されないキャルセルがあります。");
        //       return;
        //     }
        //     if(bubble.header_color.substr(0,1)!='#'&&bubble.header_color.length!=7){
        //       alert("色の形式が間違います。\n例) #00b900");
        //       return;
        //     }else if(bubble.header_background.substr(0,1)!='#'&&bubble.header_background.length!=7){
        //       alert("色の形式が間違います。\n例) #00b900");
        //       return;
        //     }else if(bubble.body_color.substr(0,1)!='#'&&bubble.body_color.length!=7){
        //       alert("色の形式が間違います。\n例) #00b900");
        //       return;
        //     }else if(bubble.body_background.substr(0,1)!='#'&&bubble.body_background.length!=7){
        //       alert("色の形式が間違います。\n例) #00b900");
        //       return;
        //     }else if(bubble.footer_color.substr(0,1)!='#'&&bubble.footer_color.length!=7){
        //       alert("色の形式が間違います。\n例) #00b900");
        //       return;
        //     }else if(bubble.footer_background.substr(0,1)!='#'&&bubble.footer_background.length!=7){
        //       alert("色の形式が間違います。\n例) #00b900");
        //       return;
        //     }else if(bubble.hero_background.substr(0,1)!='#'&&bubble.hero_background.length!=7){
        //       alert("色の形式が間違います。\n例) #00b900");
        //       return;
        //     }
        //     if(bubble.footer_type=='button'){
        //       if(bubble.footer_button=='uri'&&bubble.footer_uri.length==0){
        //         alert("ボタンのURLを入力してください。");
        //         return;
        //       } else if(bubble.footer_button=='message'&&bubble.footer_message.length==0){
        //         alert("ボタンのメッセージを入力してください。");
        //         return;
        //       }
        //     }
        //   }
        //   var data = new FormData();
        //   for(var i=0; i<this.bubble_array.length; i++){
        //     data.append('headers[]', this.bubble_array[i].header)
        //     data.append('images[]', this.heros[i])
        //     data.append('bodies[]', this.bubble_array[i].body)
        //     data.append('footers[]', this.bubble_array[i].footer)

        //     data.append('header_gravity[]', this.bubble_array[i].header_gravity)
        //     data.append('header_align[]', this.bubble_array[i].header_align)
        //     data.append('header_size[]', this.bubble_array[i].header_size)
        //     data.append('header_bold[]', this.bubble_array[i].header_bold)
        //     data.append('header_color[]', this.bubble_array[i].header_color)
        //     data.append('header_background[]', this.bubble_array[i].header_background)

        //     data.append('hero_size[]', this.bubble_array[i].hero_size)
        //     data.append('hero_align[]', this.bubble_array[i].hero_align)
        //     data.append('hero_background[]', this.bubble_array[i].hero_background)
        //     data.append('hero_ratio[]', this.bubble_array[i].hero_ratio)

        //     data.append('body_gravity[]', this.bubble_array[i].body_gravity)
        //     data.append('body_align[]', this.bubble_array[i].body_align)
        //     data.append('body_size[]', this.bubble_array[i].body_size)
        //     data.append('body_bold[]', this.bubble_array[i].body_bold)
        //     data.append('body_color[]', this.bubble_array[i].body_color)
        //     data.append('body_background[]', this.bubble_array[i].body_background)

        //     data.append('footer_gravity[]', this.bubble_array[i].footer_gravity)
        //     data.append('footer_align[]', this.bubble_array[i].footer_align)
        //     data.append('footer_size[]', this.bubble_array[i].footer_size)
        //     data.append('footer_bold[]', this.bubble_array[i].footer_bold)
        //     data.append('footer_color[]', this.bubble_array[i].footer_color)
        //     data.append('footer_background[]', this.bubble_array[i].footer_background)
        //     data.append('footer_type[]', this.bubble_array[i].footer_type)
        //     data.append('footer_button[]', this.bubble_array[i].footer_button)
        //     data.append('footer_uri[]', this.bubble_array[i].footer_uri)
        //     data.append('footer_message[]', this.bubble_array[i].footer_message)
        //   }
        //   data.append('bubble_num',this.bubble_array.length)

        } else if(!this.contents&&this.mapShow){//only map
          let geocoder = new google.maps.Geocoder();
          const latlng = this.marker_center
          geocoder.geocode({'location':this.marker_center,'language': 'ja'},(results,status)=>{
            if(status == 'OK'){
              let data = '['+results[5].formatted_address+']+[@map('+latlng.lat+','+latlng.lng+')]'
              axios.put('/api/reactions/'+this.selectedReaction.id,{
                name: this.reactionName,
                reaction_type: 'map',
                contents: data,
                image: null,
                match_option: this.selectedId,
                tag: this.tagtext.toString(),
              }).then((res)=>{
                alert("アクションセーブ完了");
                this.reactionToggle();
                this.clearReactionCSS();
              },(error)=>{
                console.log(error)
              })
            }
          })
        } else {//text+map
          alert("一つのアクションは一つのアクションでだけ修正できます。");
          return;
        }
      },
      clearTargetTag(){
        this.targetMargin['margin-bottom'] = '46px'
        this.selectedTargets = []
      },
      clearDay(){
        this.targetDay = [0,1,2,3,4,5,6]
      },
      clearTime(){
        this.startTime = '00:00'
        this.endTime = '00:00'
      },
      updateOption(){
        if(this.setDay=='setDay'&&this.targetDay.length==0){
          alert("日を設定してください。")
          return;
        }
        if(this.setTime=='setTime'&&(this.startTime.length==0||this.endTime.legnth==0)){
          alert("時間を設定してください。")
          return;
        }
        var targetTime = [this.startTime,this.endTime]
        axios.put('api/options/'+this.selectedId,{
          target_keyword: this.keywords.toString(),
          target_day: this.targetDay.toString(),
          target_time: targetTime.toString(),
          action_count: this.actionCount,
          target_friend: this.selectedTargets.toString(),
          tag: this.tagtext.toString(),
        }).then((res)=>{
          alert("条件修正完了！");
          console.log(res.data)
          this.fetchOptions();
        },(error)=>{
          console.log(error)
        })
      },
      clearKeyInput(){
        this.keyword = ''
      },
      clearTag(){
        this.tag = ''
      },
      createKeyword(){
        if(!this.keyword) return;
        if(this.keyword.search(",")>-1||this.keyword.search("、")>-1) {
          alert("コンマは条件語になれません。")
          return;
        }
        axios.post('api/keyword_check',{
          keyword: this.keyword
        }).then((res)=>{
          console.log(res.data)
          if(res.data.length>0){
            alert("もうあるキーワードです。")
            return;
          } else {
            this.keywords.push(this.keyword)
            this.keyword = '';
          }
        },(error)=>{
          console.log(error)
        })
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
      fetchOption(){
        if(this.selected != null){
          this.selectedOption = this.options[this.selected]
          if(this.selectedOption.target_keyword != null){
            if(this.selectedOption.target_keyword.length != 0){
              this.keywords = []
              this.keywords = this.selectedOption.target_keyword.split(",");
            }
          }
          this.targetDay = []
          this.targetDay = this.selectedOption.target_day.split(",")
          if(this.targetDay.length==7){
            this.setDay = 'unsetDay'
          } else {
            this.setDay = 'setDay'
          }
          var targetTime = this.selectedOption.target_time.split(",")
          this.startTime = targetTime[0]
          this.endTime = targetTime[1]
          if(this.startTime==this.endTime){
            this.setTime = 'unsetTime'
          } else {
            this.setTime = 'setTime'
          }
          if(this.selectedOption.action_count != null){
            this.actionCount = this.selectedOption.action_count
            this.setCount = 'setCount'
          } else {
            this.setCount = 'unsetCount'
          }

          this.tagtext = this.selectedOption.tag.split(",")
          let friends = this.selectedOption.target_friend
          if(friends.length>0){
            this.setTarget = 'setTarget'
            this.selectedTargets = friends.split(",")
          }
        }
      },
      fetchAllReactions(){
        axios.post('api/reactions_all',{
          option_id: this.selectedId
        }).then((res)=>{
          this.reactionsLeft = res.data
          if(this.reactionsLeft.length==0){
            alert("登録できるアクションがありません。")
            this.reactionListShow = false;
          }
          this.fetchReactions();
        },(error)=>{
          console.log(error)
        })
      },
      linkOptionReaction(id){
        // console.log(reactions)
        // console.log(reactions.length)
        if(this.reactions.length>=5){
          alert("最大アクション値は５つです。")
          this.fetchReactions();
          this.reactionListShow = false;
        } else {
          axios.post('api/link_option_reaction',{
            reaction_id: id,
            option_id: this.selectedId
          }).then((res)=>{
            this.fetchOptions();
            this.fetchAllReactions();
          },(error)=>{
            console.log(error)
          })
        }
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
      goRight(){
        var width = this.$refs.result.clientWidth
        var scrollLeft = this.$refs.result.scrollLeft
        var scrollWidth = this.$refs.result.scrollWidth
        var moveWidth = (scrollWidth - width) / 2

        this.$refs.result.scrollLeft = scrollLeft + moveWidth
        this.baseScroll = scrollLeft
        this.endPoint = this.endPoint+1
      },
      goLeft(){
        var width = this.$refs.result.clientWidth
        var scrollLeft = this.$refs.result.scrollLeft
        var scrollWidth = this.$refs.result.scrollWidth
        var moveWidth = (scrollWidth - width) / 2

        this.$refs.result.scrollLeft = scrollLeft - moveWidth
        this.baseScroll = scrollLeft
        this.endPoint = this.endPoint-1
      },
      mouseScroll(){
        var width = this.$refs.result.clientWidth
        var scrollLeft = this.$refs.result.scrollLeft
        var scrollWidth = this.$refs.result.scrollWidth
        if(scrollLeft==0){
          this.endPoint = 0
        } else if(scrollLeft==scrollWidth-width){
          this.endPoint = 2
        } else {
          this.endPoint = 1
        }
      },
      callTarget(){
        this.targetMargin['margin-bottom'] = '4px'
        this.fetchTargets();
      },
      addBubble(){
        var bubble = {
          header: 'header', hero: null, body: 'body', footer: 'footer',
          header_gravity: 'top', header_align: 'start', header_size: 'md', header_bold: 'regular', header_color: '#111111',
          header_background: '#ffffff', hero_size: 'full', hero_align: 'center', hero_background: '#ffffff', hero_ratio: '1:1'
          ,body_gravity: 'top', body_align: 'start', body_size: 'md', body_bold: 'regular', body_color: '#111111',
          body_background: '#ffffff', footer_gravity: 'top', footer_align: 'center', footer_size: 'md', footer_bold: 'regular'
          ,footer_color: '#111111', footer_background: '#ffffff', footer_type: 'text', footer_button: 'uri',footer_uri: '',
          footer_message: ''
        }
        var headerStyle = {
          'margin-left':'0', 'margin-right':'auto', 'font-size':'15px', 'font-weight':'normal', 'margin-top':'0px',
          'color':'#111111','background':'#ffffff'
        }
        var bodyStyle = {
          'margin-left':'0', 'margin-right':'auto', 'font-size':'15px', 'font-weight':'normal', 'margin-top':'0px',
          'color':'#111111', 'background':'#ffffff'
        }
        var footerStyle = {
          'margin-left':'auto', 'margin-right':'auto', 'font-size':'15px', 'font-weight':'normal', 'margin-top':'0px',
          'color':'#111111', 'background':'#ffffff'
        }

        this.bubble_array.push(bubble)
        this.header.push('header')
        this.body.push('body')
        this.footer.push('footer')

        this.headerCSS.push(headerStyle)
        this.heroCSS.push({'text-align':'center','background-color':'#ffffff'})
        this.imageCSS.push({'width':'100%', 'height': 'auto'})
        this.imageSize.push('100%')
        this.bodyCSS.push(bodyStyle)
        this.footerCSS.push(footerStyle)

        this.headerBackground.push({'background-color':'#ffffff'})
        this.bodyBackground.push({'background-color':'#ffffff'})
        this.footerBackground.push({'background-color':'#ffffff'})
      },
      removeBubble(id){
        var start = id
        for(var i=start; i<this.bubble_array.length-1; i++){
          this.bubble_array[i] = this.bubble_array[i+1]
        }
        this.bubble_array.pop();
      },
      syncHeader(index){
        this.bubble_array[index].header = this.header[index]
      },
      syncBody(index){
        this.bubble_array[index].body = this.body[index]
      },
      syncFooter(index){
        this.bubble_array[index].footer = this.footer[index]
      },
      syncGravity(){
        var i = this.selectedBubble
        switch(this.selectedComponent){
          case 'header':
          this.bubble_array[i].header_gravity = this.gravity
          this.headerCSS[i]['margin-top'] = this.gravityConverter('header', this.size, this.gravity)
          break
          case 'hero':
          break
          case 'body':
          this.bubble_array[i].body_gravity = this.gravity
          this.bodyCSS[i]['margin-top'] = this.gravityConverter('body', this.size, this.gravity)
          break
          case 'footer':
          this.bubble_array[i].footer_gravity = this.gravity
          this.footerCSS[i]['margin-top'] = this.gravityConverter('footer', this.size, this.gravity)
          break
          default:
          console.log("syncGravity error")
        }
      },
      gravityConverter(component,size,gravity){
        let slice = 0
        switch(size){
          case 'xxs':
          case 'xs':
          case 'sm':
          slice = 3
          break
          case 'md':
          slice = 4
          break
          case 'lg':
          slice = 5
          break
          case 'xl':
          slice = 6
          break
          case 'xxl':
          slice = 7
          break
          case '3xl':
          slice = 8
          break
          case '4xl':
          slice = 9
          break
          case '5xl':
          slice = 10
          break
          default:
          console.log("gravityConverter error!")
        }
        let result = 0
        if(component=='header'||component=='body'){
          result = 8.5-(0.55*slice)
        } else {
          result = 6.2-(0.55*slice)
        }
        switch(gravity){
          case 'top':
          return '0'
          break
          case 'center':
          result = result/2
          return result+'vh'
          break
          case 'bottom':
          return result+'vh'
          break
          default:
          console.log('gravityConverter error!')
        }
      },
      syncAlign(){
        var i = this.selectedBubble
        switch(this.selectedComponent){
          case 'header':
          this.bubble_array[i].header_align = this.align
          this.headerCSS[i]['margin-left'] = this.alignConverter(this.align)[0]
          this.headerCSS[i]['margin-right'] = this.alignConverter(this.align)[1]
          break
          case 'hero':
          this.bubble_array[i].hero_align = this.align
          this.heroCSS[i]['text-align'] = this.align
          break
          case 'body':
          this.bubble_array[i].body_align = this.align
          this.bodyCSS[i]['margin-left'] = this.alignConverter(this.align)[0]
          this.bodyCSS[i]['margin-right'] = this.alignConverter(this.align)[1]
          break
          case 'footer':
          this.bubble_array[i].footer_align = this.align
          this.footerCSS[i]['margin-left'] = this.alignConverter(this.align)[0]
          this.footerCSS[i]['margin-right'] = this.alignConverter(this.align)[1]
          break
          default:
          console.log("syncAlign error!")
        }
      },
      alignConverter(align){
        var leftRight = []
        switch(align){
          case 'start':
          leftRight.push('0')
          leftRight.push('auto')
          break
          case 'center':
          leftRight.push('auto')
          leftRight.push('auto')
          break
          case 'end':
          leftRight.push('auto')
          leftRight.push('0')
          break
        }
        return leftRight
      },
      syncSize(){
        var i = this.selectedBubble
        switch(this.selectedComponent){
          case 'header':
          this.bubble_array[i].header_size = this.size
          this.headerCSS[i]['font-size'] = this.sizeConverter('header',this.size)
          break
          case 'hero':
          this.bubble_array[i].hero_size = this.size
          this.imageCSS[i]['width'] = this.sizeConverter('hero',this.size)
          this.imageSize[i] = this.sizeConverter('hero',this.size)
          break
          case 'body':
          this.bubble_array[i].body_size = this.size
          this.bodyCSS[i]['font-size'] = this.sizeConverter('body',this.size)
          break
          case 'footer':
          this.bubble_array[i].footer_size = this.size
          this.footerCSS[i]['font-size'] = this.sizeConverter('footer',this.size)
          break
          default:
          console.log("syncSize error!")
        }
        this.syncGravity()
        this.syncAlign()
      },
      sizeConverter(component,size){
        switch(size){
          case 'xxs':
          if(component=='hero'){
            return '10%'
          }else {
            return '11px'
          }
          break
          case 'xs':
          if(component=='hero'){
            return '15%'
          }else {
            return '12px'
          }
          break
          case 'sm':
          if(component=='hero'){
            return '20%'
          }else {
            return '13px'
          }
          break
          case 'md':
          if(component=='hero'){
            return '30%'
          }else {
            return '15px'
          }
          break
          case 'lg':
          if(component=='hero'){
            return '40%'
          }else {
            return '20px'
          }
          break
          case 'xl':
          if(component=='hero'){
            return '50%'
          }else {
            return '25px'
          }
          break
          case 'xxl':
          if(component=='hero'){
            return '60%'
          }else {
            return '30px'
          }
          break
          case '3xl':
          if(component=='hero'){
            return '70%'
          }else {
            return '35px'
          }
          break
          case '4xl':
          if(component=='hero'){
            return '80%'
          }else {
            return '40px'
          }
          break
          case '5xl':
          if(component=='hero'){
            return '90%'
          }else {
            return '45px'
          }
          break
          case 'full':
          return '100%'
          break
          default:
          console.log('sizeConverter error!')
        }
      },
      syncRatio(){
        var i = this.selectedBubble
        this.bubble_array[i].hero_ratio = this.heroWidth + ':' + this.heroHeight
        var ratio = this.heroHeight / this.heroWidth
        var reverseRatio = this.heroWidth / this.heroHeight
        var imageWidth = this.imageSize[i]
        if(ratio > 1){
          this.imageCSS[i]['height'] = imageWidth
          var ratioWidth = imageWidth.substring(0,imageWidth.length-1)*reverseRatio
          this.imageCSS[i]['width'] = ratioWidth + '%'
        } else if(ratio==1){
          this.imageCSS[i]['width'] = imageWidth
          this.imageCSS[i]['height'] = 'auto'
        } else{
          var ratioHeight = imageWidth.substring(0,imageWidth.length-1)*ratio
          this.imageCSS[i]['height'] = ratioHeight + '%'
        }
      },
      syncBold(){
        var i = this.selectedBubble
        switch(this.selectedComponent){
          case 'header':
          this.bubble_array[i].header_bold = this.bold
          this.headerCSS[i]['font-weight'] = this.boldConverter(this.bold)
          break
          case 'body':
          this.bubble_array[i].body_bold = this.bold
          this.bodyCSS[i]['font-weight'] = this.boldConverter(this.bold)
          break
          case 'footer':
          this.bubble_array[i].footer_bold = this.bold
          this.footerCSS[i]['font-weight'] = this.boldConverter(this.bold)
          break
          default:
          console.log("syncBold error!")
        }
      },
      boldConverter(bold){
        switch(bold){
          case 'regular':
          return 'normal'
          break
          case 'bold':
          return 'bold'
          break
          default:
          console.log('error!')
        }
      },
      syncColor(){
        this.fontColor = {'background-color': this.color}
        var i = this.selectedBubble
        switch(this.selectedComponent){
          case 'header':
          this.bubble_array[i].header_color = this.color
          this.headerCSS[i]['color'] = this.color
          break
          case 'body':
          this.bubble_array[i].body_color = this.color
          this.bodyCSS[i]['color'] = this.color
          break
          case 'footer':
          this.bubble_array[i].footer_color = this.color
          this.footerCSS[i]['color'] = this.color
          break
          default:
          console.log("error!")
        }
      },
      syncBackground(){
        this.backgroundColor = {'background-color': this.background}
        var i = this.selectedBubble
        switch(this.selectedComponent){
          case 'header':
          this.bubble_array[i].header_background = this.background
          this.headerBackground[i]['background-color'] = this.background
          this.headerCSS[i]['background'] = this.background
          break
          case 'hero':
          this.bubble_array[i].hero_background = this.background
          this.heroCSS[i]['background-color'] = this.background
          break
          case 'body':
          this.bubble_array[i].body_background = this.background
          this.bodyBackground[i]['background'] = this.background
          this.bodyCSS[i]['background'] = this.background
          break
          case 'footer':
          this.bubble_array[i].footer_background = this.background
          this.footerBackground[i]['background'] = this.background
          this.footerCSS[i]['background'] = this.background
          break
          default:
          console.log("error!")
        }
      },
      syncFooterType(){
        var i = this.selectedBubble
        this.bubble_array[i].footer_type = this.footer_type
        if(this.footer_type=='button'){
          this.gravity = 'center'
          this.align = 'center'
          this.color = '#ffffff'
          this.background = '#007bff'
          this.syncGravity();
          this.syncAlign();
          this.syncColor();
          this.syncBackground();
          this.footerCSS[i]['height'] = '6vh'
          this.footerCSS[i]['width'] = '100%'
          this.footerCSS[i]['font-size'] = '25px'
          this.footerCSS[i]['line-height'] = '6vh'
          this.footerCSS[i]['cursor'] = 'pointer'
          this.footerCSS[i]['margin-top'] = '0px'
        } else{
          this.footerCSS[i]['height'] = ''
          this.footerCSS[i]['width'] = ''
          this.footerCSS[i]['font-size'] = '15px'
          this.footerCSS[i]['line-height'] = '100%'
          this.footerCSS[i]['cursor'] = ''
          this.color = '#111111'
          this.background = '#ffffff'
          this.syncColor();
          this.syncBackground();
        }
      },
      syncFooterButton(){
        var i = this.selectedBubble
        this.bubble_array[i].footer_button = this.footer_button
      },
      syncFooterUri(){
        var i = this.selectedBubble
        this.bubble_array[i].footer_uri = this.footer_uri
      },
      syncFooterMessage(){
        var i = this.selectedBubble
        this.bubble_array[i].footer_message = this.footer_message
      },
      syncHeroRatio(){
        var i = this.selectedBubble
        this.bubble_array[i].hero_ratio = this.heroWidth + ':' + this.heroHeight
      },
      selectComponent(type,index){
        this.selectedComponent = type
        this.selectedBubble = index
        switch(type){
          case 'header':
          this.gravity = this.bubble_array[index].header_gravity
          this.align = this.bubble_array[index].header_align
          this.size = this.bubble_array[index].header_size
          this.color = this.bubble_array[index].header_color
          this.background = this.bubble_array[index].header_background
          this.bold = this.bubble_array[index].header_bold
          break
          case 'hero':
          var ratio = this.bubble_array[index].hero_ratio.split(":")
          this.heroWidth = ratio[0]*1
          this.heroHeight = ratio[1]*1
          this.align = this.bubble_array[index].hero_align
          this.size = this.bubble_array[index].hero_size
          this.background = this.bubble_array[index].hero_background
          break
          case 'body':
          this.gravity = this.bubble_array[index].body_gravity
          this.align = this.bubble_array[index].body_align
          this.size = this.bubble_array[index].body_size
          this.color = this.bubble_array[index].body_color
          this.background = this.bubble_array[index].body_background
          this.bold = this.bubble_array[index].body_bold
          break
          case 'footer':
          this.gravity = this.bubble_array[index].footer_gravity
          this.align = this.bubble_array[index].footer_align
          this.size = this.bubble_array[index].footer_size
          this.color = this.bubble_array[index].footer_color
          this.background = this.bubble_array[index].footer_background
          this.bold = this.bubble_array[index].footer_bold
          this.footer_type = this.bubble_array[index].footer_type
          this.footer_button = this.bubble_array[index].footer_button
          this.footer_uri = this.bubble_array[index].footer_uri
          this.footer_message = this.bubble_array[index].footer_message
          break
          default:
          console.log("error")
        }
        this.fontColor = {'background-color': this.color}
        this.backgroundColor = {'background-color': this.background}
      },
      stretchCarouselToggle(){
        this.carouselOpen = !this.carouselOpen
        if(this.carouselOpen){
          this.carouselBoxWidth.width = "83%"
          this.carouselAreaWidth.width = "197%"
        } else {
          this.carouselBoxWidth.width = "65%"
          this.carouselAreaWidth.width = "90%"
        }
      },
      fetchBubbles(ids){
        axios.post('api/fetch_bubbles',{
          ids: ids
        }).then((res)=>{
          // console.log("bubble수집")
          console.log(res.data)
          this.carouselAreaShow = true;
          this.bubble_array = []
          for(var i in res.data){
            var bubble = res.data[i]
            this.bubble_array[i] = bubble
            this.bubble_array[i]['hero'] = bubble.image.url
            this.header[i] = bubble.header
            this.heros[i] = bubble.image
            this.body[i] = bubble.body
            this.footer[i] = bubble.footer

            var headerStyle = {
              'margin-left':'0', 'margin-right':'auto', 'font-size':'15px', 'font-weight':'normal', 'margin-top':'0px',
              'color':'#111111','background':'#ffffff'
            }
            var bodyStyle = {
              'margin-left':'0', 'margin-right':'auto', 'font-size':'15px', 'font-weight':'normal', 'margin-top':'0px',
              'color':'#111111', 'background':'#ffffff'
            }
            var footerStyle = {
              'margin-left':'auto', 'margin-right':'auto', 'font-size':'15px', 'font-weight':'normal', 'margin-top':'0px',
              'color':'#111111', 'background':'#ffffff'
            }

            this.headerCSS[i] = headerStyle
            this.heroCSS[i] = {'text-align':'center','background-color':'#ffffff'}
            this.imageCSS[i] = {'width':'100%', 'height': 'auto'}
            this.imageSize[i] = '100%'
            this.bodyCSS[i] = bodyStyle
            this.footerCSS[i] = footerStyle

            this.headerBackground[i] = {'background-color':'#ffffff'}
            this.bodyBackground[i] = {'background-color':'#ffffff'}
            this.footerBackground[i] = {'background-color':'#ffffff'}

            this.moveToSync(i,bubble,'header')
            this.moveToSync(i,bubble,'body')
            this.moveToSync(i,bubble,'footer')
          }
          this.selectComponent('header',0)
        },(error)=>{
          console.log(error)
        })
      },
      moveToSync(index,bubble,component){
        this.selectedBubble = index
        this.selectedComponent = component
        switch(component){
          case "header":
          this.gravity = bubble['header_gravity']
          this.align = bubble['header_align']
          this.size = bubble['header_size']
          this.bold = bubble['header_bold']
          this.color = bubble['header_color']
          this.background = bubble['header_background']
          break
          case "body":
          this.gravity = bubble['body_gravity']
          this.align = bubble['body_align']
          this.size = bubble['body_size']
          this.bold = bubble['body_bold']
          this.color = bubble['body_color']
          this.background = bubble['body_background']
          break
          case "footer":
          this.gravity = bubble['footer_gravity']
          this.align = bubble['footer_align']
          this.size = bubble['footer_size']
          this.bold = bubble['footer_bold']
          this.color = bubble['footer_color']
          this.background = bubble['footer_background']
          this.footer_type = bubble['footer_type']
          this.footer_button = bubble['footer_button']
          this.footer_uri = bubble['footer_uri']
          this.footer_message = bubble['footer_message']
          break
          default:
          console.log("moveToSync error!")
        }
        // this.heroWidth = bubble['heroWidth']
        // this.heroHeight = bubble['heroHeight']

        this.syncGravity();
        this.syncAlign();
        this.syncSize();
        this.syncBold();
        this.syncColor();
        this.syncBackground();
        if(component=='footer'){
          this.syncFooterType();
          this.syncFooterButton();
          this.syncFooterUri();
          this.syncFooterMessage();
        }
      },
      exchangeColor(){
        var temp = this.color
        this.color = this.background
        this.background = temp
        this.syncColor();
        this.syncBackground();
      },
      copyCSS(){
        var i = this.selectedBubble
        this.copiedType = this.selectedComponent

        this.copied['gravity'] = this.gravity
        this.copied['align'] = this.align
        this.copied['size'] = this.size
        this.copied['bold'] = this.bold
        this.copied['color'] = this.color
        this.copied['background'] = this.background
        this.copied['heroWidth']= this.heroWidth
        this.copied['heroHeight']= this.heroHeight
        this.copied['footer_type']= this.footer_type
        this.copied['footer_button']= this.footer_button
        this.copied['footer_uri']= this.footer_uri
        this.copied['footer_message']= this.footer_message
      },
      pasteCSS(){
        // var design = this.copiedCSS
        if(this.copiedType == this.selectedComponent){
          this.syncCSS()
        } else {
          if(this.copiedType=='hero'||this.selectedComponent=='hero'){
            alert("イメージのデザインはイメージ間だけ適用できます。")
          }else{
            if(this.selectedComponent!='footer'){
              this.syncCSS()
            } else {
              if(this.footer_type=='button'){
                alert("テキストのデザインはボタンに適用できません。")
              }else{
                this.syncCSS()
              }
            }
          }
        }
      },
      syncCSS(){
        if(this.copiedType=='hero'){
          this.align = this.copied['align']
          this.size = this.copied['size']
          this.background = this.copied['background']
          this.heroHeight = this.copied['heroHeight']
          this.heroWidth = this.copied['heroWidth']

          this.syncAlign();
          this.syncSize();
          this.syncBackground();
          this.syncRatio();
        } else {
          this.gravity = this.copied['gravity']
          this.align = this.copied['align']
          this.size = this.copied['size']
          this.bold = this.copied['bold']
          this.color = this.copied['color']
          this.background = this.copied['background']

          this.syncGravity();
          this.syncAlign();
          this.syncSize();
          this.syncBold();
          this.syncColor();
          this.syncBackground();
          if(this.copiedType=='footer'&&this.selectedComponent=='footer'){
            this.footer_type = this.copied['footer_type']
            this.footer_button = this.copied['footer_button']
            this.footer_uri = this.copied['footer_uri']
            this.footer_message = this.copied['footer_message']

            this.syncFooterType();
            this.syncFooterButton();
            this.syncFooterUri();
            this.syncFooterMessage();
          }
        }
      },
      copyBubble(index){
        this.addBubble();

        var header = this.bubble_array[index].header
        var body = this.bubble_array[index].body
        var file = this.heros[index]
        var hero = this.bubble_array[index].hero
        var footer = this.bubble_array[index].footer

        var end = this.bubble_array.length - 1
        this.heros[end] = file
        this.bubble_array[end]['header'] = header
        this.bubble_array[end]['body'] = body
        this.bubble_array[end]['footer'] = footer
        this.bubble_array[end].hero = hero

        this.header[end] = header
        this.body[end] = body
        this.footer[end] = footer

        var comp = ['header','hero','body','footer']
        for(var i in comp){
          this.selectComponent(comp[i],index)
          this.copyCSS();
          var target = this.bubble_array.length - 1
          this.selectComponent(comp[i],target)
          this.pasteCSS();
        }
        this.selectedBubble = null
        this.selectedComponent = null
        this.copied = {}
        this.copiedType = ''
      },
      bubbleChecker(bubble,contents){
        var temp = contents.split(",")
        for(var id of temp){
          if(bubble.id==id*1){
            return {'display': 'inline-block'}
          }
        }
        return {'display':'none'}
      },
      removeImage(){
        var i = this.selectedBubble
        this.heros[i] = null
        this.bubble_array[i].hero = null
      },
      changeEditMode(mode){
        this.editMode = mode
        if(mode='new'){
          if(this.heros.length>0){
            this.heros = []
            for(var bubble of this.bubble_array){
              bubble.hero = ''
            }
            alert("イメージファイルはプレービューだけ可能です。\nイメージを修正したい場合は新しくアップロードしてください。")
          }
          this.clearReactionCSS();
        }
      },
    },
    computed: {
      getOption(){
        let current = this.currentPage * this.parPage
        let start = current - this.parPage
        return this.options.slice(start, current)
      },
      getPageCount(){
        return Math.ceil(this.options.length / this.parPage)
      },
    }
  }
</script>
<style scoped src="../components/page7/page7.css"/>
