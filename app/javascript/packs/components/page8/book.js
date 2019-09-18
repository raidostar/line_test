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
      buttonToggle: true,
      search: {title_cont: ''}
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
      axios.get("/api/books/"+id+".json")
      .then(res => {
        this.bookInfo = res.data.book
        this.bookInfoBool = true
      })
    },
    searchBook(){
      if(this.search.title_cont.length==0) {
        this.fetchBooks();
      } else {
        let searchResult = []
        for(let book of this.allBooks){
          if(book.title.search(this.search.title_cont)>-1){
            searchResult.push(book)
          }
        }
        this.allBooks = searchResult
      }
    },
    fetchBooks(){
        axios.get('/api/books').then((res) => {
          this.allBooks = res.data.books
        }, (error) => {
          console.log(error)
        })
    },
    createBook(){
      if(!this.newBook) return;

      axios.post('/api/books', { book: { title: this.newBook } })
      .then((res) => {
        this.fetchBooks();
        this.newBook = ''
      }, (error) => {
        console.log(error)
      })
    },
    updateBook(id,title){
      this.toggleButton(title);
      if(!this.newBook) return;

      axios.put("/api/books/"+id+".json", { book: { title: this.newBook } }).
      then(res => {
        this.fetchBooks();
        this.toggleButton();
      }, (error) => {
        console.log(error)
      })
    },
    deleteBook(id){
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