import 'package:flutter/services.dart';

class AssetRepository {
  loadAssetFile(String path) async {
    return await rootBundle.loadString('assets/emptyMovement.json');
  }
}