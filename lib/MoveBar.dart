import 'package:flutter/material.dart';

class MoveBar extends StatelessWidget {
  /// To generate buttons when key is button text, value is movement dst
  final Map<String, String> name2Dst;

  /// All buttons' click event
  final Function btnCallback;

  const MoveBar(this.name2Dst, this.btnCallback, {super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: generateBtns(),
    );
  }

  List<ElevatedButton> generateBtns() {
    return name2Dst.entries
        .map((e) => ElevatedButton(
            onPressed: () {
              btnCallback(e.value);
            },
            child: Text(e.key)))
        .toList();
  }
}
