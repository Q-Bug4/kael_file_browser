import 'package:flutter/material.dart';

class Util {
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
