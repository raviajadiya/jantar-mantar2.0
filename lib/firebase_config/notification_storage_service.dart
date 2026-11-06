import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_notification_model.dart';

/// Persistent Local Storage Manager for Notifications using SharedPreferences
class NotificationStorageService {
  static const String _storageKey = 'jantar_mantar_notifications_list';
  static const int _maxNotifications = 50;

  /// Reactive Notifiers for real-time UI synchronization
  static final ValueNotifier<List<AppNotificationModel>> notificationsNotifier =
      ValueNotifier<List<AppNotificationModel>>([]);

  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  static bool _isLoaded = false;

  /// Initialize and load stored notifications
  static Future<List<AppNotificationModel>> loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_storageKey) ?? [];

      final list = rawList
          .map((jsonStr) {
            try {
              final map = jsonDecode(jsonStr) as Map<String, dynamic>;
              return AppNotificationModel.fromJson(map);
            } catch (e) {
              return null;
            }
          })
          .whereType<AppNotificationModel>()
          .toList();

      // Sort by newest first
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      _isLoaded = true;
      _updateNotifiers(list);
      return list;
    } catch (e) {
      debugPrint('[NotificationStorage] Error loading notifications: $e');
      return [];
    }
  }

  /// Save a new notification (prepends to list, saves to storage)
  static Future<void> saveNotification(AppNotificationModel notification) async {
    try {
      if (!_isLoaded) {
        await loadNotifications();
      }

      final currentList = List<AppNotificationModel>.from(notificationsNotifier.value);

      // Check if already exists by id to avoid duplicates
      final existingIndex = currentList.indexWhere((n) => n.id == notification.id);
      if (existingIndex >= 0) {
        currentList[existingIndex] = notification;
      } else {
        currentList.insert(0, notification);
      }

      // Limit max notifications
      if (currentList.length > _maxNotifications) {
        currentList.removeRange(_maxNotifications, currentList.length);
      }

      await _persistList(currentList);
      _updateNotifiers(currentList);
    } catch (e) {
      debugPrint('[NotificationStorage] Error saving notification: $e');
    }
  }

  /// Directly save notification (suitable for background message isolate)
  static Future<void> saveNotificationDirectly(AppNotificationModel notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_storageKey) ?? [];

      final list = rawList
          .map((jsonStr) {
            try {
              final map = jsonDecode(jsonStr) as Map<String, dynamic>;
              return AppNotificationModel.fromJson(map);
            } catch (_) {
              return null;
            }
          })
          .whereType<AppNotificationModel>()
          .toList();

      final existingIndex = list.indexWhere((n) => n.id == notification.id);
      if (existingIndex >= 0) {
        list[existingIndex] = notification;
      } else {
        list.insert(0, notification);
      }

      if (list.length > _maxNotifications) {
        list.removeRange(_maxNotifications, list.length);
      }

      final encodedList = list.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList(_storageKey, encodedList);

      _updateNotifiers(list);
    } catch (e) {
      debugPrint('[NotificationStorage] Error in saveNotificationDirectly: $e');
    }
  }

  /// Retrieve a stored notification by its ID
  static AppNotificationModel? getNotificationById(String id) {
    try {
      final list = notificationsNotifier.value;
      return list.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Mark single notification as read
  static Future<void> markAsRead(String id) async {
    try {
      final currentList = List<AppNotificationModel>.from(notificationsNotifier.value);
      final index = currentList.indexWhere((n) => n.id == id);
      if (index >= 0 && !currentList[index].isRead) {
        currentList[index].isRead = true;
        await _persistList(currentList);
        _updateNotifiers(currentList);
      }
    } catch (e) {
      debugPrint('[NotificationStorage] Error marking as read: $e');
    }
  }

  /// Mark all notifications as read
  static Future<void> markAllAsRead() async {
    try {
      final currentList = List<AppNotificationModel>.from(notificationsNotifier.value);
      for (var item in currentList) {
        item.isRead = true;
      }
      await _persistList(currentList);
      _updateNotifiers(currentList);
    } catch (e) {
      debugPrint('[NotificationStorage] Error marking all as read: $e');
    }
  }

  /// Delete single notification
  static Future<void> deleteNotification(String id) async {
    try {
      final currentList = List<AppNotificationModel>.from(notificationsNotifier.value);
      currentList.removeWhere((n) => n.id == id);
      await _persistList(currentList);
      _updateNotifiers(currentList);
    } catch (e) {
      debugPrint('[NotificationStorage] Error deleting notification: $e');
    }
  }

  /// Clear all notifications
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      _updateNotifiers([]);
    } catch (e) {
      debugPrint('[NotificationStorage] Error clearing notifications: $e');
    }
  }

  /// Persist list to SharedPreferences
  static Future<void> _persistList(List<AppNotificationModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = list.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  /// Update ValueNotifiers
  static void _updateNotifiers(List<AppNotificationModel> list) {
    notificationsNotifier.value = List.unmodifiable(list);
    final unread = list.where((n) => !n.isRead).length;
    unreadCountNotifier.value = unread;
  }
}

