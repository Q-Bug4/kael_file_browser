import 'dart:io';
import 'dart:math';
import 'package:kael_file_browser/util.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

class SideFileinfo extends StatefulWidget {
  List<File> files;
  Function changeIdx;

  SideFileinfo({Key? key, required this.files, required this.changeIdx})
      : super(key: key);

  @override
  State<SideFileinfo> createState() => _SideFileinfoState();
}

class _SideFileinfoState extends State<SideFileinfo> {
  late List<File> files;
  late double width;
  bool expanded = false;
  int idx = 0;
  final double EXPAND_WIDTH = 300;
  final double COLL_WIDTH = 30;
  final Icon leftArrow = const Icon(Icons.keyboard_arrow_left);
  final Icon rightArrow = const Icon(Icons.keyboard_arrow_right);

  @override
  void initState() {
    width = COLL_WIDTH;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> files =
        widget.files.map((e) => Path.basename(e.path)).toList();
    List<TextButton> btns = List.empty(growable: true);
    for (int i = 0; i < files.length; i++) {
      final TextStyle style = i == idx
          ? const TextStyle(color: Colors.blue)
          : const TextStyle(color: Colors.black);
      btns.add(TextButton(
        onPressed: () {
          setState(() {
            idx = i;
            widget.changeIdx(idx);
          });
        },
        child: Text(files[i], style: style),
      ));
    }

    Widget content = Column(children: [
      Expanded(
          child: ListView(
        children: expanded ? btns : List.empty(),
      )),
      Container(
          height: 100,
          child: expanded
              ? Column(children: [
                  Expanded(
                      child: ListView(
                    children: [
                      Text(
                        "Uri: ${widget.files[idx].path}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.indigo),
                      ),
                      Text(
                        "Size: ${Util.getReadableFileSize(widget.files[idx].lengthSync())}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.teal),
                      )
                    ],
                  )),
                  Text("${1 + idx}/${files.length}"),
                ])
              : Column()),
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
}
