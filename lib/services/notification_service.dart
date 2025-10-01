import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../features/shared/data/models/notification_model.dart';

/// Notification Service - Handles FCM and in-app notifications
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  
  String? _fcmToken;
  StreamSubscription<DatabaseEvent>? _notificationsSubscription;

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ User granted notification permission');
        
        // Get FCM token
        _fcmToken = await _messaging.getToken();
        debugPrint('📱 FCM Token: $_fcmToken');
        
        // Setup message handlers
        _setupMessageHandlers();
      } else {
        debugPrint('❌ User declined notification permission');
      }
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  /// Setup FCM message handlers
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📬 Foreground message received');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');
      
      // Handle foreground notification
      _handleMessage(message);
    });

    // Background message tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📱 Notification tapped (background)');
      _handleMessageTap(message);
    });

    // Check for initial message (app opened from terminated state)
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint('📱 App opened from notification (terminated)');
        _handleMessageTap(message);
      }
    });
  }

  /// Handle incoming message
  void _handleMessage(RemoteMessage message) {
    // You can show local notification or in-app banner here
    // For now, we just log it
    debugPrint('Handling message: ${message.messageId}');
  }

  /// Handle notification tap
  void _handleMessageTap(RemoteMessage message) {
    final data = message.data;
    debugPrint('Notification tapped with data: $data');
    
    // Navigate to relevant screen based on notification type
    // This will be handled by the app's navigation logic
  }

  /// Get FCM token
  String? get fcmToken => _fcmToken;

  /// Save FCM token to database for user
  Future<void> saveFCMToken(String userId) async {
    if (_fcmToken == null) return;
    
    try {
      await _database.ref('users/$userId/fcmToken').set(_fcmToken);
      debugPrint('✅ FCM token saved for user: $userId');
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }

  /// Send notification to database (for in-app display)
  Future<String?> sendNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? donationId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notificationRef = _database.ref('notifications/$userId').push();
      final notificationId = notificationRef.key;
      
      if (notificationId == null) return null;
      
      final notification = NotificationModel(
        notificationId: notificationId,
        userId: userId,
        type: type,
        title: title,
        body: body,
        data: data,
        createdAt: DateTime.now(),
        donationId: donationId,
      );
      
      await notificationRef.set(notification.toDatabase());
      debugPrint('✅ Notification sent to user: $userId');
      
      return notificationId;
    } catch (e) {
      debugPrint('❌ Error sending notification: $e');
      return null;
    }
  }

  /// Get user notifications stream
  Stream<List<NotificationModel>> getUserNotificationsStream(String userId) {
    return _database
        .ref('notifications/$userId')
        .orderByChild('createdAt')
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data == null) return <NotificationModel>[];
      
      final Map<dynamic, dynamic> notificationsMap = data as Map<dynamic, dynamic>;
      final notifications = notificationsMap.entries.map((entry) {
        final notificationData = Map<String, dynamic>.from(entry.value as Map<Object?, Object?>);
        return NotificationModel.fromDatabase(notificationData, entry.key.toString());
      }).toList();
      
      // Sort by date descending
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return notifications;
    });
  }

  /// Mark notification as read
  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _database
          .ref('notifications/$userId/$notificationId/isRead')
          .set(true);
      debugPrint('✅ Notification marked as read: $notificationId');
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _database
          .ref('notifications/$userId')
          .get();
      
      if (snapshot.value == null) return;
      
      final Map<dynamic, dynamic> notifications = snapshot.value as Map<dynamic, dynamic>;
      final updates = <String, dynamic>{};
      
      for (var entry in notifications.entries) {
        updates['notifications/$userId/${entry.key}/isRead'] = true;
      }
      
      await _database.ref().update(updates);
      debugPrint('✅ All notifications marked as read for user: $userId');
    } catch (e) {
      debugPrint('❌ Error marking all notifications as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      await _database
          .ref('notifications/$userId/$notificationId')
          .remove();
      debugPrint('✅ Notification deleted: $notificationId');
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications(String userId) async {
    try {
      await _database.ref('notifications/$userId').remove();
      debugPrint('✅ All notifications cleared for user: $userId');
    } catch (e) {
      debugPrint('❌ Error clearing notifications: $e');
    }
  }

  /// Get unread count
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _database
          .ref('notifications/$userId')
          .orderByChild('isRead')
          .equalTo(false)
          .get();
      
      if (snapshot.value == null) return 0;
      
      final Map<dynamic, dynamic> notifications = snapshot.value as Map<dynamic, dynamic>;
      return notifications.length;
    } catch (e) {
      debugPrint('❌ Error getting unread count: $e');
      return 0;
    }
  }

  /// Send notification for donation created (to nearby NGOs)
  Future<void> notifyNearbyNGOs({
    required String donationId,
    required String donorName,
    required String foodType,
    required int estimatedPeople,
    required List<String> ngoIds,
  }) async {
    final title = 'New Donation Available';
    final body = '$donorName has donated $foodType that can feed $estimatedPeople people';
    
    for (final ngoId in ngoIds) {
      await sendNotification(
        userId: ngoId,
        title: title,
        body: body,
        type: NotificationType.newDonationNearby,
        donationId: donationId,
        data: {
          'donorName': donorName,
          'foodType': foodType,
          'estimatedPeople': estimatedPeople,
        },
      );
    }
  }

  /// Send notification for donation accepted (to donor)
  Future<void> notifyDonorAccepted({
    required String donorId,
    required String ngoName,
    required String donationId,
  }) async {
    await sendNotification(
      userId: donorId,
      title: 'Donation Accepted',
      body: '$ngoName has accepted your donation and will pick it up soon',
      type: NotificationType.donationAccepted,
      donationId: donationId,
      data: {'ngoName': ngoName},
    );
  }

  /// Send notification for donation status update (to donor)
  Future<void> notifyDonorStatusUpdate({
    required String donorId,
    required String ngoName,
    required String status,
    required String donationId,
  }) async {
    String title = 'Donation Update';
    String body = '';
    NotificationType type;
    
    switch (status) {
      case 'on_the_way':
        title = 'On The Way';
        body = '$ngoName is on the way to collect your donation';
        type = NotificationType.donationOnTheWay;
        break;
      case 'reached':
        title = 'Reached Location';
        body = '$ngoName has reached your location';
        type = NotificationType.donationReached;
        break;
      case 'collected':
        title = 'Food Collected';
        body = '$ngoName has collected your donation';
        type = NotificationType.donationCollected;
        break;
      case 'distributed':
        title = 'Food Distributed';
        body = '$ngoName has distributed your donation to people in need';
        type = NotificationType.donationDistributed;
        break;
      case 'completed':
        title = 'Donation Completed';
        body = 'Your donation has been successfully completed. Thank you for making a difference!';
        type = NotificationType.donationCompleted;
        break;
      default:
        body = 'Your donation status has been updated';
        type = NotificationType.general;
    }
    
    await sendNotification(
      userId: donorId,
      title: title,
      body: body,
      type: type,
      donationId: donationId,
      data: {'ngoName': ngoName, 'status': status},
    );
  }

  /// Send pickup reminder to NGO
  Future<void> sendPickupReminder({
    required String ngoId,
    required String donationId,
    required String donorName,
  }) async {
    await sendNotification(
      userId: ngoId,
      title: 'Pickup Reminder',
      body: 'Don\'t forget to pick up the donation from $donorName',
      type: NotificationType.reminderPickup,
      donationId: donationId,
      data: {'donorName': donorName},
    );
  }

  /// Dispose resources
  void dispose() {
    _notificationsSubscription?.cancel();
  }
}

/// Background message handler (top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📬 Background message received: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
}
