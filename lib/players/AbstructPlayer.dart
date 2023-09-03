import 'dart:io';
import 'package:flutter/widgets.dart';

abstract class AbstractPlayer extends StatefulWidget {
  void playOrPause();

  void stop();

  void play(File file);
}