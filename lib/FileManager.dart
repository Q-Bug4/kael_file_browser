import 'dart:io';
import 'package:path/path.dart' as Path;

import 'MoveHistory.dart';

class FileManager {
  FileManager(this.files);

  /// files to manage
  List<File> files;

  /// move history
  List<MoveHistory> movements = List.empty(growable: true);

  /// current handling file's index
  int curIdx = 0;

  bool isEmpty() {
    return files.isEmpty;
  }

  bool isNotEmpty() {
    return files.isNotEmpty;
  }

  File? getOneFile(index) {
    return isEmpty() ? null : files[index];
  }

  File? getCurrentFile() {
    return isEmpty() ? null : files[curIdx];
  }

  List<File> getAllFile() {
    return files;
  }

  void setFiles(List<File> files) {
    this.files = files;
    movements.clear();
  }

  void addFileBeforeCur(File file) {
    files.insert(curIdx, file);
  }

  void removeCurFile() {
    files.removeAt(curIdx);
    rectifyIndex();
  }

  void nextFile() {
    if (isNotEmpty()) {
      curIdx++;
      rectifyIndex();
    }
  }

  void lastFile() {
    if (isNotEmpty()) {
      curIdx--;
      rectifyIndex();
    }
  }

  void setFileAt(index) {
    if (isNotEmpty()) {
      curIdx = index;
      rectifyIndex();
    }
  }

  void rectifyIndex() {
    if (isNotEmpty()) {
      curIdx = (curIdx + files.length) % files.length;
    } else {
      curIdx = 0;
    }
  }

  void addHistory(MoveHistory history) {
    movements.add(history);
  }

  bool isHistoryEmpty() {
    return movements.isEmpty;
  }

  MoveHistory popLastHistory() {
    return movements.removeLast();
  }

  void moveFileTo(String dst) {
    if (isEmpty()) {
      return;
    }
    File file = getCurrentFile()!;
    MoveHistory moveHistory =
        MoveHistory(src: file.path, dst: "$dst/${Path.basename(file.path)}");
    String errMsg = moveHistory.doMove();
    if (errMsg.isNotEmpty) {
      throw Exception("Movement error: $errMsg");
    }
    addHistory(moveHistory);
    removeCurFile();
  }

  void undoMovement() {
    if (isHistoryEmpty()) {
      return;
    }
    MoveHistory moveHistory = popLastHistory();
    String errMsg = moveHistory.undo();
    if (errMsg.isNotEmpty) {
      throw Exception("Movement undo error: $errMsg");
    }
    addFileBeforeCur(File(moveHistory.src));
  }
}
