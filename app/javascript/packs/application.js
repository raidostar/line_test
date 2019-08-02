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

import axios from 'axios'
import BootstrapVue from 'bootstrap-vue'
import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'
import Chartkick from 'vue-chartkick'
import Chart from 'chart.js'
import animate from 'animate.css'
import Paginate from 'vuejs-paginate'

axios.defaults.headers.common = {
    'X-Requested-With': 'XMLHttpRequest',
    'X-CSRF-TOKEN' : document.querySelector('meta[name="csrf-token"]').getAttribute('content')
};

Vue.use(BootstrapVue)
Vue.prototype.$https = axios
Vue.use(VueRouter)
Vue.config.productionTip = false
Vue.use(Chartkick.use(Chart))
Vue.use(animate)
Vue.component('paginate', Paginate)

const routes = [
  { path: '/home', component: Page1 },
  { path: '/friendslist', component: Page2 },
  { path: '/page3', component: Page3 },
  { path: '/page4', component: Page4 },
  { path: '/page5', component: Page5 },
  { path: '/page6', component: Page6 },
  { path: '/page7', component: Page7 },
  { path: '/page8', component: Page8 },
  { path: '/page9', component: Page9 },
  { path: '/page10', component: Page10 },
  { path: '/page11', component: Page11 },
  { path: '/page12', component: Page12 },
];

const router = new VueRouter({ routes });

new Vue({
  el: '#app',
  template: '<App/>',
  components: { App },
  router: router
})
