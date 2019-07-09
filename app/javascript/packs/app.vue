<template>
  <div id="app">
    <div id="topbar">
      <i class="fas fa-comments fa-2x text-gray-300"></i>
    </div>
    <div id="sidebar">
      <ul>
        <li><router-link to="/">Page1</router-link></li>
        <li><router-link to="/page2">Page2</router-link></li>
        <li><router-link to="/page3">Page3</router-link></li>
        <li><router-link to="/page4">Page4</router-link></li>
        <li><router-link to="/page5">Page5</router-link></li>
        <li><router-link to="/page6">Page6</router-link></li>
        <li><router-link to="/page7">Page7</router-link></li>
        <li><router-link to="/page8">Page8</router-link></li>
      </ul>
    </div>
    <div id="page">
      <router-view/>
    </div>
    <Footer msg="This is common footer rendered by vue's single file components"></Footer>
  </div>
</template>

<script>
  import Header from './components/main/header.vue'
  import Footer from './components/main/footer.vue'

  export default {
    name: 'MyApp',
    props: {
      msg: String
    },
    components: {
      Header,Footer
    }
  }
</script>

<style>
  #app {
    font-family: 'Avenir', Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    text-align: center;
    color: #2c3e50;
    margin-top: 60px;
  }
  #page {
    width: 85%;
    float: right;
  }
  #sidebar {
    width: 15%;
    float: left;
    height: 80%;
  }
  #topbar {
    height: 20px;
    padding: 0px;
    background-color: #00B900;
  }
  ul {
    list-style: none;
    padding-left: 0px;
  }
</style>