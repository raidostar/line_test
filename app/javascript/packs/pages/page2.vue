<template>
  <div class="page">
    <h1>{{ msg }}</h1>
    <div class="message">
      <h3>app/javascript/packs/assetsのロゴ</h3>
      これはページ2です。<br>
      <div class="cat_image" /><br>
      この中にスタイルをまとめて書いてね<br>
    </div>
    <router-link to="/">前のページへ</router-link>
  </div>
</template>

<script>
  export default {
    name: 'global_footer',
    props: {
      msg: "ページ1"
    }
  }
</script>

<style scoped lang="scss">
  .footer{
    background: aliceblue;
  }
  .message{
    margin: 0.2em;
    margin: 1em;
    padding: 1em;
    background: #EFEFEF;
  }
</style>