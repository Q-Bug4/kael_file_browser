import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kael_file_browser/players/AbstractPlayer.dart';

class TextPlayer extends AbstractPlayer {
  String content;

  TextPlayer(this.content);

  _TextPlayerState state = _TextPlayerState();

  @override
  State<TextPlayer> createState() {
    return state;
  }
}

class _TextPlayerState extends State<TextPlayer> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Text(widget.content);
  }
}
