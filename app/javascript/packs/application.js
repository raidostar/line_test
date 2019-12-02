import Vue from 'vue/dist/vue.esm'
import VueRouter from 'vue-router'
import App from './app.vue'

import Page1 from './pages/page1.vue'
import Page2 from './pages/page2.vue'
import Page3 from './pages/page3.vue'
import Page4 from './pages/page4.vue'
import Page5 from './pages/page5.vue'
import Page6 from './pages/page6.vue'
import Page7 from './pages/page7.vue'
import Page8 from './pages/page8.vue'
import Page9 from './pages/page9.vue'
import Page10 from './pages/page10.vue'
import Page11 from './pages/page11.vue'
import Page12 from './pages/page12.vue'
import Page13 from './pages/page13.vue'
import personalPage from './pages/personalPage.vue'

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
  { path: '/', component: Page1 },
  { path: '/friendslist', component: Page2 },
  { path: '/allMessages', component: Page3 },
  { path: '/personalMessages', component: Page4 },
  { path: '/dataAnalysis', component: Page5 },
  { path: '/sendAll', component: Page6 },
  { path: '/autoReply', component: Page7 },
  { path: '/template', component: Page8 },
  { path: '/tagManagement', component: Page9 },
  { path: '/remindReply', component: Page10 },
  { path: '/welcomeMessage', component: Page11 },
  { path: '/richmenu', component: Page12 },
  { path: '/page13', component: Page13 },
  { path: '/personalPage/:id', component: personalPage, props: true},
];

const router = new VueRouter({ routes });

new Vue({
  el: '#app',
  template: '<App/>',
  components: { App },
  router: router
})
