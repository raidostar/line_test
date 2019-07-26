<template>
  <div id="app">
    <nav id="topbar" :class="{sticky: (position > 0)}">
      <h3>LINE_TEST</h3>
      <a rel="nofollow" data-method="delete" href="/users/sign_out">LOG_OUT</a>
    </nav>
    <nav id="sidebar">
      <div class="side left nav-wrapper container">
        <ul class="hide-on-med-and-down">
          <li><router-link to="/">ページの連結</router-link></li>
          <li><router-link to="/page2">ページの連結</router-link></li>
          <li><router-link to="/page3">入力テスト</router-link></li>
          <li @click="show=!show" style="padding: 0px;"><router-link to="/page4">Component</router-link></li>
          <transition name="flipInOut">
          <li class="sub-page" v-if="show"><router-link to="/page5">Page5</router-link></li>
          </transition>
          <transition name="flipInOut">
          <li class="sub-page" v-if="show"><router-link to="/page6">Page6</router-link></li>
          </transition>
          <transition name="flipInOut">
          <li class="sub-page" v-if="show"><router-link to="/page7">Page7</router-link></li>
          </transition>
          <transition name="flipInOut">
          <li class="sub-page" v-if="show"><router-link to="/page8">Page8</router-link></li>
          </transition>
          <transition name="flipInOut">
          <li class="sub-page" v-if="show"><router-link to="/page9">Page9</router-link></li>
          </transition>
          <transition name="flipInOut">
          <li class="sub-page" v-if="show"><router-link to="/page10">Page10</router-link></li>
          </transition>
          <transition name="flipInOut">
          <li class="sub-page" v-if="show"><router-link to="/page11">Page11</router-link></li>
          </transition>
        </ul>
      </div>
    </nav>
    <div id="page">
      <router-view/>
    </div>
    <Footer msg="This is common footer rendered by vue's single file components"></Footer>
  </div>
</template>

<script src="./app.js"/>
<style src="./whole.css"/>
