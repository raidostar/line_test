<template>
  <div id="app">
    <p>{{ total }}</p>
    <button-counter v-on:increment="incrementTotal"></button-counter>
    <button-counter v-on:increment="incrementTotal"></button-counter>
    <button-counter v-on:increment="incrementTotal"></button-counter>
  </div>
</template>

<script>
  import buttonCounter from '../components/page4/buttonCounter'
  export default {
    name: 'page4',
    components: {
      buttonCounter
    },
    data: function(){
      return {
        total: 0
      }
    },
    methods: {
      incrementTotal: function(){
        this.total += 1
      }
    }
  }
</script>
