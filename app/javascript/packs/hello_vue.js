import Vue from 'vue/dist/vue.esm'
import axios from 'axios'

axios.defaults.headers.common = {
    'X-Requested-With': 'XMLHttpRequest',
    'X-CSRF-TOKEN' : document.querySelector('meta[name="csrf-token"]').getAttribute('content')
};

new Vue({
  el: '.container',
  data: {
    allBooks: [],
    bookInfo: {},
    bookInfoBool: false,
    newBook: ''
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
    },
    createBook: function(){
      if(!this.newBook) return;

      axios.post('/api/books', { book: { title: this.newBook } })
      .then((res) => {
        this.fetchBooks();
        this.newBook = ''
      }, (error) => {
        console.log(error)
      })
    }
  }
})