import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kael_file_browser/util.dart';
import 'package:photo_view/photo_view.dart';
import 'package:filesystem_picker/filesystem_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<File> imgs = List<File>.empty();
  int imgIdx = 0;
  String path = "";

  @override
  void initState() {
    imgs = List<File>.empty();
    super.initState();
  }

  openFolder(String path) {
    setState(() {
      imgs = Directory(path).listSync().map((e) => File(e.path)).toList();
      imgIdx = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    String userDir = Util.getUserDirectory();
    return Scaffold(
        body: Center(
            child: PhotoView(
          imageProvider: AssetImage(imgs.isNotEmpty ? imgs[imgIdx].path : ""),
        )),
        bottomNavigationBar: ButtonBar(
          children: [
            ElevatedButton(
                onPressed: () async {
                  String folder = await FilesystemPicker.open(
                        title: 'Open folder',
                        context: context,
                        rootDirectory: Directory(userDir),
                        directory: path.isNotEmpty ? Directory(path) : null,
                        fsType: FilesystemType.folder,
                        pickText: 'Pick folder',
                      ) ??
                      path;
                  setState(() {
                    path = folder;
                    openFolder(path);
                  });
                },
                child: const Text("Open folder")),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    imgIdx--;
                    imgIdx = (imgIdx + imgs.length) % imgs.length;
                  });
                },
                child: Text("Last")),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    imgIdx++;
                    imgIdx %= imgs.length;
                  });
                },
                child: Text("Next")),
          ],
        )
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () =>
        //       setState(() => imgPath = "/home/kael/Pictures/CoolMarket/2.jpg"),
        //   tooltip: 'Increment Counter',
        //   child: const Icon(Icons.add),
        // ),
        );
  }
}
