import 'package:gyansagar_frontend/model/notification_model.dart';
import 'package:gyansagar_frontend/resources/service/api_gateway.dart';

class NotificationRepository {
  final ApiGateway _apiGateway;

  NotificationRepository(this._apiGateway);

  Future<List<NotificationModel>> getNotifications() async {
    return await _apiGateway.getStudentNotificationsList();
  }

  Future<int> getUnreadCount() async {
    return await _apiGateway.getUnreadNotificationCount();
  }

  Future<bool> markAsRead(String notificationId) async {
    return await _apiGateway.markNotificationAsRead(notificationId);
  }

  Future<bool> markAllAsRead() async {
    return await _apiGateway.markAllNotificationsAsRead();
  }
}