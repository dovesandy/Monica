// 触发保存菜单栏的路径方法
export const savePath = ({ commit }, payload) => {
  commit("savePath", payload);
};

// 第一种是通过 context上下文用来触发事件，一种是直接通过commit，为了保存数据，都需要加第二个参数payload，不然保存到vuex的数据就是空值

// // 方法一：
// export const savePath = (context, payload) => {
//     context.commit('savePath', payload);
//  };

//  // 方法二：
//  export const savePath = ({ commit }, payload) => {
//    commit('savePath', payload);
//  };

// 触发获取当前点击的数据源方法
export const saveCurrDbSource = ({ commit }, payload) => {
  commit("saveCurrDbSource", payload);
};
