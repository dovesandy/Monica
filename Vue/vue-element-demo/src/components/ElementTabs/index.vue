<template>
  <div>
    <div style="margin-bottom: 20px;">
      <el-button size="small" @click="addTab(editableTabsValue)">add tab</el-button>
    </div>
    <el-tabs v-model="editableTabsValue" type="card" closable @tab-remove="removeTab">
      <el-tab-pane
        v-for="item in editableTabs"
        :key="item.name"
        :label="item.title"
        :name="item.name"
      >
        <component v-bind:is="item.content"></component>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script>
import TabsOne from "@/components/ElementTabs/TabsOne";
import TabsTwo from "@/components/ElementTabs/TabsTwo";
import TabsThree from "@/components/ElementTabs/TabsThree";
export default {
  name: "ElementTabs",
  components: {},
  data() {
    return {
      editableTabsValue: "1",
      editableTabs: [
        {
          title: "Tab 1",
          name: "1",
          content: TabsOne
        },
        {
          title: "Tab 2",
          name: "2",
          content: TabsTwo
        }
      ],
      tabIndex: 2
    };
  },
  methods: {
    addTab(targetName) {
      console.info(targetName);
      let newTabName = ++this.tabIndex + "";
      this.editableTabs.push({
        title: "New Tab",
        name: newTabName,
        content: TabsThree
      });
      this.editableTabsValue = newTabName;
    },
    removeTab(targetName) {
      let tabs = this.editableTabs;
      let activeName = this.editableTabsValue;
      if (activeName === targetName) {
        tabs.forEach((tab, index) => {
          if (tab.name === targetName) {
            let nextTab = tabs[index + 1] || tabs[index - 1];
            if (nextTab) {
              activeName = nextTab.name;
            }
          }
        });
      }

      this.editableTabsValue = activeName;
      this.editableTabs = tabs.filter(tab => tab.name !== targetName);
    }
  }
};
</script>

<style>
.tabs {
  color: #f00;
}
</style>