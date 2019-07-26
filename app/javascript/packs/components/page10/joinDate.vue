<template>
  <line-chart :data="joinDate"></line-chart>
</template>
<script async="./">
  import axios from 'axios'
  export default {
    data: function(){
      return {
        //joinDate: [],
        joinJan: 0, joinFeb: 0, joinMar: 0, joinApr: 0, joinMay: 0, joinJun: 0, joinJul: 0, joinAug: 0, joinSep: 0, joinOct: 0, joinNov: 0, joinDec: 0,
        joinDate: [],
      }
    },
    mounted: function(){
      this.fetchJoinDate();
    },
    methods: {
      fetchJoinDate(){
        axios.get('/api/people').then((res) => {
          for(let person of res.data.people){
            let monthNum = person.join_in.substr(5,2);
            monthNum *=1;
            switch(monthNum) {
              case 1:
              this.joinJan++;
              break
              case 2:
              this.joinFeb++;
              break
              case 3:
              this.joinMar++;
              break
              case 4:
              this.joinApr++;
              break
              case 5:
              this.joinMay++;
              break
              case 6:
              this.joinJun++;
              break
              case 7:
              this.joinJul++;
              break
              case 8:
              this.joinAug++;
              break
              case 9:
              this.joinSep++;
              break
              case 10:
              this.joinOct++;
              break
              case 11:
              this.joinNov++;
              break
              case 12:
              this.joinDec++;
              break
            }
          }
          this.joinDate.push({
            "name": "Join in",
            "data": {'Jan': this.joinJan, 'Feb': this.joinFeb, 'Mar': this.joinMar, 'Apr': this.joinApr, 'May': this.joinMay, 'Jun': this.joinJun, 'Jul': this.joinJul, 'Aug': this.joinAug, 'Sep': this.joinSep, 'Oct': this.joinOct, 'Nov': this.joinNov, 'Dec': this.joinDec, }
          })
        })
      }
    }
  }
</script>