// 保存当前菜单栏的路径
export const savePath = (state, pathName) => {
  state.pathName = pathName;
};

// 保存当前点击的数据源
export const saveCurrDbSource = (state, currDbSource) => {
  state.currDbSource = currDbSource;
};
