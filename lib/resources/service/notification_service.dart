import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gyansagar_frontend/resources/service/api_gateway.dart';
import 'package:gyansagar_frontend/model/notification_model.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging;
  final ApiGateway _apiGateway;

  NotificationService(this._firebaseMessaging, this._apiGateway);

  void initializeMessages() {
    _firebaseMessaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
    );
  }

  // Fetch notifications from your backend
  Future<List<NotificationModel>> getNotifications() async {
    try {
      return await _apiGateway.getStudentNotificationsList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }
  
  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      // You'll need to add this method to your ApiGateway interface and implementation
      await _apiGateway.markNotificationAsRead(notificationId);
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
  
  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      // You'll need to add this method to your ApiGateway interface and implementation
      await _apiGateway.markAllNotificationsAsRead();
      return true;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  void configure() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("NOTIFICATION ${message.data}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onResume: ${message.data}");
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }

  Future<String?> getDeviceToken() async {
    final token = await _firebaseMessaging.getToken();
    return token;
  }

  String getDeviceType() {
    return "android";
  }
}