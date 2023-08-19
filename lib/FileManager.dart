import 'dart:io';

import 'movement.dart';

class FileManager {
  FileManager(this.files);

  /// files to manage
  List<File> files;

  /// move history
  List<Movement> movements = List.empty(growable: true);

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

  void addFileToLast(File file) {
    files.add(file);
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

  void removeFileAt(index) {
    if (isNotEmpty()) {
      files.removeAt(index);
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

  void addHistory(Movement history) {
    movements.add(history);
  }

  bool isHistoryEmpty() {
    return movements.isEmpty;
  }

  Movement popLastHistory() {
    return movements.removeLast();
  }
}