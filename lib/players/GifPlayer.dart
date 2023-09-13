import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kael_file_browser/players/AbstractPlayer.dart';

class GifPlayer extends AbstractPlayer {
  static List<String> supportExt = ["gif"];

  static bool support(String ext) {
    return supportExt.contains(ext);
  }

  _GifPlayerState state = _GifPlayerState();

  @override
  void playOrPause() {
    state.playOrPause();
  }

  @override
  void stop() {
    state.resetFile();
  }

  @override
  void play(File file) {
    state.play(file);
  }

  @override
  State<GifPlayer> createState() {
    return state;
  }
}

class _GifPlayerState extends State<GifPlayer> with TickerProviderStateMixin {
  final File EMPTY_FILE = File('');
  late File file;

  _GifPlayerState() {
    file = EMPTY_FILE;
  }

  void resetFile() {
    file = EMPTY_FILE;

    /// TODO implement
    throw Exception("Not implement!");
  }

  void playOrPause() {
    if (!file.existsSync()) {
      return;
    }

    /// TODO implement
    throw Exception("Not implement!");
  }

  void play(File? f) {
    file = f ?? file;

    /// TODO implement
    throw Exception("Not implement!");
  }

  @override
  Widget build(BuildContext context) {
    /// TODO implement
    throw Exception("Not implement!");
  }
}
