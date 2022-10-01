import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

class SideFileinfo extends StatefulWidget {
  const SideFileinfo({Key? key}) : super(key: key);

  @override
  State<SideFileinfo> createState() => _SideFileinfoState();
}

class _SideFileinfoState extends State<SideFileinfo> {
  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: SidebarXController(selectedIndex: 0),
      extendedTheme: SidebarXTheme(width: 200),
      items: const [
        SidebarXItem(icon: Icons.home, label: 'Home'),
        SidebarXItem(icon: Icons.search, label: 'Search'),
      ],
    );
    // Your app screen body
  }
}
