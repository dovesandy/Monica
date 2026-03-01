// ...existing code...
let allSpansIndex = 0;
let pageSizeList = [2, 5, 5];
let timer = null;
let foundButtons = [];
let targetlength = 6; // 只找前两个

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// ...existing code...
async function findParentButtons() {
  let pageSize = pageSizeList[allSpansIndex];
  for (let pageIndex = 0; pageIndex < pageSize; pageIndex++) {
    console.log('pageIndex', pageIndex +1);
    if (pageIndex > 0) {
      // 翻页
      const nextButton = document.querySelector('.btn-next');
      if (nextButton) {
        nextButton.click();
        // 等待页面渲染/数据加载
        await sleep(3000);
      } else {
        // 没有下一页按钮，直接退出循环
        break;
      }
    }

    // 获取所有span元素并检查，遇到第二个匹配立即返回
    const allSpans = document.querySelectorAll('span');
    for (const span of allSpans) {
      const txt = span.textContent?.trim();
      const targetTexts = ['未开始', '进行中'];
      if (txt && targetTexts.includes(txt)) {
        const parentButton = span.closest('button');
        if (parentButton) {
          foundButtons.push(parentButton);
          // 如果找到了第二个，立即返回第二个
          // if (foundButtons.length === targetlength) {
          //   return [foundButtons[targetlength -1]]; // 只返回第二个
          // }
        }
      }
    }
    // 当前页未找到第二个，继续下一页
  }

  // 没有第二个：如果找到过第一个则返回第一个，否则返回空数组
  // if (foundButtons.length === 1) {
  //   return [foundButtons[0]];
  // }
  return []; // 未找到任何匹配
}

async function playVideo() {
  let startvideo = document.querySelector('.xgplayer-start');
  localStorage.removeItem("videoPlay");
  localStorage.getItem("videoPlay");
  await sleep(2000);
  startvideo?.click();
  clearInterval(timer);
  timer = null;
  timer = setInterval(() => {
    let videoPaused = document.querySelector('.interac');
    videoPaused?.click();
  }, 3000);

  let video = document.querySelector('video');
  const remaining = (video?.duration ?? 0) - (video?.currentTime ?? 0);
  // 保留原逻辑：视频剩余 + 5 秒，再加额外等待 5 秒
  let playtime = Math.max(0, remaining) + 5;
  console.log('视频剩余时间', playtime);
  Object.defineProperty(document.querySelector('video'), 'playbackRate', { writable: true });

  // 设置倍速播放
  video.playbackRate = 1.5;
  // 等待视频播放完并额外等待
  await sleep((playtime + 5) * 1000);

  // 返回列表
  window.history.back();

  // 等待返回页面并稳定
  await sleep(10 * 1000);

  // 继续下一个视频
  await findBigType();
}

async function findBigType() {
  let allSpans = document.querySelectorAll('.categoryTop-item');
  if (allSpansIndex >= allSpans.length) {
    return;
  }
  let playIndex = 0;
  let videos = [];
  console.log('allSpans', allSpans.length, allSpansIndex);
  allSpans[allSpansIndex]?.click();

  // 等待页面渲染/数据加载（替代原 setTimeout 5000）
  await sleep(5000);

  // 等待并获取第一个匹配的视频按钮
  videos = await findParentButtons();
  console.log('找到未看完的视频 videos', videos.length);
  // 是否有未看完的视频
  if (videos?.length) {
    // 进入视频中
    videos[playIndex].click();

    // 等待进入视频页并稳定（替代原 setTimeout 5000）
    await sleep(5000);

    await playVideo();
  } else {
    allSpansIndex++;

    // 等待后继续（替代原 setTimeout 3000）
    await sleep(3000);

    await findBigType();
  }
}

findBigType();
// ...existing code...