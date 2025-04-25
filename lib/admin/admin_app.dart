import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:gyansagar_frontend/admin/pages/login/admin_login.dart';
import 'package:gyansagar_frontend/admin/pages/dashboard/admin_dashboard.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gyansagar Admin Panel',
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const AdminLoginPage(),
        '/dashboard': (context) => const AdminDashboardPage(),
      },
    );
  }
}