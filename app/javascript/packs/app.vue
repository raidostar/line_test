<template>
  <div id="app">
    <nav id="topbar" :class="{sticky: (position > 0)}">
      <h3>LINE MANAGER
        <a class="loginOut" rel="nofollow" data-method="delete" href="/users/sign_out">
          {{userid}}
        </a>
      </h3>
    </nav>
    <nav id="sidebar">
      <div class="side left nav-wrapper container">
        <ul class="hide-on-med-and-down">
          <li v-if="mode==''">
            <router-link class="pageLink selected-mode" to="/""><i class="material-icons">home</i>ホーム</router-link>
          </li>
          <li v-else @click="changeMode('')">
            <router-link class="pageLink home" to="/"><i class="material-icons">home</i>ホーム</router-link>
          </li>

          <li class="category"><i class="material-icons">format_align_justify</i>1対1のトーク</li>
          <li v-if="mode=='friendslist'">
            <router-link class="pageLink selected-mode" to="/friendslist">友達リスト</router-link>
          </li>
          <li v-else @click="changeMode('friendslist')">
            <router-link class="pageLink" to="/friendslist">友達リスト</router-link>
          </li>

          <li v-if="mode=='allMessages'">
            <router-link class="pageLink selected-mode" to="/allMessages">トーク一覧</router-link>
          </li>
          <li v-else @click="changeMode('allMessages')">
            <router-link class="pageLink" to="/allMessages">トーク一覧</router-link>
          </li>

          <li v-if="mode=='personalMessages'">
            <router-link class="pageLink selected-mode" to="/personalMessages">個別トーク</router-link>
          </li>
          <li v-else @click="changeMode('personalMessages')">
            <router-link class="pageLink" to="/personalMessages">個別トーク</router-link>
          </li>

          <li class="category"><i class="material-icons">email</i>メッセージ</li>
          <li v-if="mode=='dataAnalysis'">
            <router-link class="pageLink selected-mode" to="/dataAnalysis">データ分析</router-link>
          </li>
          <li v-else @click="changeMode('dataAnalysis')">
            <router-link class="pageLink" to="/dataAnalysis">データ分析</router-link>
          </li>

          <li v-if="mode=='sendAll'">
            <router-link class="pageLink selected-mode" to="/sendAll">全配信</router-link>
          </li>
          <li v-else @click="changeMode('sendAll')">
            <router-link class="pageLink" to="/sendAll">全配信</router-link>
          </li>

          <li v-if="mode=='autoReply'">
            <router-link class="pageLink selected-mode" to="/autoReply">自動応答</router-link>
          </li>
          <li v-else @click="changeMode('autoReply')">
            <router-link class="pageLink" to="/autoReply">自動応答</router-link>
          </li>

          <li v-if="mode=='template'">
            <router-link class="pageLink selected-mode" to="/template">テンプレート</router-link>
          </li>
          <li v-else @click="changeMode('template')">
            <router-link class="pageLink" to="/template">テンプレート</router-link>
          </li>

          <li v-if="mode=='tagManagement'">
            <router-link class="pageLink selected-mode" to="/tagManagement">タグ管理</router-link>
          </li>
          <li v-else @click="changeMode('tagManagement')">
            <router-link class="pageLink" to="/tagManagement">タグ管理</router-link>
          </li>

          <li v-if="mode=='remindReply'">
            <router-link class="pageLink selected-mode" to="/remindReply">リマインダ配信</router-link>
          </li>
          <li v-else @click="changeMode('remindReply')">
            <router-link class="pageLink" to="/remindReply">リマインダ配信</router-link>
          </li>

          <li v-if="mode=='welcomeMessage'">
            <router-link class="pageLink selected-mode" to="/welcomeMessage">友だち追加時設定</router-link>
          </li>
          <li v-else @click="changeMode('welcomeMessage')">
            <router-link class="pageLink" to="/welcomeMessage">友だち追加時設定</router-link>
          </li>

          <li v-if="mode=='richmenu'">
            <router-link class="pageLink selected-mode" to="/richmenu">リッチメニュー</router-link>
          </li>
          <li v-else @click="changeMode('richmenu')">
            <router-link class="pageLink" to="/richmenu">リッチメニュー</router-link>
          </li>

          <li class="category"><i class="material-icons">person</i>マイページ</li>
          <li><a class="pageLink" href="users/edit">個人情報設定</a></li>
          <li><a class="pageLink" rel="nofollow" data-method="delete" href="/users/sign_out">ログアウト</a></li>
        </ul>
      </div>
    </nav>
    <div id="page">
      <router-view/>
    </div>
    <Footer msg="This is common footer rendered by vue's single file components"/>
  </div>
</template>

<script src="./app.js"/>
<style src="./app.css"/>
