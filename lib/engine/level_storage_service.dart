import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent Local Storage Manager for Game Level Progress using SharedPreferences
class LevelStorageService {
  static const String _unlockedLevelKey = 'jantar_mantar_unlocked_level';
  static const String _lastCompletedLevelKey = 'jantar_mantar_last_completed_level';

  /// Reactive Notifier for highest unlocked level (starts at 1)
  static final ValueNotifier<int> unlockedLevelNotifier = ValueNotifier<int>(1);

  static int _unlockedLevel = 1;
  static int _lastCompletedLevel = 0;
  static bool _isLoaded = false;

  /// Highest level currently unlocked by the player (minimum 1)
  static int get unlockedLevel => _unlockedLevel;

  /// Highest level completed by the player (0 if none completed yet)
  static int get lastCompletedLevel => _lastCompletedLevel;

  /// Total levels completed count
  static int get completedLevelsCount => math.max(0, _unlockedLevel - 1);

  static bool get isLoaded => _isLoaded;

  /// Initialize and load saved level progress from SharedPreferences
  static Future<int> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUnlocked = prefs.getInt(_unlockedLevelKey) ?? 1;
      final savedCompleted = prefs.getInt(_lastCompletedLevelKey) ?? 0;

      _lastCompletedLevel = math.max(0, savedCompleted);
      _unlockedLevel = math.max(
        1,
        math.max(savedUnlocked, _lastCompletedLevel + 1),
      );
      _isLoaded = true;
      unlockedLevelNotifier.value = _unlockedLevel;

      debugPrint(
        '[LevelStorage] Loaded -> unlockedLevel: $_unlockedLevel, lastCompletedLevel: $_lastCompletedLevel',
      );
      return _unlockedLevel;
    } catch (e) {
      debugPrint('[LevelStorage] Error loading level progress: $e');
      _unlockedLevel = 1;
      _lastCompletedLevel = 0;
      unlockedLevelNotifier.value = 1;
      return 1;
    }
  }

  /// Mark [completedLevel] as completed and persist the next unlocked level
  static Future<void> markLevelCompleted(int completedLevel) async {
    final safeCompleted = math.max(1, completedLevel);
    final nextLevel = safeCompleted + 1;

    // Update in-memory state synchronously so immediate navigation reflects it
    if (safeCompleted > _lastCompletedLevel) {
      _lastCompletedLevel = safeCompleted;
    }
    if (nextLevel > _unlockedLevel) {
      _unlockedLevel = nextLevel;
    }
    _isLoaded = true;
    unlockedLevelNotifier.value = _unlockedLevel;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastCompletedLevelKey, _lastCompletedLevel);
      await prefs.setInt(_unlockedLevelKey, _unlockedLevel);
      debugPrint(
        '[LevelStorage] Saved -> completed: $_lastCompletedLevel, unlockedLevel: $_unlockedLevel',
      );
    } catch (e) {
      debugPrint('[LevelStorage] Error saving level progress: $e');
    }
  }
}
