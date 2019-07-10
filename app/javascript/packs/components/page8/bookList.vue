<template>
  <span @click="$emit('setBook')">
    {{book.title}}
  </span>
</template>
<script>
  export default {
    props: {
      book: {
        type: Object,
        required: true
      }
    }
  }
</script>