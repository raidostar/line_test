<template>
  <div class="page" id="page12">
    <input
      class="line"
      type="text"
      placeholder="input the number of line you wanna see in a page"
      v-model="line"
      @click="changeLine"
      @keydown.enter="changeLine"
    >
    <ul class="list">
      <li v-for="item in getItems">
        {{ item }}
      </li>
    </ul>
    <paginate
    :page-count="getPageCount"
    :page-range="3"
    :margin-pages="2"
    :click-handler="clickCallback"
    :prev-text="'Prev'"
    :next-text="'Next'"
    :container-class="'pagination'"
    :page-class="'page-item'"
    >
    </paginate>
  </div>
</template>
<script>
  export default {
    data(){
      return {
        parPage: 30,
        currentPage: 1,
        items: [],
        line: 1
      }
    },
    mounted: function(){
      for(var i=1; i<=110; i++){
        this.items.push('item-'+i);
      }
      console.log(this.viewChange)
    },
    methods: {
      clickCallback(pageNum){
        this.currentPage = Number(pageNum);
      },
      changeLine(){
        console.log(typeof(this.line))
        this.line *=1;
        if (typeof(this.line)=='number')
        this.parPage = this.line
      }
    },
    computed: {
      getItems(){
        let current = this.currentPage * this.parPage;
        let start = current - this.parPage;
        return this.items.slice(start, current);
      },
      getPageCount(){
        return Math.ceil(this.items.length / this.parPage)
      }
    }
  }
</script>
<style scoped>
#page12 {
  padding-top: 5em;
  height: 20em;
}
li:active{
  text-decoration: none;
}
a {
  width: 10em;
}
a:active {
  text-decoration: none;
}
a:hover {
  text-decoration: none;
}
#selectArea {
  padding-top: 100px;
  height: 20em;
  width: 20em;
}
input.line {
  width: 40%;
  text-align: center;
}
</style>