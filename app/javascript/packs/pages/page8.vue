<template>
  <div class="row">

    <div class="col s4 m6">
      <div class="card">

      </div>
    </div>

  </div>
</template>

<script>
  import axios from 'axios'

  export default {
    name: 'bookInfo',
    data: function(){
      return {
        bookInfo: {}
      }
    },
    methods: {
      setBookInfo(id){
        axios.get('api/books/#{id}.json')
        .then(res => {
          this.bookInfo = res.data
        })
      }
    }
  }
</script>
