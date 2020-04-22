export default {
  namespaced: true,
  state: {
    tabsData: "2",
    tabsInfo: {
      name: "zhouqiao",
    },
    // pathName: "", // 路由
    // currDbSource: {}, // 当前数据源
  },
  getters: {
    getTabsData(state) {
      return state.tabsInfo.name;
    },
  },
  mutations: {
    // 保存当前菜单栏的路径
    setTabsData(state, tabsData) {
      state.tabsData = tabsData;
    },
  },
  actions: {
    // // 方法一：
    saveTabsData(context, payload) {
      context.commit("setTabsData", payload);
    },
    //  // 方法二：
    //  export const saveElementTabsOneOp = ({ commit }, payload) => {
    //    commit('saveElementTabsOneOp', payload);
    //  };
  },
};
