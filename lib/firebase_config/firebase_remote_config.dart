import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/network_utils.dart';
import '../widgets/app_update_dialog.dart';

/// Model representing the parsed update configuration for the current platform
class AppUpdateConfig {
  final String updatedBuildNo;
  final bool isApply;
  final bool isCancelable;
  final String storeLink;

  AppUpdateConfig({
    required this.updatedBuildNo,
    required this.isApply,
    required this.isCancelable,
    required this.storeLink,
  });

  factory AppUpdateConfig.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse boolean from "1", 1, true, etc.
    bool parseBool(dynamic value) {
      if (value == null) return false;
      final str = value.toString().trim().toLowerCase();
      return str == "1" || str == "true";
    }

    return AppUpdateConfig(
      updatedBuildNo: (json['updated_build_no'] ?? '').toString().trim(),
      isApply: parseBool(json['is_apply']),
      isCancelable: parseBool(json['is_cancelable']),
      storeLink: (json['store_link'] ?? '').toString().trim(),
    );
  }

  @override
  String toString() {
    return 'AppUpdateConfig(updatedBuildNo: $updatedBuildNo, isApply: $isApply, isCancelable: $isCancelable, storeLink: $storeLink)';
  }
}

/// Service class to manage Firebase Remote Config and App Updates
class FirebaseRemoteConfigService {
  static const String keyAppBasicConfig = 'app_basic_config';
  static const String keyIsAdsDisplay = 'isAdsDisplay';

  /// Standard parameter names supported in Firebase Remote Config Console
  static const List<String> adParamKeys = [
    'isAdsDisplay',
    'is_ads_display',
    'isAds',
    'is_ads',
  ];

  /// Default configuration provided when offline or fallback
  static const Map<String, dynamic> defaultBasicConfig = {
    "force_update": {
      "android": {
        "updated_build_no": "1",
        "is_apply": "0",
        "is_cancelable": "1",
        "store_link": "https://play.google.com/store/apps/details?id=com.envisiontechnolabs.jantarmantar",
      },
      "ios": {
        "updated_build_no": "1",
        "is_cancelable": "0",
        "is_apply": "0",
        "store_link": "",
      }
    },
    "isAdsDisplay": false,
  };

  static FirebaseRemoteConfig? _remoteConfigInstance;

  static FirebaseRemoteConfig get _remoteConfig =>
      _remoteConfigInstance ??= FirebaseRemoteConfig.instance;

  static StreamSubscription<RemoteConfigUpdate>? _configUpdateSubscription;

