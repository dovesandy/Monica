<template>
  <div>
    <div class="tabs">TabsTwo</div>
    <el-row>
      <el-button type="primary" @click="add">加按钮</el-button>
      <el-button type="warning" @click="subtraction">减按钮</el-button>
      <el-button type="success" @click="output">输出按钮</el-button>
    </el-row>
    <!-- <div>name:{{this.$store.state.name}}</div> -->
    <div>tabsData:{{tabsData}}</div>
    <div>name:{{name}}</div>
  </div>
</template>

<script>
import { mapState, mapGetters, mapActions } from "vuex";
export default {
  name: "TabsTwo",
  props: {
    msg: String
  },
  data() {
    return {};
  },
  methods: {
    ...mapActions("tabs", {
      saveTabsData: "saveTabsData"
    }),
    add() {
      this.saveTabsData("5");
    },
    subtraction() {},
    output() {
      // console.info(this.tabsData);
    }
  },
  computed: {
    ...mapState({
      tabsData: state => state.tabs.tabsData
    }),
    ...mapGetters("tabs", {
      name: "getTabsData"
    })
  },
  watch: {}
};
</script>
<style scoped>
</style>
