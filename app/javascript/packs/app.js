import Header from './components/main/header.vue'
import Footer from './components/main/footer.vue'
import axios from 'axios'

export default {
  name: 'MyApp',
  props: {
    msg: String
  },
  components: {
    Header,Footer
  },
  data: function(){
    return {
      position: undefined,
      show: false,
      userid: '',
      group: '',
      loading: true,
      mode: '',
      status: '',
    }
  },
  mounted: function(){
    this.sendMode();
    axios.post('/show_current').then((res)=>{
      this.userid = res.data.user.email
      this.group = res.data.user.group
      this.status = res.data.user.status
    },(error)=>{
      console.log(error)
    })
  },
  methods: {
    sendMode(){
      var url = window.location.href
      var mode = url.substr(24,url.length)
      this.changeMode(mode);
    },
    changeMode(mode){
      this.mode = mode
    }
  }
}