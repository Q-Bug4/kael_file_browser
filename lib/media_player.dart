import 'dart:io';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
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

class _MediaPlayerState extends State<MediaPlayer> {
  final File EMPTY_FILE = File('');
  late File file;
  Player player = Player(id: 60002);
  PositionState position = PositionState();
  bool shouldAutoOpen = false;

  void resetFile() {
    file = EMPTY_FILE;
    player.stop();
  }

  void playOrPause() {
    if (file == EMPTY_FILE) {
      return;
    }
    if (position.position?.inMilliseconds ==
        position.duration?.inMilliseconds) {
      player.open(Media.file(file));
    } else {
      player.playOrPause();
    }
  }

  void play(File f) {
    file = f;
    setState(() {
      player.open(Media.file(file));
    });
  }

  @override
  void initState() {
    super.initState();
    resetFile();
    player.positionStream.listen((PositionState state) {
      if (state.duration!.inMilliseconds == 0) {
        return;
      }
      shouldAutoOpen = false;
      setState(() {
        position = state;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!file.existsSync()) {
      return const Text("Please pick a folder");
    }
    bool isVideo = Util.isVideo(file.path);
    if (!isVideo) {
      player.pause();
    } else if (shouldAutoOpen) {
      player.open(Media.file(file));
    }
    shouldAutoOpen = true;
    Widget widget = isVideo
        ? Video(
            player: player,
            scale: 1.0, // default
            showControls: false,
          )
        : PhotoView(imageProvider: FileImage(file));

    return Column(children: [
      Expanded(
        child: widget,
      ),
      Container(
          height: 40,
          child: Flexible(
              child: Slider(
                  min: 0,
                  max: position.duration!.inMilliseconds.toDouble(),
                  value: position.position!.inMilliseconds.toDouble(),
                  onChanged: (position) {
                    player.seek(
                      Duration(
                        milliseconds: position.toInt(),
                      ),
                    );
                  })))
    ]);
  }
}
