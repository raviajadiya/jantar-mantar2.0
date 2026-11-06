import 'dart:io';
import 'package:flutter/foundation.dart';

/// Utility class to check real internet connectivity.
class NetworkUtils {
  static bool? _cachedStatus;
  static DateTime? _lastCheckTime;

  /// Checks whether an active internet connection is available.
  /// Caches result for 8 seconds to prevent multiple redundant network lookups.
  static Future<bool> hasInternetConnection() async {
    if (kIsWeb) return true;

    if (_cachedStatus != null &&
        _lastCheckTime != null &&
        DateTime.now().difference(_lastCheckTime!).inSeconds < 8) {
      return _cachedStatus!;
    }

    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(milliseconds: 1200));
      final hasConn = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      _cachedStatus = hasConn;
      _lastCheckTime = DateTime.now();
      return hasConn;
    } catch (_) {
      try {
        final result = await InternetAddress.lookup('cloudflare.com')
            .timeout(const Duration(milliseconds: 1000));
        final hasConn = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        _cachedStatus = hasConn;
        _lastCheckTime = DateTime.now();
        return hasConn;
      } catch (_) {
        _cachedStatus = false;
        _lastCheckTime = DateTime.now();
        return false;
      }
    }
  }
}

