<template>
  <div class="page" id="page6">
    <p class="lineArea" v-for="message in allMessages">
      <span>{{ message.contents }}</span>
    </p>
    <br/>
    <div class="imageArea">
      <img v-show="uploadedImage" :src="uploadedImage">
      <label class="input-item__label">
        <input type="file" v-on:change="onFileChange">
      </label>
    </div>
    <div class="inputArea">
      <textarea type="text" v-model="newMessage" placeholder="send a Line_Notify here" @keydown="keyListener"/>
      <div class="send">
        <button @click="insertMessage">SEND</button>
      </div>
    </div>
  </div>
</template>

<script>
  import axios from 'axios'

  export default {
    name: 'page6',
    data(){
      return {
        allMessages: [],
        result: '',
        newMessage: '',
        uploadedImage: '',
      }
    },
    mounted: function(){
      this.fetchMessages()
    },
    methods: {
      fetchMessages(){
        axios.get('/api/messages').then((res) => {
          console.log(res.data.messages)
          this.allMessages=res.data.messages
        }, (error) => {
          console.log(error)
        })
      },
      keyListener(event){
        if(event.keyCode==13){
          if(!event.shiftKey){
            event.preventDefault();
            this.insertMessage();
          }
        }
      },
      insertMessage(){
        if (!this.newMessage) return;

        axios.post('/api/messages',
          { message: { sender: 'FullouT', receiver: 'User', contents: this.newMessage, image_url: this.uploadedImage}})
        .then((res) => {
          this.newMessage = '';
          this.fetchMessages();
        }, (error) => {
          console.log(error)
        })
      },
      onFileChange(e){
        let files = e.target.files || e.dataTransfer.files;
        this.createImage(files[0]);
      },
      createImage(file){
        let reader = new FileReader();

        reader.onload = (e) => {
          this.uploadedImage = e.target.result;
          //console.log('uploadedImage'+this.uploadedImage)
        }
        reader.readAsDataURL(file);
        console.log(typeof(this.uploadedImage))
      }
    }
  }
</script>
<style scoped>
.inputArea {
  width: 100%;
  float: left;
  padding-left: 3em;
}
textarea {
  width: 75%;
  height: auto;
}
.lineArea {
  white-space: pre-line;
  background-color: rgba(255, 255, 128, .5);
  height: 3em;
  text-align: left;
  padding-left: 15px;
}
.send {
  float: right;
  padding-right: 3em;
}
label > input {
  display: none;
}

label {
  border: solid 1px #888;
}

label::after {
  content: 'ファイル追加';
  font-size: 1rem;
  color: #888;
  padding-left: 5px;
  padding-right: 5px;
}
</style>