import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kael_file_browser/FileManager.dart';
import 'package:kael_file_browser/ConfigManager.dart';
import 'package:kael_file_browser/MoveBar.dart';
import 'package:kael_file_browser/media_player.dart';
import 'package:kael_file_browser/side_fileinfo.dart';
import 'package:kael_file_browser/util.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:dart_vlc/dart_vlc.dart';
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
    // avoid to open the same folder
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
      playCurrentFile();
    });
  }

  void playCurrentFile() {
    setState(() {
      File? file = fileManager.getCurrentFile();
      if (file != null) {
        mediaPlayer.play(file);
      } else {
        mediaPlayer.resetFile();
      }
    });
  }

  void move(String dst) {
    mediaPlayer.resetFile();
    try {
      fileManager.moveFileTo(dst);
    } on Exception catch (e) {
      Util.showInfoDialog(context, "Move Exception", e.toString());
    }
    playCurrentFile();
  }

  void undoMovement() {
    try {
      fileManager.undoMovement();
    } on Exception catch (e) {
      Util.showInfoDialog(context, "Undo Move Exception", e.toString());
    }
    playCurrentFile();
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
                    showConfigDialog();
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
          return (snapshot.connectionState == ConnectionState.done)
              ? MoveBar(configManager.getAlias(), move)
              : Container();
        },
      ),
    );
  }

  String showConfigDialog() {
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
    return jsonStr;
  }
}
