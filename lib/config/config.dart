import 'package:flutter/material.dart';

class Config {
  final String appName;
  final String apiBaseUrl;
  final bool apiLogging;
  final String appToken;
  final String appIcon;
  final bool diagnostic;

  Config({
    required this.appName,
    required this.apiBaseUrl,
    required this.appToken,
    required this.appIcon,
    this.apiLogging = false,
    this.diagnostic = false,
  });

  Config copyWith({
    String? appName,
    String? apiBaseUrl,
    bool? apiLogging,
    bool? diagnostic,
    String? appToken,
    String? appIcon,
  }) {
    return Config(
      appName: appName ?? this.appName,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      apiLogging: apiLogging ?? this.apiLogging,
      diagnostic: diagnostic ?? this.diagnostic,
      appToken: appToken ?? this.appToken,
      appIcon: appIcon ?? this.appIcon,
    );
  }
}

class AppConfig extends InheritedWidget {
  final Config config;

  const AppConfig({super.key, 
    required this.config,
    required super.child,
  });

  static AppConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
