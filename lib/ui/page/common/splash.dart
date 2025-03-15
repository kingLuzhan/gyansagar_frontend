import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/config/config.dart';
import 'package:gyansagar_frontend/ui/page/home/home_page_student.dart';
import 'package:gyansagar_frontend/ui/page/home/home_page_teacher.dart';
import 'package:gyansagar_frontend/ui/page/auth/login.dart'; // Import the login page
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:get_it/get_it.dart';
import 'package:gyansagar_frontend/helper/shared_preference_helper.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => doAutoLogin());
  }

  Future<void> doAutoLogin() async {
    if (_hasNavigated) return;

    try {
      print("Auto login started");
      final getIt = GetIt.instance;
      final prefs = getIt<SharedPreferenceHelper>();
      final accessToken = await prefs.getAccessToken();
      print("Access token: $accessToken");

      if (accessToken == null || accessToken.isEmpty) {
        print("No access token found, redirecting to login page");
        _navigateTo(LoginPage());
      } else {
        final isStudent = await prefs.isStudent();
        print("Is student: $isStudent");
        _navigateTo(isStudent ? StudentHomePage() : TeacherHomePage());
      }
    } catch (e) {
      print("Error during auto-login: $e");
      _navigateTo(LoginPage());
    }
  }

  void _navigateTo(Widget page) {
    if (!_hasNavigated) {
      _hasNavigated = true;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => page),
            (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: SizedBox(
        height: AppTheme.fullHeight(context) - 50,
        width: AppTheme.fullWidth(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (AppConfig.of(context)?.config.appIcon != null) ...[
              Image.asset(AppConfig.of(context)!.config.appIcon,
                  width: AppTheme.fullWidth(context) * .7),
            ],
            // Image.asset(Images.logoText, height: 70),
          ],
        ),
      ),
    );
  }
}