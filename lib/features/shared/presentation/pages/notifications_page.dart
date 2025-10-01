import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/notification_provider.dart';
import '../../data/models/notification_model.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.notifications.isEmpty) return const SizedBox.shrink();
              
              return PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'mark_all_read') {
                    await provider.markAllAsRead();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All marked as read')),
                      );
                    }
                  } else if (value == 'clear_all') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear All'),
                        content: const Text('Are you sure you want to clear all notifications?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirmed == true && context.mounted) {
                      await provider.clearAllNotifications();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All notifications cleared')),
                        );
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  if (provider.unreadCount > 0)
                    const PopupMenuItem(
                      value: 'mark_all_read',
                      child: Row(
                        children: [
                          Icon(Icons.done_all, size: 20),
                          SizedBox(width: 8),
                          Text('Mark all as read'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all, size: 20),
                        SizedBox(width: 8),
                        Text('Clear all'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'re all caught up!',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return _buildNotificationCard(context, provider, notification);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationProvider provider,
    NotificationModel notification,
  ) {
    return Dismissible(
      key: Key(notification.notificationId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        provider.deleteNotification(notification.notificationId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted')),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: notification.isRead ? null : Colors.blue.shade50,
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              provider.markAsRead(notification.notificationId);
            }
            _handleNotificationTap(context, notification);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.isRead 
                                    ? FontWeight.normal 
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            timeago.format(notification.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            notification.type.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              color: _getNotificationColor(notification.type),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.donationCreated:
        return Icons.add_circle;
      case NotificationType.donationAccepted:
        return Icons.check_circle;
      case NotificationType.donationOnTheWay:
        return Icons.directions_car;
      case NotificationType.donationReached:
        return Icons.place;
      case NotificationType.donationCollected:
        return Icons.inventory;
      case NotificationType.donationDistributed:
        return Icons.people;
      case NotificationType.donationCompleted:
        return Icons.done_all;
      case NotificationType.donationCancelled:
        return Icons.cancel;
      case NotificationType.newDonationNearby:
        return Icons.restaurant;
      case NotificationType.reminderPickup:
        return Icons.alarm;
      case NotificationType.system:
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.donationCreated:
        return Colors.blue;
      case NotificationType.donationAccepted:
        return Colors.green;
      case NotificationType.donationOnTheWay:
        return Colors.orange;
      case NotificationType.donationReached:
        return Colors.purple;
      case NotificationType.donationCollected:
        return Colors.teal;
      case NotificationType.donationDistributed:
        return Colors.indigo;
      case NotificationType.donationCompleted:
        return Colors.green;
      case NotificationType.donationCancelled:
        return Colors.red;
      case NotificationType.newDonationNearby:
        return Colors.orange;
      case NotificationType.reminderPickup:
        return Colors.amber;
      case NotificationType.system:
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    // Navigate to relevant screen based on notification type
    // This would be implemented based on your navigation setup
    debugPrint('Notification tapped: ${notification.notificationId}');
    debugPrint('Donation ID: ${notification.donationId}');
    
    // Example navigation:
    // if (notification.donationId != null) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (_) => DonationDetailsPage(donationId: notification.donationId!),
    //     ),
    //   );
    // }
  }
}
