import 'package:flutter/foundation.dart';
import 'package:gyansagar_frontend/model/notification_model.dart';
import 'package:gyansagar_frontend/resources/repository/notification_repository.dart';

class NotificationState extends ChangeNotifier {
  List<NotificationModel> notifications;
  bool _isLoading = false;
  String? _errorMessage;

  NotificationState({
    this.notifications = const [],
  });

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
      final repo = NotificationRepository();
      notifications = await repo.getNotifications();
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