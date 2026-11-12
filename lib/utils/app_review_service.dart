import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import '../firebase_config/firebase_analytics_service.dart';

/// Shared helper for triggering Android / iOS native In-App Review flow safely
class AppReviewService {
  AppReviewService._();

  static final InAppReview _inAppReview = InAppReview.instance;

  /// Requests the system In-App Review dialog.
  ///
  /// Set [fallbackToStore] to `true` for explicit Rating buttons (like in Settings)
  /// so devices without native in-app review support can open the Play Store listing.
  static Future<void> requestInAppReview({
    required String source,
    int? level,
    bool fallbackToStore = false,
  }) async {
    try {
      FirebaseAnalyticsService.instance.logInAppReviewTriggered(
        source: source,
        level: level,
      );

      final isAvailable = await _inAppReview.isAvailable().timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );

      if (isAvailable) {
        await _inAppReview.requestReview();
        debugPrint('[AppReview] Native requestReview completed (source: $source)');
      } else if (fallbackToStore) {
        await _inAppReview.openStoreListing();
        debugPrint('[AppReview] Fallback openStoreListing invoked (source: $source)');
      } else {
        debugPrint('[AppReview] In-app review not available (source: $source)');
      }
    } catch (e) {
      debugPrint('[AppReview] Error requesting review ($source): $e');
      if (fallbackToStore) {
        try {
          await _inAppReview.openStoreListing();
        } catch (storeErr) {
          debugPrint('[AppReview] Store listing fallback error: $storeErr');
        }
      }
    }
  }
}

