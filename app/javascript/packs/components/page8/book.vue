<template>
  <div>
    <input class="control" @keydown.enter="createBook" v-model="newBook" :placeholder="message"/>
    <button class="bookButton addButton" v-if="buttonToggle" @click="createBook">
      <i class="material-icons">add_circle_outline</i>
    </button>
    <hr/>
    <div class="searchBar" v-if="buttonToggle">
      <input class="control" @keydown.enter="searchBook" placeholder="search" v-model="search.title_cont"/>
      <button class="bookButton" @click="searchBook"><i class="material-icons">search</i></button><hr/>
    </div>

    <table class="table">
      <tr>
        <th class="title">タイトル</th>
        <th class="author">著者</th>
        <th class="publisher">出版社</th>
        <th class="genre">ジャンル</th>
        <th class="release">リリース</th>
      </tr>
      <tr v-for="book in allBooks">
        <bookList
          class="title"
          :key="book.id"
          :book="book"
          id="'title_of_book_'+book.id"
          @updateBook="updateBook(book.id, book.title)"
          @deleteBook="deleteBook(book.id)"
        />
        <td class="author">{{book.author}}</td>
        <td class="publisher">{{book.publisher}}</td>
        <td class="genre">{{book.genre}}</td>
        <td class="release">{{book.release_at}}</td>
      </tr>
    </table>
    <hr/>
    <bookShow class="row" v-show="bookInfoBool" v-model="bookInfo" :bookInfo="bookInfo"/>
  </div>
</template>
<script src="./book.js"/>
<style scoped src="./book.css"/>
