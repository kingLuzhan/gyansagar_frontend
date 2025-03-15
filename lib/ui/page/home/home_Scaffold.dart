import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/config/config.dart';
import 'package:gyansagar_frontend/states/auth/auth_state.dart';
import 'package:gyansagar_frontend/ui/kit/alert.dart';
import 'package:gyansagar_frontend/ui/page/auth/login.dart';
import 'package:gyansagar_frontend/ui/theme/theme.dart';
import 'package:provider/provider.dart';

class HomeScaffold<T> extends StatelessWidget {
  const HomeScaffold({
    super.key,
    required this.floatingActionButton,
    required this.floatingButtons,
    required this.showFabButton,
    required this.slivers,
    required this.onNotificationTap,
    required this.builder,
  });

  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget floatingActionButton;
  final Widget floatingButtons;
  final ValueNotifier<bool> showFabButton;
  final VoidCallback onNotificationTap;
  final List<Widget> slivers;

  void deleteBatch(context) async {
    Alert.yesOrNo(context,
        message: "Are you sure, you want to logout?",
        title: "Message",
        barrierDismissible: true,
        onCancel: () {}, onYes: () async {
          Provider.of<AuthState>(context, listen: false).logout();
          Navigator.pushReplacement(context, LoginPage.getRoute());
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AppConfig.of(context)!.config.appIcon),
        ),
        title: Text(AppConfig.of(context)!.config.appName, style: const TextStyle(color: PColors.black)),
        actions: <Widget>[
          IconButton(
            onPressed: onNotificationTap,
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            onPressed: () {
              deleteBatch(context);
            },
            icon: const Icon(Icons.login),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: <Widget>[
          Consumer<T>(
            builder: (context, state, child) {
              return builder(context, state, child);
            },
          ),
          AnimatedPositioned(
            bottom: 16 + 60.0,
            right: 25,
            duration: const Duration(milliseconds: 500),
            child: floatingButtons,
          ),
        ],
      ),
    );
  }
}