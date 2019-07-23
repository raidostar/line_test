<template>
  <div>
    <input class="notify" @keydown.enter="sendNotify" v-model="notify" :placeholder="place"/>
    <button class="notifyButton" @click="sendNotify">send</button>
  </div>
</template>
<script scoped>
  import axios from 'axios'
  import qs from 'querystring'
  import request from 'request'

  export default {
    name: 'notify',
    data: function(){
      return {
        notify: '',
        place: 'you can send notify here',
        setting: {
          url: 'https://notify-api.line.me/api/notify',
          headers: {
            Authorization: 'Bearer xmFj7d0G95unqtddMopRCLpeFwJ7iuso29LLXaH1q3n',
            'Content-Type': 'application/x-www-form-urlencoded'
          },
          data: qs.stringify({message: 'hello'})
        }
      }
    },
    methods: {
      sendNotify(){
        axios.request(this.setting).then((res) => {
          console.log(res.data)
        }, (error) => {
          console.log(error)
        })
      }
    }
  }
</script>
<style scoped>

</style>