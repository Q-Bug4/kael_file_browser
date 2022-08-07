import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
// import 'package:path/path.dart' as path;

void main() => runApp(const MyApp());

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
  String direcctory = "";
  String imgPath = "/home/kael/Pictures/CoolMarket/1.jpg";

  @override
  void initState() {
    direcctory = "/home/kael/Pictures/CoolMarket/";
    print(Directory(direcctory).listSync());
    imgs = Directory(direcctory).listSync().map((e) => File(e.path)).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Sample Code'),
        // ),
        body: Center(
            child: PhotoView(
          imageProvider: AssetImage(imgs.length > 0 ? imgs[imgIdx].path : ""),
        )),
        bottomNavigationBar: ButtonBar(
          children: [
            ElevatedButton(onPressed: () {}, child: Text("Open folder")),
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