  /// Safely parses boolean value from bool, string ("true", "1", "false", "0"), int (1, 0), etc.
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final str = value.toString().trim().toLowerCase();
    if (str == "false" || str == "0" || str == "no" || str == "off" || str.isEmpty) {
      return false;
    }
    return str == "true" || str == "1" || str == "yes" || str == "on";
  }

  /// Parses `isAdsDisplay` from raw JSON map/string (app_basic_config).
  /// Returns `null` if no ad key is present in rawConfig.
  static bool? parseIsAdsDisplay(dynamic rawConfig) {
    if (rawConfig == null) return null;

    Map<String, dynamic>? configMap;
    if (rawConfig is String) {
      if (rawConfig.trim().isEmpty) return null;
      try {
        final decoded = jsonDecode(rawConfig);
        if (decoded is Map<String, dynamic>) {
          configMap = decoded;
        } else if (decoded is Map) {
          configMap = Map<String, dynamic>.from(decoded);
        } else {
          return null;
        }
      } catch (e) {
        debugPrint("[RemoteConfig] JSON Decode error for isAdsDisplay: $e");
        return null;
      }
    } else if (rawConfig is Map<String, dynamic>) {
      configMap = rawConfig;
    } else if (rawConfig is Map) {
      configMap = Map<String, dynamic>.from(rawConfig);
    }

    if (configMap == null) return null;

    for (final key in adParamKeys) {
      if (configMap.containsKey(key)) {
        return _parseBool(configMap[key]);
      }
    }

    return null;
  }

  /// Checks for standalone remote parameters ('isAdsDisplay', 'is_ads_display', etc.)
  /// Returns null if none are set remotely by Firebase Console.
  static bool? _getRemoteDirectAdParam() {
    for (final key in adParamKeys) {
      try {
        final val = _remoteConfig.getValue(key);
        if (val.source == ValueSource.valueRemote) {
          final str = val.asString().trim();
          if (str.isNotEmpty) {
            // If the user pasted the entire config JSON into this parameter key
            if (str.startsWith('{')) {
              final jsonParsed = parseIsAdsDisplay(str);
              if (jsonParsed != null) {
                debugPrint("[RemoteConfig] Parsed JSON from parameter '$key': $jsonParsed");
                return jsonParsed;
              }
            }
            final parsed = _parseBool(str);
            debugPrint("[RemoteConfig] Found remote direct parameter '$key': $parsed (raw: '$str')");
            return parsed;
          }
        }
      } catch (e) {
        debugPrint("[RemoteConfig] Error reading remote parameter '$key': $e");
      }
    }
    return null;
  }

  /// Checks inside remote `app_basic_config` JSON parameter.
  /// Returns null if not provided remotely or if key is omitted.
  static bool? _getRemoteJsonAdParam() {
    try {
      final val = _remoteConfig.getValue(keyAppBasicConfig);
      if (val.source == ValueSource.valueRemote) {
        final rawString = val.asString();
        if (rawString.isNotEmpty) {
          final insideJson = parseIsAdsDisplay(rawString);
          if (insideJson != null) {
            debugPrint("[RemoteConfig] Found isAdsDisplay in remote '$keyAppBasicConfig': $insideJson");
            return insideJson;
          }
        }
      }
    } catch (e) {
      debugPrint("[RemoteConfig] Error reading remote '$keyAppBasicConfig': $e");
    }
    return null;
  }

  /// Master Ads Display Switch resolver (kept for future remote config compatibility):
  static bool getIsAdsDisplay() {
    try {
      // 1. Check remote app_basic_config JSON (Primary)
      final jsonRemote = _getRemoteJsonAdParam();
      if (jsonRemote != null) {
        debugPrint("[RemoteConfig] Resolved isAdsDisplay from remote $keyAppBasicConfig: $jsonRemote");
        return jsonRemote;
      }

      // 2. Check remote direct parameter ('isAdsDisplay', 'is_ads_display', etc.)
      final directRemote = _getRemoteDirectAdParam();
      if (directRemote != null) {
        debugPrint("[RemoteConfig] Resolved isAdsDisplay from remote direct parameter: $directRemote");
        return directRemote;
      }

      // 3. Fallback: check cached/default app_basic_config JSON
      final rawString = _remoteConfig.getString(keyAppBasicConfig);
      if (rawString.isNotEmpty) {
        final insideJson = parseIsAdsDisplay(rawString);
        if (insideJson != null) {
          debugPrint("[RemoteConfig] Resolved isAdsDisplay from fallback/cached $keyAppBasicConfig: $insideJson");
          return insideJson;
        }
      }

      // 4. Default fallback: false (ads disabled)
      return false;
    } catch (e) {
      debugPrint("[RemoteConfig] Error reading isAdsDisplay: $e");
      return false;
    }
  }

  /// Fetches Remote Config (fast timeout for offline safety)
  static Future<void> fetchAndApplyConfig() async {
    try {
      await initialize(
        fetchTimeout: const Duration(seconds: 4),
        minimumFetchInterval: Duration.zero,
      );
    } catch (e) {
      debugPrint("[RemoteConfig] Offline or failed to fetch config: $e");
    }
  }

  /// Initialize and configure Firebase Remote Config
  static Future<void> initialize({
    Duration fetchTimeout = const Duration(seconds: 4),
    Duration minimumFetchInterval = Duration.zero,
  }) async {
    try {
      await _remoteConfig.setDefaults({
        keyAppBasicConfig: jsonEncode(defaultBasicConfig),
        keyIsAdsDisplay: false,
      });

      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: fetchTimeout,
          minimumFetchInterval: minimumFetchInterval,
        ),
      );

      // 1. Immediately activate previously cached config (0ms delay)
      await _remoteConfig.activate();

      // 2. Fetch latest from server and activate
      try {
        await _remoteConfig.fetchAndActivate();
        debugPrint("[RemoteConfig] Fetched and activated latest remote config.");
      } catch (e) {
        debugPrint("[RemoteConfig] Fetch error: $e");
      }

      // 3. Listen for real-time config updates from Firebase Console
      _subscribeToRealtimeUpdates();
    } catch (e) {
      debugPrint("[RemoteConfig] Initialization error (falling back to default): $e");
    }
  }

  static void _subscribeToRealtimeUpdates() {
    _configUpdateSubscription?.cancel();
    try {
      _configUpdateSubscription = _remoteConfig.onConfigUpdated.listen(
        (RemoteConfigUpdate event) async {
          debugPrint("[RemoteConfig] Real-time config update received: ${event.updatedKeys}");
          try {
            await _remoteConfig.activate();
          } catch (e) {
            debugPrint("[RemoteConfig] Error activating real-time update: $e");
          }
        },
        onError: (e) {
          debugPrint("[RemoteConfig] Real-time update stream error: $e");
        },
      );
    } catch (e) {
      debugPrint("[RemoteConfig] Real-time updates subscription error: $e");
    }
  }

  /// Parses and returns the AppUpdateConfig for the current platform from raw JSON map/string
  static AppUpdateConfig? parseUpdateConfig(dynamic rawConfig) {
    if (rawConfig == null) return null;

    Map<String, dynamic>? configMap;
    if (rawConfig is String) {
      if (rawConfig.trim().isEmpty) return null;
      try {
        configMap = jsonDecode(rawConfig) as Map<String, dynamic>;
      } catch (e) {
        debugPrint("[RemoteConfig] JSON Decode error: $e");
        return null;
      }
    } else if (rawConfig is Map<String, dynamic>) {
      configMap = rawConfig;
    }

    if (configMap == null) return null;

    final forceUpdate = configMap['force_update'];
    if (forceUpdate is! Map<String, dynamic>) return null;

    Map<String, dynamic>? platformConfig;
    if (kIsWeb) {
      platformConfig = null;
    } else if (Platform.isAndroid) {
      platformConfig = forceUpdate['android'] as Map<String, dynamic>?;
    } else if (Platform.isIOS) {
      platformConfig = forceUpdate['ios'] as Map<String, dynamic>?;
    }

    if (platformConfig == null) return null;
    return AppUpdateConfig.fromJson(platformConfig);
  }

  /// Fetch remote config value and parse platform-specific AppUpdateConfig
  static Future<AppUpdateConfig?> getAppUpdateConfig() async {
    try {
      final isOnline = await NetworkUtils.hasInternetConnection();
      if (!isOnline) {
        debugPrint("[RemoteConfig] Offline: Returning defaultBasicConfig directly.");
        return parseUpdateConfig(defaultBasicConfig);
      }

      await initialize();
      final rawString = _remoteConfig.getString(keyAppBasicConfig);
      debugPrint("[RemoteConfig] Raw config: $rawString");
      final config = parseUpdateConfig(rawString);
      return config ?? parseUpdateConfig(defaultBasicConfig);
    } catch (e) {
      debugPrint("[RemoteConfig] Error fetching config, falling back to default: $e");
      return parseUpdateConfig(defaultBasicConfig);
    }
  }

  /// Main method to check and display the update dialog if needed
  static Future<void> checkAndShowUpdate(BuildContext context) async {
    try {
      final isOnline = await NetworkUtils.hasInternetConnection();
      if (!isOnline) {
        debugPrint("[RemoteConfig] Offline: Skipping update check, app works normally.");
        return;
      }
      // 1. Get current installed app package info
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuildNoStr = packageInfo.buildNumber;
      final currentBuildNo = int.tryParse(currentBuildNoStr) ?? 0;

      // 2. Fetch remote update configuration
      final config = await getAppUpdateConfig();
      if (config == null) {
        debugPrint("[RemoteConfig] No update configuration found.");
        return;
      }

      debugPrint("[RemoteConfig] Current build: $currentBuildNo, Target config: $config");

      // 3. Check if update is active/applied
      if (!config.isApply) {
        debugPrint("[RemoteConfig] is_apply is 0 (Disabled). Skipping dialog.");
        return;
      }

      // 4. Compare build numbers
      final targetBuildNo = int.tryParse(config.updatedBuildNo) ?? 0;
      if (currentBuildNo >= targetBuildNo) {
        debugPrint(
          "[RemoteConfig] App is up to date (current: $currentBuildNo >= target: $targetBuildNo). Skipping dialog.",
        );
        return;
      }

      // 5. Show Update Dialog if current build number is smaller
      if (context.mounted) {
        AppUpdateDialog.show(
          context,
          updatedBuildNo: config.updatedBuildNo,
          currentBuildNo: currentBuildNoStr.isNotEmpty ? currentBuildNoStr : "1",
          currentVersion: packageInfo.version,
          isCancelable: config.isCancelable,
          storeLink: config.storeLink,
        );
      }
    } catch (e) {
      debugPrint("[RemoteConfig] checkAndShowUpdate error: $e");
    }
  }

  /// Helper to get a string value by key
  static String getString(String key) => _remoteConfig.getString(key);

  /// Helper to get a boolean value by key
  static bool getBool(String key) => _remoteConfig.getBool(key);

  /// Helper to get an integer value by key
  static int getInt(String key) => _remoteConfig.getInt(key);
}

