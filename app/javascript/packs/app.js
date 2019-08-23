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
      group: ''
    }
  },
  mounted: function(){
    axios.post('/show_current').then((res)=>{
      this.userid = res.data.user.email
      this.group = res.data.user.group
    },(error)=>{
      console.log(error)
    })
  }
}