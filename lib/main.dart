import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kael_file_browser/media_player.dart';
import 'package:kael_file_browser/movement.dart';
import 'package:kael_file_browser/side_fileinfo.dart';
import 'package:kael_file_browser/util.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:path/path.dart' as Path;
import 'package:localstore/localstore.dart';
import 'package:json_editor/json_editor.dart';

final db = Localstore.instance;
Map<String, String> alias2dst = Map();
String activate = "";
late Map<String, dynamic>? local;

setLocal(Map<String, dynamic> map) {
  db
      .collection("custom_movement")
      .doc("kael_file_browser")
      .set(map)
      .then((value) => {});
}

initLocal() async {
  activate = local!['activate'];
  String movementStr = local!['cases'][activate]
      .toString()
      .replaceAllMapped(RegExp(r'([/\w\.]+)'), (match) {
    return '"${match.group(0)}"';
  });
  alias2dst = Map<String, dynamic>.from(jsonDecode(movementStr))
      .map((key, value) => MapEntry(key, value.toString()));
}

void main() async {
  await DartVLC.initialize(useFlutterNativeView: true);
  WidgetsFlutterBinding.ensureInitialized();
  local = await db.collection("custom_movement").doc("kael_file_browser").get();
  if (local != null) {
    await initLocal();
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
  int itemIdx = 0;
  List<Movement> movements = List.empty(growable: true);
  String path = local?['path'] ?? "/home/kael/tmp/";
  MediaPlayer mediaPlayer = MediaPlayer();

  void openFolder(String path) {
    if (items.isNotEmpty && path == this.path) {
      return;
    }
    Directory.current = Directory(path);
    local!['path'] = path;
    setLocal(local!);
    setState(() {
      items = Directory(path)
          .listSync()
          .where((p) =>
              Util.isGif(p.path) ||
              Util.isImage(p.path) ||
              Util.isVideo(p.path))
          .map((e) => File(e.path))
          .toList();
      itemIdx = 0;
      // items.sort((a, b) => b.lengthSync() - a.lengthSync());
      if (items.isNotEmpty) {
        playCurrentFile();
      }
      movements.clear();
    });
  }

  void playCurrentFile() {
    setState(() {
      mediaPlayer.play(items[itemIdx]);
    });
  }

  void move(String dst) {
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
    items.add(File(movement.src));
    itemIdx = items.length - 1;
    playCurrentFile();
  }

  void removeItemOffList() {
    if (items.isEmpty) {
      return;
    }
    items.removeAt(itemIdx);
    if (items.isNotEmpty) {
      itemIdx %= items.length;
      playCurrentFile();
    } else {
      mediaPlayer.resetFile();
    }
  }

  void addIdx(int addtion) {
    if (items.isEmpty) {
      itemIdx = 0;
      return;
    }
    itemIdx += addtion;
    while (itemIdx < 0) {
      itemIdx += items.length;
    }
    itemIdx %= items.length;
  }

  void setIdx(int idx) {
    setState(() {
      itemIdx = max(0, idx) % items.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: mediaPlayer,
          ),
          SideFileinfo(
            files: items,
            changeIdx: (idx) => {
              setState(() {
                setIdx(idx);
                playCurrentFile();
              })
            },
          ),
        ],
      ),
      bottomNavigationBar: ButtonBar(
        children: generateBtns(),
      ),
    );
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
          onPressed: () {
            undoMovement();
          },
          child: const Text("Undo")),
      ElevatedButton(
          onPressed: () async {
            String jsonStr = "";
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text("Edit your movement"),
                      content: JsonEditor.object(
                        object: local,
                        onValueChanged: (val) {
                          jsonStr = val.toString();
                        },
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              setLocal(json.decode(jsonStr));
                              local = Map<String, dynamic>.from(
                                  jsonDecode(jsonStr));
                              setState(() {
                                initLocal();
                              });
                            },
                            child: const Text("OK")),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancel"))
                      ],
                    ));
          },
          child: const Text("Edit movement")),
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
              openFolder(folder);
              path = folder;
            });
          },
          child: const Text("Open folder")),
      ElevatedButton(
          onPressed: () {
            addIdx(-1);
            playCurrentFile();
          },
          child: const Text("Last")),
      ElevatedButton(
          onPressed: () {
            addIdx(1);
            playCurrentFile();
          },
          child: const Text("Next")),
      ElevatedButton(
          onPressed: () {
            mediaPlayer.playOrPause();
          },
          child: const Text("Play/Pause")),
    ]));
    return btns;
  }
}
