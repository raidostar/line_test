<template>
  <div>
    <input class="control" @keydown.enter="createBook" v-model="newBook" :placeholder="message"/>
    <button class="bookButton addButton" v-if="buttonToggle" @click="createBook">
      <i class="material-icons">add_circle_outline</i>
    </button><hr/>
    <input class="control" @keydown.enter="searchBook" placeholder="search" v-model="search.title_cont"/>
    <button class="bookButton" @click="searchBook"><i class="material-icons">search</i></button><hr/>
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
<script src="./book.js"></script>
<style scoped>
.control {
  width: 60%;
  margin: 0 auto;
}
.bookButton {
  border-radius: 100%;
  background-color: #fff;
}
.material-icons {
  background-color: #00b900;
  border-radius: 100%;
}
</style>