import 'package:flutter/foundation.dart';

class WebConfig {
  static bool get isWebPlatform => kIsWeb;
  
  // Web-specific API endpoints or configurations
  static String get apiBaseUrl => 'http://localhost:3000/api'; // Update with your actual API endpoint
  
  // Web-specific storage methods
  static Future<void> saveToLocalStorage(String key, String value) async {
    // Implement web storage logic using HTML5 localStorage
    if (kIsWeb) {
      // Add implementation using dart:html
      // window.localStorage[key] = value;
    }
  }
  
  static Future<String?> getFromLocalStorage(String key) async {
    // Implement web storage retrieval logic
    if (kIsWeb) {
      // Add implementation using dart:html
      // return window.localStorage[key];
    }
    return null;
  }
  
  // Web configuration for admin interface
  static Map<String, dynamic> get adminConfig => {
    'appName': 'Gyansagar Admin',
    'appIcon': 'assets/images/logo.png',
    'apiVersion': 'v1',
    'authEndpoint': '${apiBaseUrl}/admin/auth',
  };
  
  // Handle web-specific authentication
  static Future<void> handleWebAuthentication() async {
    if (kIsWeb) {
      // Implement web-specific authentication logic
      // This could include OAuth, JWT handling, etc.
    }
  }
}