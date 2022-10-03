import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;

class Util {
  static String moveFile(String src, String dst) {
    String msg = "";
    if (src.isEmpty || dst.isEmpty) {
      return msg;
    }
    try {
      File dstTmp = File(dst);
      if (!dstTmp.existsSync()) {
        dstTmp.parent.createSync(recursive: true);
      }
      File(src).renameSync(dst);
    } catch (e) {
      msg = e.toString();
    }
    return msg;
    // return Process.runSync('mv', [src, dst]).stderr.toString();
  }

  static String getUserDirectory() {
    String home = "/";
    Map<String, String> envVars = Platform.environment;
    if (Platform.isMacOS) {
      home = envVars['HOME'] ?? home;
    } else if (Platform.isLinux) {
      home = envVars['HOME'] ?? home;
    } else if (Platform.isWindows) {
      home = envVars['UserProfile'] ?? home;
    }
    return home;
  }

  static bool isVideo(String filename) {
    List exts = List.of(<String>[
      '.mp4',
      '.m4v',
      '.mov',
      '.wmv',
      '.avi',
      '.avchd',
      '.flv,',
      '.f4v,',
      '.swf',
      '.mkv'
    ]);
    return exts.contains(Path.extension(filename.toLowerCase()));
  }

  static bool isGif(String filename) {
    List exts = List.of(<String>['.gif']);
    return exts.contains(Path.extension(filename.toLowerCase()));
  }

  static bool isImage(String filename) {
    List exts = List.of(<String>['.jpg', '.jpeg', '.png']);
    // TODO add gif frames viewer and rm this add statement
    exts.add('.gif');
    return exts.contains(Path.extension(filename.toLowerCase()));
  }

  static Future<void> showInfoDialog(
      BuildContext context, String title, String content) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: content.split("\n").map((e) => Text(e)).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static String getReadableFileSize(int bytes) {
    List<String> units = List.of(<String>["B", "KB", "MB", "GB"]);
    final double STEP_CNT = 1024;
    int unitIdx = 0;
    double result = bytes.toDouble();
    while (result >= STEP_CNT) {
      result /= STEP_CNT;
      unitIdx++;
    }
    return result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 2) +
        units[unitIdx];
  }
}
