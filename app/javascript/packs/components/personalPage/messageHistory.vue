<template>
  <div class="in-panel" ref="result">
    <div v-show="loading" class="waiting-screen">
      <div class="spinner">
        <div class="bounce1"></div>
        <div class="bounce2"></div>
        <div class="bounce3"></div>
      </div>
    </div>
    <div class="message" v-for="msg in this.messages">
      <div class="chatting-line" v-if="msg.check_status!='answered'&&msg.check_status!='notified'&&msg.check_status!='reminded'&&msg.check_status!='welcome'">
        <div class="balloon-left" v-if="msg.message_type=='text'">
          <span v-html="msg.contents">{{msg.contents}}</span>
        </div>
        <div class="balloon-leftimage" v-else-if="msg.message_type=='stamp'">
          <img class="attachedStamp" :src="getImgUrl(msg.contents)"/>
        </div>
        <div class="balloon-leftimage" v-else-if="msg.message_type=='image'">
          <img class="attachedImg" :src="msg.image.url+''">
        </div>
        <span class="left-time">{{msg.created_at}}</span>
      </div>
      <div v-else>
        <div class="balloon-right" v-if="msg.message_type=='text'">
          <span v-if="msg.check_status=='answered'" v-html="msg.contents">
            {{msg.contents}}
          </span>
          <span v-else v-html="msg.contents" style="color: #ffc107;">
            {{msg.contents}}
          </span>
        </div>
        <div class="balloon-image" v-else-if="msg.message_type=='stamp'">
          <img :src="getImgUrl(msg.contents)" style="width: 10em;"/>
        </div>
        <div class="balloon-image" v-else-if="msg.message_type=='image'">
          <img class="attachedImg" :src="msg.image.url">
        </div>
        <div class="balloon-image" v-else-if="msg.message_type=='carousel'" style="height: max-content;">
          <div class="carousel-box" style="margin-bottom: 1em;">
            <div class="bubble-box" style="height: auto; display: inline-flex;">
              <div v-for="(bubble,index) in bubbles">
                <div class="bubble" style="height: inherit; width: 20.5em;" :style="bubbleChecker(bubble,msg.contents)">
                  <div style="height: 100%;">
                    <div class="result-blocks header-block rounder1">
                      <div class="header-text rounder1" v-html="bubble.header" :style="resultHeaderCSS[index]">
                      </div>
                    </div>
                    <div class="result-blocks hero-block">
                      <div class="carousel-img-area" v-show="bubble.image.url" style="bottom: -1%; display: grid; align-items: center;justify-content: center;">
                        <img class="carousel-img" :src="bubble.image.url">
                      </div>
                    </div>
                    <div class="result-blocks body-block">
                      <div class="body-text" v-html="bubble.body" :style="resultBodyCSS[index]">
                      </div>
                    </div>
                    <div class="result-blocks footer-block" style="line-height: 4.5vh">
                      <div class="footer-text rounder2" v-html="bubble.footer" :style="resultFooterCSS[index]">
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="balloon-image" v-else>
          <GmapMap
          :center="mapConvert(msg.contents)"
          :zoom="12"
          map-type-id="terrain"
          style="width: 16em; height: 16em;"
          >
          <GmapMarker
          :position="mapConvert(msg.contents)"
          :clickable="true"
          :draggable="false"
          />
        </GmapMap>
      </div>
      <span class="right-time">{{msg.created_at}}</span>
    </div>
  </div>
</div>
</template>
<script>
  export default {
    name: 'messageHistory',
    props: {
      messages: Array,
      bubbles: Array,
      resultHeaderCSS: Array,
      resultHeroCSS: Array,
      resultBodyCSS: Array,
      resultFooterCSS: Array,
      getImgUrl: Function,
    },
    data: function(){
      return {
        loading: true,
      }
    },
    methods: {
      mapConvert(contents){
        let tempArr = contents.split("+")
        const tempLength = tempArr[1].length
        tempArr = tempArr[1].substring(6,tempLength-2).split(",")
        tempArr[0] = tempArr[0]*1
        tempArr[1] = tempArr[1]*1
        return {lat: tempArr[0], lng: tempArr[1]}
      },
      bubbleChecker(bubble,contents){
        var temp = contents.split(",")
        for(var id of temp){
          if(bubble.id==id*1){
            return {'display': 'inline-block'}
          }
        }
        this.mouseScroll();
        return {'display':'none'}
      },
      mouseScroll(){
        let height = this.$refs.result.clientHeight
        let scrollTop = this.$refs.result.scrollTop
        let scrollHeight = this.$refs.result.scrollHeight
        scrollTop = scrollHeight - height
        this.$refs.result.scrollTop = scrollTop
        this.$nextTick(function(){
          this.loading = false
        })
      },

    }
  }
