<template>
  <div>
    <pie-chart :data="genderData" :colors="['#ff0000', '#000077']"/>
    <column-chart :data="ageData"/>
  </div>
</template>

<script>
  import axios from 'axios'
  export default {
    data: function(){
      return {
        genderData: [],
        ageData: [],
        maleNum: 0,
        femaleNum: 0,
      }
    },
    mounted: function(){
      this.fetchPeople();
    },
    methods: {
      fetchPeople(){
        axios.get('/api/people').then((res) =>{
          this.allPeople = res.data.people
          for (let person of this.allPeople){
            this.ageData.push([person.name, person.age])
            if (person.gender == 'Male') this.maleNum++;
            else this.femaleNum++;
          }
          this.genderData.push(['Male', this.maleNum], ['Female', this.femaleNum])
        }, (error) => {
          console.log(error)
        })
      }
    }
  }
</script>
