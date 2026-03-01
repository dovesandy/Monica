
let allSpansIndex = 0;
let pageSizeList = [2, 5, 5];
let pageIndex = 0;
// 查找所有包含文本为"未开始"的span的父级button元素
function findParentButtons() {

  // 获取所有span元素
  const allSpans = document.querySelectorAll('span');
  const resultButtons = [];
  // 遍历所有span元素
  allSpans.forEach(span => {
    // 检查span的文本内容是否为"未开始"
    if (span.textContent.trim() === '未开始' || span.textContent.trim() === '进行中') {
      // 查找最近的button父元素
      const parentButton = span.closest('button');

      // 如果找到了button父元素，并且尚未添加到结果中
      if (parentButton && !resultButtons.includes(parentButton)) {
        resultButtons.push(parentButton);
      }
    }
  });
  return resultButtons;
}

function playVideo() {
  let startvideo = document.querySelector('.xgplayer-start');
  startvideo.click();
  let video = document.querySelector('video');
  let playtime = video?.duration - video?.currentTime + 5;
  console.log('视频剩余时间', playtime);
  setTimeout(() => {
    // 返回列表
    window.history.back();
    // 继续下一个视频
    setTimeout(() => {
      findBigType();
    }, 10 * 1000)
  }, playtime + 5 * 1000)
}

function findBigType() {
  if (allSpansIndex >= 3) {
    return;
  }
  let playIndex = 0;
  let videos = [];
  let allSpans = document.querySelectorAll('.categoryTop-item');
  console.log('allSpans', allSpans.length, allSpansIndex);
  allSpans[allSpansIndex]?.click();
  setTimeout(() => {
    videos = findParentButtons();
    console.log('找到未看完的视频 videos', videos.length);
    // 是否有未看完的视频
    if (videos?.length) {
      // 进入视频中
      videos[playIndex].click();
      setTimeout(() => {
        playVideo();
      }, 5000)
    } else {
      allSpansIndex++;
      setTimeout(() => {
        findBigType();
      }, 3000)
    }
  }, 5000)
}

findBigType();
