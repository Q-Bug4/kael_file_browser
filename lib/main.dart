import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kael_file_browser/FileManager.dart';
import 'package:kael_file_browser/ConfigManager.dart';
import 'package:kael_file_browser/media_player.dart';
import 'package:kael_file_browser/MoveHistory.dart';
import 'package:kael_file_browser/side_fileinfo.dart';
import 'package:kael_file_browser/util.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:path/path.dart' as Path;
import 'package:json_editor/json_editor.dart';

void main() async {
  await DartVLC.initialize(useFlutterNativeView: true);
  WidgetsFlutterBinding.ensureInitialized();
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
  FileManager fileManager = FileManager(List<File>.empty());
  MediaPlayer mediaPlayer = MediaPlayer();
  ConfigManager configManager = ConfigManager(collectionName: "custom_movement", docName: "kael_file_browser");

  void openFolder(String path) {
    if (fileManager.isNotEmpty() && path == configManager.getPath()) {
      return;
    }
    Directory.current = Directory(path);
    configManager.setPath(path);
    setState(() {
      List<File> files = Directory(path)
          .listSync()
          .where((p) =>
              Util.isGif(p.path) ||
              Util.isImage(p.path) ||
              Util.isVideo(p.path))
          .map((e) => File(e.path))
          .toList();
      fileManager.setFiles(files);
      // items.sort((a, b) => b.lengthSync() - a.lengthSync());
      if (fileManager.isNotEmpty()) {
        playCurrentFile();
      }
    });
  }

  void playCurrentFile() {
    setState(() {
      File? file = fileManager.getCurrentFile();
      if (file != null) {
        mediaPlayer.play(file);
      }
    });
  }

  void move(String dst) {
    if (fileManager.isEmpty()) {
      return;
    }
    File file = fileManager.getCurrentFile()!;
    MoveHistory moveHistory =
        MoveHistory(src: file.path, dst: "$dst/${Path.basename(file.path)}");
    mediaPlayer.resetFile();
    String errMsg = moveHistory.doMove();
    if (errMsg.isNotEmpty) {
      Util.showInfoDialog(context, "Movement error", errMsg);
      return;
    }
    fileManager.addHistory(moveHistory);
    removeItemOffList();
  }

  void undoMovement() {
    if (fileManager.isHistoryEmpty()) {
      return;
    }
    MoveHistory moveHistory = fileManager.popLastHistory();
    String errMsg = moveHistory.undo();
    if (errMsg.isNotEmpty) {
      Util.showInfoDialog(context, "Movement error", errMsg);
      return;
    }
    fileManager.addFileBeforeCur(File(moveHistory.src));
    playCurrentFile();
  }

  void removeItemOffList() {
    if (fileManager.isEmpty()) {
      return;
    }
    fileManager.removeCurFile();
    if (fileManager.isNotEmpty()) {
      playCurrentFile();
    } else {
      mediaPlayer.resetFile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: mediaPlayer,
          ),
          SideFileInfo(
            files: fileManager.getAllFile(),
            btns: List<ElevatedButton>.of(<ElevatedButton>[
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
                            object: configManager.getLocal(),
                            onValueChanged: (val) {
                              jsonStr = val.toString();
                            },
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    configManager.setLocal(jsonDecode(jsonStr));
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
                  child: const Text("Move conf")),
              ElevatedButton(
                  onPressed: () async {
                    String folder = await FilesystemPicker.open(
                      title: 'Open folder',
                      context: context,
                      rootDirectory: Directory("/"),
                      directory: configManager.getPath().isNotEmpty
                          ? Directory(configManager.getPath())
                          : Directory(Util.getUserDirectory()),
                      fsType: FilesystemType.folder,
                      pickText: 'Pick folder',
                    ) ??
                        configManager.getPath();
                    setState(() {
                      openFolder(folder);
                      configManager.setPath(folder);
                    });
                  },
                  child: const Text("Open folder")),
              ElevatedButton(
                  onPressed: () {
                    fileManager.lastFile();
                    playCurrentFile();
                  },
                  child: const Text("Last")),
              ElevatedButton(
                  onPressed: () {
                    fileManager.nextFile();
                    playCurrentFile();
                  },
                  child: const Text("Next")),
            ]),
            changeIdx: (idx) => {
              setState(() {
                fileManager.setFileAt(idx);
                playCurrentFile();
              })
            },
          ),
        ],
      ),
      bottomNavigationBar: FutureBuilder(
        future: configManager.init(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Wrap(
              children: generateBtns(),
            );
          }
          return const Wrap(children: [],);
        },
      ),
    );
  }

  List<ElevatedButton> generateBtns() {
    return configManager.getAlias().entries
        .map((e) => ElevatedButton(
            onPressed: () {
              move(e.value);
            },
            child: Text(e.key)))
        .toList();
  }
}
