// 监听文件修改更新浏览器
function ListenFileAndRefresh() {
  var listenFileTimer = '';

  function listenFileTimerFun() {
    listenFileTimer = setInterval(function () {
      fetch('http://localhost:4444/r').then(response => response.json())
        .then(data => {
          console.log(':');
          if (data && data.msg) {
            location.reload(true)
          }
        })
    }, 3000);
  }

  listenFileTimerFun();
  document.addEventListener('visibilitychange', function () {
    // 用户息屏、或者切到后台运行 （离开页面）
    if (document.visibilityState === 'hidden') {
      if (listenFileTimer) {
        clearInterval(listenFileTimer);
      }
    } else if (document.visibilityState === 'visible') {
      // 用户打开或回到页面
      listenFileTimerFun();
    }
  });
}

ListenFileAndRefresh.prototype = {
  constructor: ListenFileAndRefresh,
};
