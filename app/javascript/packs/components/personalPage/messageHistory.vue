<template>
  <div class="in-panel">
    <div class="message" v-for="message in this.messages">
      <span>{{message.contents}}</span>
      <span style="float: right;">{{message.created_at}}</span>
    </div>
  </div>
</template>
<script>

  export default {
    name: 'messageHistory',
    props: ['messages']
  }
</script>
<style scoped>
.in-panel {
  height: auto;
  max-height: 100%;
  overflow: scroll;
}
.message {
  height: 3em;
  line-height: 3em;
}
</style>