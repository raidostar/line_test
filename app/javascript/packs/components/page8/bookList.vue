<template>
  <td >
    {{ book.title }}
  <i @click="$emit('updateBook')" class="material-icons">edit</i>
  <i @click="$emit('deleteBook')" class="material-icons">delete</i>
  </td>
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
<style scoped>
.material-icons {
  font-size: 12px;
}
.material-icons:hover {
  cursor: pointer;
}
</style>