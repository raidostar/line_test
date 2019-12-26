import Vue from 'vue/dist/vue.esm'
import VueRouter from 'vue-router'
import App from './app.vue'

import Home from './pages/home.vue'
import FriendsList from './pages/friendsList.vue'
import AllMessages from './pages/allMessages.vue'
import PersonalMessages from './pages/personalMessages.vue'
import DataAnalysis from './pages/dataAnalysis.vue'
import SendAll from './pages/sendAll.vue'
import AutoReply from './pages/autoReply.vue'
import ActionTemplate from './pages/actionTemplate.vue'
import TagManagement from './pages/tagManagement.vue'
import RemindReply from './pages/remindReply.vue'
import WelcomeMessage from './pages/welcomeMessage.vue'
import RichMenu from './pages/richMenu.vue'
import AdminPage from './pages/adminPage.vue'
import MembersManage from './pages/membersManage.vue'
import PersonalPage from './pages/personalPage.vue'
import ChannelManage from './pages/channelManage.vue'

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
  { path: '/', component: Home },
  { path: '/friendsList', component: FriendsList },
  { path: '/allMessages/:searchKeyword', component: AllMessages, props: true},
  { path: '/personalMessages', component: PersonalMessages },
  { path: '/dataAnalysis', component: DataAnalysis },
  { path: '/sendAll', component: SendAll },
  { path: '/autoReply', component: AutoReply },
  { path: '/actionTemplate', component: ActionTemplate },
  { path: '/tagManagement', component: TagManagement },
  { path: '/remindReply', component: RemindReply },
  { path: '/welcomeMessage', component: WelcomeMessage },
  { path: '/richMenu', component: RichMenu },
  { path: '/adminPage', component: AdminPage },
  { path: '/membersManage', component: MembersManage},
  { path: '/personalPage/:id', component: PersonalPage, props: true},
  { path: '/channelManage', component: ChannelManage},
];

const router = new VueRouter({ routes });

new Vue({
  el: '#app',
  template: '<App/>',
  components: { App },
  router: router
})
