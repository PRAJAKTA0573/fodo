import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../services/notification_service.dart';
import '../../data/models/notification_model.dart';

/// Notification Provider - Manages notification state
class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService;
  final String userId;

  StreamSubscription<List<NotificationModel>>? _notificationsSubscription;
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  NotificationProvider({
    required NotificationService notificationService,
    required this.userId,
  }) : _notificationService = notificationService {
    _initialize();
  }

  // Getters
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  
  List<NotificationModel> get readNotifications =>
      _notifications.where((n) => n.isRead).toList();

  /// Initialize notifications stream
  void _initialize() {
    _loadNotifications();
    _loadUnreadCount();
  }

  /// Load notifications from Firebase
  void _loadNotifications() {
    _notificationsSubscription?.cancel();
    _notificationsSubscription = _notificationService
        .getUserNotificationsStream(userId)
        .listen(
      (notifications) {
        _notifications = notifications;
        _updateUnreadCount();
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error loading notifications: $error');
      },
    );
  }

  /// Load unread count
  Future<void> _loadUnreadCount() async {
    _unreadCount = await _notificationService.getUnreadCount(userId);
    notifyListeners();
  }

  /// Update unread count from local list
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(userId, notificationId);
    // Stream will automatically update
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    _isLoading = true;
    notifyListeners();
    
    await _notificationService.markAllAsRead(userId);
    
    _isLoading = false;
    notifyListeners();
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _notificationService.deleteNotification(userId, notificationId);
    // Stream will automatically update
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    _isLoading = true;
    notifyListeners();
    
    await _notificationService.clearAllNotifications(userId);
    
    _isLoading = false;
    notifyListeners();
  }

  /// Refresh notifications
  Future<void> refresh() async {
    await _loadUnreadCount();
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
  }
}
