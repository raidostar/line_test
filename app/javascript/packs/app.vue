<template>
  <div id="app">
    <nav id="topbar" :class="{sticky: (position > 0)}">
      <h3>LINE_MANAGER_FOR_{{group}}
        <a class="loginOut" rel="nofollow" data-method="delete" href="/users/sign_out">
          {{userid}}
        </a>
      </h3>
    </nav>
    <nav id="sidebar">
      <div class="side left nav-wrapper container">
        <ul class="hide-on-med-and-down">
          <li><router-link class="pageLink home" to="/">
            <i class="material-icons">home</i>
            ホーム
          </router-link></li>
          <li class="category">
            <i class="material-icons">format_align_justify</i>
            1対1のトーク
          </li>
          <li><router-link class="pageLink" to="/friendslist">友達リスト</router-link></li>
          <li><router-link class="pageLink" to="/page3">トーク一覧</router-link></li>
          <li><router-link class="pageLink" to="/page4">個別トーク</router-link></li>
          <li class="category">
            <i class="material-icons">email</i>
            メッセージ
          </li>
          <li><router-link class="pageLink" to="/page5">シナリオ配信</router-link></li>
          <li><router-link class="pageLink" to="/page6">一斉配信</router-link></li>
          <li><router-link class="pageLink" to="/page7">自動応答</router-link></li>
          <li><router-link class="pageLink" to="/page8">テンプレート</router-link></li>
          <li><router-link class="pageLink" to="/page9">回答フォーム</router-link></li>
          <li><router-link class="pageLink" to="/page10">リマインダ配信</router-link></li>
          <li><router-link class="pageLink" to="/page11">友だち追加時設定</router-link></li>
          <li><router-link class="pageLink" to="/page12">アクション管理</router-link></li>
          <li class="category">
            <i class="material-icons">person</i>
            マイページ
          </li>
          <li><router-link class="pageLink" to="/page13">個人情報設定</router-link></li>
          <li>
            <a class="pageLink" rel="nofollow" data-method="delete" href="/users/sign_out">
              ログアウト
            </a>
          </li>
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
