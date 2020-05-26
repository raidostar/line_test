<template>
  <div class="footer">
    <footer class="sticky-footer bg-white">
      <div class="container my-auto">
        <div class="copyright text-center my-auto">
          <span>Copyright &copy; FullouT 2020</span>
        </div>
      </div>
    </footer>
  </div>
</template>

<script>
  export default {
    name: 'global_footer',
    props: {
      msg: String
    }
  }
</script>

<style scoped>
  .footer{
    height: auto;
  }
</style>