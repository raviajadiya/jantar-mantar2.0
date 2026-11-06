import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../firebase_config/firebase_analytics_service.dart';
import '../firebase_config/firebase_notification_service.dart';
import '../firebase_config/notification_storage_service.dart';
import '../models/app_notification_model.dart';

/// Notification Center Screen for Jantar Mantar 2.0
class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseNotificationService.isNotificationScreenOpen = true;
    NotificationStorageService.loadNotifications();
  }

  @override
  void dispose() {
    FirebaseNotificationService.isNotificationScreenOpen = false;
    super.dispose();
  }

  Future<void> _handleClearAll(BuildContext context) async {
    HapticFeedback.lightImpact();
    final count = NotificationStorageService.notificationsNotifier.value.length;
    if (count == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF334155), width: 1.5),
        ),
        title: const Text(
          'Clear Notifications?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        content: const Text(
          'Are you sure you want to remove all notifications? This cannot be undone.',
          style: TextStyle(
            fontSize: 13.5,
            color: Color(0xFF94A3B8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'CLEAR ALL',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await NotificationStorageService.clearAll();
      FirebaseAnalyticsService.instance.logNotificationsCleared(clearedCount: count);
    }
  }

  void _showNotificationDetail(BuildContext context, AppNotificationModel item) {
    NotificationStorageService.markAsRead(item.id);
    FirebaseAnalyticsService.instance.logNotificationItemClicked(
      notificationId: item.id,
      title: item.title,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: const Border(
              top: BorderSide(color: Color(0xFFF59E0B), width: 2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Category & Time
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.accentColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: item.accentColor.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.iconData, size: 14, color: item.accentColor),
                        const SizedBox(width: 5),
                        Text(
                          item.categoryLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: item.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    item.formattedTime,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Title
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              // Body
              Text(
                item.body,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.5,
                  color: Color(0xFFCBD5E1),
                ),
              ),

              // Image if exists
              if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
              ],

              // External link button
              if (item.hasOpenUrl) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      FirebaseNotificationService.launchExternalUrl(item.openUrl!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: const Color(0xFF0F172A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.open_in_new_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'OPEN LINK',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const Text(
              'NOTIFICATIONS',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<int>(
              valueListenable: NotificationStorageService.unreadCountNotifier,
              builder: (context, unread, _) {
                if (unread == 0) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "$unread",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          ValueListenableBuilder<List<AppNotificationModel>>(
            valueListenable: NotificationStorageService.notificationsNotifier,
            builder: (context, list, _) {
              if (list.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFEF4444)),
                tooltip: 'Clear All',
                onPressed: () => _handleClearAll(context),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<AppNotificationModel>>(
        valueListenable: NotificationStorageService.notificationsNotifier,
        builder: (context, notifications, _) {
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ValueListenableBuilder<int>(
            valueListenable: NotificationStorageService.unreadCountNotifier,
            builder: (context, unreadCount, _) {
              return Column(
                children: [
                  _buildStatusBar(notifications.length, unreadCount),
                  Expanded(
                    child: RefreshIndicator(
                      color: const Color(0xFFF59E0B),
                      backgroundColor: const Color(0xFF1E293B),
                      onRefresh: () async {
                        await NotificationStorageService.loadNotifications();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: notifications.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = notifications[index];
                          return _buildNotificationCard(context, item);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBar(int total, int unread) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF1E293B),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            unread > 0
                ? '$total Total • $unread Unread'
                : '$total Notifications',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
          ),
          const Spacer(),
          if (unread > 0)
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                NotificationStorageService.markAllAsRead();
              },
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  'Mark all as read',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    AppNotificationModel item,
  ) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      onDismissed: (_) {
        NotificationStorageService.deleteNotification(item.id);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showNotificationDetail(context, item),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: item.isRead
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: item.isRead
                    ? const Color(0xFF334155).withValues(alpha: 0.6)
                    : const Color(0xFFF59E0B).withValues(alpha: 0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Icon Badge
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: item.accentColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.accentColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Icon(item.iconData, color: item.accentColor, size: 22),
                ),

                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: item.accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.categoryLabel,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: item.accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.formattedTime,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const Spacer(),
                          if (!item.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      if (item.hasOpenUrl) ...[
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.link_rounded, size: 13, color: Color(0xFFF59E0B)),
                            SizedBox(width: 4),
                            Text(
                              'Open Link',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 40,
                color: Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'NO NOTIFICATIONS YET',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Stay tuned for gameplay events, updates, and circuit challenges!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

