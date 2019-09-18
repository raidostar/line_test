<template>
  <div id="page13" class="page">
    <div class="inputForm">
      <div>
        <input type="text" name="moji_text" v-model="moji_text">
        <label>moji_text</label>

        <input type="text" name="img_url" v-model="img_url">
        <label>img_url</label>

        <input type="text" name="unicode" v-model="unicode">
        <label>unicode</label>
        <br/>
        <button @click="addEmoji">add emoji</button>
      </div>

    </div>
  </div>
</template>
<script>
  import axios from 'axios'
  export default {
    name: 'emojiAdding',
    data: function(){
      return {
        moji_text: '',
        img_url: '',
        unicode: '',
      }
    },
    mounted: function(){
      this.fetchEmojis();
    },
    methods: {
      fetchEmojis(){
        axios.get('api/emojis').then((res)=>{
          console.log(res.data)
        },(error)=>{
          console.log(error)
        })
      },
      addEmoji(){
        axios.post('api/emojis', {emoji: {moji_text: this.moji_text, img_url: this.img_url, unicode: this.unicode}})
        .then((res)=>{
          alert("emoji added!")
          this.moji_text = ''
          this.unicode = ''
          this.fetchEmojis();
        },(error)=>{
          console.log(error)
        })
      }
    }
  }
</script>
<style scoped>
.inputForm {
  width: 50%;
  margin-left: 30px;
}
</style>