<template>
  <div class="cover">
    <table>
      <tr>
        <th>状態</th>
        <th>名前</th>
        <th>性別</th>
        <th>年齢</th>
        <th>登録</th>
        <th>解除</th>
      </tr>
      <tr v-for="person in getPeople">
        <td v-if="person.withdraw_at!=null">
          <i class="material-icons" style="background-color: red; box-shadow: 0 0 5px #666;"/>
        </td>
        <td v-else>
          <i v-if="person.block" class="material-icons" style="background-color: yellow; box-shadow: 0 0 5px #666;"/>
          <i v-else class="material-icons" style="background-color: green; box-shadow: 0 0 5px #666;"/>
        </td>
        <td>{{ person.name }}</td>
        <td>{{ person.gender }}</td>
        <td>{{ person.age }}</td>
        <td>{{ person.join_in }}</td>
        <td>{{ person.withdraw_at }}</td>
      </tr>
    </table>
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
    <join-date/>
  </div>
</template>
<script src="./personTable.js"/>
<style scoped src="./personTable.css"/>
