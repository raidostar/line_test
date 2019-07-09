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

import axios from 'axios'
import BootstrapVue from 'bootstrap-vue'
import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'

Vue.use(BootstrapVue)
Vue.prototype.$http = axios
Vue.use(VueRouter)
Vue.config.productionTip = false

const routes = [
  { path: '/', component: Page1 },
  { path: '/page2', component: Page2 },
  { path: '/page3', component: Page3 },
  { path: '/page4', component: Page4 },
  { path: '/page5', component: Page5 },
  { path: '/page6', component: Page6 },
  { path: '/page7', component: Page7 },
  { path: '/page8', component: Page8 }
];

const router = new VueRouter({ routes });

new Vue({
  el: '#app',
  template: '<App/>',
  components: { App },
  router: router
})
