<template>
  <div id="twice">
    <button @click="show = !show">Toggle Render</button>
    <transition name="slide-fade">
      <p id="twice" v-if="show">hello</p>
    </transition>
  </div>
</template>

<script>
  export default {
    name: 'toggle',
    data: function(){
      return {
        show: true
      }
    }
  }
</script>

<style scoped lang="scss">
#twice {
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
</style>