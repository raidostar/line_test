<template>
  <line-chart :data="joinDate"></line-chart>
</template>
<script async="./">
  import axios from 'axios'
  export default {
    data: function(){
      return {
        joinDate: [],
        Jan: 0, Feb: 0, Mar: 0, Apr: 0, May: 0, Jun: 0, Jul: 0, Aug: 0, Sep: 0, Oct: 0, Nov: 0, Dec: 0,
        // joinDate: [['Jan', 0],['Feb', 0],['Mar', 0],['Apr', 0],['May', 0],['Jun', 0],['Jul', 0],['Aug', 0],['Sep', 0],['Otc', 0],['Nov', 0],['Dec', 0]]
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
                this.Jan++;
              break
              case 2:
                this.Feb++;
              break
              case 3:
                this.Mar++;
              break
              case 4:
                this.Apr++;
              break
              case 5:
                this.May++;
              break
              case 6:
                this.Jun++;
              break
              case 7:
                this.Jul++;
              break
              case 8:
                this.Aug++;
              break
              case 9:
                this.Sep++;
              break
              case 10:
                this.Oct++;
              break
              case 11:
                this.Nov++;
              break
              case 12:
                this.Dec++;
              break
            }
          }
          this.joinDate.push(['Jan', this.Jan], ['Feb', this.Feb], ['Mar', this.Mar], ['Apr', this.Apr], ['May', this.May], ['Jun', this.Jun], ['Jul', this.Jul], ['Aug', this.Aug], ['Sep', this.Sep], ['Oct', this.Oct], ['Nov', this.Nov], ['Dec', this.Dec])
        })
      }
    }
  }
</script>