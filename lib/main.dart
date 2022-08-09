import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kael_file_browser/util.dart';
import 'package:photo_view/photo_view.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
// import 'package:dart_vlc_ffi/dart_vlc_ffi.dart';
import 'package:dart_vlc/dart_vlc.dart';

void main() async {
  await DartVLC.initialize(useFlutterNativeView: true);
  runApp(const MyApp());
}

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
  final player = Player(id: 60002);

  Future<void> _showMyDialog(String title, String content) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: content.split("\n").map((e) => Text(e)).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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

  removeItemOffList() {
    if (imgs.isEmpty) {
      return;
    }
    imgs.removeAt(imgIdx);
    setState(() {
      if (imgs.isNotEmpty) {
        imgIdx %= imgs.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String userDir = Util.getUserDirectory();
    return Scaffold(
        body: Center(
            //   child: PhotoView(
            // imageProvider: AssetImage(imgs.isNotEmpty ? imgs[imgIdx].path : ""),
            child: Video(
          player: player,
          height: 1920.0,
          width: 1080.0,
          scale: 1.0, // default
          showControls: false, // default
        )),
        bottomNavigationBar: ButtonBar(
          children: [
            ElevatedButton(
                onPressed: () {
                  player.open(Media.file(File('/home/kael/tmp/1.jpg')));
                },
                child: const Text("play")),
            ElevatedButton(
                onPressed: () {
                  if (imgs.isEmpty) {
                    return;
                  }
                  Process.run('mv', [imgs[imgIdx].path, '/home/kael/tmp/'])
                      .then((result) {
                    if (result.stderr.toString().isNotEmpty) {
                      _showMyDialog('Command error', result.stderr.toString());
                      return;
                    }
                    removeItemOffList();
                  });
                },
                child: const Text("Run shell")),
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
