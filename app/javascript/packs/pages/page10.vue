<template>
  <div class="page" id="page10">
    <person-table/>
  </div>
</template>
<script>
  import personTable from '../components/page10/personTable.vue'
  export default {
    components: {
      personTable
    }
  }
</script>
<style lang="scss">
  #page10 {
    padding-top: 40px;
  }
</style>