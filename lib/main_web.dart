import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:gyansagar_frontend/config/config.dart';
import 'package:gyansagar_frontend/config/configs.dart';
import 'package:gyansagar_frontend/config/web_config.dart'; // Add this import
import 'package:gyansagar_frontend/helper/locator.dart';
import 'package:gyansagar_frontend/ui/app.dart';
import 'package:gyansagar_frontend/admin/pages/login/admin_login.dart';

void main() async {
  final config = Config(
    appName: "Gyansagar Admin",
    apiBaseUrl:
        "http://localhost:3000/api", // Update with your actual API endpoint
    appToken: 'your_app_token_here',
    appIcon: "assets/images/logo.png",
    apiLogging: true,
    diagnostic: true,
  );

  WidgetsFlutterBinding.ensureInitialized();
  setUrlStrategy(PathUrlStrategy());
  await setupLocator(config);

  runApp(
    AppConfig(
      config: config,
      child: const GyansagarApp(home: AdminLoginPage()),
    ),
  );
}
