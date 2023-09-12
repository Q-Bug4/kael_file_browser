import 'dart:io';
import 'package:kael_file_browser/FileSystemUtil.dart';
import 'package:kael_file_browser/util.dart';
import 'package:path/path.dart' as Path;

import 'MoveHistory.dart';

class FileManager {
  FileManager(this.files) {
    fileSystemUtil = FileSystemUtil();
  }

  FileManager.withUtil(this.files, this.fileSystemUtil);

  late FileSystemUtil fileSystemUtil;

  /// files to manage
  late List<File> files;

  /// move history
  List<MoveHistory> moveHistoryList = List.empty(growable: true);

  /// current handling file's index
  int curIdx = 0;

  bool isEmpty() {
    return files.isEmpty;
  }

  File? getCurrentFile() {
    return isEmpty() ? null : files[curIdx];
  }

  List<File> getAllFile() {
    return files;
  }

  /// list files in dir and replace held files
  void readFilesOfDir(String path) {
    List<File> files = fileSystemUtil.listFiles(path)
    // TODO move file format validation into other component
        .where((p) =>
            Util.isGif(p.path) || Util.isImage(p.path) || Util.isVideo(p.path))
        .toList();
    this.files = files;
    moveHistoryList.clear();
  }

  void setFileAt(index) {
    if (isEmpty()) {
      return;
    }
    curIdx = index;
    _rectifyIndex();
  }

  void _rectifyIndex() {
    curIdx = isEmpty() ? 0 : (curIdx + files.length) % files.length;
  }

  void moveFileTo(String dst) {
    if (isEmpty()) {
      return;
    }
    File file = getCurrentFile()!;
    MoveHistory moveHistory =
        MoveHistory(src: file.path, dst: "$dst/${Path.basename(file.path)}");
    fileSystemUtil.moveFile(moveHistory.src, moveHistory.dst);
    moveHistoryList.add(moveHistory);
    files.removeAt(curIdx);
    _rectifyIndex();
  }

  void undoMovement() {
    if (moveHistoryList.isEmpty) {
      return;
    }
    MoveHistory moveHistory = moveHistoryList.removeLast();
    fileSystemUtil.moveFile(moveHistory.dst, moveHistory.src);
    files.insert(curIdx, File(moveHistory.src));
  }
}
