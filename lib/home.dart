import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:flutter/material.dart';
import 'package:shelf_plus/shelf_plus.dart' as plus;
import 'package:shelf/shelf_io.dart' as io;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String value = '';
  Map files = {};
  List<String> paths = [];
  Timer? timer;
  var app = plus.Router().plus;
  late HttpServer server;
  bool flag = false;
  List<plus.WebSocketSession> users = [];
  int filesLimit = 3000;

  @override
  void initState() {
    super.initState();
    getCache();
    init();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  timeSendMsg() {
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (users.isNotEmpty) {
        flag = false;
        comparisonFile();
        if (flag) {
          for (var user in users) {
            user.send('1');
          }
        }
      }
    });
  }

  getCache() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      paths = prefs.getStringList('paths') ?? [];
    });
  }

  toast(msg) {
    if (ScaffoldMessenger.of(context).mounted) {
      // 清理
      ScaffoldMessenger.of(context).clearSnackBars();
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(msg)));
  }

  setCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('paths', paths);
    toast("保存成功");
  }

  init() async {
    app.use(corsHeaders());
    app.get(
      '/ws',
      () => plus.WebSocketSession(
        onOpen: (ws) {
          users.add(ws);
          ws.send("欢迎使用，炜哥出品。");
          setState(() {});
        },
        onClose: (ws) {
          // Leave chat
          ws.send('有缘再见，炜哥出品。');
          users.remove(ws);
          setState(() {});
        },
        onMessage: (ws, dynamic data) {
          // Deliver messages to all users
          timeSendMsg();
        },
      ),
    );
    server = await io.serve(app, 'localhost', 4444);
    timeSendMsg();
  }

  comparisonFile() {
    if (paths.isNotEmpty) {
      for (String path in paths) {
        if (path.isNotEmpty) {
          if (FileSystemEntity.isDirectorySync(path)) {
            dirEach(path);
            // 文件夹
          } else if (FileSystemEntity.isFileSync(path)) {
            // 文件
            getFile(path);
          }
        }
      }
    }
  }

  dirEach(path) {
    try {
      if (files.length >= filesLimit) {
        return;
      } else {
        List<FileSystemEntity> fileList = Directory(path).listSync();
        if (fileList.isNotEmpty) {
          for (FileSystemEntity p in fileList) {
            if (FileSystemEntity.isDirectorySync(p.path)) {
              dirEach(p.path);
              // 文件夹
            } else if (FileSystemEntity.isFileSync(p.path)) {
              // 文件
              getFile(p.path);
            }
          }
        }
      }
    } catch (_) {}
  }

  getFile(String path) {
    try {
      File f = File(path);
      // print('获取文件最后修改时间: ${f.lastModifiedSync()}');
      String lastModified = f.lastModifiedSync().toString();
      if (files[path] != null) {
        if (files[path] != lastModified) {
          files[path] = lastModified;
          flag = true;
        }
      } else {
        String suffix = path.substring(path.lastIndexOf('.') + 1);
        if (files.length >= filesLimit) {
          toast("监听文件数超过2000");
          setState(() {});
          return;
        } else {
          if (['html', 'css', 'js'].contains(suffix)) {
            files[path] = lastModified;
            flag = true;
          }
        }
      }
    } catch (_) {}
  }

  selectedFile(index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(lockParentWindow: true);
    if (result != null) {
      setState(() {
        files.clear();
        paths[index] = result.files.single.path ?? '';
      });
    }
  }

  selectedFolder(index) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(lockParentWindow: true);
    if (selectedDirectory != null) {
      setState(() {
        files.clear();
        paths[index] = selectedDirectory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      paths.add('');
                    });
                  },
                  child: const Text("添加路径"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setCache();
                  },
                  child: const Text("保存路径"),
                ),
                Text('用户数：${users.length}个'),
                Text('文件数：${files.length}个'),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 34,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xffdddddd)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: SelectableText(paths[index]),
                        ),
                        // child: Input(
                        //   onChanged: (v) {
                        //     paths[index] = v.trim();
                        //   },
                        //   value: paths[index],
                        // ),
                      ),
                      IconButton(
                        splashRadius: 17,
                        onPressed: () {
                          selectedFile(index);
                        },
                        icon: const Icon(
                          Icons.insert_drive_file_outlined,
                        ),
                      ),
                      IconButton(
                        splashRadius: 17,
                        onPressed: () {
                          selectedFolder(index);
                        },
                        icon: const Icon(
                          Icons.folder_outlined,
                        ),
                      ),
                      IconButton(
                        splashRadius: 17,
                        onPressed: () {
                          setState(() {
                            paths.removeAt(index);
                          });
                        },
                        icon: const Icon(
                          CupertinoIcons.clear,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  );
                },
                itemCount: paths.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
