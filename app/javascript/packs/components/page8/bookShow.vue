<template>
  <div>
    <span>{{bookInfo.title}}</span> /
    <span>{{bookInfo.author}}</span> /
    <span>{{bookInfo.publisher}}</span>
  </div>
</template>
<script>
  export default {
    props: {
      bookInfo: {
        type: Object,
        required: true
      }
    }
  }
</script>