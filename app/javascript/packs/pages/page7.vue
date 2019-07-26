<template>
  <div class="page" id="page7">
    <p id="message">{{ message }}</p>
    <input v-model="message">
  </div>
</template>

<script>
  export default {
    name: 'pracVmodel',
    data: function(){
      return {
        message: 'Hello'
      }
    }
  }
</script>

<style scoped lang="scss">
  #message {
    color: red;
  }
</style>