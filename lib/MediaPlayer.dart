import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kael_file_browser/PlayerFactory.dart';
import 'package:kael_file_browser/players/AbstractPlayer.dart';

class MediaPlayer extends StatefulWidget {
  MediaPlayer({Key? key}) : super(key: key);
  _MediaPlayerState state = _MediaPlayerState();

  void playOrPause() {
    state.playOrPause();
  }

  void stop() {
    state.stop();
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
  PlayerFactory playerFactory = PlayerFactory();
  late AbstractPlayer player;

  _MediaPlayerState() {
    player = playerFactory.getDefaultPlayer();
  }

  void stop() {
    player.stop();
  }

  void playOrPause() {
    player.playOrPause();
    setState(() {});
  }

  void play(File file) {
    player.stop();
    player = playerFactory.getPlayer(file);
    setState(() {
      player.play(file);
    });
  }

  @override
  void initState() {
    super.initState();
    stop();
  }

  @override
  Widget build(BuildContext context) {
    return player;
  }
}
