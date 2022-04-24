// 监听文件修改更新浏览器
function ListenFileAndRefresh() {
  this.listenFileTimer = '';
  this.lockReconnect = false;
}

ListenFileAndRefresh.prototype = {
  constructor: ListenFileAndRefresh,
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
    ws.onopen = function (evt) {};
    ws.onmessage = function (evt) {
      console.log('Received Message: ' + evt.data);
      if (evt.data === '1') {
        location.reload(true)
      }
    };
    ws.onclose = function (evt) {
      self.reconnect();
    };
    ws.onerror = function (event) {
      self.reconnect();
    }
  },
};