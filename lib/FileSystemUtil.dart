import 'dart:io';

class FileSystemUtil {
  List<File> listFiles(String path) {
    return Directory(path).listSync().map((e) => File(e.path)).toList();
  }

  String moveFile(String src, String dst) {
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
  }
}