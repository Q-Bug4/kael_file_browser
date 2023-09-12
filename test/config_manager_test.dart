import 'package:flutter_test/flutter_test.dart';
import 'package:kael_file_browser/AssetRepository.dart';
import 'package:kael_file_browser/ConfigManager.dart';
import 'package:kael_file_browser/LocalStorageRepository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'config_manager_test.mocks.dart';


@GenerateMocks([LocalStorageRepository, AssetRepository])
void main() {
  group("Config manager init", () {
    test("should read default config when local storage is null", () async {
      MockLocalStorageRepository stubRepo = MockLocalStorageRepository();
      when(stubRepo.getConfig()).thenAnswer((_) => Future(() => null));
      when(stubRepo.setConfig(any)).thenAnswer((_) => Future(() => null));

      MockAssetRepository mockAssetRepo = MockAssetRepository();
      when(mockAssetRepo.loadAssetFile(any)).thenAnswer((realInvocation) => "{}");

      ConfigManager manager = ConfigManager.withRepo(collectionName: "colTest", docName: "docTest", repository: stubRepo, assetRepository: mockAssetRepo);
      await manager.init();
      verify(mockAssetRepo.loadAssetFile(any));
    });

    test("should set local storage when local storage is null", () async {
      MockLocalStorageRepository mockRepo = MockLocalStorageRepository();
      when(mockRepo.getConfig()).thenAnswer((_) => Future(() => null));

      MockAssetRepository stubAssetRepo = MockAssetRepository();
      when(stubAssetRepo.loadAssetFile('assets/initConfig.json')).thenAnswer((_) => Future(() => "{}"));

      ConfigManager manager = ConfigManager.withRepo(collectionName: "colTest", docName: "docTest", repository: mockRepo, assetRepository: stubAssetRepo);
      await manager.init();
      verify(mockRepo.setConfig(any));
    });

    test("should set filed local when local storage is null", () async {
      MockLocalStorageRepository stubRepo = MockLocalStorageRepository();
      when(stubRepo.getConfig()).thenAnswer((_) => Future(() => null));
      when(stubRepo.setConfig(any)).thenAnswer((_) => Future(() => null));

      MockAssetRepository stubAssetRepo = MockAssetRepository();
      when(stubAssetRepo.loadAssetFile('assets/initConfig.json')).thenAnswer((_) => Future(() => "{}"));

      ConfigManager manager = ConfigManager.withRepo(collectionName: "colTest", docName: "docTest", repository: stubRepo, assetRepository: stubAssetRepo);
      await manager.init();
      var local = manager.getLocal();
      expect(local != null, true);
      expect(local!.isEmpty, true);
    });
  });

  group("Config manager set local", () {
    test("should call repo setConfig", () async {
      MockLocalStorageRepository mockRepo = MockLocalStorageRepository();

      ConfigManager manager = ConfigManager.withRepo(collectionName: "colTest", docName: "docTest", repository: mockRepo, assetRepository: AssetRepository());
      await manager.setLocal({});
      verify(mockRepo.setConfig(any));
    });

    test("should set field local", () async {
      MockLocalStorageRepository stubRepo = MockLocalStorageRepository();
      when(stubRepo.setConfig(any)).thenAnswer((realInvocation) => Future(() => null));

      ConfigManager manager = ConfigManager.withRepo(collectionName: "colTest", docName: "docTest", repository: stubRepo, assetRepository: AssetRepository());
      await manager.setLocal({});
      expect(manager.getLocal(), {});
    });
  });

  group("Config manager set path", () {
    test("should call repo set local", () async {
      MockLocalStorageRepository mockRepo = MockLocalStorageRepository();
      when(mockRepo.setConfig(any)).thenAnswer((realInvocation) => Future(() => null));

      ConfigManager manager = ConfigManager.withRepo(collectionName: "colTest", docName: "docTest", repository: mockRepo, assetRepository: AssetRepository());
      await manager.setPath("test");
      verify(mockRepo.setConfig(any));
    });

    test("should set path", () {
      MockLocalStorageRepository stubRepo = MockLocalStorageRepository();
      when(stubRepo.setConfig(any)).thenAnswer((realInvocation) => Future(() => null));

      ConfigManager manager = ConfigManager.withRepo(collectionName: "colTest", docName: "docTest", repository: stubRepo, assetRepository: AssetRepository());
      manager.setPath("test");
      expect(manager.getLocal()!['path'], 'test');
    });
  });

  group("Config manager get alias", () {
    test("should get empty map when activate is null", () async {
      MockLocalStorageRepository stubRepo = MockLocalStorageRepository();
      when(stubRepo.setConfig(any)).thenAnswer((realInvocation) => Future(() => null));

      ConfigManager manager = ConfigManager.withRepo(collectionName: "colTest", docName: "docTest", repository: stubRepo, assetRepository: AssetRepository());
      await manager.setLocal({'activate': 'test', 'cases': {}});
      var alias = manager.getMovements();
      expect(alias.isEmpty, true);
    });

    test("should get alias map", () async {
      MockLocalStorageRepository stubRepo = MockLocalStorageRepository();
      when(stubRepo.setConfig(any)).thenAnswer((realInvocation) => Future(() => null));

      ConfigManager manager = ConfigManager.withRepo(collectionName: "colTest", docName: "docTest", repository: stubRepo, assetRepository: AssetRepository());
      var movementMap = {};
      await manager.setLocal({'activate': 'test', 'cases': {'test': movementMap}});
      var alias = manager.getMovements();
      expect(alias, movementMap);
    });
  });
}