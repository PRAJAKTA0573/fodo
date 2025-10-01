import 'package:firebase_database/firebase_database.dart';

/// Notification Model - Complete notification information
class NotificationModel {
  final String notificationId;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final String? donationId;
  final String? actionUrl;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.donationId,
    this.actionUrl,
  });

  factory NotificationModel.fromDatabase(Map<String, dynamic> data, String notificationId) {
    return NotificationModel(
      notificationId: notificationId,
      userId: data['userId'] ?? '',
      type: NotificationType.fromString(data['type'] ?? 'general'),
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      data: data['data'] != null ? Map<String, dynamic>.from(data['data'] as Map<Object?, Object?>) : null,
      isRead: data['isRead'] ?? false,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int)
          : DateTime.now(),
      donationId: data['donationId'],
      actionUrl: data['actionUrl'],
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'userId': userId,
      'type': type.value,
      'title': title,
      'body': body,
      'data': data,
      'isRead': isRead,
      'createdAt': ServerValue.timestamp,
      'donationId': donationId,
      'actionUrl': actionUrl,
    };
  }

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      notificationId: notificationId,
      userId: userId,
      type: type,
      title: title,
      body: body,
      data: data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      donationId: donationId,
      actionUrl: actionUrl,
    );
  }
}

/// Notification Type
enum NotificationType {
  donationCreated('donation_created'),
  donationAccepted('donation_accepted'),
  donationOnTheWay('donation_on_the_way'),
  donationReached('donation_reached'),
  donationCollected('donation_collected'),
  donationDistributed('donation_distributed'),
  donationCompleted('donation_completed'),
  donationCancelled('donation_cancelled'),
  newDonationNearby('new_donation_nearby'),
  reminderPickup('reminder_pickup'),
  general('general'),
  system('system');

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.general,
    );
  }

  String get displayName {
    switch (this) {
      case NotificationType.donationCreated:
        return 'Donation Created';
      case NotificationType.donationAccepted:
        return 'Donation Accepted';
      case NotificationType.donationOnTheWay:
        return 'On The Way';
      case NotificationType.donationReached:
        return 'Reached Location';
      case NotificationType.donationCollected:
        return 'Food Collected';
      case NotificationType.donationDistributed:
        return 'Food Distributed';
      case NotificationType.donationCompleted:
        return 'Donation Completed';
      case NotificationType.donationCancelled:
        return 'Donation Cancelled';
      case NotificationType.newDonationNearby:
        return 'New Donation Available';
      case NotificationType.reminderPickup:
        return 'Pickup Reminder';
      case NotificationType.general:
        return 'Notification';
      case NotificationType.system:
        return 'System';
    }
  }
}
