import Vue from 'vue/dist/vue.esm'
import axios from 'axios'

new Vue({
  el: '.container',
  data: {
    allBooks: [],
    bookInfo: {},
    bookInfoBool: false
  },
  mounted: function(){
    this.fetchBooks();
  },
  methods: {
    setBookInfo(id){
      console.log(id)
      axios.get("/api/books/"+id+".json")
      .then(res => {
        console.log(res.data.book)
        this.bookInfo = res.data.book
        this.bookInfoBool = true
        console.log(this.bookInfo.publisher)
      })
    },
    fetchBooks: function(){
      axios.get('/api/books').then((res) => {
          this.allBooks = res.data.books
          //console.log(this.allBooks)
      }, (error) => {
        console.log(error)
      })
    }
  }
})