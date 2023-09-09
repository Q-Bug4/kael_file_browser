import 'package:localstore/localstore.dart';

class LocalStorageRepository {
  final _db = Localstore.instance;

  final String _collectionName;
  final String _docName;

  LocalStorageRepository(this._collectionName, this._docName);

  /// get config map from local storage
  Future<Map<String, dynamic>?> getConfig() async {
    return _db.collection(_collectionName).doc(_docName).get();
  }

  /// set config into local storage
  Future<void> setConfig(Map<String, dynamic> configMap) async {
    _db.collection(_collectionName).doc(_docName).set(configMap);
  }
}