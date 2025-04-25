import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:gyansagar_frontend/config/config.dart';
import 'package:gyansagar_frontend/helper/locator.dart';
import 'package:gyansagar_frontend/admin/admin_app.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  final config = Config(
    appName: "Gyansagar Admin",
    apiBaseUrl: "http://localhost:3000/api",
    appToken: '',
    appIcon: "assets/logo/gyansagarlogo.png",
    apiLogging: true,
    diagnostic: true,
  );

  WidgetsFlutterBinding.ensureInitialized();
  setUrlStrategy(PathUrlStrategy());
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "YOUR_API_KEY",
      authDomain: "YOUR_AUTH_DOMAIN",
      projectId: "YOUR_PROJECT_ID",
      storageBucket: "YOUR_STORAGE_BUCKET",
      messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
      appId: "YOUR_APP_ID"
    ),
  );
  
  await setupLocator(config);

  runApp(AppConfig(config: config, child: const AdminApp()));
}
