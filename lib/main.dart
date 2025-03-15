import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/config/config.dart';
import 'package:gyansagar_frontend/config/configs.dart';
import 'package:gyansagar_frontend/locator.dart';
import 'package:gyansagar_frontend/ui/app.dart';
import 'package:gyansagar_frontend/ui/page/common/splash.dart';

void main() async {
  final config = Configs.devConfig();


  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await setUpDependency(config);
  final configuredApp = AppConfig(
    config: config,
    child: const GyansagarApp(home: SplashPage()),
  );
  runApp(configuredApp);
}
