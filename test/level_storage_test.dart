import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jantarmantar/engine/level_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LevelStorageService', () {
    test('defaults to Level 1 on fresh install', () async {
      SharedPreferences.setMockInitialValues({});
      final loaded = await LevelStorageService.init();

      expect(loaded, 1);
      expect(LevelStorageService.unlockedLevel, 1);
      expect(LevelStorageService.lastCompletedLevel, 0);
      expect(LevelStorageService.completedLevelsCount, 0);
    });

    test('persists next unlocked level after completing a level and restores on relaunch', () async {
      SharedPreferences.setMockInitialValues({});
      await LevelStorageService.init();

      await LevelStorageService.markLevelCompleted(1);
      expect(LevelStorageService.unlockedLevel, 2);
      expect(LevelStorageService.lastCompletedLevel, 1);
      expect(LevelStorageService.completedLevelsCount, 1);

      // Simulate cold restart loading from the same SharedPreferences store
      final reloaded = await LevelStorageService.init();
      expect(reloaded, 2);
      expect(LevelStorageService.unlockedLevel, 2);
      expect(LevelStorageService.lastCompletedLevel, 1);
      expect(LevelStorageService.completedLevelsCount, 1);
    });

    test('does not downgrade highest unlocked level when replaying earlier level', () async {
      SharedPreferences.setMockInitialValues({
        'jantar_mantar_unlocked_level': 5,
        'jantar_mantar_last_completed_level': 4,
      });
      await LevelStorageService.init();

      await LevelStorageService.markLevelCompleted(2);
      expect(LevelStorageService.unlockedLevel, 5);
      expect(LevelStorageService.lastCompletedLevel, 4);

      final reloaded = await LevelStorageService.init();
      expect(reloaded, 5);
    });

    test('advances normally when highest unlocked level is completed', () async {
      SharedPreferences.setMockInitialValues({
        'jantar_mantar_unlocked_level': 3,
        'jantar_mantar_last_completed_level': 2,
      });
      await LevelStorageService.init();

      await LevelStorageService.markLevelCompleted(3);
      expect(LevelStorageService.unlockedLevel, 4);
      expect(LevelStorageService.lastCompletedLevel, 3);
      expect(LevelStorageService.completedLevelsCount, 3);
    });
  });
}
