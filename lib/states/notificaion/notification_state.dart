import 'package:flutter/foundation.dart';
import 'package:gyansagar_frontend/model/notification_model.dart';
import 'package:gyansagar_frontend/resources/repository/notification_repository.dart';

class NotificationState extends ChangeNotifier {
  List<NotificationModel> notifications;
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;
  final NotificationRepository _notificationRepository;

  NotificationState({
    required NotificationRepository notificationRepository,
    this.notifications = const [],
  }) : _notificationRepository = notificationRepository;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchNotifications() async {
    setLoading(true);
    setError(null);
    try {
      notifications = await _notificationRepository.getNotifications();
      _calculateUnreadCount();
    } catch (error) {
      setError(error.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      _unreadCount = await _notificationRepository.getUnreadCount();
      notifyListeners();
    } catch (error) {
      print('Error fetching unread count: $error');
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final success = await _notificationRepository.markAsRead(notificationId);
      if (success) {
        // Update the local notification object
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final updatedNotification = NotificationModel(
            id: notifications[index].id,
            title: notifications[index].title,
            body: notifications[index].body,
            type: notifications[index].type,
            isRead: true,
            metadata: notifications[index].metadata,
            createdAt: notifications[index].createdAt,
          );
          
          notifications[index] = updatedNotification;
          _calculateUnreadCount();
          notifyListeners();
        }
      }
      return success;
    } catch (error) {
      setError(error.toString());
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final success = await _notificationRepository.markAllAsRead();
      if (success) {
        // Update all local notification objects
        notifications = notifications.map((notification) => 
          NotificationModel(
            id: notification.id,
            title: notification.title,
            body: notification.body,
            type: notification.type,
            isRead: true,
            metadata: notification.metadata,
            createdAt: notification.createdAt,
          )
        ).toList();
        
        _unreadCount = 0;
        notifyListeners();
      }
      return success;
    } catch (error) {
      setError(error.toString());
      return false;
    }
  }

  void _calculateUnreadCount() {
    _unreadCount = notifications.where((notification) => !notification.isRead).length;
  }

  void addNotification(NotificationModel notification) {
    notifications.add(notification);
    _calculateUnreadCount();
    notifyListeners();
  }

  void removeNotification(NotificationModel notification) {
    notifications.remove(notification);
    _calculateUnreadCount();
    notifyListeners();
  }

  void clearNotifications() {
    notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }
}