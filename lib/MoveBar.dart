import 'package:flutter/material.dart';

class MoveBar extends StatelessWidget {
  final btnHeight = 30.0;

  /// To generate buttons when key is button text, value is movement dst
  final Map<String, String> name2Dst;

  /// All buttons' click event
  final Function btnCallback;

  const MoveBar(this.name2Dst, this.btnCallback, {super.key});

  @override
  Widget build(BuildContext context) {
    List<Entry> entries = generateEntries();
    return Wrap(
      spacing: 2,
      children: entries.map((e) => buildButton(e)).toList(),
    );
  }

  Widget buildButton(Entry entry) {
    var mainButton = Container(
        height: btnHeight,
        child: ElevatedButton(
            onPressed: () {
              btnCallback(entry._dst);
            },
            child: Text(entry._name)));
    if (!entry.hasChildren()) {
      return mainButton;
    }

    List<DropdownMenuItem<Entry>> menuItems = [];
    for (MapEntry<String, String> child in entry._children.entries) {
      menuItems.add(DropdownMenuItem(
        value: Entry(child.key, child.value, {}),
        child: Text(child.key),
      ));
    }

    return Container(
      color: Colors.greenAccent,
      height: btnHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          mainButton,
          DropdownButton<Entry>(
              selectedItemBuilder: (ctx) =>
                  [for (final _ in menuItems) Container()],
              disabledHint: Container(),
              items: menuItems,
              onChanged: (entry) {
                print("item changed: ");
                print(entry);
                btnCallback(entry!._dst);
              }),
        ],
      ),
    );
  }

  /// convert list into structure that can
  /// 1. diff bottom type
  /// 2. describe relation
  List<Entry> generateEntries() {
    Map<String, Entry> entries = {};
    for (String name in name2Dst.keys) {
      // $parent/$self
      int index = name.indexOf("/");
      if (index == -1 && !entries.containsKey(name)) {
        entries[name] = Entry(name, name2Dst[name]!, {});
        continue;
      }
      String parent = name.substring(0, index);
      String self = name.substring(index + 1);
      if (!entries.containsKey(parent)) {
        entries[parent] = Entry(parent, name2Dst[parent]!, {});
      }
      entries[parent]!.addChildren(self, name2Dst[name]!);
    }
    return entries.values.toList();
  }
}

class Entry {
  final String _name;
  final String _dst;
  final Map<String, String> _children;

  Entry(this._name, this._dst, this._children);

  void addChildren(String name, String dst) {
    _children[name] = dst;
  }

  bool hasChildren() {
    return _children.isNotEmpty;
  }
}
