import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kael_file_browser/players/AbstructPlayer.dart';
import 'package:kael_file_browser/players/GifPlayer.dart';
import 'package:kael_file_browser/players/PhotoPlayer.dart';
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
  VideoPlayer videoPlayer = VideoPlayer();

  void resetFile() {
    file = EMPTY_FILE;
    videoPlayer.stop();
  }

  void playOrPause() {
    if (!file.existsSync()) {
      return;
    }
    if (Util.isVideo(file.path)) {
      videoPlayer.playOrPause();
    }
    setState(() {});
  }

  void play(File? f) {
    file = f ?? file;

    try {
      if (Util.isVideo(file.path)) {
        videoPlayer.play(file);
      }
    } catch (e) {
      Util.showInfoDialog(context, 'Vlc Error', e.toString());
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    resetFile();
  }

  @override
  Widget build(BuildContext context) {
    AbstractPlayer player;
    print("MediaPlayer rebuilding...");
    if (Util.isImage(file.path)) {
      player = PhotoPlayer(file);
    } else if (Util.isGif(file.path)) {
      player = GifPlayer();
    } else if (Util.isVideo(file.path)) {
      player = videoPlayer;
    } else {
      return const Text("Please pick a folder");
    }
    player.stop();
    player.play(file);

    return player;
  }
}
