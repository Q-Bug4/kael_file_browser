import 'dart:io';

class FileSystemUtil {
  List<File> listFiles(String path) {
    return Directory(path).listSync().map((e) => File(e.path)).toList();
  }

  void moveFile(String src, String dst) {
    if (src.isEmpty || dst.isEmpty) {
      return;
    }
    File dstTmp = File(dst);
    if (!dstTmp.existsSync()) {
      dstTmp.parent.createSync(recursive: true);
    }
    File(src).renameSync(dst);
  }
}
