# listen_file_to_refresh

监听文件并刷新

![Image text](./doc/1.png)

## 添加文件路径实现监听

- WebSocket地址: ws://localhost:4444/ws
- 选择监听路径尽可能范围小
- 选择监听文件数限制3000
- 只监听 'html', 'css', 'js'文件

### 使用方法

- 使用方法1

```js
// 项目页面引入js文件(在项目中或者在安装包中listenFileAndRefresh.js)
try {
  // var opt = new Viewer();
  代码区
} finally {
  (new ListenFileAndRefresh()).ws();
}
```

- 使用方法2

```js

try {
  // var opt = new Viewer();
  代码区
} finally {
  (function () {
    var lockReconnect = false;

    // 自动重连
    function reconnect() {
      if (lockReconnect) return;
      lockReconnect = true;
      setTimeout(function () {
        lockReconnect = false;
        ws();
      }, 3000);
    }

    function ws() {
      var ws = new WebSocket('ws://localhost:4444/ws');
      // ws.onopen = function (evt) {};
      ws.onmessage = function (evt) {
        console.log(evt.data);
        if (evt.data === '1') location.reload(true)
      };
      ws.onclose = reconnect;
      ws.onerror = reconnect
    }

    if (['localhost', '192.168.1.131'].indexOf(window.location.hostname) > -1) {
      ws();
    }

  })()
}

```