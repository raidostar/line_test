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
      show: false
    }
  },
  mounted: function(){
    Window.load(alert("hello!"))
  }
}