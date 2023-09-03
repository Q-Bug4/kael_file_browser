import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kael_file_browser/players/AbstractPlayer.dart';
import 'package:kael_file_browser/players/GifPlayer.dart';
import 'package:kael_file_browser/players/PhotoPlayer.dart';
import 'package:kael_file_browser/players/TextPlayer.dart';
import 'package:kael_file_browser/players/VideoPlayer.dart';
import 'package:kael_file_browser/util.dart';

class MediaPlayer extends StatefulWidget {
  MediaPlayer({Key? key}) : super(key: key);
  _MediaPlayerState state = _MediaPlayerState();

  void playOrPause() {
    state.playOrPause();
  }

  void resetFile() {
    state.resetFile();
  }

  void play(File file) {
    state.play(file);
  }

  @override
  State<MediaPlayer> createState() {
    return state;
  }
}

class _MediaPlayerState extends State<MediaPlayer>
    with TickerProviderStateMixin {
  final File EMPTY_FILE = File('');
  late File file;
  late AbstractPlayer player = TextPlayer("Please open folder to start.");

  void resetFile() {
    file = EMPTY_FILE;
  }

  void playOrPause() {
    if (!file.existsSync()) {
      return;
    }
    player.playOrPause();
    setState(() {});
  }

  void play(File? f) {
    player.stop();
    file = f ?? file;
    if (Util.isImage(file.path)) {
      player = PhotoPlayer(file);
    } else if (Util.isGif(file.path)) {
      player = GifPlayer();
    } else if (Util.isVideo(file.path)) {
      player = VideoPlayer();
    } else {
      player = TextPlayer("Please choose a file or open folder to start.");
    }
    setState(() {
      player.play(file);
    });
  }

  @override
  void initState() {
    super.initState();
    resetFile();
  }

  @override
  Widget build(BuildContext context) {
    return player;
  }
}
