import 'dart:io';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gif/gif.dart';
import 'package:kael_file_browser/players/VideoPlayer.dart';
import 'package:kael_file_browser/util.dart';
import 'package:photo_view/photo_view.dart';

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
  // late GifController gifController;

  bool isGifPlaying = true;
  final File EMPTY_FILE = File('');
  late File file;
  VideoPlayer videoPlayer = VideoPlayer();
  bool shouldAutoOpen = false;

  void resetFile() {
    file = EMPTY_FILE;
    videoPlayer.stop();
  }

  void playOrPause() {
    if (!file.existsSync()) {
      return;
    }
    if (Util.isGif(file.path)) {
      if (isGifPlaying) {
        // gifController.value = gifController.value;
      } else {
        // gifController.forward();
      }
      isGifPlaying = !isGifPlaying;
    } else if (Util.isVideo(file.path)) {
      videoPlayer.playOrPause();
    }
    setState(() {});
  }

  void play(File? f) {
    file = f ?? file;

    isGifPlaying = true;
    try {
      if (Util.isVideo(file.path)) {
        // Media.file() can't open file whose name contains '#'
        // var media = Media.asset(file.path);
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
    // gifController = GifController(vsync: this);
    resetFile();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;
    print("MediaPlayer rebuilding...");
    if (Util.isImage(file.path)) {
      widget = PhotoView(imageProvider: FileImage(file));
    } else if (Util.isGif(file.path)) {
      widget = Column(children: [
        Expanded(
          child: Gif(
              // controller: gifController,
              autostart: Autostart.once,
              image: FileImage(file)),
        ),
      ]);
    } else if (Util.isVideo(file.path)) {
      widget = videoPlayer;
    } else {
      return const Text("Please pick a folder");
    }
    if (!Util.isVideo(file.path)) {
      videoPlayer.stop();
    } else if (shouldAutoOpen) {
      videoPlayer.play(file);
    }
    shouldAutoOpen = true;

    return widget;
  }

  @override
  void dispose() {
    super.dispose();
  }

  String formatDuration(Duration? duration) {
    if (duration == null) {
      return "00:00:00";
    }
    int seconds = duration.inSeconds;
    int minutes = seconds ~/ 60;
    int hours = minutes ~/ 60;
    return "${hours.toString().padLeft(2, '0')}"
        ":${(minutes % 60).toString().padLeft(2, '0')}"
        ":${(seconds % 60).toString().padLeft(2, '0')}";
  }
}
