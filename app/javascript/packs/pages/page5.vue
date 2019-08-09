<template>
  <div class="page" id="page5">
    <button @click="show = !show">Toggle Render</button>
    <transition name="slide-fade">
      <p id="twice" v-if="show">hello</p>
    </transition>
    <img :src="src" class="profileImg">
  </div>
</template>

<script>
  export default {
    name: 'toggle',
    data: function(){
      return {
        show: true,
        src: 'https://profile.line-scdn.net/0hFwLyAADjGVhxADOEkbFmD01FFzUGLh8QCWFROlwBQz9UZQtcSzVQbQcJRD1ZZ18MGDUGO1RVRWla'
      }
    }
  }
</script>

<style scoped>
#page5 {
  color: #009d00;
}
.slide-fade-enter-active {
  transition: all .3s ease;
}
.slide-fade-leave-active {
  transition: all .8s cubic-bezier(1.0,0.5,0.8,1.0);
}
.slide-fade-enter, .slide-fade-leave-to {
  transform: translateX(10px);
  opacity: 0;
}
button:focus {
  outline: none;
}
.profileImg {
  width: 40px;
  height: 40px;
  border-radius: 100%;
}
</style>