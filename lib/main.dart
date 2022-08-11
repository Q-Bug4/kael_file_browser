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
  List<File> items = List<File>.empty();
  int itemIdx = 0;
  String path = "";
  final player = Player(id: 60002);

  @override
  void initState() {
    items = List<File>.empty();
    super.initState();
  }

  openFolder(String path) {
    setState(() {
      items = Directory(path)
          .listSync()
          .where((p) => Util.isImage(p.path) || Util.isVideo(p.path))
          .map((e) => File(e.path))
          .toList();
      itemIdx = 0;
    });
  }

  removeItemOffList() {
    if (items.isEmpty) {
      return;
    }
    items.removeAt(itemIdx);
    setState(() {
      if (items.isNotEmpty) {
        itemIdx %= items.length;
      }
    });
  }

  void playVideo() {
    player.open(Media.file(File(items[itemIdx].path)));
  }

  void move(String dst) {
    if (items.isEmpty) {
      return;
    }
    Process.run('mv', [items[itemIdx].path, dst]).then((result) {
      if (result.stderr.toString().isNotEmpty) {
        _showMyDialog('Command error', result.stderr.toString());
        return;
      }
      removeItemOffList();
    });
  }

  @override
  Widget build(BuildContext context) {
    String userDir = Util.getUserDirectory();
    bool isVideo = items.isNotEmpty && Util.isVideo(items[itemIdx].path);
    if (isVideo) {
      playVideo();
    } else {
      player.pause();
    }
    Map<String, String> alias2dst = {
      "tmp": "/home/kael/tmp",
      "pic": "/home/kael/Pictures/"
    };
    List<ElevatedButton> btns = alias2dst.entries
        .map((e) => ElevatedButton(
            onPressed: () => move(e.value), child: Text("[Mv] ${e.key}")))
        .toList();

    btns.addAll(List<ElevatedButton>.of(<ElevatedButton>[
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
              itemIdx--;
              itemIdx = (itemIdx + items.length) % items.length;
            });
          },
          child: const Text("Last")),
      ElevatedButton(
          onPressed: () {
            setState(() {
              itemIdx++;
              itemIdx %= items.length;
            });
          },
          child: const Text("Next"))
    ]));
    return Scaffold(
        body: Center(
            child: items.isNotEmpty
                ? (isVideo
                    ? Video(
                        player: player,
                        scale: 1.0, // default
                        showControls: true, // default
                      )
                    : PhotoView(
                        imageProvider: AssetImage(
                            items.isNotEmpty ? items[itemIdx].path : "")))
                : const Text("Please pick a folder")),
        bottomNavigationBar: ButtonBar(
          children: btns,
        ));
  }

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
}
