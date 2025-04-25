import 'package:get_it/get_it.dart';
import 'package:gyansagar_frontend/config/config.dart';
import 'package:gyansagar_frontend/helper/shared_preference_helper.dart';
import 'package:gyansagar_frontend/resources/repository/batch_repository.dart';
import 'package:gyansagar_frontend/resources/service/api_gateway.dart';
import 'package:gyansagar_frontend/resources/service/api_gateway_impl.dart';
import 'package:gyansagar_frontend/resources/service/dio_client.dart';
import 'package:gyansagar_frontend/resources/service/session/session.dart';
import 'package:gyansagar_frontend/resources/service/session/session_impl.dart';
import 'package:dio/dio.dart';
import 'package:gyansagar_frontend/helper/constants.dart';

final locator = GetIt.instance;

Future<void> setupLocator(Config config) async {
  // Initialize SharedPreferences
  await SharedPreferenceHelper.init();

  // Register config
  locator.registerSingleton<Config>(config);

  // Register SharedPreferenceHelper singleton instance
  locator.registerSingleton<SharedPreferenceHelper>(
    SharedPreferenceHelper.instance,
  );

  // Register DioClient
  locator.registerSingleton<DioClient>(
    DioClient(Dio(), baseEndpoint: Constants.productionBaseUrl, logging: true),
  );

  // Register ApiGateway implementation
  locator.registerSingleton<ApiGateway>(
    ApiGatewayImpl(
      locator<DioClient>(),
      pref: locator<SharedPreferenceHelper>(),
    ),
  );

  // Register SessionService
  locator.registerSingleton<SessionService>(
    SessionServiceImpl(
      locator<ApiGateway>(),
      locator<SharedPreferenceHelper>(),
    ),
  );

  // Register BatchRepository
  locator.registerSingleton<BatchRepository>(
    BatchRepository(locator<ApiGateway>(), locator<SessionService>()),
  );
}
