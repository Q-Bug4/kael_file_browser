import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kael_file_browser/movement.dart';
import 'package:kael_file_browser/util.dart';
import 'package:photo_view/photo_view.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:path/path.dart' as Path;
import 'package:localstore/localstore.dart';

final db = Localstore.instance;
Map<String, String> alias2dst = Map();

void main() async {
  await DartVLC.initialize(useFlutterNativeView: true);
  WidgetsFlutterBinding.ensureInitialized();
  Map<String, dynamic>? local =
      await db.collection("custom_movement").doc("kael_file_browser").get();
  if (local != null) {
    alias2dst = local.map((key, value) => MapEntry(key, value.toString()));
  }
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
  final doc = Localstore.instance
      .collection("custom_movement")
      .doc("kael_file_browser");

  List<File> items = List<File>.empty();
  List<Movement> movements = List.empty();
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
      movements = List.empty(growable: true);
    });
  }

  move(dst) {
    if (items.isEmpty) {
      return;
    }
    File file = items[itemIdx];
    Movement movement =
        Movement(src: file.path, dst: "$dst/${Path.basename(file.path)}");
    String errMsg = movement.doMove();
    if (errMsg.isNotEmpty) {
      _showMyDialog("Movement error", errMsg);
      return;
    }
    movements.add(movement);
    removeItemOffList();
  }

  undoMovement() {
    if (movements.isEmpty) {
      return;
    }
    Movement movement = movements.removeLast();
    String errMsg = movement.undo();
    if (errMsg.isNotEmpty) {
      _showMyDialog("Movement error", errMsg);
      return;
    }
    setState(() {
      items.add(File(movement.src));
      itemIdx = items.length - 1;
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

  @override
  Widget build(BuildContext context) {
    String userDir = Util.getUserDirectory();
    bool isVideo = items.isNotEmpty && Util.isVideo(items[itemIdx].path);
    if (isVideo) {
      playVideo();
    } else {
      player.pause();
    }

    List<ElevatedButton> btns = alias2dst.entries
        .map((e) => ElevatedButton(
            onPressed: () {
              move(e.value);
            },
            child: Text("[Mv] ${e.key}")))
        .toList();

    btns.addAll(List<ElevatedButton>.of(<ElevatedButton>[
      ElevatedButton(
          onPressed: () async {
            JsonEncoder encoder = const JsonEncoder.withIndent('  ');
            TextEditingController controller =
                TextEditingController(text: encoder.convert(alias2dst));
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text("Edit your movement"),
                      content: TextField(
                        autofocus: true,
                        maxLines: null,
                        controller: controller,
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              db
                                  .collection("custom_movement")
                                  .doc("kael_file_browser")
                                  .set(json.decode(controller.text))
                                  .then((value) => {});
                              setState(() {
                                alias2dst =
                                    Map.castFrom(json.decode(controller.text));
                              });
                            },
                            child: const Text("确定")),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("取消"))
                      ],
                    ));
          },
          child: const Text("Edit movement")),
      ElevatedButton(
          onPressed: () {
            undoMovement();
          },
          child: const Text("Undo")),
      ElevatedButton(
          onPressed: () async {
            String folder = await FilesystemPicker.open(
                  title: 'Open folder',
                  context: context,
                  rootDirectory: Directory("/"),
                  directory:
                      path.isNotEmpty ? Directory(path) : Directory(userDir),
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
