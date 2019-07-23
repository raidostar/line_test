<template>
  <div id="page8">
    <h3>Book登録テスト</h3>
    <meta name="csrf-token" content="F6dek0xG3Kl/8fc8wlAdAdwWNgBhJ/O8da3ziVQG5y9yOxO7QUS8QVbro9+pLYF9/+qkHXQtrSwIcUteffGd1A==" />
    <book-test/>
  </div>
</template>
<script>
  import bookTest from '../components/page8/book.vue'
  export default {
    components: {
      bookTest
    }
  }
</script>
<style>
  button,
  button::after {
    -webkit-transition: all 0.3s;
    -moz-transition: all 0.3s;
    -o-transition: all 0.3s;
    transition: all 0.3s;
  }
  button {
    border: 3px solid #fff;
    border-radius: 5px;
    background-color: #00b900;
    color: #fff;
    font-weight: bold;
    position: relative;
    text-transform: uppercase;
  }
  button::before,
  button::after {
    height: 0;
    left: 50%;
    top: 50%;
    width: 0;
  }
  button:hover:after {
    color: #2ecc71;
    height: 100%;
    left: 0;
    top: 0;
    width: 100%;
  }
</style>