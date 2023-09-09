import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:kael_file_browser/LocalStorageRepository.dart';

class ConfigManager {
  Map<String, dynamic>? local = {};
  late LocalStorageRepository repository;
  final String collectionName;
  final String docName;

  ConfigManager({required this.collectionName, required this.docName}) {
    repository = LocalStorageRepository(collectionName, docName);
  }

  Future<void> init() async {
    local = await repository.getConfig();
    if (local == null) {
      var jsonStr = await rootBundle.loadString('assets/emptyMovement.json');
      setLocal(json.decode(jsonStr));
    }
  }

  setLocal(Map<String, dynamic> map) {
    repository.setConfig(map).then((ignored) => local = map);
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
        .map((key, value) => MapEntry(key, _defaultDst(key, value)));
  }

  /// while given movement value is empty, use key as the dst folder
  String _defaultDst(String key, String dst) {
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
