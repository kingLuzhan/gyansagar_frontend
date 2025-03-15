import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/states/auth/auth_state.dart';
import 'package:gyansagar_frontend/states/home_state.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:provider/provider.dart';

class GyansagarApp extends StatefulWidget {
  final Widget home;

  const GyansagarApp({
    super.key,
    required this.home,
  });

  @override
  _GyansagarAppState createState() => _GyansagarAppState();
}

class _GyansagarAppState extends State<GyansagarApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthState>(create: (_) => AuthState()),
        ChangeNotifierProvider<HomeState>(create: (_) => HomeState()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (BuildContext context) => "Gyansagar",
        theme: AppTheme.lightTheme,
        home: widget.home,
      ),
    );
  }
}