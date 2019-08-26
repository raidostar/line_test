<template>
  <div id="clock">
    <p class="date" v-text="date"></p>
    <p class="time" v-text="time"></p>
  </div>
</template>
<script>
  export default {
    data: function(){
      return {
        date: '',
        time: '',
        zero: '',
        week: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'],
        intervalId: undefined
      }
    },
    mounted: function(){
      this.$options.interval=setInterval(this.updateTime, 1000);
    },
    beforeDestroy: function(){
      clearInterval(this.$options.interval);
    },
    methods: {
      updateTime(){
        let cd = new Date();
        this.time = this.zeroPadding(cd.getHours(), 2) + ':' + this.zeroPadding(cd.getMinutes(), 2) + ':' + this.zeroPadding(cd.getSeconds(), 2);
        console.log("run?")
        this.date = this.zeroPadding(cd.getFullYear(), 4) + '-' + this.zeroPadding(cd.getMonth()+1, 2) + '-' + this.zeroPadding(cd.getDate(), 2) + ' ' +this.week[cd.getDay()];
      },
      zeroPadding(num, digit){
        for(let i=0; i<digit; i++){
          this.zero += 0
        }
        return (this.zero + num).slice(-digit)
      }
    }
  }
</script>
<style lang="css">
p {
  margin: 0;
  padding: 0;
}
#clock {
  padding-top: 100px;
  height: 100%;
  width: 100%;
  background: #0f3854;
  background: radial-gradient(ellipse at center,  #0a2e38  0%, #000000 70%);
  background-size: 100%;
  font-family: 'Share Tech Mono', monospace;
  color: #ffffff;
  text-align: center;
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  color: #daf6ff;
  text-shadow: 0 0 20px rgba(10, 175, 230, 1),  0 0 20px rgba(10, 175, 230, 0);

}
.time {
  letter-spacing: 0.05em;
  font-size: 80px;
  padding: 5px 0;
}
.date {
  letter-spacing: 0.1em;
  font-size: 24px;
}
.text {
  letter-spacing: 0.1em;
  font-size: 12px;
  padding: 20px 0 0;
}
</style>