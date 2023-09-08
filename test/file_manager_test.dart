import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kael_file_browser/FileManager.dart';
import 'package:kael_file_browser/FileSystemUtil.dart';
import 'package:kael_file_browser/MoveHistory.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'file_manager_test.mocks.dart';

@GenerateMocks([FileSystemUtil])
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
    test("should list files in dir", () {
      final stubFileSystemUtil = MockFileSystemUtil();
      var expectedFiles = [File("stubFile1.mp4")];
      when(stubFileSystemUtil.listFiles("/")).thenReturn(expectedFiles);

      var fileManager = FileManager.withUtil([], stubFileSystemUtil);
      fileManager.readFilesOfDir("/");

      expect(fileManager.getAllFile(), expectedFiles);
    });

    test("should filter unexpect files when not media file in dir", () {
      final stubFileSystemUtil = MockFileSystemUtil();
      var expectedFiles = [File("stubFile1.mp4"), File("notExceptedFile.abc")];
      when(stubFileSystemUtil.listFiles("/")).thenReturn(expectedFiles);

      var fileManager = FileManager.withUtil([], stubFileSystemUtil);
      fileManager.readFilesOfDir("/");

      expect(fileManager.getAllFile(), [expectedFiles.first]);
    });

    test("should move file when given correct dst", () {
      final stubFileSystemUtil = MockFileSystemUtil();
      bool moved = false;
      MoveHistory history = MoveHistory(src: "/src/stubFile.mp4", dst: "/dst/stubFile.mp4");
      when(stubFileSystemUtil.moveFile(history.src, history.dst)).thenAnswer((realInvocation) {
        moved = true;
      });

      var fileManager = FileManager.withUtil([File("/src/stubFile.mp4")], stubFileSystemUtil);
      fileManager.moveFileTo("/dst");
      expect(moved, true);
    });

    test("should throw exception when move error", () {
      final stubFileSystemUtil = MockFileSystemUtil();
      MoveHistory history = MoveHistory(src: "/src/stubFile.mp4", dst: "/dst/stubFile.mp4");
      when(stubFileSystemUtil.moveFile(history.src, history.dst)).thenThrow(Exception("stub exception"));

      var fileManager = FileManager.withUtil([File("/src/stubFile.mp4")], stubFileSystemUtil);
      expect(() => fileManager.moveFileTo("/dst"), throwsA(isA<Exception>()));
    });

    test("should bring file back when file is moved", () {
      final stubFileSystemUtil = MockFileSystemUtil();
      bool isUndo = false;
      MoveHistory history = MoveHistory(src: "/src/stubFile.mp4", dst: "/dst/stubFile.mp4");
      when(stubFileSystemUtil.moveFile(history.src, history.dst)).thenReturn("");
      when(stubFileSystemUtil.moveFile(history.dst, history.src)).thenAnswer((realInvocation) {
        isUndo = true;
      });

      var fileManager = FileManager.withUtil([File("/src/stubFile.mp4")], stubFileSystemUtil);
      fileManager.moveFileTo("/dst");
      fileManager.undoMovement();
      expect(isUndo, true);
    });

    test("should throw exception when undo move error", () {
      final stubFileSystemUtil = MockFileSystemUtil();
      MoveHistory history = MoveHistory(src: "/src/stubFile.mp4", dst: "/dst/stubFile.mp4");
      when(stubFileSystemUtil.moveFile(history.dst, history.src)).thenThrow(Exception("stub exception"));

      var fileManager = FileManager.withUtil([File("/src/stubFile.mp4")], stubFileSystemUtil);
      fileManager.moveFileTo("/dst");
      expect(() => fileManager.undoMovement(), throwsA(isA<Exception>()));
    });
  });
}