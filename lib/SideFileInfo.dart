import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:kael_file_browser/ConfigManager.dart';
import 'package:kael_file_browser/FileManager.dart';
import 'package:kael_file_browser/MediaPlayer.dart';
import 'package:kael_file_browser/util.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

class SideFileInfo extends StatefulWidget {
  final FileManager fileManager;
  final MediaPlayer mediaPlayer;
  final ConfigManager configManager;
  final Function showDialog;

  const SideFileInfo(
      {Key? key,
      required this.fileManager,
      required this.configManager,
      required this.mediaPlayer,
      required this.showDialog})
      : super(key: key);

  @override
  State<SideFileInfo> createState() => _SideFileInfoState();
}

class _SideFileInfoState extends State<SideFileInfo> {
  late double width;
  bool expanded = true;
  String sortValue = "Name";
  bool sortDesc = true;
  int idx = 0;
  final double EXPAND_WIDTH = 300;
  final double COLL_WIDTH = 30;
  final Icon leftArrow = const Icon(Icons.keyboard_arrow_left);
  final Icon rightArrow = const Icon(Icons.keyboard_arrow_right);

  void sort() {
    switch (sortValue) {
      case "Size":
        widget.fileManager.getAllFile().sort(
            (a, b) => (sortDesc ? 1 : -1) * (b.lengthSync() - a.lengthSync()));
        break;
      case "Name":
        widget.fileManager
            .getAllFile()
            .sort((a, b) => (sortDesc ? 1 : -1) * b.path.compareTo(a.path));
        break;
      default:
    }
    setState(() {});
    changeIdx(0);
  }

  void changeIdx(idx) {
    widget.fileManager.setFileAt(idx);
    setState(() {});
    playCurrentFile();
  }

  void playCurrentFile() {
    File? file = widget.fileManager.getCurrentFile();
    if (file != null) {
      widget.mediaPlayer.play(file);
    } else {
      widget.mediaPlayer.stop();
    }
  }

  @override
  void initState() {
    width = expanded ? EXPAND_WIDTH : COLL_WIDTH;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> files = widget.fileManager
        .getAllFile()
        .map((e) => path.basename(e.path))
        .toList();
    List<TextButton> fileBtns = List.empty(growable: true);
    for (int i = 0; i < files.length; i++) {
      final TextStyle style = i == idx
          ? const TextStyle(color: Colors.blue)
          : const TextStyle(color: Colors.black);
      fileBtns.add(TextButton(
        onPressed: () {
          idx = i;
          changeIdx(idx);
        },
        child: Text(files[i], style: style),
      ));
    }

    Widget content = Column(children: [
      Expanded(
          child: ListView(
        children: expanded ? fileBtns : List.empty(),
      )),
      Container(
          height: 100,
          child: expanded && !widget.fileManager.isEmpty()
              ? Column(children: [
                  Expanded(
                      child: ListView(
                    children: [
                      Text(
                        "Uri: ${widget.fileManager.getCurrentFile()!.path}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.indigo),
                      ),
                      Row(
                        children: [
                          Text(
                            "  Size: ${Util.getReadableFileSize(widget.fileManager.getCurrentFile()!.lengthSync())}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.teal),
                          ),
                          Spacer(),
                          Text("${1 + idx}/${files.length}  "),
                        ],
                      ),
                      Row(
                        children: [
                          Text("sort"),
                          Radio(
                              value: "Name",
                              groupValue: sortValue,
                              onChanged: (v) {
                                sortValue = v.toString();
                                sort();
                              }),
                          Text("Name"),
                          Radio(
                              value: "Size",
                              groupValue: sortValue,
                              onChanged: (v) {
                                sortValue = v.toString();
                                sort();
                              }),
                          Text("Size"),
                          Checkbox(
                              value: sortDesc,
                              onChanged: (v) {
                                sortDesc = !sortDesc;
                                sort();
                              }),
                          Text("Reverse"),
                        ],
                      )
                    ],
                  )),
                ])
              : Column()),
      Container(
        child: expanded
            ? Wrap(
                children: List<ElevatedButton>.of(<ElevatedButton>[
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          undoMovement();
                        });
                      },
                      child: const Text("Undo")),
                  ElevatedButton(
                      onPressed: () async {
                        widget.showDialog();
                      },
                      child: const Text("Move conf")),
                  ElevatedButton(
                      onPressed: () async {
                        String? folder = await FilePicker.platform
                                .getDirectoryPath(
                                    dialogTitle: "Pick your directory",
                                    lockParentWindow: false,
                                    initialDirectory:
                                        widget.configManager.getPath());
                        if (folder == null) {
                          return;
                        }
                        openFolder(folder);
                        widget.configManager.setPath(folder);
                      },
                      child: const Text("Open folder")),
                ]),
              )
            : const Wrap(),
      ),
      Container(
        height: 40,
        width: width,
        child: IconButton(
            onPressed: () {
              setState(() {
                expanded = !expanded;
                width = expanded ? EXPAND_WIDTH : COLL_WIDTH;
              });
            },
            icon: expanded ? rightArrow : leftArrow),
      )
    ]);

    return Container(width: width, child: content);
  }

  void undoMovement() {
    try {
      widget.fileManager.undoMovement();
    } on Exception catch (e) {
      Util.showInfoDialog(context, "Undo Move Exception", e.toString());
    }
    playCurrentFile();
  }

  void openFolder(String path) {
    // avoid to open the same folder
    if (!widget.fileManager.isEmpty() &&
        path == widget.configManager.getPath()) {
      return;
    }
    Directory.current = Directory(path);
    widget.configManager.setPath(path);
    setState(() {
      widget.fileManager.readFilesOfDir(path);
    });
    playCurrentFile();
  }
}
