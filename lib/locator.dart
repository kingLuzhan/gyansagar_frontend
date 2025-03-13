import 'package:contacts_service/contacts_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gyansagar_frontend/config/config.dart';
import 'package:gyansagar_frontend/helper/shared_preference_helper.dart';
import 'package:gyansagar_frontend/resources/repository/batch_repository.dart';
import 'package:gyansagar_frontend/resources/repository/teacher/teacher_repository.dart';
import 'package:gyansagar_frontend/resources/service/api_gateway.dart';
import 'package:gyansagar_frontend/resources/service/api_gateway_impl.dart';
import 'package:gyansagar_frontend/resources/service/dio_client.dart';
import 'package:gyansagar_frontend/resources/service/notification_service.dart';
import 'package:gyansagar_frontend/resources/service/session/session.dart';
import 'package:gyansagar_frontend/resources/service/session/session_impl.dart';
import 'package:get_it/get_it.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> setUpDependency(Config config) async {
  if (!serviceLocator.isRegistered<ContactsService>()) {
    serviceLocator.registerSingleton<ContactsService>(ContactsService());
  }

  if (!serviceLocator.isRegistered<SharedPreferenceHelper>()) {
    await SharedPreferenceHelper.init(); // Initialize SharedPreferences before registering the singleton
    serviceLocator.registerSingleton<SharedPreferenceHelper>(SharedPreferenceHelper.instance);
  }

  if (!serviceLocator.isRegistered<NotificationService>()) {
    serviceLocator.registerSingleton<NotificationService>(
      NotificationService(FirebaseMessaging.instance),
    );

    // Initialize notifications after registering
    final notificationService = serviceLocator<NotificationService>();
    notificationService.initializeMessages();
    notificationService.configure();
  }

  if (!serviceLocator.isRegistered<ApiGateway>()) {
    serviceLocator.registerLazySingleton<ApiGateway>(
          () => ApiGatewayImpl(
        DioClient(Dio(), baseEndpoint: config.apiBaseUrl, logging: true),
        pref: serviceLocator<SharedPreferenceHelper>(),
      ),
    );
  }

  if (!serviceLocator.isRegistered<SessionService>()) {
    serviceLocator.registerLazySingleton<SessionService>(
          () => SessionServiceImpl(
        serviceLocator<ApiGateway>(),
        serviceLocator<SharedPreferenceHelper>(),
      ),
    );
  }

  if (!serviceLocator.isRegistered<BatchRepository>()) {
    serviceLocator.registerLazySingleton<BatchRepository>(
          () => BatchRepository(
        serviceLocator<ApiGateway>(),
        serviceLocator<SessionService>(),
      ),
    );
  }

  if (!serviceLocator.isRegistered<TeacherRepository>()) {
    serviceLocator.registerLazySingleton<TeacherRepository>(
          () => TeacherRepository(
        serviceLocator<ApiGateway>(),
        serviceLocator<SessionService>(),
        serviceLocator<SharedPreferenceHelper>(),
      ),
    );
  }

  await serviceLocator.allReady(); // Ensures async dependencies are ready before use
}