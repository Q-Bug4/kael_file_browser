import 'dart:convert';

import 'package:kael_file_browser/AssetRepository.dart';
import 'package:kael_file_browser/LocalStorageRepository.dart';

class ConfigManager {
  Map<String, dynamic>? local = {};
  late LocalStorageRepository repository;
  late AssetRepository assetRepository;
  final String collectionName;
  final String docName;

  ConfigManager({required this.collectionName, required this.docName}) {
    repository = LocalStorageRepository(collectionName, docName);
    assetRepository = AssetRepository();
  }

  ConfigManager.withRepo(
      {required this.collectionName,
      required this.docName,
      required this.repository,
      required this.assetRepository});

  Future<void> init() async {
    local = await repository.getConfig();
    if (local == null) {
      var jsonStr = await assetRepository.loadAssetFile('assets/initConfig.json');
      await setLocal(json.decode(jsonStr));
    }
  }

  setLocal(Map<String, dynamic> map) async {
    await repository.setConfig(map);
    local = map;
  }

  Map<String, dynamic>? getLocal() {
    return local;
  }

  Map<String, String> getMovements() {
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

  setPath(path) async {
    local!['path'] = path;
    setLocal(local!);
  }
}
