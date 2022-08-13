import 'dart:ffi';
import 'dart:io';
import 'package:path/path.dart' as Path;

class Util {
  static String moveFile(String src, String dst) {
    if (src.isEmpty || dst.isEmpty) {
      return "";
    }
    return Process.runSync('mv', [src, dst]).stderr.toString();
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
      '.mov',
      '.wmv',
      '.avi',
      '.avchd',
      '.flv,',
      '.f4v,',
      '.swf',
      '.mkv'
    ]);
    return exts.contains(Path.extension(filename));
  }

  static bool isImage(String filename) {
    List exts = List.of(<String>['.jpg', '.jpeg', '.png', '.gif']);
    return exts.contains(Path.extension(filename));
  }
}
