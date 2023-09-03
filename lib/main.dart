import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kael_file_browser/FileManager.dart';
import 'package:kael_file_browser/ConfigManager.dart';
import 'package:kael_file_browser/MoveBar.dart';
import 'package:kael_file_browser/MediaPlayer.dart';
import 'package:kael_file_browser/SideFileInfo.dart';
import 'package:kael_file_browser/util.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:json_editor/json_editor.dart';

void main() async {
  await DartVLC.initialize(useFlutterNativeView: true);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'X File Filter';

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
  ConfigManager configManager = ConfigManager(
      collectionName: "custom_movement", docName: "kael_file_browser");

  void playCurrentFile() {
      File? file = fileManager.getCurrentFile();
      if (file != null) {
        setState(() {
          mediaPlayer.play(file);
        });
      } else {
        mediaPlayer.resetFile();
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: mediaPlayer,
          ),
          SideFileInfo(
            fileManager: fileManager,
            configManager: configManager,
            mediaPlayer: mediaPlayer,
            showDialog: showConfigDialog,
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
