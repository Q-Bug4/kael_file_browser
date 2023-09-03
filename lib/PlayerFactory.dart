import 'dart:io';

import 'package:kael_file_browser/players/AbstractPlayer.dart';
import 'package:kael_file_browser/players/GifPlayer.dart';
import 'package:kael_file_browser/players/PhotoPlayer.dart';
import 'package:kael_file_browser/players/TextPlayer.dart';
import 'package:kael_file_browser/players/VideoPlayer.dart';
import 'package:kael_file_browser/util.dart';

class PlayerFactory {
  /// singleton
  final VideoPlayer videoPlayer = VideoPlayer();

  /// get player depends on file type
  AbstractPlayer getPlayer(File file) {
    AbstractPlayer player;
    if (Util.isImage(file.path)) {
      player = PhotoPlayer(file);
    } else if (Util.isGif(file.path)) {
      player = GifPlayer();
    } else if (Util.isVideo(file.path)) {
      player = videoPlayer;
    } else {
      player = TextPlayer("Please choose a file or open folder to start.");
    }
    return player;
  }

  /// get default player, normally Text Widget to notice user what to do next.
  AbstractPlayer getDefaultPlayer() {
    return TextPlayer("Please choose a file or open folder to start.");
  }
}