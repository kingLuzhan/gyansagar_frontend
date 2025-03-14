import 'package:gyansagar_frontend/model/notification_model.dart';
import 'package:gyansagar_frontend/resources/service/api_gateway.dart';

class NotificationRepository {
  final ApiGateway _apiGateway;

  NotificationRepository(this._apiGateway);

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiGateway.getStudentNotificationsList();
      return response;
    } catch (error) {
      rethrow;
    }
  }
}