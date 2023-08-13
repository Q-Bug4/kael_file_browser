import 'dart:io';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gif/gif.dart';
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
  Player player = Player(id: 60002);
  PositionState position = PositionState();
  bool shouldAutoOpen = false;

  void resetFile() {
    setState(() {
      file = EMPTY_FILE;
      player.stop();
    });
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
      if (position.position?.inMilliseconds ==
          position.duration?.inMilliseconds) {
        play(file);
      } else {
        player.playOrPause();
      }
    }
  }

  void play(File? f) {
    setState(() {
      file = f ?? file;
    });

    isGifPlaying = true;
    try {
      if (Util.isVideo(file.path)) {
        var media = Media.file(file);
        player.open(media);
      }
    } catch (e) {
      Util.showInfoDialog(context, 'Vlc Error', e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    // gifController = GifController(vsync: this);

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
    Widget widget;
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
        // Container(
        //     height: 40,
        //     child: AnimatedBuilder(
        //       animation: gifController,
        //       builder: (context, child) {
        //         return Slider(
        //             value: gifController.value.toDouble(),
        //             onChanged: (position) {
        //               gifController.value = position;
        //               isGifPlaying = false;
        //             });
        //       },
        //     ))
      ]);
    } else if (Util.isVideo(file.path)) {
      widget = Column(children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              playOrPause();
            },
            child: Video(
              player: player,
              scale: 1.0, // default
              showControls: false,
            ),
          ),
        ),
        Container(
            height: 40,
            child: Row(
              children: [
                Text(formatDuration(player.position.position)),
                Expanded(child: Slider(
                    min: 0,
                    max: position.duration!.inMilliseconds.toDouble(),
                    value: position.position!.inMilliseconds.toDouble(),
                    onChanged: (position) {
                      player.seek(
                        Duration(
                          milliseconds: position.toInt(),
                        ),
                      );
                    })),
                Text(formatDuration(player.position.duration)),
              ],
            ))
      ]);
    } else {
      return const Text("Please pick a folder");
    }
    if (!Util.isVideo(file.path)) {
      player.pause();
    } else if (shouldAutoOpen) {
      play(file);
    }
    shouldAutoOpen = true;

    return widget;
  }

  @override
  void dispose() {
    // gifController.dispose();
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
