<template>
  <div class="in-panel">
    <div class="message" v-for="msg in this.messages">
      <div class="chatting-line" v-if="msg.check_status!='answered'">
        <div class="balloon-left">
          <span v-if="msg.message_type=='text'" v-html="msg.contents">{{msg.contents}}</span>
          <span v-else-if="msg.message_type=='stamp'"><img class="attachedStamp" :src="msg.contents"/></span>
          <span v-else-if="msg.message_type=='image'"><img class="attachedImg" :src="msg.image.url+''"></span>
          <span v-else>
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
        </span>
      </div>
    </div>
    <div class="balloon-right" v-if="msg.check_status=='answered'">
      <span v-if="msg.message_type=='text'" v-html="msg.contents">{{msg.contents}}</span>
      <span v-else-if="msg.message_type=='stamp'"><img class="attachedStamp" :src="msg.contents"/></span>
      <span v-else-if="msg.message_type=='image'"><img class="attachedImg" :src="msg.image.url+''"></span>
      <span v-else>
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
    </span>
  </div>
</div>
</div>
</template>
<script>
  export default {
    name: 'messageHistory',
    props: ['messages'],
    methods: {
      mapConvert(contents){
        let tempArr = contents.split("+")
        const tempLength = tempArr[1].length
        tempArr = tempArr[1].substring(6,tempLength-2).split(",")
        tempArr[0] = tempArr[0]*1
        tempArr[1] = tempArr[1]*1
        return {lat: tempArr[0], lng: tempArr[1]}
      },
    }
  }
</script>
<style scoped>
.in-panel {
  height: auto;
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
  z-index: 3;
  float: left;
  word-break: keep-all;
  margin-left: 1em;
  margin-right: 50%;
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
  z-index: 3;
  float: right;
  color: white;
  word-break: keep-all;
  margin-right: 1em;
  margin-left: 50%;
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
</style>