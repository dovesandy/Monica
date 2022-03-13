<template>
  <div>
    <div class="tabs">TabsOne</div>
    <el-row>
      <el-button type="primary" @click="add">加按钮</el-button>
      <el-button type="warning" @click="subtraction">减按钮</el-button>
      <el-button type="success" @click="output">输出按钮</el-button>
    </el-row>
    <!-- <div>name:{{this.$store.state.name}}</div> -->
    <div>name:{{name}}</div>
    <div>getUserName:{{getUserName}}</div>
  </div>
</template>

<script>
import { mapState, mapMutations, mapActions, mapGetters } from "vuex";
export default {
  name: "TabsOne",
  props: {
    msg: String
  },
  data() {
    return {};
  },
  methods: {
    ...mapMutations(["setName"]),
    ...mapActions(["saveName"]),
    add() {
      // this.$store.commit("setName", "zhouqiao");
      // this.setName("zhouqiao");
      // this.$store.dispatch("saveName", "zhouqiao");
      this.saveName("zhouqiao");
    },
    subtraction() {},
    output() {
      // console.info(this.tabsData);
    }
  },
  computed: {
    ...mapState(["name"]),
    ...mapGetters(["getUserName"])
  },
  watch: {}
};
</script>
<style scoped>
</style>
