<template>
  <div>
    <input class="form-control" @keydown.enter="createBook" v-model="newBook" :placeholder="message" />
    <button v-if="buttonToggle" @click="createBook">ADD</button><hr/>
    <div v-for="book in allBooks">
      <bookList :key="book.id" :book="book" id="'title_of_book_'+book.id" @setBook="setBookInfo(book.id)"/>
      <button v-if="buttonToggle" @click="toggleButton(book.title)">修正</button>
      <button v-if="buttonToggle" @click="deleteBook(book.id)">X</button>
      <button v-if="!buttonToggle" @click="updateBook(book.id)">確認</button>
      <button v-if="!buttonToggle" @click="toggleButton">X</button>
    </div><hr/>
    <bookShow class="row" v-show="bookInfoBool" v-model="bookInfo" :bookInfo="bookInfo"/>
  </div>
</template>
<script>
  import bookShow from './bookShow.vue'
  import bookList from './bookList.vue'
  import axios from 'axios'

  export default {
    name: 'thisBook',
    components: {
      bookList,
      bookShow
    },
    data: function(){
      return {
        allBooks: [],
        bookInfo: {},
        bookInfoBool: false,
        newBook: '',
        message: 'Add Your Book',
        buttonToggle: true
      }
    },
    mounted: function(){
      this.fetchBooks();
    },
    methods: {
      toggleButton(title){
        this.buttonToggle = !this.buttonToggle
        if (!this.buttonToggle){
          this.message = title
        } else {
          this.newBook = ''
          this.message = 'Add Your Book'
        }
      },
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
      },
      updateBook: function(id){
        if(!this.newBook) return;

        axios.put("/api/books/"+id+".json", { book: { title: this.newBook } }).
        then(res => {
          this.fetchBooks();
          this.toggleButton();
        }, (error) => {
          console.log(error)
        })
      },
      deleteBook: function(id){
        axios.delete("/api/books/"+id+".json")
        .then(res =>{
          alert("delete success!");
          this.fetchBooks();
        }, (error) => {
          console.log(error)
        })
      }
    }
  }
</script>