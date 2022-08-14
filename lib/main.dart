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
import 'package:json_editor/json_editor.dart';

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
  List<File> items = List<File>.empty();
  List<Movement> movements = List.empty(growable: true);
  int itemIdx = 0;
  String path = "";
  final player = Player(id: 60002);

  void openFolder(String path) {
    setState(() {
      items = Directory(path)
          .listSync()
          .where((p) => Util.isImage(p.path) || Util.isVideo(p.path))
          .map((e) => File(e.path))
          .toList();
      itemIdx = 0;
      movements.clear();
      // movements = List.empty(growable: true);
    });
  }

  void move(dst) {
    if (items.isEmpty) {
      return;
    }
    File file = items[itemIdx];
    Movement movement =
        Movement(src: file.path, dst: "$dst/${Path.basename(file.path)}");
    String errMsg = movement.doMove();
    if (errMsg.isNotEmpty) {
      Util.showInfoDialog(context, "Movement error", errMsg);
      return;
    }
    movements.add(movement);
    removeItemOffList();
  }

  void undoMovement() {
    if (movements.isEmpty) {
      return;
    }
    Movement movement = movements.removeLast();
    String errMsg = movement.undo();
    if (errMsg.isNotEmpty) {
      Util.showInfoDialog(context, "Movement error", errMsg);
      return;
    }
    setState(() {
      items.add(File(movement.src));
      itemIdx = items.length - 1;
    });
  }

  void removeItemOffList() {
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

  List<ElevatedButton> generateBtns() {
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
            String jsonStr = "";
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text("Edit your movement"),
                      content: JsonEditor.object(
                        object: alias2dst,
                        onValueChanged: (val) {
                          jsonStr = val.toString();
                        },
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              db
                                  .collection("custom_movement")
                                  .doc("kael_file_browser")
                                  .set(json.decode(jsonStr))
                                  .then((value) => {});
                              setState(() {
                                alias2dst = Map.castFrom(json.decode(jsonStr));
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
                  directory: path.isNotEmpty
                      ? Directory(path)
                      : Directory(Util.getUserDirectory()),
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
    return btns;
  }

  Widget getMediaWidget() {
    if (items.isEmpty) {
      return const Text("Please pick a folder");
    }
    bool isVideo = Util.isVideo(items[itemIdx].path);
    if (isVideo) {
      player.open(Media.file(File(items[itemIdx].path)));
    } else {
      player.pause();
    }

    return isVideo
        ? Video(
            player: player,
            scale: 1.0, // default
            showControls: true, // default
          )
        : PhotoView(
            imageProvider:
                AssetImage(items.isNotEmpty ? items[itemIdx].path : ""));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(child: getMediaWidget()),
        bottomNavigationBar: ButtonBar(
          children: generateBtns(),
        ));
  }
}