</script>
<style scoped>
.in-panel {
  height: 74vh;
  max-height: 100%;
  overflow-y: scroll;
  overflow-x: hidden;
}
.message {
  height: 3em;
  line-height: 3em;
}
.attachedImg {
  width: 18em;
  border-radius: 8px;
  position: initial;
}
.balloon-left {
  display: inline-block;
  position: relative;
  background: #fff;
  height: auto;
  width: max-content;
  max-width: 23em;
  margin: 4px 0px;
  border-radius: 10px;
  padding: 8px 12px;
  z-index: 1;
  float: left;
  word-break: keep-all;
  margin-left: 1em;
  margin-right: 90%;
}
.balloon-left:after {
  content: '';
  position: absolute;
  height: 20px;
  width: 20px;
  z-index: -1;
  bottom: 10px;
  left: -3px;
  top: 5px;
  background: #fff;
  -ms-transform: rotate(45deg); /* IE 9 */
  -webkit-transform: rotate(45deg); /* Chrome, Safari, Opera */
  transform: rotate(45deg);
}
.balloon-right {
  display: inline-block;
  position: relative;
  background: #2c3e50;
  height: auto;
  width: max-content;
  max-width: 50vh;
  margin: 4px 0px;
  border-radius: 10px;
  padding: 8px 12px;
  z-index: 1;
  float: right;
  color: white;
  word-break: keep-all;
  margin-right: 1em;
  margin-left: 90%;
}
.balloon-right:after {
  content: '';
  position: absolute;
  height: 20px;
  width: 20px;
  z-index: -1;
  bottom: 10px;
  right: -3px;
  top: 5px;
  background: #2c3e50;
  -ms-transform: rotate(45deg); /* IE 9 */
  -webkit-transform: rotate(45deg); /* Chrome, Safari, Opera */
  transform: rotate(45deg);
}
.attachedStamp {
  width: 8em;
}
.carousel-box {
  max-width: 62em;
  height: 100%;
  float: left;
  overflow-x: scroll;
  overflow-y: hidden;
}
.balloon-image{
  float: right;
  display: inline-block;
  position: relative;
  height: auto;
  width: max-content;
  /*max-width: 50vh;*/
  margin: 0 auto 10px;
  border-radius: 10px;
  z-index: 3;
  float: right;
  color: white;
  margin-left: 90%;
}
.bubble-box {
  width: max-content;
  height: 100%;
}
.result-blocks {
  margin: 2px 1px;
  border-radius: 8px;
}
.header-block {
  min-height: 16%;
  text-align: left;
}
.hero-block {
  height: 54%;
}
.body-block {
  min-height: 16%;
  text-align: left;
}
.footer-block {
  min-height: 12%;
  text-align: center;
}
.rounder1 {
  border-radius: 8px 8px 0px 0px;
}
.rounder2 {
  border-radius: 8px;
}
.carousel-img-area {
  width: 100%;
  height: 95%;
  position: relative;
  bottom: 100%;
}
.carousel-img {
  max-width: 100%;
  max-height: 100%;
  width: 20em;
}
.left-time {
  color: grey;
  float: left;
  font-size: 10px;
  margin: 0px 10px;
}
.right-time {
  color: grey;
  float: right;
  font-size: 10px;
  margin-bottom: 10px;
}
.balloon-leftimage {
  display: inline-block;
  position: relative;
  height: auto;
  width: max-content;
  margin: 0 auto 10px;
  border-radius: 10px;
  z-index: 1;
  float: left;
  color: white;
  margin-right: 90%;
  margin-left: 1em;
}
</style>