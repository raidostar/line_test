<template>
  <div class="page" id="page12">
    <div class="col-left">
      <div class="richmenu-list">Richmenu List</div>
      <div class="richmenu-list action-list">Action List</div>
    </div>
    <div class="col-right">
      <div class="richmenu-image" ondragstart="return false" ref="richmenu"
      @mousedown="mouseDown" @mousemove="mouseTrack" @mouseup="mouseUp" @mouseout="mouseOut">
        richmenu image
        <div class="rich-image" >
          <label class="add-label" title="イメージ追加">
            <i class="material-icons add-rich-image" v-if="!uploadedImage">add</i>
            <input type="file" @change="onFileChange" class="imageBtn" ref="hero" accept="img/*">
          </label>
          <div class="richmenu-img-area" v-show="uploadedImage">
            <img class="richmenu-img" :src="uploadedImage">
          </div>
        </div>
        <div v-show="dragStart" class="selected-range" ref="selectedRange"></div>
        <div v-show="dragStart" class="original-point" ref="firstDot"></div>
        <div v-show="dragStart" class="original-point" ref="secondDot"></div>
        <div v-show="dragStart" class="original-point" ref="thirdDot"></div>
        <div v-show="dragStart" class="original-point" ref="fourthDot"></div>
      </div>
      <div class="mouse-location">
        json영역으로 해야겠다
      </div>
    </div>
  </div>
</template>
<script>
  import axios from 'axios'
  export default {
    name: 'Richmenu',
    data: function(){
      return {
        xSpot: '',
        ySpot: '',
        areaWidth: '',
        areaHeight: '',
        dragStart: false,
        dragEnd: false,
        imageFile: null,
        uploadedImage: '',
      }
    },
    mounted: function(){

    },
    methods: {
      mouseDown(e){
        console.log(this.$refs.firstDot.offsetTop)
        console.log(this.$refs.firstDot.offsetLeft)
        this.dragStart = true
        this.dragEnd = false
        this.xSpot = e.clientX - 724
        this.ySpot = e.clientY - 58
        this.$refs.firstDot.style.background = "red"
        this.$refs.firstDot.style.top = this.ySpot+"px"
        this.$refs.firstDot.style.left = this.xSpot+"px"
        this.$refs.richmenu.style.cursor = "crosshair"
      },
      mouseTrack(e){
        var baseX = this.xSpot
        var baseY = this.ySpot
        var xAfter = e.clientX - 724
        var yAfter = e.clientY - 58
        var width = xAfter - this.xSpot
        var height = yAfter - this.ySpot
        if(this.dragStart&&!this.dragEnd){
          this.$refs.secondDot.style.left = (xAfter-width)+"px"
          this.$refs.secondDot.style.top = yAfter+"px"

          this.$refs.thirdDot.style.left = xAfter+"px"
          this.$refs.thirdDot.style.top = yAfter+"px"

          this.$refs.fourthDot.style.left = xAfter+"px"
          this.$refs.fourthDot.style.top = (yAfter-height)+"px"
          if(width<0){
            baseX = xAfter
            width = width*(-1)
          }
          if(height<0){
            baseY = yAfter
            height = height*(-1)
          }

          this.$refs.selectedRange.style.left = baseX+"px"
          this.$refs.selectedRange.style.top = baseY+"px"
          this.$refs.selectedRange.style.width = (width+8)+"px"
          this.$refs.selectedRange.style.height = (height+8)+"px"

        }
        // console.log(e.clientX)
        // console.log(e.clientY)
      },
      mouseUp(e){
        this.dragEnd = true
        this.$refs.firstDot.style.background = "white"
        this.$refs.richmenu.style.cursor = "default"
        var xBefore = this.xSpot
        var yBefore = this.ySpot
        var xAfter = e.clientX-724
        var yAfter = e.clientY-58

        var areaWidth = xAfter - xBefore
        var areaHeight = yAfter - yBefore

        if(areaWidth>=0){
          this.areaWidth = areaWidth
        } else {
          this.xSpot = xAfter
          this.areaWidth = areaWidth*(-1)
        }
        if(areaHeight>=0){
          this.areaHeight = areaHeight
        } else {
          this.ySpot = yAfter
          this.areaHeight = areaHeight*(-1)
        }
        console.log("x:"+this.xSpot)
        console.log("y:"+this.ySpot)
        console.log("width:"+this.areaWidth)
        console.log("height:"+this.areaHeight)
      },
      mouseOut(e){
        // console.log("x:"+e.clientX)
        // console.log("y:"+e.clientY)
      },
      onFileChange(e){
        let files = e.target.files || e.dataTransfer.files;
        this.imageFile = files[0]
        this.createImage(files[0]);
      },
      createImage(file){
        let reader = new FileReader();
        let vm = this
        reader.onload = (e) => {
          this.uploadedImage = e.target.result;
        }
        reader.readAsDataURL(file);
      }
    }
  }
</script>
<style scoped src="../components/page12/page12.css"/>