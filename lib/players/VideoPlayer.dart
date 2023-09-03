import 'dart:io';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kael_file_browser/players/AbstructPlayer.dart';
import 'package:kael_file_browser/util.dart';

class VideoPlayer extends AbstractPlayer {
  _MediaPlayerState state = _MediaPlayerState();

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
  State<VideoPlayer> createState() {
    return state;
  }
}

class _MediaPlayerState extends State<VideoPlayer>
    with TickerProviderStateMixin {
  final File EMPTY_FILE = File('');
  late File file;
  Player player = Player(id: 60002);
  late PositionState position;
  bool shouldAutoOpen = false;

  _MediaPlayerState() {
    position = PositionState();
    file = EMPTY_FILE;
  }

  void resetFile() {
    file = EMPTY_FILE;
    player.stop();
  }

  void playOrPause() {
    if (!file.existsSync()) {
      return;
    }
    if (position.position?.inMilliseconds ==
        position.duration?.inMilliseconds) {
      play(file);
    } else {
      player.playOrPause();
    }
  }

  void play(File? f) {
    file = f ?? file;

    try {
      // Media.file() can't open file whose name contains '#'
      var media = Media.asset(file.path);
      player.open(media);
    } catch (e) {
      Util.showInfoDialog(context, 'Vlc Error', e.toString());
    }
  }

  @override
  void initState() {
    super.initState();

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
    if (!Util.isVideo(file.path)) {
      return const Text("Video player need to pick a folder.");
    }
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
              Expanded(
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
                      })),
              Text(formatDuration(player.position.duration)),
            ],
          ))
    ]);
    if (shouldAutoOpen) {
      play(file);
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
