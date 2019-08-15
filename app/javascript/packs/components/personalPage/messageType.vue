<template>
  <div class="in-panel">
    <pie-chart :data="messageType" :colors="['#ff0000', '#000077']"/>
  </div>
</template>
<script>
  export default {
    name: 'messageType',
    props: ['messageType']
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