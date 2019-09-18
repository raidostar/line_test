<template>
  <div class="in-panel">
    <div class="test">
      this is message response!!
    </div>
    <div class="test">
      this is message response!!
    </div>
    <div class="test">
      this is message response!!
    </div>
    <div class="test">
      this is message response!!
    </div>
    <div class="test">
      this is message response!!
    </div>
  </div>
</template>
<script>
  import axios from 'axios'
  export default {
    name: 'responseTime',
    mounted: function(){
      axios.post('/number_of_monthly').then((res)=>{
        console.log(res.data)
      },(error)=>{
        console.log(error)
      })
    }
  }
</script>
<style scoped>
.test {
  height: 10em;
}
.in-panel {
  height: 33em;
  max-height: 100%;
  overflow: scroll;
}
</style>