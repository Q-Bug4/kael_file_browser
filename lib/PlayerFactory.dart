import 'dart:io';

import 'package:kael_file_browser/players/AbstractPlayer.dart';
import 'package:kael_file_browser/players/GifPlayer.dart';
import 'package:kael_file_browser/players/PhotoPlayer.dart';
import 'package:kael_file_browser/players/TextPlayer.dart';
import 'package:kael_file_browser/players/VideoPlayer.dart';
import 'package:path/path.dart' as Path;

class PlayerFactory {
  /// singleton
  final VideoPlayer videoPlayer = VideoPlayer();

  /// get player depends on file type
  AbstractPlayer getPlayer(File file) {
    String ext = Path.extension(file.path);
    AbstractPlayer player;
    if (PhotoPlayer.support(ext)) {
      player = PhotoPlayer(file);
    } else if (GifPlayer.support(ext)) {
      player = GifPlayer();
    } else if (VideoPlayer.support(ext)) {
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