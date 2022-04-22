# listen_file_to_refresh

监听文件并刷新

## 添加文件路径实现监听
- WebSocket地址: ws://localhost:4444/ws
- Ajax GET地址: http://localhost:4444/r
- 选择监听路径尽可能范围小
- 只监听 'html', 'css', 'js'文件
- 项目页面引入js文件(在项目中或者在安装包中listenFileAndRefresh.js)
- 也可选择本人网站 http://www.zhengw.top/listenFileAndRefresh.js
- 使用方法(支持ajax和ws[推荐])

```js
try {
  // var opt = new Viewer();
   代码区
} finally {
  (new ListenFileAndRefresh()).ws();
}
```

1. websocket调用方法: (new ListenFileAndRefresh()).ws();
2. ajax调用方法: (new ListenFileAndRefresh()).ajax();
