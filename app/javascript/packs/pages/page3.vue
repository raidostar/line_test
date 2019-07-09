<template>
  <div id="page3">
    <h1>My Todo App!</h1>
    <TodoList/>
  </div>
</template>

<script>
  import TodoList from '../components/page3/todoList.vue'

  export default {
    components: {
      TodoList
    }
  }
</script>

<style scoped lang="scss">
  @import '../components/page3/variables.scss';

  *, *::before, *::after {
    box-sizing: border-box;
  }

  #page3 {
    max-width: 75%;
    margin: 0 auto;
    line-height: 1.4;
    font-family: 'Avenir', Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    color: $vue-blue;
  }

  h1 {
    text-align: center;
  }
</style>