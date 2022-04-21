import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:listen_file_to_refresh/input.dart';
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

  @override
  void initState() {
    super.initState();
    getCache();
    init();
  }

  var app = plus.Router().plus;
  late HttpServer server;
  bool flag = false;

  getCache() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      paths = prefs.getStringList('paths') ?? [];
    });
  }

  setCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('paths', paths);
    if (ScaffoldMessenger.of(context).mounted) {
      // 清理
      ScaffoldMessenger.of(context).clearSnackBars();
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text("保存成功")));
  }

  init() async {
    app.use(corsHeaders());
    app.get('/r', (plus.Request request) {
      flag = false;
      comparisonFile();
      return plus.Response.ok(jsonEncode({'msg': flag}));
    });
    server = await io.serve(app, 'localhost', 4444);
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

  getFile(path) {
    File f = File(path);
    // print('获取文件最后修改时间: ${f.lastModifiedSync()}');
    String lastModified = f.lastModifiedSync().toString();
    if (files[path] != null) {
      if (files[path] != lastModified) {
        files[path] = lastModified;
        flag = true;
      }
    } else {
      files[path] = lastModified;
      flag = true;
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
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Input(
                            onChanged: (v) {
                              paths[index] = v.trim();
                            },
                            value: paths[index],
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
                    ),
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