import Vue from 'vue/dist/vue.esm'
import VueRouter from 'vue-router'
import App from './app.vue'
import Home from './pages/home.vue'

import axios from 'axios'
import BootstrapVue from 'bootstrap-vue'
import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'
import Chartkick from 'vue-chartkick'
import Chart from 'chart.js'
import animate from 'animate.css'
import Paginate from 'vuejs-paginate'
import * as VueGoogleMaps from 'vue2-google-maps'

axios.defaults.headers.common = {
    'X-Requested-With': 'XMLHttpRequest',
    'X-CSRF-TOKEN' : document.querySelector('meta[name="csrf-token"]').getAttribute('content')
};

Vue.use(BootstrapVue)
Vue.prototype.$https = axios
Vue.use(VueRouter)
Vue.config.productionTip = false
Chartkick.options = {
  colors: ["#b00", "#666"]
}
Vue.use(Chartkick.use(Chart))
Vue.use(animate)
Vue.component('paginate', Paginate)
Vue.use(VueGoogleMaps, {
  load: {
    key: 'AIzaSyDveRX7Bi5rvU26eCLTyB2bGVbsq5Cg4pQ',
    libraries: 'places',
    language: 'ja'
  }
})

const routes = [
  {
    path: '/',
    component: Home
  },
  {
    path: '/friendsList',
    name: "FriendsList",
    component: () => import("./pages/friendsList.vue")
  },
  {
    path: '/allMessages/:searchKeyword',
    name: "AllMessages",
    component: () => import("./pages/allMessages.vue"),
    props: true
  },
  {
    path: '/personalMessages',
    name: "PersonalMessages",
    component: () => import("./pages/personalMessages.vue")
  },
  {
    path: '/dataAnalysis',
    name: "DataAnalysis",
    component: () => import("./pages/dataAnalysis.vue")
  },
  {
    path: '/sendAll',
    name: "SendAll",
    component: () => import("./pages/sendAll.vue")
  },
  {
    path: '/autoReply',
    name: "AutoReply",
    component: () => import("./pages/autoReply.vue")
  },
  {
    path: '/actionTemplate',
    name: "ActionTemplate",
    component: () => import("./pages/actionTemplate.vue")
  },
  {
    path: '/tagManagement',
    name: "TagManagement",
    component: () => import("./pages/tagManagement.vue")
  },
  {
    path: '/remindReply',
    name: "RemindReply",
    component: () => import("./pages/remindReply.vue")
  },
  {
    path: '/welcomeMessage',
    name: "WelcomeMessage",
    component: () => import("./pages/welcomeMessage.vue")
  },
  {
    path: '/richMenu',
    name: "RichMenu",
    component: () => import("./pages/richMenu.vue")
  },
  {
    path: '/adminPage',
    name: "AdminPage",
    component: () => import("./pages/adminPage.vue")
  },
  {
    path: '/membersManage',
    name: "MembersManage",
    component: () => import("./pages/membersManage.vue")
  },
  {
    path: '/personalPage/:id',
    name: "PersonalPage",
    component: () => import("./pages/personalPage.vue"),
    props: true
  },
  {
    path: '/channelManage',
    name: "ChannelManage",
    component: () => import("./pages/channelManage.vue")
  },
];

const router = new VueRouter({
  routes
});

new Vue({
  el: '#app',
  template: '<App/>',
  components: { App },
  router: router
})
