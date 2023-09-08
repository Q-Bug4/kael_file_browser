import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:localstore/localstore.dart';

class ConfigManager {
  Map<String, dynamic>? local = {};
  final db = Localstore.instance;
  final String collectionName;
  final String docName;

  ConfigManager({required this.collectionName, required this.docName});

  Future<void> init() async {
    local = await db.collection(collectionName).doc(docName).get();
    if (local == null) {
      var jsonStr = await rootBundle.loadString('assets/emptyMovement.json');
      setLocal(json.decode(jsonStr));
    }
  }

  setLocal(Map<String, dynamic> map) {
    db.collection(collectionName).doc(docName).set(map).then((value) => {});
    local = map;
  }

  getLocal() {
    return local;
  }

  Map<String, String> getAlias() {
    String activate = local!['activate'];
    var activateCase = local!['cases'][activate];
    if (activateCase == null) {
      return Map.identity();
    }
    String movementStr = json.encode(activateCase);
    return Map<String, dynamic>.from(jsonDecode(movementStr))
        .map((key, value) => MapEntry(key, value.toString()))
        .map((key, value) => MapEntry(key, defaultDst(key, value)));
  }

  /// while given movement value is empty, use key as the dst folder
  String defaultDst(String key, String dst) {
    if (dst == "") {
      return key;
    }
    return dst;
  }

  String getPath() {
    return local!['path'];
  }

  setPath(path) {
    local!['path'] = path;
    setLocal(local!);
  }
}
