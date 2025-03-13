import 'package:flutter/foundation.dart';
import 'package:gyansagar_frontend/model/notification_model.dart';

class NotificationState extends ChangeNotifier {
  List<NotificationModel> notifications;

  NotificationState({
    this.notifications = const [],
  });

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