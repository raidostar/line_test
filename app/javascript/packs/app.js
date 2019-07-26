import Header from './components/main/header.vue'
import Footer from './components/main/footer.vue'

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
    document.onscroll = function(e){
      this.position = document.documentElement.scrollTop || document.body.scrollTop;
      //console.log(this.position)
    }
  }
}