import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kael_file_browser/players/AbstractPlayer.dart';
import 'package:photo_view/photo_view.dart';

class PhotoPlayer extends AbstractPlayer {
  static List<String> supportExt = ['.jpg', '.jpeg', '.png'];

  static bool support(String ext) {
    return supportExt.contains(ext);
  }

  File file;

  PhotoPlayer(this.file);

  _PhotoPlayerState state = _PhotoPlayerState();

  @override
  State<PhotoPlayer> createState() {
    return state;
  }
}

class _PhotoPlayerState extends State<PhotoPlayer> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return PhotoView(imageProvider: FileImage(widget.file));
  }
}
