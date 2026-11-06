import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// Notification categories for Jantar Mantar 2.0
enum AppNotificationType {
  update,
  game,
  alert,
  tip,
  general,
}

/// Model representing a stored notification item
class AppNotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final AppNotificationType type;

  AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.data,
    this.type = AppNotificationType.general,
  });

  /// Extracted URL from custom data payload if 'open_url', 'url', 'link' exists
  String? get openUrl {
    if (data == null) return null;
    final val = data!['open_url'] ?? data!['openUrl'] ?? data!['url'] ?? data!['link'];
    if (val != null && val.toString().trim().isNotEmpty) {
      return val.toString().trim();
    }
    return null;
  }

  /// Whether this notification has an actionable external / web link
  bool get hasOpenUrl => openUrl != null && openUrl!.isNotEmpty;

  /// Factory constructor from Firebase RemoteMessage
  factory AppNotificationModel.fromRemoteMessage(RemoteMessage message) {
    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'Jantar Mantar Alert';

    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        'New update available in Jantar Mantar!';

    final imageUrl = message.notification?.android?.imageUrl ??
        message.notification?.apple?.imageUrl ??
        message.data['image_url']?.toString();

    final id = message.messageId ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final typeStr = (message.data['type'] ?? '').toString().toLowerCase();
    final type = _detectType(title, body, typeStr);

    return AppNotificationModel(
      id: id,
      title: title,
      body: body,
      timestamp: message.sentTime ?? DateTime.now(),
      isRead: false,
      imageUrl: imageUrl,
      data: message.data,
      type: type,
    );
  }

  /// Automatically detect notification type for appropriate badges and styling
  static AppNotificationType _detectType(
    String title,
    String body,
    String typeStr,
  ) {
    final combined = '$title $body $typeStr'.toLowerCase();
    if (combined.contains('update') ||
        combined.contains('version') ||
        combined.contains('upgrade') ||
        combined.contains('new feature')) {
      return AppNotificationType.update;
    } else if (combined.contains('game') ||
        combined.contains('score') ||
        combined.contains('flag') ||
        combined.contains('trophy') ||
        combined.contains('police') ||
        combined.contains('circuit') ||
        combined.contains('dharna')) {
      return AppNotificationType.game;
    } else if (combined.contains('alert') ||
        combined.contains('urgent') ||
        combined.contains('warn') ||
        combined.contains('important')) {
      return AppNotificationType.alert;
    } else if (combined.contains('tip') ||
        combined.contains('trick') ||
        combined.contains('hint') ||
        combined.contains('guide')) {
      return AppNotificationType.tip;
    }
    return AppNotificationType.general;
  }

  /// Convert to JSON Map for persistent storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'image_url': imageUrl,
      'data': data,
      'type': type.name,
    };
  }

  /// Factory constructor from JSON Map
  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    AppNotificationType parsedType = AppNotificationType.general;
    try {
      final typeName = json['type']?.toString() ?? '';
      parsedType = AppNotificationType.values.firstWhere(
        (e) => e.name == typeName,
        orElse: () => _detectType(
          json['title']?.toString() ?? '',
          json['body']?.toString() ?? '',
          typeName,
        ),
      );
    } catch (_) {}

    return AppNotificationModel(
      id: (json['id'] ?? DateTime.now().millisecondsSinceEpoch).toString(),
      title: json['title']?.toString() ?? 'Notification',
      body: json['body']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['is_read'] == true ||
          json['is_read'] == 1 ||
          json['is_read'] == '1',
      imageUrl: json['image_url']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : null,
      type: parsedType,
    );
  }

  /// Friendly relative time (e.g., "Just now", "5 mins ago", "2 hrs ago", "Yesterday")
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 45) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins min${mins > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hr${hours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
    }
  }

  /// Label for the category
  String get categoryLabel {
    switch (type) {
      case AppNotificationType.update:
        return 'Update';
      case AppNotificationType.game:
        return 'Arcade';
      case AppNotificationType.alert:
        return 'Alert';
      case AppNotificationType.tip:
        return 'Tip';
      case AppNotificationType.general:
        return 'Notification';
    }
  }

  /// Primary color for badge & accents
  Color get accentColor {
    switch (type) {
      case AppNotificationType.update:
        return const Color(0xFF10B981); // Emerald Green
      case AppNotificationType.game:
        return const Color(0xFFF59E0B); // Amber / Gold
      case AppNotificationType.alert:
        return const Color(0xFFEF4444); // Red
      case AppNotificationType.tip:
        return const Color(0xFF38BDF8); // Sky Blue
      case AppNotificationType.general:
        return const Color(0xFFF59E0B); // Amber
    }
  }

  /// Material icon representing category
  IconData get iconData {
    switch (type) {
      case AppNotificationType.update:
        return Icons.system_update_rounded;
      case AppNotificationType.game:
        return Icons.sports_esports_rounded;
      case AppNotificationType.alert:
        return Icons.priority_high_rounded;
      case AppNotificationType.tip:
        return Icons.lightbulb_rounded;
      case AppNotificationType.general:
        return Icons.notifications_active_rounded;
    }
  }
}

