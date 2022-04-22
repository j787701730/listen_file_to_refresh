import 'dart:io';

import 'package:flutter/material.dart';
import 'package:listen_file_to_refresh/home.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

const String appName = '监听文件并刷新';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  // Use it only after calling `hiddenWindowAtLaunch`
  await protocolHandler.register('listenfiletorefresh');
  windowManager.waitUntilReadyToShow().then((_) async {
    // Hide window title bar
    await windowManager.setSize(const Size(800, 600));
    // await windowManager.setTitle(appName);
    await windowManager.center();
    await windowManager.show();
    // await windowManager.setSkipTaskbar(false);
    // 开启关闭拦截功能
    await windowManager.setPreventClose(true);
  });
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TrayListener, WindowListener, ProtocolListener {
  bool maximizeFlag = false;

  @override
  void initState() {
    super.initState();
    protocolHandler.addListener(this);
    trayManager.addListener(this);
    windowManager.addListener(this);
    setTray();
  }

  setTray() async {
    // 开启关闭拦截功能
    // await windowManager.setPreventClose(true);
    await trayManager.setIcon(
      Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app_icon.png',
    );
    List<MenuItem> items = [
      MenuItem(
        key: 'show_window',
        title: '显示',
      ),
      MenuItem.separator,
      MenuItem(
        key: 'exit_app',
        title: '退出',
      ),
    ];
    await trayManager.setContextMenu(items);
    await trayManager.setToolTip(appName);
  }

  @override
  void onWindowMaximize() {
    maximizeFlag = true;
  }

  @override
  void onWindowUnmaximize() {
    maximizeFlag = false;
  }

  @override
  void onWindowFocus() {
    setState(() {});
  }

  @override
  void onWindowClose() {
    windowManager.hide();
  }

  windowShow() async {
    if (await windowManager.isMinimized()) {
      if (maximizeFlag) {
        windowManager.maximize();
      } else {
        windowManager.restore();
      }
    } else {
      windowManager.show().then((value) {
        setState(() {});
        if (maximizeFlag) windowManager.maximize();
      });
    }
  }

  @override
  void onTrayIconMouseDown() {
    windowShow();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'show_window') {
      windowShow();
    } else if (menuItem.key == 'exit_app') {
      // 退出
      trayManager.destroy().then((_) => exit(0));
    }
  }

  @override
  void dispose() {
    super.dispose();
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    protocolHandler.removeListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          size: 18,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shadowColor: MaterialStateProperty.all(Colors.transparent),
            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 12)),
          ),
        ),
        tooltipTheme: const TooltipThemeData(
          textStyle: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        fontFamily: '微软雅黑',
        textTheme: const TextTheme(
          bodyText2: TextStyle(
            fontSize: 14,
          ),
          button: TextStyle(
            fontSize: 14,
          ),
        ),
      ),
      home: const Home(),
    );
  }
}
