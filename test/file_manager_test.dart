import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kael_file_browser/FileManager.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([Directory])
void main() {
  group("FileManager file holding", () {
    test("should be empty", () {
      expect(FileManager(List.empty()).isEmpty(), true);
    });

    test("should not be empty", () {
      expect(FileManager([File("")]).isEmpty(), false);
    });

    test("should get file when manager is not empty", () {
      File file = File("");
      expect(FileManager([file]).getCurrentFile(), file);
    });

    test("should get null when manager is empty", () {
      expect(FileManager([]).getCurrentFile(), null);
    });

    test("should get file when current index changed", () {
      List<File> files = [File("first"), File("second"), File("last")];
      var fileManager = FileManager(files);
      expect(fileManager.getCurrentFile(), files[0]);
      fileManager.setFileAt(2);
      expect(fileManager.getCurrentFile(), files[2]);
    });

    test("should get files which passed into manager", () {
      List<File> files = [File("first"), File("second"), File("last")];
      expect(FileManager(files).getAllFile(), files);
    });

    test("should change current file index when index is valid", () {
      List<File> files = [File("first"), File("second"), File("last")];
      var fileManager = FileManager(files);
      expect(fileManager.curIdx, 0);
      fileManager.setFileAt(2);
      expect(fileManager.curIdx, 2);
    });

    test("should change current file index when index is less than 0", () {
      List<File> files = [File("first"), File("second"), File("last")];
      var fileManager = FileManager(files);
      fileManager.setFileAt(-1);
      expect(fileManager.curIdx, 2);
    });

    test("should change current file index when index is larger than files length", () {
      List<File> files = [File("first"), File("second"), File("last")];
      var fileManager = FileManager(files);
      fileManager.setFileAt(4);
      expect(fileManager.curIdx, 1);
    });
  });

  group("FileManager file movement", () {
    // TODO directory list mocking
    test("should list files in dir", () {
      List<File> files = [File("first"), File("second"), File("last")];
      var fileManager = FileManager(files);
      fileManager.readFilesOfDir("/");

    });

    // TODO undo movement mocking
    test("should bring file back when file is moved", () {

    });

    // TODO move file mocking
    test("should move file when given correct dst", () {

    });
  });
}