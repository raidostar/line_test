import axios from 'axios'
import joinDate from './joinDate.vue'
export default {
  components: {
    joinDate
  },
  data: function(){
    return {
      people: [],
      ageData: [],
      parPage: 10,
      currentPage: 1,
    }
  },
  mounted: function(){
    this.fetchPeople();
  },
  methods: {
    fetchPeople(){
      axios.get('/api/people').then((res)=>{
        console.log(res.data.people)
        this.people = res.data.people
        for (let person of this.people){
          this.ageData.push([person.name, person.age])
        }
      }, (error)=>{
        console.log(error)
      });
    },
    clickCallback(pageNum){
      this.currentPage = Number(pageNum);
    },
  },
  computed: {
    getPeople(){
      let current = this.currentPage * this.parPage;
      let start = current - this.parPage;
      return this.people.slice(start, current);
    },
    getPageCount(){
      return Math.ceil(this.people.length / this.parPage)
    }
  }
}