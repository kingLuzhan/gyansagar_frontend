import 'package:flutter/foundation.dart';
import 'package:gyansagar_frontend/model/notification_model.dart';
import 'package:gyansagar_frontend/resources/repository/notification_repository.dart';

class NotificationState extends ChangeNotifier {
  List<NotificationModel> notifications;
  bool _isLoading = false;
  String? _errorMessage;
  final NotificationRepository _notificationRepository;

  NotificationState({
    required NotificationRepository notificationRepository,
    this.notifications = const [],
  }) : _notificationRepository = notificationRepository;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
    } catch (error) {
      setError(error.toString());
    } finally {
      setLoading(false);
    }
  }

  void addNotification(NotificationModel notification) {
    notifications.add(notification);
    notifyListeners();
  }

  void removeNotification(NotificationModel notification) {
    notifications.remove(notification);
    notifyListeners();
  }

  void clearNotifications() {
    notifications.clear();
    notifyListeners();
  }
}