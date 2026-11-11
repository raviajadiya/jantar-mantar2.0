import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Single common service class for managing all Firebase Analytics events.
/// Contains central event names and type-safe logging methods for all key app features.
class FirebaseAnalyticsService {
  static final FirebaseAnalyticsService _instance =
      FirebaseAnalyticsService._internal();

  static FirebaseAnalyticsService get instance => _instance;

  factory FirebaseAnalyticsService() => _instance;

  FirebaseAnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Initializes analytics, enables collection, and logs app open
  static Future<void> initialize() async {
    try {
      await _instance._analytics.setAnalyticsCollectionEnabled(true);
      await _instance._analytics.logAppOpen();
      if (kDebugMode) {
        debugPrint('[FirebaseAnalytics] Initialized & App Open logged successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirebaseAnalytics] Init error: $e');
      }
    }
  }

  /// Underlying FirebaseAnalytics instance
  FirebaseAnalytics get analytics => _analytics;

  /// Navigation observer for automatic screen tracking
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ===========================================================================
  // EVENT NAMES (Central Constants)
  // ===========================================================================

  // 1. App Update & Notifications
  static const String eventUpdateDialogShown = 'update_dialog_shown';
  static const String eventUpdateDialogAction = 'update_dialog_action';
  static const String eventNotificationOpened = 'notification_opened';
  static const String eventNotificationItemClicked = 'notification_item_clicked';
  static const String eventNotificationsCleared = 'notifications_cleared';

  // 2. Gameplay Events
  static const String eventGameStarted = 'game_started';
  static const String eventGameWon = 'game_won';
  static const String eventGameArrested = 'game_arrested';
  static const String eventFlagCollected = 'flag_collected';

  // 3. User Preferences & Settings
  static const String eventThemeChanged = 'theme_changed';
  static const String eventAudioToggled = 'audio_toggled';
  static const String eventInAppReviewTriggered = 'in_app_review_triggered';

  // ===========================================================================
  // GENERIC LOGGER
  // ===========================================================================
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      if (kDebugMode) {
        debugPrint('[FirebaseAnalytics] Event logged: $name, params: $parameters');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirebaseAnalytics] Error logging event $name: $e');
      }
    }
  }

  // ===========================================================================
  // UPDATE DIALOG & NOTIFICATION EVENTS
  // ===========================================================================

  Future<void> logUpdateDialogShown({
    required String updatedBuildNo,
    required String currentBuildNo,
    required bool isCancelable,
  }) async {
    await logEvent(
      name: eventUpdateDialogShown,
      parameters: {
        'updated_build_no': updatedBuildNo,
        'current_build_no': currentBuildNo,
        'is_cancelable': isCancelable ? 1 : 0,
        'force_update': isCancelable ? 0 : 1,
      },
    );
  }

  Future<void> logUpdateDialogAction({
    required String action,
    required String updatedBuildNo,
  }) async {
    await logEvent(
      name: eventUpdateDialogAction,
      parameters: {
        'action': action,
        'updated_build_no': updatedBuildNo,
      },
    );
  }

  Future<void> logNotificationOpened({
    required String notificationId,
    required String title,
  }) async {
    await logEvent(
      name: eventNotificationOpened,
      parameters: {
        'notification_id': notificationId,
        'notification_title': title,
      },
    );
  }

  Future<void> logNotificationItemClicked({
    required String notificationId,
    required String title,
  }) async {
    await logEvent(
      name: eventNotificationItemClicked,
      parameters: {
        'notification_id': notificationId,
        'notification_title': title,
      },
    );
  }

  Future<void> logNotificationsCleared({required int clearedCount}) async {
    await logEvent(
      name: eventNotificationsCleared,
      parameters: {
        'count': clearedCount,
      },
    );
  }

  // ===========================================================================
  // GAMEPLAY FEATURE EVENT METHODS
  // ===========================================================================

  Future<void> logGameStarted({
    required String playerName,
    required String country,
    int level = 1,
  }) async {
    await logEvent(
      name: eventGameStarted,
      parameters: {
        'player_name': playerName,
        'country': country,
        'level': level,
      },
    );
  }

  Future<void> logGameWon({
    required double timeSeconds,
    required int flagsCollected,
    int level = 1,
  }) async {
    await logEvent(
      name: eventGameWon,
      parameters: {
        'level': level,
        'time_seconds': double.parse(timeSeconds.toStringAsFixed(1)),
        'flags_collected': flagsCollected,
      },
    );
  }

  Future<void> logGameArrested({
    required double timeSeconds,
    required int flagsCollected,
    int level = 1,
  }) async {
    await logEvent(
      name: eventGameArrested,
      parameters: {
        'level': level,
        'time_seconds': double.parse(timeSeconds.toStringAsFixed(1)),
        'flags_collected': flagsCollected,
      },
    );
  }

  Future<void> logFlagCollected({
    required String flagCountry,
    required int remainingFlags,
  }) async {
    await logEvent(
      name: eventFlagCollected,
      parameters: {
        'flag_country': flagCountry,
        'remaining_flags': remainingFlags,
      },
    );
  }

  Future<void> logThemeChanged({
    required String themeName,
  }) async {
    await logEvent(
      name: eventThemeChanged,
      parameters: {
        'theme_name': themeName,
      },
    );
  }

  Future<void> logAudioToggled({
    required bool musicEnabled,
    required bool sfxEnabled,
  }) async {
    await logEvent(
      name: eventAudioToggled,
      parameters: {
        'music_enabled': musicEnabled ? 1 : 0,
        'sfx_enabled': sfxEnabled ? 1 : 0,
      },
    );
  }

  Future<void> logInAppReviewTriggered({
    required String source,
    int? level,
  }) async {
    await logEvent(
      name: eventInAppReviewTriggered,
      parameters: {
        'source': source,
        'level': ?level,
      },
    );
  }
}

