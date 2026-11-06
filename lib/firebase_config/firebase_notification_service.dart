import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_notification_model.dart';
import '../utils/network_utils.dart';
import '../screens/notification_list_screen.dart';
import 'firebase_analytics_service.dart';
import 'notification_storage_service.dart';

/// Top-level background message handler for terminated & background states
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('[FCM Background] Received message: ${message.messageId}');
    final notification = AppNotificationModel.fromRemoteMessage(message);
    await NotificationStorageService.saveNotificationDirectly(notification);
  } catch (e) {
    debugPrint('[FCM Background] Handler error: $e');
  }
}

/// Main Firebase Push Notification Service
class FirebaseNotificationService {
  /// Global Navigation Key used to route from any app state
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'jantar_mantar_alerts', // id
    'Jantar Mantar Alerts', // title
    description: 'Notifications for game updates, events, and gameplay alerts',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static bool hasPendingNotificationLaunch = false;
  static String? pendingOpenUrl;
  static bool isNotificationScreenOpen = false;

  static bool _isInitialized = false;
  static bool _hasRequestedPermission = false;

  /// Requests notification permission only when internet is available
  static Future<void> requestPermissionIfOnline() async {
    if (_hasRequestedPermission) return;
    try {
      final isOnline = await NetworkUtils.hasInternetConnection();
      if (!isOnline) return;

      _hasRequestedPermission = true;
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('[FCM] Online permission status: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('[FCM] requestPermissionIfOnline error: $e');
    }
  }

  /// Initialize Firebase Messaging & Local Notifications
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize notification storage
      await NotificationStorageService.loadNotifications();

      // 2. Request FCM permissions only when internet is available
      final isOnline = await NetworkUtils.hasInternetConnection();
      final messaging = FirebaseMessaging.instance;

      if (isOnline) {
        _hasRequestedPermission = true;
        final settings = await messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        debugPrint('[FCM] Online permission status: ${settings.authorizationStatus}');
      } else {
        debugPrint('[FCM] Offline: Skipping notification permission request.');
      }

      // 3. Configure Android notification channel
      if (!kIsWeb && Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_channel);
      }

      // 4. Initialize Local Notifications Plugin
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          debugPrint('[FCM] Local notification tapped with payload: ${response.payload}');
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            final item = NotificationStorageService.getNotificationById(payload);
            if (item != null) {
              await handleNotificationAction(item);
              return;
            }
          }
          navigateToNotificationList();
        },
      );

      // Check if launched from local notification tap in killed state
      final notificationAppLaunchDetails =
          await _localNotifications.getNotificationAppLaunchDetails();
      if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
        final payload = notificationAppLaunchDetails?.notificationResponse?.payload;
        debugPrint('[FCM] App launched from local notification tap, payload: $payload');
        if (payload != null && payload.isNotEmpty) {
          final item = NotificationStorageService.getNotificationById(payload);
          if (item != null && item.hasOpenUrl) {
            pendingOpenUrl = item.openUrl;
          } else {
            hasPendingNotificationLaunch = true;
          }
        } else {
          hasPendingNotificationLaunch = true;
        }
      }

      // 5. Configure Foreground Notification Presentation (iOS)
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 6. Register Background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 7. Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM Foreground] Message received: ${message.notification?.title}');
        final notification = AppNotificationModel.fromRemoteMessage(message);
        NotificationStorageService.saveNotification(notification);
        _showLocalNotification(notification);
      });

      // 8. Background / App Inactive notification click listener
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FCM onMessageOpenedApp] Notification clicked!');
        final notification = AppNotificationModel.fromRemoteMessage(message);
        NotificationStorageService.saveNotification(notification);
        handleNotificationAction(notification);
      });

      // 9. Terminated State: Handle notification when app is launched from killed state
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[FCM InitialMessage] Launched from terminated state: ${initialMessage.messageId}');
        final notification = AppNotificationModel.fromRemoteMessage(initialMessage);
        await NotificationStorageService.saveNotification(notification);
        if (notification.hasOpenUrl) {
          debugPrint('[FCM InitialMessage] Found open_url: ${notification.openUrl}');
          pendingOpenUrl = notification.openUrl;
        } else {
          hasPendingNotificationLaunch = true;
        }
      }

      // 10. Fetch & log FCM Token
      _logFCMToken();

      _isInitialized = true;
      debugPrint('[FCM] FirebaseNotificationService initialized successfully.');
    } catch (e) {
      debugPrint('[FCM] Error initializing notification service: $e');
    }
  }

  /// Launch external URL using url_launcher with automatic scheme prefixing
  static Future<bool> launchExternalUrl(String urlString) async {
    try {
      final trimmed = urlString.trim();
      if (trimmed.isEmpty) return false;

      final String formattedUrl;
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        formattedUrl = trimmed;
      } else {
        formattedUrl = 'https://$trimmed';
      }

      final uri = Uri.tryParse(formattedUrl);
      if (uri != null) {
        debugPrint('[Notification] Launching URL via url_launcher: $formattedUrl');
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('[Notification] Error launching URL ($urlString): $e');
    }
    return false;
  }

  /// Handle notification tap redirection:
  /// - If open_url exists in custom data, launch it via url_launcher.
  /// - Otherwise, navigate to NotificationListScreen.
  static Future<void> handleNotificationAction(AppNotificationModel notification) async {
    await FirebaseAnalyticsService.instance.logNotificationOpened(
      notificationId: notification.id,
      title: notification.title,
    );
    if (notification.hasOpenUrl) {
      debugPrint('[FCM] open_url detected: ${notification.openUrl}. Launching browser...');
      await launchExternalUrl(notification.openUrl!);
    } else {
      navigateToNotificationList();
    }
  }

  /// Display a heads-up local notification when in foreground
  static Future<void> _showLocalNotification(AppNotificationModel item) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(
          item.body,
          htmlFormatBigText: false,
          contentTitle: item.title,
          htmlFormatContentTitle: false,
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final notificationId = item.id.hashCode & 0x7fffffff;

      await _localNotifications.show(
        id: notificationId,
        title: item.title,
        body: item.body,
        notificationDetails: notificationDetails,
        payload: item.id,
      );
    } catch (e) {
      debugPrint('[FCM] Error displaying local notification: $e');
    }
  }

  /// Navigate to NotificationListScreen safely using global navigatorKey
  static void navigateToNotificationList() {
    if (isNotificationScreenOpen) {
      debugPrint('[FCM] NotificationListScreen is already open. Skipping duplicate navigation.');
      return;
    }

    final navState = navigatorKey.currentState;
    if (navState != null) {
      navState.push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const NotificationListScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(curved),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        ),
      );
    } else {
      // If navigator state is not ready yet, set flag so it will navigate when the root/dashboard is ready
      hasPendingNotificationLaunch = true;
    }
  }

  /// Get and print FCM Token
  static Future<String?> _logFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('==================================================');
      debugPrint('[FCM Token]: $token');
      debugPrint('==================================================');
      return token;
    } catch (e) {
      debugPrint('[FCM] Could not get FCM token: $e');
      return null;
    }
  }
}

