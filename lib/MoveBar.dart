import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class MoveBar extends StatelessWidget {
  final btnHeight = 30.0;

  /// To generate buttons when key is button text, value is move history dst
  final Map<String, String> name2Dst;

  /// All buttons' click event
  final Function btnCallback;

  const MoveBar(this.name2Dst, this.btnCallback, {super.key});

  @override
  Widget build(BuildContext context) {
    List<SubMovement> subMovements = generateEntries();
    return Wrap(
      spacing: 2,
      children: subMovements.map((e) => buildButton(e)).toList(),
    );
  }

  Widget buildButton(SubMovement subMovement) {
    var mainButton = Container(
        height: btnHeight,
        child: ElevatedButton(
            onPressed: () {
              btnCallback(subMovement._dst);
            },
            child: Text(subMovement._name)));
    if (!subMovement.hasChildren()) {
      return mainButton;
    }

    List<DropdownMenuItem<SubMovement>> menuItems = [];
    for (MapEntry<String, String> child in subMovement._children.entries) {
      menuItems.add(DropdownMenuItem(
        value: SubMovement(child.key, child.value, {}),
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
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              customButton: const Icon(
                Icons.list,
                size: 25,
                color: Colors.cyan,
              ),
              items: menuItems,
              onChanged: (entry) {
                btnCallback((entry! as SubMovement)._dst);
              },
              dropdownStyleData: DropdownStyleData(
                width: 160,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.cyan,
                ),
                offset: const Offset(0, 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<SubMovement> generateEntries() {
    Map<String, SubMovement> subMovements = {};
    for (String name in name2Dst.keys) {
      // $parent/$self
      int index = name.indexOf("/");
      if (index == -1 && !subMovements.containsKey(name)) {
        subMovements[name] = SubMovement(name, name2Dst[name]!, {});
        continue;
      }
      String parent = name.substring(0, index);
      String self = name.substring(index + 1);
      if (!subMovements.containsKey(parent)) {
        subMovements[parent] = SubMovement(parent, name2Dst[parent]!, {});
      }
      subMovements[parent]!.addChildren(self, name2Dst[name]!);
    }
    return subMovements.values.toList();
  }
}

class SubMovement {
  final String _name;
  final String _dst;
  final Map<String, String> _children;

  SubMovement(this._name, this._dst, this._children);

  void addChildren(String name, String dst) {
    _children[name] = dst;
  }

  bool hasChildren() {
    return _children.isNotEmpty;
  }
}
