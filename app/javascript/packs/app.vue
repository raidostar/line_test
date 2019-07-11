<template>
  <div id="app">
    <div id="topbar">
      <h3>LINE_TEST</h3>
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
        <li><router-link to="/page9">Page9</router-link></li>
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
h3{
  padding-top: 20px;
}
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 0px;
}
#page {
  width: 85%;
  float: right;
}
#sidebar {
  width: 15%;
  float: left;
  height: 80px;
}
#topbar {
  height: 100px;
  padding: 0px;
  background-color: #00B900;
}
ul {
  list-style: none;
  padding-left: 0px;
}
</style>