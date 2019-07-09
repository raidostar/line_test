<template>
  <div>
    <ul>
      <li v-for="item in items">
        {{ item.text }}
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  name: 'testFor',
  data: function(){
    return {
      items: [
        { text: 1 },
        { text: 2 },
        { text: 3 }
      ]
    }
  }
}
</script>