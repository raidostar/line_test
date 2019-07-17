<template>
  <div class="cover">
    <div class="left name">
      NAME
      <div v-for="person in people" class="personName">{{ person.name }}</div>
    </div>
    <div class="left gender">
      GENDER
      <div v-for="person in people" class="personName">{{ person.gender }}</div>
    </div>
    <div class="left age">
      AGE
      <div v-for="person in people" class="personName">{{ person.age }}</div>
    </div>
    <column-chart :data="ageData" :stacked="true"></column-chart>
  </div>
</template>
<script src="./person.js"></script>
<style>
.name {
  background-color: #ff99cc;
  padding: 1px;
  margin: 1px;
  border: 1;
  border-color: black;
  width: 25em;
}
.gender {
  background-color: #6699ff;
  padding: 1px;
  margin: 1px;
  border: 1px;
  border-color: black;
  width: 25em;
}
.age {
  background-color: #ffffcc;
  padding: 1px;
  margin: 1px;
  border: 1px;
  border-color: black;
  width: 25em;
}
.personName {
  background-color: #fff;
  border: 1;
  border-color: black;
}
</style>