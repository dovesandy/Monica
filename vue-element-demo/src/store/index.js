import Vue from "vue";
import Vuex from "vuex";
import tabs from "./modules/tabs";
// import products from './modules/products'
// import createLogger from '../../../src/plugins/logger'

Vue.use(Vuex);

// const debug = process.env.NODE_ENV !== 'production'

export default new Vuex.Store({
  state: {
    name: "chongsen",
    number: "0",
    userInfo: {
      age: 20,
      name: "zhouqiao",
    },
  },
  modules: {
    tabs,
  },
  mutations: {
    setName(state, name) {
      state.name = name;
    },
  },
  actions: {
    saveName(content, name) {
      setTimeout(() => {
        content.commit("setName", name);
      }, 1000);
    },
  },
  getters: {
    getUserName(state) {
      return state.userInfo.name;
    },
  },
});
