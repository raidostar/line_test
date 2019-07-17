import axios from 'axios'
  export default {
    data: function(){
      return {
        people: [],
        ageData: []
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
      }
    }
  }