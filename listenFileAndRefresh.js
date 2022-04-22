// 监听文件修改更新浏览器
function ListenFileAndRefresh() {
  this.listenFileTimer = '';
  var self = this;
  this.isAjax = false;
  this.lockReconnect = false;
  document.addEventListener('visibilitychange', function () {
    // 用户息屏、或者切到后台运行 （离开页面）
    if (document.visibilityState === 'hidden') {
      if (self.listenFileTimer && self.isAjax) {
        clearInterval(self.listenFileTimer);
      }
    } else if (document.visibilityState === 'visible') {
      // 用户打开或回到页面
      if (self.isAjax) {
        self.listenFileTimerFun();
      }
    }
  });
}

ListenFileAndRefresh.prototype = {
  constructor: ListenFileAndRefresh,
  ajax: function () {
    this.isAjax = true;
    this.listenFileTimerFun();
  },
  reconnect: function reconnect() {
    var self = this;
    if (self.lockReconnect) return;
    self.lockReconnect = true;
    setTimeout(function () {
      self.lockReconnect = false;
      self.ws();
    }, 3000); //断开后2s自动重连
  },
  ws: function () {
    var self = this;
    var ws = new WebSocket('ws://localhost:4444/ws');
    ws.onopen = function (evt) {
      console.log('Connection open ...');
      ws.send('Hello WebSockets!');
    };
    ws.onmessage = function (evt) {
      console.log('Received Message: ' + evt.data);
      if (evt.data === '1') {
        location.reload(true)
      }
    };
    ws.onclose = function (evt) {
      console.log('Connection closed.');
      self.reconnect();
    };
    ws.onerror = function (event) {
      console.log("---error---");
      self.reconnect();
    }
  },
  listenFileTimerFun: function () {
    this.listenFileTimer = setInterval(function () {
      fetch('http://localhost:4444/r')
        .then(response => response.json())
        .then(data => {
          if (data && data.msg) {
            location.reload(true)
          }
        })
    }, 3000);
  }
};